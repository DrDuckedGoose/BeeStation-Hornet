/*
	This allows us to dress our robots up
*/

/datum/endo_assembly/item/clothing
	item_requirment = /obj/item/clothing/under
	///Ref to our clothing overlay
	var/mutable_appearance/clothing_overlay
	///Default icon file
	var/icon_file = 'icons/mob/clothing/under/default.dmi'

/datum/endo_assembly/item/clothing/New(datum/parent)
	. = ..()
	RegisterSignal(part_parent, COMSIG_ENDO_ASSEMBLE, PROC_REF(catch_assembly))
	RegisterSignal(part_parent.parent, COMSIG_ENDO_UNASSEMBLE, PROC_REF(catch_unassembly))
	RegisterSignal(part_parent, COMSIG_ENDO_ATTACHED, PROC_REF(catch_attached))
	RegisterSignal(part_parent, COMSIG_ENDO_REMOVED, PROC_REF(catch_removed))

/datum/endo_assembly/item/clothing/Destroy(force, ...)
	. = ..()
	QDEL_NULL(clothing_overlay)

/datum/endo_assembly/item/clothing/add_part(datum/source, obj/item/I, mob/living/L)
	. = ..()
	if(!. || !build_clothing_overlay())
		return
	var/atom/A = part_parent.parent
	A.add_overlay(clothing_overlay)

/datum/endo_assembly/item/clothing/remove_part(datum/source, obj/item/I)
	. = ..()
	var/atom/A = part_parent.parent
	A.cut_overlay(clothing_overlay)

/datum/endo_assembly/item/clothing/build_ideal_part()
	return

/datum/endo_assembly/item/clothing/proc/catch_assembly(datum/source, mob/M)
	SIGNAL_HANDLER

	var/mob/living/silicon/new_robot/R = M
	if(!istype(R))
		return
	RegisterSignal(M, COMSIG_PARENT_ATTACKBY, PROC_REF(catch_attackby), TRUE)
	if(!build_clothing_overlay())
		return
	R.chassis_component.apply_offset(src, part_parent.offset_key, clothing_overlay)
	R.add_overlay(clothing_overlay)

/datum/endo_assembly/item/clothing/proc/catch_unassembly(datum/source, mob/M)
	SIGNAL_HANDLER

	if(clothing_overlay)
		M.cut_overlay(clothing_overlay)
	UnregisterSignal(M, COMSIG_PARENT_ATTACKBY)

/datum/endo_assembly/item/clothing/proc/catch_attached(datum/source, obj/item/I, datum/component/endopart/part)
	SIGNAL_HANDLER

	I.add_overlay(clothing_overlay)

/datum/endo_assembly/item/clothing/proc/catch_removed(datum/source, obj/item/I, datum/component/endopart/part)
	SIGNAL_HANDLER

	I.cut_overlay(clothing_overlay)

/datum/endo_assembly/item/clothing/proc/catch_attackby(datum/source, obj/item, mob/living, params)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(add_clothing), item, living)

/datum/endo_assembly/item/clothing/proc/add_clothing(obj/item, mob/living)
	if(pre_check_assemble(src, item) && do_after(living, 2 SECONDS, part_parent.assembled_mob))
		add_part(src, item, living)
		catch_assembly(src, part_parent.assembled_mob)
		part_parent.current_assembly += item
		item.forceMove(part_parent.parent)

/datum/endo_assembly/item/clothing/proc/build_clothing_overlay()
	var/obj/item/clothing/C = locate(/obj/item/clothing) in parts
	if(!C)
		return
	clothing_overlay = C.build_worn_icon(default_icon_file = icon_file)
	return clothing_overlay

/*
	Masks
*/

/datum/endo_assembly/item/clothing/mask
	item_requirment = /obj/item/clothing/mask
	icon_file = 'icons/mob/clothing/mask.dmi'

/*
	Hats
*/

/datum/endo_assembly/item/clothing/hat
	item_requirment = /obj/item/clothing/head
	icon_file = 'icons/mob/clothing/head/default.dmi'
	//Add cases for attackby and hitby, for hat placement
	///Hats we DO NOT fuck with
	var/list/blacklisted_hats = list(
	/obj/item/clothing/head/helmet/space/santahat,
	/obj/item/clothing/head/utility/welding,
	/obj/item/clothing/head/helmet/space/eva,
	)

/datum/endo_assembly/item/clothing/hat/pre_check_assemble(datum/source, obj/item/I)
	if(is_type_in_typecache(I, blacklisted_hats))
		return
	return ..()

/datum/endo_assembly/item/clothing/hat/catch_assembly(datum/source, mob/M)
	. = ..()
	RegisterSignal(M, COMSIG_ATOM_HITBY, PROC_REF(catch_hitby), TRUE)

/datum/endo_assembly/item/clothing/hat/catch_unassembly(datum/source, mob/M)
	. = ..()
	UnregisterSignal(M, COMSIG_ATOM_HITBY)

/datum/endo_assembly/item/clothing/hat/proc/catch_hitby(datum/source, atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER

	if(pre_check_assemble(src, AM))
		add_part(src, AM)
		catch_assembly(src, part_parent.assembled_mob)
		part_parent.current_assembly += AM
		AM.forceMove(part_parent.parent)
