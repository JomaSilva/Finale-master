// =====================================================================
// VEGETA CITY & LABORATORIES  (built on z3 near the spawn (127,282) / castle)
// Castle-stone walls are made OPAQUE so you can't see inside from outside.
// Interiors are furnished. Rebuilt each boot (base .dmm reloads fresh, so
// it's idempotent). Lab benches are real Research Stations (Craft->Technology
// opens the tech build window).
// =====================================================================
var/vegeta_built = 0

// walls (castle stone) — placed opaque so they block line-of-sight
var/list/VEG_WALL = list(
	"W" = /turf/CastleWall/Center,
	"O" = /turf/CastleWall/Window2,
	"T" = /turf/CastleWall/Torch2,
	"B" = /turf/CastleWall/Banner2,
)
// furniture/objects — a floor is laid first, then the object on top
var/list/VEG_FURN = list(
	"b" = /obj/buildables/Bed,
	"k" = /obj/buildables/Bookshelf,
	"d" = /obj/buildables/drawer,
	"s" = /obj/buildables/stool,
	"r" = /obj/buildables/rtable,
	"p" = /obj/buildables/piano,
	"L" = /obj/Technology/Research_Station,
	"m" = /obj/buildables/Computer2,
	"F" = /obj/buildables/Files,
)
// "." = floor, "+" = door, " " = leave the tile untouched

proc/veg_stamp(list/rows, ox, oy, oz, floortype, area/inside)
	var/h = rows.len
	for(var/r = 1 to h)
		var/row = rows[r]
		var/yy = oy + (h - r) // first row = north (top)
		for(var/cc = 1 to length(row))
			var/ch = copytext(row, cc, cc + 1)
			if(ch == " ") continue
			var/xx = ox + (cc - 1)
			var/turf/cur = locate(xx, yy, oz)
			if(!cur) continue
			if(inside) inside.contents += cur //mark the building footprint as indoors (InsideArea) so weather effects skip it; turf replacements below inherit this area
			if(VEG_WALL[ch])
				if(istype(cur, /turf/CastleWall)) continue // already a wall here -> don't stack another
				var/wt = VEG_WALL[ch]
				var/turf/W = new wt(cur)
				if(W) W.opacity = 1 // <- blocks vision so you can't see the interior from outside
				continue
			if(ch == "+")
				if(istype(cur, /turf/Door)) continue // door already here
				new /turf/Door/Door2(cur)
				continue
			var/ft = VEG_FURN[ch]
			if(ft)
				var/exists = 0
				for(var/obj/o in cur)
					if(istype(o, ft)) { exists = 1; break }
				if(exists) continue // the furniture (e.g. a Research Station) is already here -> skip so it never stacks
				if(!istype(cur, floortype)) new floortype(cur) // lay floor under the furniture only if needed
				new ft(cur)
			else if(!istype(cur, floortype))
				new floortype(cur) // plain floor, only if it isn't already that floor

proc/Build_Vegeta_Structures()
	set waitfor = 0
	if(vegeta_built) return
	vegeta_built = 1
	var/oz = 3
	var/carpet = /turf/CastleFloor/Carpet  // cozy house interior
	var/labfl  = /turf/Tile/Tile16          // clean lab interior
	var/area/vinside = locate(/area/Vegeta/Inside)  // the InsideArea subarea -> tiles added here get no weather

	// ---- a furnished Saiyan house (11 x 9): bed, drawers, table, piano, bookshelves, windows ----
	var/list/house = list(
		"WWWOWWWOWWW",
		"Wb..d..r.sW",
		"Wb.....r.sW",
		"W.........W",
		"O....p....O",
		"W.........W",
		"Wk.......kW",
		"W.........W",
		"WWWWW+WWWWW",
	)
	// ---- a research laboratory (13 x 10): benches, computers, filing cabinets, bookshelves ----
	var/list/lab = list(
		"WWWWOWWWOWWWW",
		"W..L.m.m.L..W",
		"W...........W",
		"WF.........FW",
		"O...........O",
		"Wk.........kW",
		"W...........W",
		"W..L.m.m.L..W",
		"W...........W",
		"WWWWW+WWWWWWW",
	)

	// two laboratories on the west side
	veg_stamp(lab, 60, 333, oz, labfl, vinside)
	veg_stamp(lab, 60, 318, oz, labfl, vinside)
	// six houses (3 columns x 2 rows) on the east side
	for(var/hx in list(78, 92, 106))
		veg_stamp(house, hx, 338, oz, carpet, vinside)
		veg_stamp(house, hx, 320, oz, carpet, vinside)

	// one-time cleanup: collapse any pre-existing stacks of research benches that share a tile
	// (left over from boots before veg_stamp checked, or baked into the saved map) -> keep one per tile
	var/list/seen_bench = list()
	for(var/obj/Technology/Research_Station/RS in world)
		if(RS.z != oz) continue
		var/k = "[RS.x]_[RS.y]"
		if(seen_bench[k]) del(RS) // a bench already kept on this tile -> remove the duplicate
		else seen_bench[k] = 1
