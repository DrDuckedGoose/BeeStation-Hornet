/*
	Coconut
	medium fruit type that grows average
*/
/datum/plant_feature/fruit/coconut
	species_name = "dolor durum"
	name = "coconut"
	icon_state = "tomato" //TODO: - Racc
	fruit_product = /obj/item/food/grown/tomato //TODO: - Racc
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/consumable/coconutmilk = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_MEDIUM
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
