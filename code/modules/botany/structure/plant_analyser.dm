/obj/machinery/plant_analyser
	name = "plant analyzer"
	desc = "An advanced device designed to analyse plant genetic makeup."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "dnamod"
	density = TRUE
	pass_flags = PASSTABLE

	///Plant we're curently editing
	var/obj/inserted_plant
	///Shortcut to component
	var/datum/component/plant/plant_component
	///Currently selected feature
	var/datum/plant_feature/current_feature
	var/current_feature_ref

	///Inserted disk we're saving data too
	var/obj/item/plant_disk/disk
	///Are we in the process of saving a feature
	var/saving_feature = FALSE
	///What traits are we not saving with the plant feature, if we are saving a plant feature
	var/list/save_excluded_traits = list()
	var/list/save_excluded_traits_ref = list()

/obj/machinery/plant_analyser/attackby(obj/item/C, mob/user)
	. = ..()
	//insert disk
	if(istype(C, /obj/item/plant_disk) && !disk)
		C.forceMove(src)
		disk = C
		return
	//Insert plant
	var/datum/component/plant/plant = C.GetComponent(/datum/component/plant)
	if(!plant)
		return
	C.forceMove(src)
	inserted_plant = C
	plant_component = plant

//TODO: Add a button in the UI to do this too - Racc
/obj/machinery/plant_analyser/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	//Remove disk
	if(!disk)
		return
	disk.forceMove(get_turf(src))
	user.put_in_active_hand(disk)
	disk = null

/obj/machinery/plant_analyser/attackby_secondary(obj/item/weapon, mob/user, params)
	. = ..()
	//TODO: Make this work exclusively with a spade - Racc
	if(!inserted_plant)
		return
	inserted_plant.forceMove(get_turf(src))
	inserted_plant = null
	plant_component = null
	current_feature = null
	current_feature_ref = null

/obj/machinery/plant_analyser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlantEditor")
		ui.open()

/obj/machinery/plant_analyser/ui_data(mob/user)
	var/list/data = list()
	//generic stats
	data["plant_feature_data"] = list()
	if(plant_component)
		for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
			data["plant_feature_data"] += list(feature.get_ui_stats())
	//icons
	//current feature
	data["current_feature"] = current_feature_ref
	data["current_feature_data"] = current_feature?.get_ui_data()
	data["current_feature_traits"] = current_feature?.get_ui_traits()
	//Current inserted plant's name
	data["inserted_plant"] = inserted_plant?.name
	///Are we saving a feature
	data["saving_feature"] = saving_feature
	///Which traits are we not including in the save
	data["save_excluded_traits"] = save_excluded_traits_ref
	///Is there a disk inserted
	data["disk_inserted"] = disk

	return data

/obj/machinery/plant_analyser/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("select_feature")
			current_feature_ref = current_feature_ref == params["key"] ? null : params["key"]
			current_feature = locate(current_feature_ref)
			ui_update()
			return
		if("save_trait")
			if(!disk)
				return
			if(disk.saved)
				qdel(disk.saved)
			var/datum/plant_trait/trait = locate(params["key"])
			disk.saved = trait.copy()
			ui_update()
		if("save_feature")
			if(!disk)
				return
			if(disk.saved)
				qdel(disk.saved)
			if(!length(current_feature.plant_traits) || params["force"])
				var/datum/plant_feature/feature = locate(params["key"])
				feature = feature.copy()
				for(var/datum/plant_trait/trait as anything in feature.plant_traits)
					if(trait.type in save_excluded_traits)
						feature.plant_traits -= trait
						qdel(trait)
				disk.saved = feature
				saving_feature = FALSE
				ui_update()
				return
			saving_feature = !isnull(current_feature?.get_ui_traits())
		if("toggle_trait")
			var/datum/plant_trait/trait = locate(params["key"])
			if(params["key"] in save_excluded_traits_ref)
				save_excluded_traits_ref -= params["key"]
				save_excluded_traits -= trait.type
			else
				save_excluded_traits_ref += params["key"]
				save_excluded_traits += trait.type
			ui_update()
			return

	return TRUE
