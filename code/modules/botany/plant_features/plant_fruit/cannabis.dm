//TODO: Sprites - Racc
/*
	Generic Weed
*/
/datum/plant_feature/fruit/cannabis
	species_name = "alta folium"
	name = "cannabis" //All cannabis leafs have the same name, only observant people will tell them apart
	icon_state = "missing"
	fruit_product = /obj/item/food/grown/cannabis
	fast_reagents = list(/datum/reagent/drug/space_drugs = PLANT_REAGENT_MEDIUM, /datum/reagent/toxin/lipolicide = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/*
	Death Weed
*/
/datum/plant_feature/fruit/cannabis/death
	species_name = "mors folium"
	icon_state = "missing"
	fruit_product = /obj/item/food/grown/cannabis/death
	fast_reagents = list(/datum/reagent/drug/space_drugs = PLANT_REAGENT_MEDIUM, /datum/reagent/toxin/lipolicide = PLANT_REAGENT_MEDIUM, /datum/reagent/toxin/cyanide = PLANT_REAGENT_MEDIUM)

/*
	Life Weed
*/
/datum/plant_feature/fruit/cannabis/life
	species_name = "vita folium"
	icon_state = "missing"
	fruit_product = /obj/item/food/grown/cannabis/white
	fast_reagents = list(/datum/reagent/drug/space_drugs = PLANT_REAGENT_MEDIUM, /datum/reagent/toxin/lipolicide = PLANT_REAGENT_MEDIUM, /datum/reagent/medicine/omnizine = PLANT_REAGENT_MEDIUM)

/*
	Rainbow Weed
*/
/datum/plant_feature/fruit/cannabis/rainbow
	species_name = "iris folium"
	icon_state = "missing"
	fruit_product = /obj/item/food/grown/cannabis/rainbow
	fast_reagents = list(/datum/reagent/toxin/mindbreaker = PLANT_REAGENT_MEDIUM, /datum/reagent/toxin/lipolicide = PLANT_REAGENT_MEDIUM)

/*
	Omega Weed
*/
/datum/plant_feature/fruit/cannabis/omega
	species_name = "omega folium"
	icon_state = "missing"
	fruit_product = /obj/item/food/grown/cannabis/ultimate
	fast_reagents = list(/datum/reagent/drug/space_drugs = PLANT_REAGENT_MICRO, /datum/reagent/toxin/mindbreaker = PLANT_REAGENT_MICRO, /datum/reagent/toxin/lipolicide = PLANT_REAGENT_MICRO, /datum/reagent/mercury = PLANT_REAGENT_MICRO,
	/datum/reagent/lithium = PLANT_REAGENT_MICRO, /datum/reagent/medicine/atropine = PLANT_REAGENT_MICRO, /datum/reagent/medicine/haloperidol = PLANT_REAGENT_MICRO, /datum/reagent/drug/methamphetamine = PLANT_REAGENT_MICRO,
	/datum/reagent/consumable/capsaicin = PLANT_REAGENT_MICRO, /datum/reagent/barbers_aid = PLANT_REAGENT_MICRO, /datum/reagent/drug/bath_salts = PLANT_REAGENT_MICRO, /datum/reagent/toxin/itching_powder = PLANT_REAGENT_MICRO,
	/datum/reagent/drug/crank = PLANT_REAGENT_MICRO, /datum/reagent/drug/krokodil = PLANT_REAGENT_MICRO, /datum/reagent/toxin/histamine = PLANT_REAGENT_MICRO)
	total_volume = PLANT_FRUIT_VOLUME_VERY_LARGE
	growth_time = PLANT_FRUIT_GROWTH_SLOW
