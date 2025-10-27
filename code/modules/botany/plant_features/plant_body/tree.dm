//TODO: Consider giving these unique stats, and sprites - Racc
/*
	Tree
*/
/datum/plant_feature/body/tree
	species_name = "humilis arbor"
	name = "tree"
	icon_state = "tree"
	overlay_positions = list(list(14, 18), list(21, 20), list(20, 26), list(13, 25), list(16, 22))
	yields = PLANT_BODY_YIELD_LARGE
	yield_cooldown_time = PLANT_BODY_YIELD_TIME_MEDIUM
	max_harvest = PLANT_BODY_HARVEST_MEDIUM
	mutations = list(/datum/plant_feature/body/tree/mini)

/*
	Mini
*/
/datum/plant_feature/body/tree/mini
	species_name = "infantem arbor"
	name = "fruit tree"
	icon_state = "tree"
	overlay_positions = list(list(11, 20), list(16, 30), list(23, 23), list(8, 31)) //TODO: Remember to update these - Racc
	mutations = list(/datum/plant_feature/body/tree/sparse)

/*
	Sparse
*/
/datum/plant_feature/body/tree/sparse
	species_name = "arbor sparsa"
	name = "sparse tree"
	icon_state = "missing"
	overlay_positions = list(list(11, 20), list(16, 30), list(23, 23), list(8, 31))
	mutations = list(/datum/plant_feature/body/tree/palm)

/*
	Palm
*/
/datum/plant_feature/body/tree/palm
	species_name = "litus arbore"
	name = "palm tree"
	icon_state = "palm"
	overlay_positions = list(list(16, 18), list(21, 19, list(12, 20), list(21, 24)))
	mutations = list(/datum/plant_feature/body/tree)

