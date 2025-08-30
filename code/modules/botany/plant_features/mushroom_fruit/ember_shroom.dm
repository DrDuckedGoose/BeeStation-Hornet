/*
	Embershroom
*/
/datum/plant_feature/fruit/mushroom/embershroom
	species_name = "calidum sporis"
	name = "embershroom"
	icon_state = "ball"
	colour_overlay = "ball_colour"
	colour_override = "#505050"
	fruit_product = /obj/item/food/grown/ash_flora/mushroom_stem
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	fast_reagents = list(/datum/reagent/consumable/tinlux = PLANT_REAGENT_SMALL, /datum/reagent/drug/space_drugs = PLANT_REAGENT_SMALL)
