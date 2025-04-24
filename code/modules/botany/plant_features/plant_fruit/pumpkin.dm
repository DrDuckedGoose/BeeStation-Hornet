//TODO: Sprites - Racc
/*
	Pumpkin
	Slow growing large volume fruit
*/
/datum/plant_feature/fruit/pumpkin
	species_name = "cucurbita magna"
	name = "pumpkin"
	icon_state = "banana" //TODO: - Racc
	fruit_product = /obj/item/food/grown/pumpkin
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment/large, /datum/plant_trait/reagent/fruit/vitamin/large)
	total_volume = PLANT_FRUIT_VOLUME_LARGE
	growth_time = PLANT_FRUIT_GROWTH_SLOW
	mutations = list(/datum/plant_feature/fruit/pumpkin/blumpkin)

/*
	Blumpkin
*/
/datum/plant_feature/fruit/pumpkin/blumpkin
	species_name = "cucurbita venenum"
	name = "blumpkin"
	icon_state = "banana" //TODO: - Racc
	fruit_product = /obj/item/food/grown/blumpkin
	fast_reagents = list(/datum/reagent/ammonia = PLANT_REAGENT_MEDIUM, /datum/reagent/chlorine = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/pumpkin)
