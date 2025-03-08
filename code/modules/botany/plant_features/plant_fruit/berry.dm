//TODO: Consider make different berry types, instead of the generic - Racc
/datum/plant_feature/fruit/berry
	icon_state = "apple"
	fruit_product = /obj/item/food/grown/berries
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)

/datum/plant_feature/fruit/berry/glow
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin, /datum/plant_trait/reagent/fruit/radium/large, /datum/plant_trait/reagent/fruit/iodine/large)
