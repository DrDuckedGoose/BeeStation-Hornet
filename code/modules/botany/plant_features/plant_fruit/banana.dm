//TODO: Sprites - Racc
/*
	Banana
*/
/datum/plant_feature/fruit/banana
	species_name = "lycopersicum solanum"
	name = "banana"
	icon_state = "banana" //TODO: Implement bunches - Racc
	fruit_product = /obj/item/food/grown/banana
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin/large,
	/datum/plant_trait/fruit/slippery)
	fast_reagents = list(/datum/reagent/consumable/banana = PLANT_REAGENT_MEDIUM, /datum/reagent/potassium = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/banana/mime, /datum/plant_feature/fruit/banana/bluespace)

/*
	Mimana
*/
/datum/plant_feature/fruit/banana/mime
	species_name = "lycopersicum mimum"
	name = "mimana"
	icon_state = "banana" //TODO: - Racc
	fruit_product = /obj/item/food/grown/banana/mime
	fast_reagents = list(/datum/reagent/consumable/nothing = PLANT_REAGENT_MEDIUM, /datum/reagent/toxin/mutetoxin = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/banana)

/*
	Bluespace Banana
*/
/datum/plant_feature/fruit/banana/bluespace
	species_name = "lycopersicum fatum"
	name = "bluespace banana"
	icon_state = "banana" //TODO: - Racc
	fruit_product = /obj/item/food/grown/banana/bluespace
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin/large,
	/datum/plant_trait/fruit/slippery, /datum/plant_trait/fruit/bluespace)
	fast_reagents = list(/datum/reagent/bluespace = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/banana)

/*
	Test banana
	TODO: Remove this - Racc
*/
/datum/plant_feature/fruit/banana/test
	total_volume = PLANT_FRUIT_VOLUME_VERY_LARGE
	plant_traits = list(/datum/plant_trait/fruit/slippery, /datum/plant_trait/seperated_contents, /datum/plant_trait/fruit/liquid_contents/sensitive)
	fast_reagents = list(/datum/reagent/water = PLANT_REAGENT_MEDIUM, /datum/reagent/potassium = PLANT_REAGENT_MEDIUM)

//Banana
/obj/item/plant_seeds/preset/banana/test
	name = "banana seeds"
	name_override = "banana tree"
	plant_features = list(/datum/plant_feature/roots/sand, /datum/plant_feature/body/tree/palm, /datum/plant_feature/fruit/banana/test)
