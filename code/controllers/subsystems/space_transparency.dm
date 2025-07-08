//
// This is for custom circuits, mostly the initialization of global properties about them.
// Might make this also process them in the future if its better to do that than using the obj ticker.
//
SUBSYSTEM_DEF(space_transparency)
	name = "Space Transparency"
	init_order = -62
	flags = SS_NO_FIRE
	var/list/to_change_space_tiles = list()

/datum/controller/subsystem/space_transparency/Recover()
	flags |= SS_NO_INIT // Make extra sure we don't initialize twice.

/datum/controller/subsystem/space_transparency/Initialize()
	space_change()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/space_transparency/proc/space_change()
	for(var/z_level = 1 to world.maxz)
		for(var/turf/entry in to_change_space_tiles["[z_level]"])
			entry.ChangeTurf(/turf/simulated/open/vacuum)
