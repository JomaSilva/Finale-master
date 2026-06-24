/*

  -- Map Instancing --

This library lets you create and manage copies of maps. While the game
is running you can create a duplicate instance of an existing map. The
library will automatically create additional z levels for these new
instances. When you're done using a map the library will re-use z levels
so you can conserve space.


  -- How to Use It --

The library comes with two demos, each is contained in its own sub-
folder. To run a demo, include all of the files in the sub-folder and
run the library. Some demos may have additional instructions, so check
the "demo.dm" file in the demo's folder.

To create a copy of a map you just have to do this:

	var/Map/map = maps.copy(2)

This creates a copy of the second z level. The copy is created on the
first available z level (or, if none are available, a new one is created).
The Map object is returned so you can manage the new map instance:

	mob.loc = locate(5, 3, map.z)

	map.repop()

	map.free()

The Map object has a "z" var which tells you what z level the map copy
was created on. This lets you move mobs to the new map. The object also
has some procs. The repop() proc creates new instances of objects to
replace deleted ones - it's like world.Repop() except it only repopulates
that one map instance. The free() proc tells the library that you're done
using the map, this way the library can use that z level again later.


  -- Version History --

Version 5 (posted 03-03-2012)

 * Updated the library to make it work with the Region library. If you
   place a /region object on a map and copy the map, the copied turfs
   will be added to the region too.
 * I removed the use_warp verb from the demos, now you automatically
   use the warp by stepping on it.

Version 4 (posted 02-15-2012)

 * Changed the order of events when maps are created - the area of
   the turf is now set before the new turf is created, this way the
   turf's New() proc can check the type of its loc (the area).
 * Removed the z var from the /MapBase object.
 * Added the get() proc on the Map object which returns a list of all
   objects of the specified type on that map's z level.
 * Added the reset() proc to the /Map object. This is similar to repop
   except it re-generates the entire map on the same z level. This not
   only restores deleted objects, but restores the initial state of each
   object and turf. There is an example of this in the demo called "demo".
 * Added the atom.is_instanced() proc which returns 0 or 1. This is used
   by the library to determine which objects get stored in the MapBase
   object. You can override this proc to change which objects are saved.
   By default, all objects are stored except mobs with clients.

Version 3 (posted 10-12-2011)

 * Added saving and loading and a demo that shows how to
   use it - see saving-and-loading-demo\demo.dm

Version 2 (posted 10-12-2011)

 * Added the maps.clear() proc to free up existing z levels (even
   ones that weren't dynamically created by the library).

Version 1 (posted 10-11-2011)

 * Initial version

*/