//Trash bog of holding
/obj/item/borg/upgrade/item/tboh
	name = "janitor cyborg trash bag of holding"
	desc = "A trash bag of holding replacement for the janiborg's standard trash bag."
	icon_state = "cyborg_upgrade3"
	compatible_modules = list(/obj/item/new_robot_module/janitor)
	module_flags = BORG_MODULE_JANITOR
	upgrade_item = /obj/item/storage/bag/trash/cyborg

//Advanced mop
/obj/item/borg/upgrade/item/amop
	name = "janitor cyborg advanced mop"
	desc = "An advanced mop replacement for the janiborg's standard mop."
	icon_state = "cyborg_upgrade3"
	compatible_modules = list(/obj/item/new_robot_module/janitor)
	module_flags = BORG_MODULE_JANITOR
	upgrade_item = /obj/item/mop/advanced/cyborg

//TODO: make all of these roundstart available to service printers and command - Racc
//Service upgrade template
/obj/item/borg/upgrade/speciality
	name = "Speciality Module"
	icon_state = "cyborg_upgrade3"
	compatible_modules = list(/obj/item/robot_module/butler)
	module_flags = BORG_MODULE_SPECIALITY
	///Extra items we'll be adding to the module
	var/additional_items = list()
	///Reagents we'll be adding to the module's borgshaker
	var/list/additional_reagents = list()

/obj/item/borg/upgrade/speciality/install(obj/item/new_robot_module/module, mob/living/silicon/new_robot/R, mob/user)
	. = ..()
	if(!.)
		return
	//Add our special items
	for(var/item in additional_items)
		additional_items -= item
		var/obj/item/I = new item()
		additional_items += I
		module.prepare_item(I, TRUE)
	//Add our special reagents
	for(var/obj/item/reagent_containers/borghypo/borgshaker/H in module.all_items)
		for(var/reagent in additional_reagents)
			H.add_reagent(reagent)

/obj/item/borg/upgrade/speciality/remove(obj/item/new_robot_module/module, mob/living/silicon/new_robot/R, mob/user)
	. = ..()
	if(!.)
		return
	for(var/obj/item/item as() in additional_items)
		module.remove_item(item)
		additional_items -= item
		qdel(item)
	for(var/obj/item/reagent_containers/borghypo/borgshaker/H in module.all_items)
		for(var/reagent in additional_reagents)
			H.del_reagent(reagent)

//kitchen
/obj/item/borg/upgrade/speciality/kitchen
	name = "Cook Speciality"
	desc = "A service cyborg upgrade allowing for basic food handling."
	additional_items = list (
		/obj/item/knife/kitchen,
		/obj/item/kitchen/rollingpin,
	)
	additional_reagents = list(
		/datum/reagent/consumable/enzyme,
		/datum/reagent/consumable/sugar,
		/datum/reagent/consumable/flour,
		/datum/reagent/water,
	)

//Botany
/obj/item/borg/upgrade/speciality/botany
	name = "Botany Speciality"
	desc = "A service cyborg upgrade allowing for plant tending and manipulation."
	additional_items = list (
		/obj/item/storage/bag/plants/portaseeder,
		/obj/item/cultivator,
		/obj/item/plant_analyzer,
		/obj/item/shovel/spade,
	)
	additional_reagents = list(
		/datum/reagent/water,
	)

//Based
/obj/item/borg/upgrade/speciality/casino
	name = "Gambler Speciality"
	desc = "It's not crew harm if they do it themselves!"
	additional_items = list (
		/obj/item/gobbler,
		/obj/item/storage/pill_bottle/dice_cup/cyborg,
		/obj/item/toy/cards/deck/cyborg,
	)

//Ditto
/obj/item/borg/upgrade/speciality/party
	name = "Party Speciality"
	desc = "The night's still young..."
	additional_items = list (
		/obj/item/stack/tile/light/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/dance_trance,
	)
