//Hypospray extra reagents template
/obj/item/borg/upgrade/hypospray
	name = "medical cyborg hypospray advanced synthesiser"
	desc = "An upgrade to the Medical module cyborg's hypospray, allowing it \
		to produce more advanced and complex medical reagents."
	icon_state = "cyborg_upgrade3"
	compatible_modules = list(/obj/item/new_robot_module/medical)
	module_flags = BORG_MODULE_MEDICAL
	///Extra reagents our hypospray injects
	var/list/additional_reagents = list()

/obj/item/borg/upgrade/hypospray/install(obj/item/new_robot_module/module, mob/living/silicon/new_robot/R, mob/user)
	. = ..()
	if(!.)
		return
	for(var/obj/item/reagent_containers/borghypo/H in module.all_items)
		if(!H.accepts_reagent_upgrades)
			continue
		for(var/reagent in additional_reagents)
			H.add_reagent(reagent)

/obj/item/borg/upgrade/hypospray/remove(obj/item/new_robot_module/module, mob/living/silicon/new_robot/R, mob/user)
	. = ..()
	if(!.)
		return
	for(var/obj/item/reagent_containers/borghypo/H in module.all_items)
		if(!H.accepts_reagent_upgrades)
			continue
		for(var/reagent in additional_reagents)
			H.del_reagent(reagent)

//Expanded
/obj/item/borg/upgrade/hypospray/expanded
	name = "medical cyborg expanded hypospray"
	desc = "An upgrade to the Medical module's hypospray, allowing it \
		to treat a wider range of conditions and problems."
	additional_reagents = list(/datum/reagent/medicine/mannitol, /datum/reagent/medicine/oculine, /datum/reagent/medicine/inacusiate,
		/datum/reagent/medicine/mutadone, /datum/reagent/medicine/haloperidol, /datum/reagent/medicine/oxandrolone, /datum/reagent/medicine/sal_acid, /datum/reagent/medicine/rezadone,
		/datum/reagent/medicine/pen_acid)

//Expanded
/obj/item/borg/upgrade/piercing_hypospray
	name = "cyborg piercing hypospray"
	desc = "An upgrade to a cyborg's hypospray, allowing it to \
		pierce armor and thick material."
	icon_state = "cyborg_upgrade3"
	//Don't limit this to medical module

/obj/item/borg/upgrade/piercing_hypospray/install(obj/item/new_robot_module/module, mob/living/silicon/new_robot/R, mob/user)
	. = ..()
	if(!.)
		return
	var/found_hypo = FALSE
	for(var/obj/item/reagent_containers/borghypo/H in module.all_items)
		H.bypass_protection = TRUE
		found_hypo = TRUE
	if(!found_hypo)
		return FALSE

/obj/item/borg/upgrade/piercing_hypospray/remove(obj/item/new_robot_module/module, mob/living/silicon/new_robot/R, mob/user)
	. = ..()
	if(!.)
		return
	for(var/obj/item/reagent_containers/borghypo/H in module.all_items)
		H.bypass_protection = initial(H.bypass_protection)

//Defib
/obj/item/borg/upgrade/item/defib
	name = "medical cyborg defibrillator"
	desc = "An upgrade to the Medical module, installing a built-in \
		defibrillator, for on the scene revival."
	icon_state = "cyborg_upgrade3"
	compatible_modules = list(/obj/item/new_robot_module/medical)
	module_flags = BORG_MODULE_MEDICAL
	upgrade_item = /obj/item/shockpaddles/cyborg

//Medical processor
/obj/item/borg/upgrade/item/processor
	name = "medical cyborg surgical processor"
	desc = "An upgrade to the Medical module, installing a processor \
		capable of scanning surgery disks and carrying \
		out procedures"
	icon_state = "cyborg_upgrade3"
	compatible_modules = list(/obj/item/new_robot_module/medical, /obj/item/new_robot_module/syndicate_medical)
	module_flags = BORG_MODULE_MEDICAL
	upgrade_item = /obj/item/surgical_processor

//Pin pointer
/obj/item/borg/upgrade/item/pinpointer
	name = "medical cyborg crew pinpointer"
	desc = "A crew pinpointer module for the medical cyborg. Permits remote access to the crew monitor."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinpointer_crew"
	compatible_modules = list(/obj/item/new_robot_module/medical, /obj/item/new_robot_module/syndicate_medical)
	module_flags = BORG_MODULE_MEDICAL
	upgrade_item = /obj/item/pinpointer/crew
	//Special action for convenience
	var/datum/action/crew_monitor

/obj/item/borg/upgrade/item/pinpointer/install(obj/item/new_robot_module/module, mob/living/silicon/new_robot/R, mob/user)
	. = ..()
	if(!.)
		return
	crew_monitor = new /datum/action/item_action/crew_monitor(src)
	crew_monitor.Grant(R)
	icon_state = "scanner"

/obj/item/borg/upgrade/item/pinpointer/remove(obj/item/new_robot_module/module, mob/living/silicon/new_robot/R, mob/user)
	. = ..()
	if(!.)
		return
	icon_state = "pinpointer_crew"
	crew_monitor.Remove(R)
	QDEL_NULL(crew_monitor)

/obj/item/borg/upgrade/item/pinpointer/ui_action_click()
	if(..())
		return
	var/mob/living/silicon/new_robot/Cyborg = usr
	GLOB.crewmonitor.show(Cyborg, Cyborg)

//Beaker
/obj/item/borg/upgrade/item/beaker_app
	name = "beaker storage apparatus"
	desc = "A supplementary beaker storage apparatus for medical cyborgs."
	icon_state = "cyborg_upgrade3"
	compatible_modules = list(/obj/item/new_robot_module/medical)
	module_flags = BORG_MODULE_MEDICAL
	upgrade_item = /obj/item/borg/apparatus/beaker/extra
