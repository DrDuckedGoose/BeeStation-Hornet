SUBSYSTEM_DEF(telescience)
	name = "Telescience"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_TELESCIENCE
	///weight of built up uses
	var/weight = 0
	///Used for multiple portals, helps avoid references
	var/last_effect = 0
	///List of available blockers
	var/list/blockers = list()
	///List of blocked tiles
	var/list/blocked = list()
	///List of blocked tiles for UI
	var/list/blocked_coords = list(list("x" = -1, "y" = -1))
	///List of effects - special blocked
	var/list/effects = list()

/datum/controller/subsystem/telescience/Initialize()
	. = ..()
	shuffle_blockers()

///Chooses a random assortment of blockers from the world list
/datum/controller/subsystem/telescience/proc/shuffle_blockers()
	if(!blockers.len)
		return
	for(var/obj/effect/mapping_helpers/telescience_block/B as() in blockers)
		B.unappend_block()
		if(prob(45))
			B.append_block()

///When multiple doors are layered
/datum/controller/subsystem/telescience/proc/do_collapse(obj/structure/D, effect_type = DOOR_EFFECTS)
	var/datum/telescience_effect/E = new /datum/telescience_effect/fire
	E.action(D)
	qdel(E)
