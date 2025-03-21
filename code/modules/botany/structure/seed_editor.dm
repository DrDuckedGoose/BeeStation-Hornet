/obj/machinery/seed_editor
	name = "seed sequencer"
	desc = "An advanced device designed to manipulate seed genetic makeup."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "dnamod"
	density = TRUE
	pass_flags = PASSTABLE
	///Inserted seeds we're editing
	var/obj/item/plant_seeds/seeds
	///Currently selected feature
	var/datum/plant_feature/current_feature
	var/current_feature_ref
	//TODO: Please consider if this is really the best way to design this, giving access to saved traits - Racc
	///Inserted disk we're reading data from
	var/obj/item/plant_disk/disk

/obj/machinery/seed_editor/attackby(obj/item/C, mob/user)
	. = ..()
	//insert disk
	if(istype(C, /obj/item/plant_disk) && !disk)
		C.forceMove(src)
		disk = C
	//insert seeds
	if(istype(C, /obj/item/plant_seeds) && !seeds)
		C.forceMove(src)
		seeds = C

//TODO: Add a button in the UI to do this too - Racc
/obj/machinery/seed_editor/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!seeds)
		return
	seeds.forceMove(get_turf(src))
	user.put_in_active_hand(seeds)
	seeds = null

//TODO: Add a button in the UI to do this too - Racc
/obj/machinery/seed_editor/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	//Remove disk
	if(!disk)
		return
	disk.forceMove(get_turf(src))
	user.put_in_active_hand(disk)
	disk = null

/obj/machinery/seed_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SeedEditor")
		ui.open()

/obj/machinery/seed_editor/ui_data(mob/user)
	var/list/data = list()
	//generic stats
	data["seeds_feature_data"] = list()
	if(seeds)
		for(var/datum/plant_feature/feature as anything in seeds.plant_features)
			data["seeds_feature_data"] += list(feature.get_ui_stats())
	//icons
	//current feature
	data["current_feature"] = current_feature_ref
	data["current_feature_data"] = current_feature?.get_ui_data()
	data["current_feature_traits"] = current_feature?.get_ui_traits()
	//Current inserted plant's name
	data["inserted_plant"] = seeds?.name
	///Is there a disk inserted
	data["disk_inserted"] = disk
	data["disk_feature_data"] = null
	data["disk_trait_data"] = null
	if(istype(disk?.saved, /datum/plant_feature))
		var/datum/plant_feature/feature = disk.saved
		data["disk_feature_data"] += feature.get_ui_stats()
	else if(istype(disk?.saved, /datum/plant_trait))
		var/datum/plant_trait/trait = disk?.saved
		data["disk_trait_data"] += trait.get_ui_stats()[1]

	return data

/obj/machinery/seed_editor/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("select_feature")
			current_feature_ref = current_feature_ref == params["key"] ? null : params["key"]
			current_feature = locate(current_feature_ref)
			ui_update()
			return
		if("remove_feature")
			var/datum/plant_feature/feature = locate(params["key"])
			seeds.plant_features -= feature
			qdel(feature)
		if("remove_trait")
			if(!current_feature)
				return
			var/datum/plant_trait/trait = locate(params["key"])
			current_feature.plant_traits -= trait
			qdel(trait)
		if("add_trait")
			if(!current_feature)
				return
			var/datum/plant_trait/trait = locate(params["key"])
			if(locate(trait.type) in current_feature.plant_traits)
				return
			var/datum/plant_trait/new_trait = trait.copy(current_feature)
			if(!QDELING(new_trait))
				current_feature.plant_traits += new_trait
		if("add_feature")
			var/datum/plant_feature/feature = locate(params["key"])
			for(var/datum/plant_feature/current_feature as anything in seeds.plant_features)
				if(current_feature.feature_catagories & feature.feature_catagories)
					//TODO: Add an error message and explanation - Racc
					return
			var/datum/plant_feature/new_feature = feature.copy()
			seeds.plant_features += new_feature
