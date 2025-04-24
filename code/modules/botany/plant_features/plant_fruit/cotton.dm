/*
	Cotton
	Volumeless fruit type that grows fast
*/
/datum/plant_feature/fruit/cotton
	species_name = "bombacio mollis"
	name = "cotton"
	icon_state = "tomato" //TODO: - Racc
	fruit_product = /obj/item/grown/cotton
	total_volume = 0
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/cotton/durathread)

/*
	Durathread
*/
/datum/plant_feature/fruit/cotton/durathread
	species_name = "bombacio lenta"
	name = "durathread"
	icon_state = "tomato" //TODO: - Racc
	fruit_product = /obj/item/grown/cotton/durathread
	mutations = list(/datum/plant_feature/fruit/cotton)
