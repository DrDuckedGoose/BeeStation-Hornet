//TODO: Refactor / improve all UI code - Racc
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
/obj/machinery/seed_editor/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	//TODO: Optimize / review this - Racc
//Remove Seeds
	seeds.forceMove(get_turf(src))
	user.put_in_active_hand(seeds)
	seeds = null
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
			if(!feature.can_remove)
				return
			seeds.plant_features -= feature
			qdel(feature)
			//We can safely set this to null, so it makes a new ID when planted.
			seeds.species_id = null
		if("remove_trait")
			if(!current_feature)
				return
			var/datum/plant_trait/trait = locate(params["key"])
			if(!trait.can_remove)
				return
			current_feature.plant_traits -= trait
			qdel(trait)
			seeds.species_id = null
		if("add_trait")
			if(!current_feature)
				return
			//Don't allow trait duplication
			var/datum/plant_trait/trait = locate(params["key"])
			var/datum/plant_trait/trait_similar = (locate(trait.type) in current_feature.plant_traits)
			if(!trait.allow_multiple && trait_similar?.get_id() == trait.get_id()) //Check if it REALLY is the same
				return
			//Add the trait
			var/datum/plant_trait/new_trait = trait.copy(current_feature)
			if(!QDELING(new_trait))
				current_feature.plant_traits += new_trait
			//Reset the species ID
			seeds.species_id = null
		if("add_feature")
			var/datum/plant_feature/feature = locate(params["key"])
		//Generic compatibility checking
			for(var/datum/plant_feature/current_feature as anything in seeds.plant_features)
				//Does this plant already have this kind of feature>
				if(current_feature.feature_catagories & feature.feature_catagories) //If you want to have multiple features of the same type on one plant, this is one of the things stopping you
					playsound(src, 'sound/machines/terminal_error.ogg', 60)
					say("ERROR: Seed composition cannot fit selected feature!")
					say("SOLUTION: Please remove existing feature.")
					return
				//Is this feature blacklisted from another feature
				if(is_type_in_typecache(feature, current_feature.blacklist_features))
					playsound(src, 'sound/machines/terminal_error.ogg', 60)
					say("ERROR: Seed composition not compatible with selected feature!")
					return
				//If a feature has a whitelist, are we in it?
				if(length(current_feature.whitelist_features) && !is_type_in_typecache(feature, current_feature.whitelist_features))
					playsound(src, 'sound/machines/terminal_error.ogg', 60)
					say("ERROR: Seed composition not compatible with selected feature!")
					return
		//Special compatibility checking
			//If it's a fruit- check if it fits on the body - This will be the other thing you'll have to potentially rewrite if you allow duplicate features
			var/datum/plant_feature/fruit/fruit_feature = feature
			var/datum/plant_feature/body/body_feature = locate(/datum/plant_feature/body) in seeds.plant_features //Might create overhead if they spam it and we later add 5 million unique features
			//These are arranged to be a little more readable, dont sweat efficiency
			if(istype(fruit_feature) && !body_feature)
				playsound(src, 'sound/machines/terminal_error.ogg', 60)
				say("ERROR: Seed composition does not contain a supporting body for this feature!")
				return
			if((istype(fruit_feature) && body_feature) && fruit_feature.fruit_size > body_feature.upper_fruit_size)
				playsound(src, 'sound/machines/terminal_error.ogg', 60)
				say("ERROR: Seed composition's body feature doesn't support this feature!")
				return
		//Good to go, slap that bad boy on
			var/datum/plant_feature/new_feature = feature.copy()
			seeds.plant_features += new_feature
			seeds.species_id = null
	ui_update()
