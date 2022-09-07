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
	///List of blocked - tiles
	var/list/blocked = list()
	///List of blocked tiles for UI
	var/list/blocked_coords = list(list("x" = -1, "y" = -1))
	///List of effects
	var/list/effects = list()
	///List of special tiles for UI
	var/list/effects_coords = list(list("x" = -1, "y" = -1))
	///List of active adventure levels
	var/list/levels = list()

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

///Used to build new telescience levels
/datum/controller/subsystem/telescience/proc/generate_level()
	return

///Handles turf access in the constant of one-time operations
/datum/controller/subsystem/telescience/proc/handle_turf_access(turf/T, obj/structure/S)
	if(locate(T) in blocked)
		do_collapse(S, BLOCKED_EFFECTS)
		return
	var/datum/telescience_crash_effect/map/M = effects["[T.x][T.y][T.z]"]
	S.say("[M ? "Found effect" : "No effect"]")
	return M?.action(T) || T

///When multiple doors are layered
/datum/controller/subsystem/telescience/proc/do_collapse(obj/structure/D, effect_type = DOOR_EFFECTS)
	var/datum/telescience_crash_effect/E = pick(effect_type)
	E = new E
	E.action(D)
	qdel(E)
