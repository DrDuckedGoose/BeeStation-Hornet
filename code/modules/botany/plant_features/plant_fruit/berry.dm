//TODO: Consider make different berry types, instead of the generic - Racc
//TODO: Blueberry, raspberry, whatever - Racc
//TODO: Sprites - Racc
/*
	Berry
	Micro fruit type that grows very fast
*/
/datum/plant_feature/fruit/berry
	species_name = "bacca clara"
	name = "berry"
	icon_state = "berry"
	fruit_product = /obj/item/food/grown/berries
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	colour_override = "#ff0037"
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_VERY_FAST
	mutations = list(/datum/plant_feature/fruit/berry/glow)

/*
	Glow Berry
*/
/datum/plant_feature/fruit/berry/glow
	species_name = "bacca rutilans"
	name = "glow berry"
	fruit_product = /obj/item/food/grown/berries/glow
	fast_reagents = list(/datum/reagent/uranium/radium = PLANT_REAGENT_MEDIUM, /datum/reagent/iodine = PLANT_REAGENT_MEDIUM)
	colour_override = "#a6ff00"
	mutations = list(/datum/plant_feature/fruit/berry/poison)

/*
	Poison Berry
*/
/datum/plant_feature/fruit/berry/poison
	species_name = "bacca venenum"
	name = "poison berry"
	fruit_product = /obj/item/food/grown/berries/poison
	fast_reagents = list(/datum/reagent/toxin/cyanide = PLANT_REAGENT_MEDIUM, /datum/reagent/toxin/staminatoxin = PLANT_REAGENT_MEDIUM)
	colour_override = "#0dff00"
	mutations = list(/datum/plant_feature/fruit/berry/death)

/*
	Poison Berry
*/
/datum/plant_feature/fruit/berry/death
	species_name = "bacca mortem"
	name = "poison berry"
	fruit_product = /obj/item/food/grown/berries/poison
	fast_reagents = list(/datum/reagent/toxin/coniine = PLANT_REAGENT_SMALL, /datum/reagent/toxin/staminatoxin = PLANT_REAGENT_MEDIUM)
	colour_override = "#0dff00"
	mutations = list(/datum/plant_feature/fruit/berry)
