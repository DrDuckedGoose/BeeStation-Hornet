/obj/item/plant_item/random
	skip_growth = TRUE

/obj/item/plant_item/random/Initialize(mapload)
	. = ..()
	//Build some random features
	var/list/random_features = list()
	random_features += SSbotany.get_random_body()
	random_features += SSbotany.get_random_fruit()
	random_features += SSbotany.get_random_root()
	//TODO: Add a chance to add random traits too - Racc
	//Add our random features
	var/datum/component/plant/plant_component = GetComponent(/datum/component/plant)
	plant_component.populate_features(random_features)
