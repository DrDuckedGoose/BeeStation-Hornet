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

//Plant dictionary
	///List of dictionary chapters- features, plants, traits
	var/list/chapters = list()
	///List of links for dictionary references, like finding which features a trait appears in
	var/list/dictionary_links = list()
	///Special index for fast reagents, keeping track of what's logged already
	var/list/fast_reagents = list()

/datum/controller/subsystem/botany/Initialize(timeofday)
	build_dict()
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

/datum/controller/subsystem/botany/proc/build_dict()
//Features
	var/list/keyed_features = list() //List of features keyed by type, so we can link them to plants
	chapters["features"] = list()
	var/list/features = subtypesof(/datum/plant_feature)
	for(var/datum/plant_feature/feature as anything in features)
		var/datum/plant_feature/entry_feature = new feature()
		//Don't let abstract types through
		if(entry_feature.type == /datum/plant_feature || entry_feature.type == /datum/plant_feature/body || entry_feature.type == /datum/plant_feature/fruit || entry_feature.type == /datum/plant_feature/roots)
			qdel(entry_feature)
			continue
		chapters["features"] += entry_feature
		keyed_features["[entry_feature.type]"] = "[ref(entry_feature)]"
		//Build links
		for(var/datum/plant_trait/trait as anything in entry_feature.plant_traits)
			dictionary_links["[trait.get_id()]"] = dictionary_links["[trait.get_id()]"] || list()
			dictionary_links["[trait.get_id()]"] += "[ref(entry_feature)]"
//Traits
	chapters["traits"] = chapters["traits"] || list() //Race condition weirdness
	var/list/traits = subtypesof(/datum/plant_trait)
	for(var/datum/plant_trait/trait as anything in traits)
		var/datum/plant_trait/entry_trait = new trait()
		if(trait.type == /datum/plant_trait || trait.type == /datum/plant_trait/fruit || trait.type == /datum/plant_trait/body || trait.type == /datum/plant_trait/roots || trait.type == /datum/plant_trait/reagent)
			qdel(entry_trait)
			continue
		chapters["traits"] += entry_trait
//Plants - This is a lie, it's actually got pre-made seeds
	chapters["plants"] = list()
	for(var/obj/item/plant_seeds/preset as anything in typesof(/obj/item/plant_seeds/preset))
		var/obj/item/plant_seeds/seeds = new preset()
		if(seeds.type == /obj/item/plant_seeds/preset)
			qdel(seeds)
			continue
		chapters["plants"] += seeds
		//Build links
		for(var/datum/plant_feature/feature as anything in seeds.plant_features)
			var/link_feature = keyed_features["[feature.type]"]
			dictionary_links[link_feature] = dictionary_links[link_feature] || list()
			dictionary_links[link_feature] += "[ref(seeds)]"

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

/datum/controller/subsystem/botany/proc/append_reagent_trait(datum/plant_trait/reagent/reagent)
	if(!fast_reagents["[reagent.name][reagent.volume_percentage]"])
		fast_reagents["[reagent.name][reagent.volume_percentage]"] = reagent
		SSbotany.chapters["traits"] = SSbotany.chapters["traits"] || list() //Race condition weirdness
		SSbotany.chapters["traits"] += reagent
