/*
	Cactus
	Medium fruit type that grows fast
*/
/datum/plant_feature/fruit/cactus
	species_name = "spinis fructificatio"
	name = "fruiting cactus"
	icon_state = "cactus"
	fruit_product = /obj/item/food/grown/ash_flora/cactus_fruit
	//TODO: Add a trait for pickles - Racc
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/consumable/vitfro = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_MEDIUM
	growth_time = PLANT_FRUIT_GROWTH_FAST
