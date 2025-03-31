/*
	Watermelon
*/
/datum/plant_feature/fruit/watermelon
	icon_state = "apple"
	fruit_product = /obj/item/food/grown/watermelon
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment/large, /datum/plant_trait/reagent/fruit/vitamin/large, /datum/plant_trait/reagent/fruit/water)
	total_volume = PLANT_REAGENT_LARGE
	growth_time = PLANT_FRUIT_GROWTH_SLOW

/*
	Holy Watermelom
*/
/datum/plant_feature/fruit/watermelon/holy
	fruit_product = /obj/item/food/grown/holymelon
	fast_reagents = list(/datum/reagent/water/holywater = PLANT_FRUIT_VOLUME_MEDIUM)


/*
	Ballolon
*/
/datum/plant_feature/fruit/watermelon/ballolon
	fruit_product = /obj/item/food/grown/ballolon
	fast_reagents = list(/datum/reagent/hydrogen = PLANT_FRUIT_VOLUME_MEDIUM, /datum/reagent/oxygen = PLANT_FRUIT_VOLUME_MEDIUM)
