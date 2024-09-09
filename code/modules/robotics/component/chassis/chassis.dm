/*
	Sub-component for chassis
*/
/datum/component/endopart/chassis
	name = "chassis"
	///What mob we assemble, more complex chassies will need to implement more than this
	var/assembly_mob = /mob/living/silicon/robot
	///Is this chassis rideable?
	var/can_ride = FALSE
	var/can_ride_incapacitated = TRUE
	var/list/ride_offset = list(0, 0)
	var/static/list/can_ride_typecache = typecacheof(/mob/living/carbon/human)
	///Can this chassis be pushed, shoved?
	var/can_be_pushed = FALSE
	///Can this chassis be disposed through bins & chutes
	var/can_dispose = FALSE
	///How many legs to chassis expects, used for walk speed efficiency
	var/expected_legs = 2

/datum/component/endopart/chassis/New(list/raw_args)
	. = ..()
	if(!parent)
		return
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_WRENCH), PROC_REF(catch_wrench))

/datum/component/endopart/chassis/build_assembly_overlay(atom/A)
	//Temporarily remove all our overlays
	var/atom/parent_atom = parent
	var/list/temp = parent_atom.overlays
	parent_atom.overlays = list()
	if(!assembly_overlay)
		assembly_overlay = new()
		assembly_overlay.appearance = parent_atom.appearance
		assembly_overlay.pixel_x = 0
		assembly_overlay.pixel_y = 0
		assembly_overlay.plane = A.plane
	SEND_SIGNAL(A, COMSIG_ENDO_APPLY_OFFSET, offset_key, assembly_overlay)
	A?.cut_overlay(assembly_overlay)
	A?.add_overlay(assembly_overlay)
	parent_atom.overlays = temp

/datum/component/endopart/chassis/refresh_assembly(datum/source, mob/target)
	. = ..()
	if(can_be_pushed)
		target.status_flags |= CANPUSH
	else
		target.status_flags &= ~CANPUSH

/datum/component/endopart/chassis/life(datum/source, mob/M)
	. = ..()
	//Power stuff
	var/mob/living/silicon/new_robot/R = M
	if(!istype(R))
		return
	if(!.)
		R.powered = FALSE
		M.throw_alert("nocell", /atom/movable/screen/alert/nocell)
		M.add_movespeed_modifier(/datum/movespeed_modifier/nopowercell)
	else
		M.clear_alert("nocell")
		M.remove_movespeed_modifier(/datum/movespeed_modifier/nopowercell)
		R.powered = TRUE
	//Leg slowdown stuff
	var/list/legs = list()
	SEND_SIGNAL(parent, COMSIG_ENDO_LIST_PART, /datum/component/endopart/leg, legs)
	var/operable_legs = length(legs)
	for(var/atom/A as() in legs)
		var/datum/component/endopart/leg/L = A.GetComponent(/datum/component/endopart/leg)
		if(L?.check_completion() & ENDO_ASSEMBLY_INCOMPLETE)
			operable_legs--
	if(expected_legs > operable_legs)
		var/max_slowdown = 6
		M.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/limbless, multiplicative_slowdown = ((expected_legs-operable_legs)/expected_legs*max_slowdown))
	else
		M.remove_movespeed_modifier(/datum/movespeed_modifier/limbless)

///Handles screwdriver interaction, for removing parts
/datum/component/endopart/chassis/proc/catch_wrench(datum/source, mob/living/user, obj/item/I, list/recipes)
	SIGNAL_HANDLER

	if(assembled_mob)
		return
	INVOKE_ASYNC(src, PROC_REF(catch_wrench_async), user, I, recipes)

/datum/component/endopart/chassis/proc/catch_wrench_async(mob/living/L, obj/item/I, list/recipes)
	if(assembled_mob)
		return
	//Check if any of our assemblies are incomplete and integral
	var/outcome = check_completion()
	if((outcome & ENDO_ASSEMBLY_INCOMPLETE) && !(outcome & ENDO_ASSEMBLY_NON_INTEGRAL))
		to_chat(L, "<span class='warning'>[parent] is missing integral pieces!</span>")
		return
	//Otherwise, build that robot
	if(!do_after(L, 3 SECONDS, parent))
		return
	build_robot()

/datum/component/endopart/chassis/proc/build_robot(mob/M)
	var/mob/living/new_mob = M || assemble_mob()
	var/atom/movable/AM = parent
	if(istype(AM))
		AM.forceMove(new_mob) //Hide inside our new mob so we can be used again later
	apply_assembly(src, new_mob)
	return new_mob

/datum/component/endopart/chassis/proc/assemble_mob()
	var/mob/living/L = new assembly_mob(get_turf(parent))
	return L

/datum/component/endopart/chassis/proc/can_ride(mob/M)
	if(M.incapacitated() && !can_ride_incapacitated || !can_ride)
		return FALSE
	return is_type_in_typecache(M, can_ride_typecache)
