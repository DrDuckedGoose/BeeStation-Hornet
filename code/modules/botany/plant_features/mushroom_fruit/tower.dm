/*
	Tower-cap
*/
//TODO: - Sprites
/datum/plant_feature/fruit/mushroom/tower
	species_name = "turrim fungus"
	name = "tower-cap"
	icon_state = "missing"
	fruit_product = /obj/item/grown/log
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	fast_reagents = list(/datum/reagent/carbon = PLANT_REAGENT_LARGE)
	mutations = list(/datum/plant_feature/fruit/mushroom/tower/steel)

/*
	Steel-cap
*/
//TODO: - Sprites
/datum/plant_feature/fruit/mushroom/tower/steel
	species_name = "ferro fungus"
	name = "steel-cap"
	icon_state = "missing"
	fruit_product = /obj/item/grown/log/steel
	fast_reagents = list(/datum/reagent/iron = PLANT_REAGENT_LARGE)
	mutations = list(/datum/plant_feature/fruit/mushroom/tower)
