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

proc/veg_stamp(list/rows, ox, oy, oz, floortype)
	var/h = rows.len
	for(var/r = 1 to h)
		var/row = rows[r]
		var/yy = oy + (h - r) // first row = north (top)
		for(var/cc = 1 to length(row))
			var/ch = copytext(row, cc, cc + 1)
			if(ch == " ") continue
			var/xx = ox + (cc - 1)
			if(!locate(xx, yy, oz)) continue
			if(VEG_WALL[ch])
				var/wt = VEG_WALL[ch]
				var/turf/W = new wt(locate(xx, yy, oz))
				if(W) W.opacity = 1 // <- blocks vision so you can't see the interior from outside
				continue
			if(ch == "+")
				new /turf/Door/Door2(locate(xx, yy, oz))
				continue
			// floor for everything else (and under furniture)
			new floortype(locate(xx, yy, oz))
			var/ft = VEG_FURN[ch]
			if(ft) new ft(locate(xx, yy, oz))

proc/Build_Vegeta_Structures()
	set waitfor = 0
	if(vegeta_built) return
	vegeta_built = 1
	var/oz = 3
	var/carpet = /turf/CastleFloor/Carpet  // cozy house interior
	var/labfl  = /turf/Tile/Tile16          // clean lab interior

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
	veg_stamp(lab, 60, 333, oz, labfl)
	veg_stamp(lab, 60, 318, oz, labfl)
	// six houses (3 columns x 2 rows) on the east side
	for(var/hx in list(78, 92, 106))
		veg_stamp(house, hx, 338, oz, carpet)
		veg_stamp(house, hx, 320, oz, carpet)
