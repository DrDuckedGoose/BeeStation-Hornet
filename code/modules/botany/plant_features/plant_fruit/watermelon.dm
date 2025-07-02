/*
	Watermelon
*/
/datum/plant_feature/fruit/watermelon
	species_name = "pepo magna"
	name = "watermelon"
	icon_state = "watermelon"
	fruit_product = /obj/item/food/grown/watermelon
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment/large, /datum/plant_trait/reagent/fruit/vitamin/large)
	fast_reagents = list(/datum/reagent/water = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_LARGE
	growth_time = PLANT_FRUIT_GROWTH_SLOW
	mutations = list(/datum/plant_feature/fruit/watermelon/ballolon)

/*
	Holy Watermelom
*/
/datum/plant_feature/fruit/watermelon/holy
	species_name = "pepo sanctus"
	name = "holy watermelon"
	icon_state = "watermelon-2"
	colour_override = "#ff0"
	fruit_product = /obj/item/food/grown/holymelon
	plant_traits = list(/datum/plant_trait/fruit/biolight) //TODO: Relevant colour - Racc
	fast_reagents = list(/datum/reagent/water/holywater = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/watermelon)


/*
	Ballolon
*/
/datum/plant_feature/fruit/watermelon/ballolon
	species_name = "pepo volare"
	name = "ballolon"
	icon_state = "watermelon-2"
	colour_override = "#ff0048"
	fruit_product = /obj/item/food/grown/ballolon
	plant_traits = list(/datum/plant_trait/fruit/gaseous)
	fast_reagents = list(/datum/reagent/hydrogen = PLANT_REAGENT_MEDIUM, /datum/reagent/oxygen = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/watermelon/holy)
