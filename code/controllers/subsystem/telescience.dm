SUBSYSTEM_DEF(telescience)
	name = "Telescience"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_TELESCIENCE
	///weight of built up uses
	var/weight = 0
	///Used for multiple portals, helps avoid references
	var/last_effect = 0
	///List of blocked tiles
	var/list/blocked = list()
	///List of effects - special blocked
	var/list/effects = list()

/datum/controller/subsystem/telescience/Initialize()
	. = ..()

///When multiple doors are layered
/datum/controller/subsystem/telescience/proc/do_door_collapse()
	return
