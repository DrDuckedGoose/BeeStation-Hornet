//TODO: Consider giving these unique stats - Racc
//TODO: Sprites for all of these - Racc
/*
	Tomato Bush-Vine
*/
/datum/plant_feature/body/bush_vine
	species_name = "arbor parva"
	name = "bush"
	icon_state = "bush_vine"
	overlay_positions = list(list(10, 18), list(23, 17), list(16, 24), list(10, 10), list(23, 10), list(17, 17), list(17, 10))
	yields = PLANT_BODY_YIELD_MEDIUM
	yield_cooldown_time = PLANT_BODY_YIELD_TIME_FAST
	max_harvest = PLANT_BODY_HARVEST_MEDIUM
	upper_fruit_size = PLANT_FRUIT_SIZE_SMALL
	seeds = 2

/*
	Berry Bush
*/
/datum/plant_feature/body/bush_vine/berry
	species_name = "parvum parva fructum"
	name = "berry bush"
	icon_state = "bush"
	random_plant = TRUE

/*
	Flower Bush
*/
/datum/plant_feature/body/bush_vine/flower
	species_name = "flosculus arboris"
	name = "flower bush"
	icon_state = "bush_flower"
	draw_below_water = FALSE
	random_plant = TRUE
	overlay_positions = list(list(11, 12), list(21, 17), list(18, 11), list(24, 9), list(9, 8))

/*
	Grape Vine
*/
/datum/plant_feature/body/bush_vine/grape
	species_name = "uva arbor"
	name = "grape vine"
	icon_state = "missing"
	overlay_positions = list(list(13, 16), list(21, 16), list(13, 9), list(21, 9), list(13, 2), list(21, 2)) //TODO: Remember to update these - Racc

/*
	Ground Vine
*/
/datum/plant_feature/body/bush_vine/ground
	species_name = "terra arbore"
	name = "ground vine"
	icon_state = "vine_ground"
	draw_below_water = FALSE
	overlay_positions = list(list(24, 6))

/*
	Ambrosia bush
*/
/datum/plant_feature/body/bush_vine/ambrosia
	species_name = "folium rubi"
	name = "ambrosia bush"
	icon_state = "missing"
	draw_below_water = FALSE
	overlay_positions = list(list(24, 6))

/*
	Nettle bush
*/
/datum/plant_feature/body/bush_vine/nettle
	species_name = "aculeatum rubi"
	name = "nettle bush"
	icon_state = "missing"
	draw_below_water = FALSE
	overlay_positions = list(list(24, 6))

/*
	Cannabis bush
*/
/datum/plant_feature/body/bush_vine/cannabis
	species_name = "ridiculam rubi"
	name = "cannabis bush"
	icon_state = "missing"
	draw_below_water = FALSE
	overlay_positions = list(list(24, 6))


/*
	Tea bush
*/
/datum/plant_feature/body/bush_vine/tea
	species_name = "asperae rubi"
	name = "tea bush"
	icon_state = "missing"
	draw_below_water = FALSE
	overlay_positions = list(list(24, 6))
