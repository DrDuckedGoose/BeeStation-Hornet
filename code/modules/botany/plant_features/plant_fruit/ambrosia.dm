/*
	Ambrosia Vulgaris
*/
/datum/plant_feature/fruit/ambrosia
	species_name = "folium viride"
	name = "ambrosia vulgaris"
	icon_state = "apple" //TODO: - Racc
	fruit_product = /obj/item/food/grown/ambrosia
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/medicine/bicaridine = PLANT_REAGENT_SMALL, /datum/reagent/medicine/kelotane = PLANT_REAGENT_SMALL, /datum/reagent/drug/space_drugs = PLANT_REAGENT_SMALL, /datum/reagent/toxin = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/ambrosia/deus)

/*
	Ambrosia Deus
*/
/datum/plant_feature/fruit/ambrosia/deus
	species_name = "folium caeruleum"
	name = "ambrosia deus"
	icon_state = "apple" //TODO: - Racc
	fruit_product = /obj/item/food/grown/ambrosia/deus
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/medicine/synaptizine = PLANT_REAGENT_SMALL, /datum/reagent/medicine/omnizine = PLANT_REAGENT_SMALL, /datum/reagent/drug/space_drugs = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/ambrosia/gaia)

/*
	Ambrosia Vulgaris
*/
/datum/plant_feature/fruit/ambrosia/gaia
	species_name = "folium aurum"
	name = "ambrosia gaia"
	icon_state = "apple" //TODO: - Racc
	fruit_product = /obj/item/food/grown/ambrosia/gaia
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/medicine/earthsblood = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/ambrosia)
