/*
	Grass
	Generic fruit with no reagents that grows fast
	TODO: Consider making grass, bamboo, etc. only grow on the ground or sum. But probably dont - Racc
*/
/datum/plant_feature/fruit/grass
	species_name = "gramen viridis"
	name = "grass"
	icon_state = "tomato" //TODO: - Racc
	fruit_product = /obj/item/food/grown/grass
	total_volume = 0
	growth_time = PLANT_FRUIT_GROWTH_VERY_FAST
	mutations = list(/datum/plant_feature/fruit/grass/carpet)

/*
	Carpet
*/
/datum/plant_feature/fruit/grass/carpet
	species_name = "gramen otium"
	name = "carpet"
	icon_state = "tomato" //TODO: - Racc
	fruit_product = /obj/item/food/grown/grass/carpet
	mutations = list(/datum/plant_feature/fruit/grass/fairy)

/*
	Fairy Grass
*/
/datum/plant_feature/fruit/grass/fairy
	species_name = "gramen mediocris"
	name = "fairy grass"
	icon_state = "tomato" //TODO: - Racc
	fruit_product = /obj/item/food/grown/grass/fairy
	mutations = list(/datum/plant_feature/fruit/grass/shamrock)

/*
	Fairy Grass
*/
/datum/plant_feature/fruit/grass/shamrock
	species_name = "gramen trifolium"
	name = "shamrock"
	icon_state = "tomato" //TODO: - Racc
	fruit_product = /obj/item/food/grown/grass/shamrock
	mutations = list(/datum/plant_feature/fruit/grass)
