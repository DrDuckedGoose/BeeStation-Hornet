/*
	Pineapple
*/
/datum/plant_feature/fruit/pineapple
	species_name = "abiete malum"
	name = "pineapple"
	icon_state = "tomato" //TODO: - Racc
	fruit_product = /obj/item/food/grown/pineapple
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment/large, /datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/water = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_MEDIUM
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
