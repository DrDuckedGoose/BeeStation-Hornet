/*
	Flower
	Generic flower
*/
/datum/plant_feature/fruit/flower
	species_name = "uva erubesco" //TODO: - Racc
	name = "grape" //TODO: - Racc
	icon_state = "flower_1"
	//colour_overlay = "flower_1_colour"
	random_plant = TRUE
	fruit_product = /obj/item/food/grown/flower/forgetmenot
	plant_traits = list(/datum/plant_trait/nectar)
	//colour_override = "#ffffff"
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_VERY_FAST

/*
	Flower
	Generic flower
*/
/datum/plant_feature/fruit/flower/poppy
	species_name = "uva erubesco" //TODO: - Racc
	name = "grape" //TODO: - Racc
	icon_state = "flower_3"
	colour_overlay = "flower_3_colour"
	fruit_product = /obj/item/food/grown/flower/poppy //TODO: - Racc
	plant_traits = list(/datum/plant_trait/nectar) //TODO: - Racc
	colour_override = "#af3030"


/*
	Flower
	Generic flower
*/
/datum/plant_feature/fruit/flower/geranium
	species_name = "uva erubesco" //TODO: - Racc
	name = "grape" //TODO: - Racc
	icon_state = "flower_2"
	colour_overlay = "flower_2_colour"
	fruit_product = /obj/item/food/grown/flower/geranium //TODO: - Racc
	plant_traits = list(/datum/plant_trait/nectar) //TODO: - Racc
	colour_override = "#7f44a1"
