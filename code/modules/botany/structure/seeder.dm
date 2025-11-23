/*
	Used to make and store seeds
		Semi important that this isn't a plant machine subtype
*/
/obj/machinery/seeder
	name = "industrial seeder"
	desc = "A large set of jaws set in a compact frame.\n<span class='notice'>Turns 'fruit' into seed</span>"
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "seeder"
	///Upper amount of seeds we can make
	var/seed_amount = 3
	///
	var/list/stored_seeds = list()
	///
	var/focused_seeds

/obj/machinery/seeder/Initialize(mapload)
	. = ..()
	//TODO: remove before release - Racc
	for(var/obj/item/plant_seeds/seeds as anything in subtypesof(/obj/item/plant_seeds/preset))
		var/obj/item/plant_seeds/new_seeds = new seeds()
		stored_seeds["[new_seeds.species_id]"] = stored_seeds["[new_seeds.species_id]"] || list()
		stored_seeds["[new_seeds.species_id]"] += new_seeds
		new_seeds.forceMove(src)

/obj/machinery/seeder/attackby(obj/item/C, mob/user)
	. = ..()
//Store seeds
	if(istype(C, /obj/item/plant_seeds))
		var/obj/item/plant_seeds/seeds = C
		stored_seeds["[seeds.species_id]"] = stored_seeds["[seeds.species_id]"] || list()
		stored_seeds["[seeds.species_id]"] += seeds
		seeds.forceMove(src)
		return
//Turn fruit into seeds
	//Shortcut for fruit that appears roundstart
	var/obj/item/food/grown/fruit = C
	if(istype(fruit) && fruit.seed)
		for(var/index in 1 to seed_amount)
			new fruit.seed(get_turf(src))
		to_chat(user, "<span class='notice'>[seed_amount] seeds created!</span>")
		return
	//General genes
	var/list/genes = list()
	SEND_SIGNAL(C, COMSIG_PLANT_GET_GENES, genes)
	//Features
	var/list/features = genes[PLANT_GENE_INDEX_FEATURES]
	//species ID
	var/species_id = genes[PLANT_GENE_INDEX_ID]
	//Impart onto seeds
	if(!length(features))
		return
	for(var/index in 1 to seed_amount)
		new /obj/item/plant_seeds(get_turf(src), features, species_id)
	to_chat(user, "<span class='notice'>[seed_amount] seeds created!</span>")
	qdel(C)

/obj/machinery/seeder/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SeedStorage")
		ui.open()

/obj/machinery/seeder/ui_data(mob/user)
	var/list/data = list()
	//General seed data
	data["seeds"] = list()
	for(var/species_id as anything in stored_seeds)
		if(!length(stored_seeds[species_id]))
			continue
		var/obj/item/plant_seeds/seeds = stored_seeds[species_id][1]
		var/list/features = list()
		for(var/datum/plant_feature/feature as anything in seeds.plant_features)
			features["[ref(feature)]"] = list()
			features["[ref(feature)]"]["data"] = feature.get_ui_data()
			features["[ref(feature)]"]["traits"] = feature.get_ui_traits()
			features["[ref(feature)]"]["stats"] = feature.get_ui_stats()
		data["seeds"]["[seeds.species_id]"] = list("name" = seeds.name_override || name, "species_name" = seeds.get_species_name(), "count" = length(stored_seeds[species_id]),
		"seeds" = seeds.seeds, "features" = features, "species_id" = seeds.species_id, "ref" = "[ref(seeds)]")
	//Special boy who tells us who the star is
	data["focused_seeds"] = list()
	if(focused_seeds)
		var/obj/item/plant_seeds/seeds = locate(focused_seeds)
		data["focused_seeds"] = list("key" = focused_seeds, "species_id" = seeds.species_id)
	return data

/obj/machinery/seeder/ui_act(action, params)
	if(..())
		return
	playsound(src, get_sfx("keyboard"), 30, TRUE)
	switch(action)
		if("select_entry")
			focused_seeds = params["key"]
			ui_update()
		if("dispense")
			var/species_id = params["key"]
			if(!length(stored_seeds[species_id])) //This shouldn't be possible, but laggier UIs might make it so
				return
			var/obj/item/plant_seeds/seeds = stored_seeds[species_id][1]
			stored_seeds[species_id] -= seeds
			seeds.forceMove(get_turf(src))
			if(focused_seeds && focused_seeds["species_id"] == species_id && length(stored_seeds[species_id]) <= 0)
				focused_seeds = null
			ui_update()
