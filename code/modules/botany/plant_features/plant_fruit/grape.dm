/*
	Grape
*/
//TODO: make this and other fruits like it use grouped sprites when there are multiple fruits - Racc
/datum/plant_feature/fruit/grape
	species_name = "uva erubesco"
	name = "grape"
	icon_state = "berry"
	fruit_product = /obj/item/food/grown/grapes
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/consumable/sugar = PLANT_REAGENT_MEDIUM)
	colour_override = "#7b194f"
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_VERY_FAST
	mutations = list(/datum/plant_feature/fruit/grape/green)

/*
	Green Grape
*/
/datum/plant_feature/fruit/grape/green
	species_name = "uva viridis"
	name = "green grape"
	fruit_product = /obj/item/food/grown/grapes/green
	fast_reagents = list(/datum/reagent/consumable/sugar = PLANT_REAGENT_MEDIUM,
	/datum/reagent/medicine/kelotane = PLANT_REAGENT_MEDIUM)
	colour_override = "#a1cc6f"
	mutations = list(/datum/plant_feature/fruit/grape)
