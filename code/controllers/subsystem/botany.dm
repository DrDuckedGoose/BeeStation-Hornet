SUBSYSTEM_DEF(botany)
	name = "Botany"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_BOTANY

	///list of plant species - This is used for the discovery component
	var/list/plant_species = list()
	///List of discovered plant species
	var/list/discovered_species = list()
	///List of plant seed tiers, and their seed contents
	var/list/seed_tiers = list()

	///List for random plant bodies
	var/list/random_bodies = list()
	///List of unused random bodies
	var/list/unused_random_bodies = list()

	///List for random plant fruits
	var/list/random_fruits = list()
	///List of unused random fruits
	var/list/unused_random_fruits = list()

	///List for random plant roots
	var/list/random_roots = list()
	///List of unused random roots
	var/list/unused_random_roots = list()

/datum/controller/subsystem/botany/Initialize(timeofday)
//Build random plant feature lists
	for(var/datum/plant_feature/feature as anything in subtypesof(/datum/plant_feature))
		feature = new feature()
		if(!feature.random_plant)
			continue
		if(istype(feature, /datum/plant_feature/body))
			random_bodies += feature.type
		if(istype(feature, /datum/plant_feature/fruit))
			random_fruits += feature.type
		if(istype(feature, /datum/plant_feature/roots))
			random_roots += feature.type
		QDEL_NULL(feature)
//TODO: Remove this feature - Racc
	//build plant seed tiers
	var/list/preset_seeds = subtypesof(/obj/item/plant_seeds/preset)
	for(var/obj/item/plant_seeds/preset/seed as anything in preset_seeds)
		var/tier = initial(seed.tier)
		if(!seed_tiers["[tier]"])
			seed_tiers["[tier]"] = list()
		seed_tiers["[tier]"] += seed

//Template for random features
/datum/controller/subsystem/botany/proc/get_random_feature(list/feature_list, list/unused_feature_list, consider_unused = TRUE)
	//If we just want a truly random random-compatible body
	if(!consider_unused)
		return pick(feature_list)
	//If we want a random body we haven't used yet
	if(!length(unused_feature_list))
		unused_feature_list = feature_list.Copy()
	var/feature = pick(unused_feature_list)
	unused_feature_list -= feature
	return feature

/datum/controller/subsystem/botany/proc/get_random_body(consider_unused = TRUE)
	return get_random_feature(random_bodies, unused_random_bodies, consider_unused)

/datum/controller/subsystem/botany/proc/get_random_fruit(consider_unused = TRUE)
	return get_random_feature(random_fruits, unused_random_fruits, consider_unused)

/datum/controller/subsystem/botany/proc/get_random_root(consider_unused = TRUE)
	return get_random_feature(random_roots, unused_random_roots, consider_unused)

