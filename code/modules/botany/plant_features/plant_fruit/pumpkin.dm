//TODO: Sprites - Racc
/*
	Pumpkin
*/
/datum/plant_feature/fruit/pumpkin
	icon_state = "apple"
	fruit_product = /obj/item/food/grown/pumpkin
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment/large, /datum/plant_trait/reagent/fruit/vitamin/large)
	total_volume = PLANT_REAGENT_LARGE
	growth_time = PLANT_FRUIT_GROWTH_SLOW

/*
	Blumpkin
*/
/datum/plant_feature/fruit/pumpkin/blumpkin
	icon_state = "apple"
	fruit_product = /obj/item/food/grown/blumpkin
	fast_reagents = list(/datum/reagent/ammonia = PLANT_FRUIT_VOLUME_MEDIUM, /datum/reagent/chlorine = PLANT_FRUIT_VOLUME_SMALL)
