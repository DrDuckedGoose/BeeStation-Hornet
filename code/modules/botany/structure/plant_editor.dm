/obj/machinery/plant_editor
	name = "plant analyzer"
	desc = "An advanced device designed to manipulate plant genetic makeup."
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

	///
	var/saved
	///Are we in the process of saving a feature
	var/saving_feature = FALSE
	///What traits are we not saving with the plant feature, if we are saving a plant feature
	var/list/save_excluded_traits = list()
	var/list/save_excluded_traits_ref = list()

/obj/machinery/plant_editor/attackby(obj/item/C, mob/user)
	. = ..()
	var/datum/component/plant/plant = C.GetComponent(/datum/component/plant)
	if(!plant)
		return
	C.forceMove(src)
	inserted_plant = C
	plant_component = plant

/obj/machinery/plant_editor/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	//TODO: Make this work exclusively with a spade - Racc
	if(!inserted_plant)
		return
	inserted_plant.forceMove(get_turf(src))
	inserted_plant = null
	plant_component = null
	current_feature = null
	current_feature_ref = null

/obj/machinery/plant_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlantEditor")
		ui.open()

/obj/machinery/plant_editor/ui_data(mob/user)
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

	return data

/obj/machinery/plant_editor/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("select_feature")
			current_feature_ref = current_feature_ref == params["key"] ? null : params["key"]
			current_feature = locate(current_feature_ref)
		if("save_trait")
			if(saved)
				qdel(saved)
			var/datum/plant_trait/trait = locate(params["key"])
			saved = trait.copy()
		if("save_feature")
			if(saved)
				qdel(saved)
			if(!length(current_feature.plant_traits) || params["force"])
				var/datum/plant_feature/feature = locate(params["key"])
				feature = feature.copy()
				for(var/datum/plant_trait/trait as anything in feature.plant_traits)
					if(trait.type in save_excluded_traits)
						feature.plant_traits -= trait
						qdel(trait)
				saved = feature
				saving_feature = FALSE
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

	return TRUE
