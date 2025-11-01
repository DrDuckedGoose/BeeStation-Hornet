/obj/item/plant_item/random
	skip_growth = TRUE

/obj/item/plant_item/random/Initialize(mapload)
	. = ..()
	//Get some random features
	var/list/random_features = list()
	random_features += SSbotany.get_random_body()
	random_features += SSbotany.get_random_fruit()
	random_features += SSbotany.get_random_root()
	//Build our random features
	var/datum/component/plant/plant_component = GetComponent(/datum/component/plant)
	plant_component.populate_features(random_features)
	//Add some random traits to our features
	for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
		var/datum/plant_trait/trait = SSbotany.get_random_trait("[feature.trait_type_shortcut]")
		trait = new trait(feature)
		feature.plant_traits += trait
