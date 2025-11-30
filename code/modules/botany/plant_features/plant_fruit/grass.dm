/*
	Grass
	Generic fruit with no reagents that grows fast
*/
/datum/plant_feature/fruit/grass
	species_name = "gramen viridis"
	name = "grass"
	icon_state = "grass"
	fruit_product = /obj/item/food/grown/grass
	total_volume = 0
	growth_time = PLANT_FRUIT_GROWTH_VERY_FAST
	skip_animation = TRUE
	mutations = list(/datum/plant_feature/fruit/grass/carpet = 5)
	whitelist_features = list(/datum/plant_feature/body/tuber/grass, /datum/plant_feature/roots)

/*
	Carpet
*/
/datum/plant_feature/fruit/grass/carpet
	species_name = "gramen otium"
	name = "carpet"
	icon_state = "carpet"
	fruit_product = /obj/item/food/grown/grass/carpet
	mutations = list(/datum/plant_feature/fruit/grass/shamrock = 5)

/*
	Clovers
*/
/datum/plant_feature/fruit/grass/shamrock
	species_name = "gramen trifolium"
	name = "shamrock"
	icon_state = "shamrock"
	fruit_product = /obj/item/food/grown/grass/shamrock
	mutations = list(/datum/plant_feature/fruit/grass/fairy = 10)

/*
	Fairy Grass
*/
/datum/plant_feature/fruit/grass/fairy
	species_name = "gramen mediocris"
	name = "fairy grass"
	icon_state = "fairy_grass"
	fruit_product = /obj/item/food/grown/grass/fairy
	mutations = list(/datum/plant_feature/fruit/grass)
