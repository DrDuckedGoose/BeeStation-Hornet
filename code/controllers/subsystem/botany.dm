SUBSYSTEM_DEF(botany)
	name = "Botany"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_BOTANY

	///list of plant species - This is used for the discovery component
	var/list/plant_species = list()

	///List of plant needs we randomly pick from to compensate for overdrawing genetic budget
	var/list/overdraw_needs = list()

	///List of discovered plant species
	var/list/discovered_species = list()

	///Blacklist of fruits that can't be slippery
	var/list/fruit_blacklist = list(/obj/item/food/grown/banana)

//Random Features
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

//Random traits
	///List of all random traits - linked list, arranged by trait compat list(/datum/plant_feature/body = list(traits))
	var/list/random_traits = list()
	var/list/unused_random_traits = list()

/datum/controller/subsystem/botany/Initialize(timeofday)
	fruit_blacklist = typecacheof(fruit_blacklist)
	//Build overdraw need list
	for(var/datum/plant_need/need as anything in subtypesof(/datum/plant_need))
		if(initial(need.overdraw_need))
			overdraw_needs += need
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
	//Build random traits
	for(var/datum/plant_trait/trait as anything in subtypesof(/datum/plant_trait))
		if(!initial(trait.random_trait))
			continue
		//Don't let abstract types through
		var/path = initial(trait.type)
		if(path == /datum/plant_trait || path == /datum/plant_trait/fruit || path == /datum/plant_trait/body || path == /datum/plant_trait/roots || path == /datum/plant_trait/reagent)
			continue
		if(!random_traits["[initial(trait.plant_feature_compat)]"])
			random_traits["[initial(trait.plant_feature_compat)]"] = list()
		random_traits["[initial(trait.plant_feature_compat)]"] += trait

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

/datum/controller/subsystem/botany/proc/get_random_need()
	return pick(overdraw_needs)

/datum/controller/subsystem/botany/proc/get_random_trait(filter, consider_unused = TRUE)
	if(!filter)
		return
	if(!consider_unused)
		return pick(random_traits[filter])
	if(!length(unused_random_traits[filter]))
		var/list/copy_list = random_traits[filter]
		unused_random_traits[filter] = copy_list.Copy()
	var/trait = pick(unused_random_traits[filter])
	unused_random_traits[filter] -= trait
	return trait
