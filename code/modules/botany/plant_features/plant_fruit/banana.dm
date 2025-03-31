//TODO: implement the banana bunch sprite - Racc
/datum/plant_feature/fruit/banana
	icon_state = "banana"
	fruit_product = /obj/item/food/grown/banana
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin/large)
	fast_reagents = list(/datum/reagent/consumable/banana = 10, /datum/reagent/potassium = 10)
	total_volume = PLANT_REAGENT_MEDIUM
	growth_time = PLANT_FRUIT_GROWTH_FAST

//TODO: Mimama & Bluespace - Racc
