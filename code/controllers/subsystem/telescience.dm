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
	///List of blocked tiles for UI
	var/list/blocked_coords = list(list("x" = 0, "y" = 0))
	///List of effects - special blocked
	var/list/effects = list()

/datum/controller/subsystem/telescience/Initialize()
	. = ..()

///When multiple doors are layered
/datum/controller/subsystem/telescience/proc/do_door_collapse(obj/structure/teleporter_door/D, effect_type = DOOR_EFFECTS)
	var/datum/telescience_effect/E = pick(effect_type)
	E = new(E)
	E.action(D)
	qdel(E)
	qdel(D)
