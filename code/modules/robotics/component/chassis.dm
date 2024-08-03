/*
	Sub-component for chassis
	blah blah blah
*/
/datum/component/endopart/chassis
	name = "chassis"
	///What mob we assemble, more complex chassies will need to implement more than this
	var/assembly_mob = /mob/living/silicon/robot

/datum/component/endopart/chassis/New(list/raw_args)
	. = ..()
	if(!parent)
		return
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_WRENCH), PROC_REF(catch_wrench))

/datum/component/endopart/chassis/build_assembly_overlay(atom/A)
	//Temporarily remove all our overlays
	//TODO: Condiser just making then endo parts remove their overlays fromm this when assembled to the mob - Racc
	var/atom/parent_atom = parent
	var/list/temp = parent_atom.overlays
	parent_atom.overlays = list()
	. = ..()
	parent_atom.overlays = temp

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
	var/mob/living/new_mob = assembled_mob()
	var/atom/movable/AM = parent
	if(istype(AM))
		AM.forceMove(new_mob) //Hide inside our new mob so we can be used again later
	apply_assembly(src, new_mob) //TODO: make sure we don't need a way to undo this chassis assembly stuff - Racc

/datum/component/endopart/chassis/proc/assembled_mob()
	var/mob/living/L = new assembly_mob(get_turf(parent))
	return L
