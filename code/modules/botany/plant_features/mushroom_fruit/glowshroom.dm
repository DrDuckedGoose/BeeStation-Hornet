/*
	Glowshroom
*/
//TODO: Sprites - Racc
/datum/plant_feature/fruit/mushroom/glowshroom
	species_name = "meridiem fungus"
	name = "glowshroom"
	icon_state = "missing"
	fruit_product = /obj/item/food/grown/mushroom/glowshroom
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	plant_traits = list(/datum/plant_trait/fruit/biolight/green)
	fast_reagents = list(/datum/reagent/uranium/radium = PLANT_REAGENT_SMALL, /datum/reagent/phosphorus = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/mushroom/glowshroom/glowcap)

/*
	Glowcap
*/
/datum/plant_feature/fruit/mushroom/glowshroom/glowcap
	species_name = "fulgur fungus"
	name = "glowcap"
	icon_state = "missing"
	fruit_product = /obj/item/food/grown/mushroom/glowshroom/glowcap
	plant_traits = list(/datum/plant_trait/fruit/biolight/red)
	fast_reagents = list(/datum/reagent/teslium = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/mushroom/glowshroom)
