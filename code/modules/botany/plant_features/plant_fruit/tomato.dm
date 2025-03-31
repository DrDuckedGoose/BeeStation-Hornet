//TODO: Sprites - Racc
/*
	Tomato
	Generic small fruit type
*/
/datum/plant_feature/fruit/tomato
	icon_state = "tomato"
	fruit_product = /obj/item/food/grown/tomato
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin,
	/datum/plant_trait/fruit/liquid_contents)
	total_volume = PLANT_REAGENT_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/*
	Blood Tomato
*/
/datum/plant_feature/fruit/tomato/blood
	icon_state = "tomato" //TODO: - Racc
	fruit_product = /obj/item/food/grown/tomato/blood
	fast_reagents = list(/datum/reagent/blood = PLANT_FRUIT_VOLUME_MEDIUM)

/*
	Killer Tomato
*/
/datum/plant_feature/fruit/tomato/killer
	icon_state = "tomato" //TODO: - Racc
	fruit_product = /obj/item/food/grown/tomato/killer
