/*
	Sub-component for chassis
	blah blah blah
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
	///Hats we DO NOT fuck with
	var/list/blacklisted_hats = list( //Hats that don't really work on borgos
	/obj/item/clothing/head/helmet/space/santahat,
	/obj/item/clothing/head/utility/welding,
	/obj/item/clothing/head/helmet/space/eva,
	)

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
	. = ..()
	parent_atom.overlays = temp

/datum/component/endopart/chassis/apply_assembly(datum/source, mob/target)
	. = ..()
	if(can_be_pushed)
		target.status_flags |= CANPUSH
	else
		target.status_flags &= ~CANPUSH

///Handles screwdriver interaction, for removing parts
/datum/component/endopart/chassis/proc/catch_wrench(datum/source, mob/living/user, obj/item/I, list/recipes)
	SIGNAL_HANDLER

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

/datum/component/endopart/chassis/proc/can_wear(var/obj/item/clothing/head/hat)
	if(!istype(hat) || is_type_in_typecache(hat, blacklisted_hats))
		return FALSE
	return TRUE

/datum/component/endopart/chassis/proc/can_ride(mob/M)
	if(M.incapacitated() && !can_ride_incapacitated || !can_ride)
		return FALSE
	return is_type_in_typecache(M, can_ride_typecache)
