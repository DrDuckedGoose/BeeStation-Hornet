/datum/plant_feature/fruit/mushroom
	icon = 'icons/obj/hydroponics/features/mushroom.dmi'
	icon_state = "apple"
	genetic_budget = 1
	//Mushrooms have no needs
	plant_needs = list()
	//We can fit on only mushroom bodies, but any kind of roots
	whitelist_features = list(/datum/plant_feature/body/mushroom, /datum/plant_feature/roots)
	//TODO: Do I want a seperate category for mushrooms? - Racc
	feature_catagories = PLANT_FEATURE_FRUIT
