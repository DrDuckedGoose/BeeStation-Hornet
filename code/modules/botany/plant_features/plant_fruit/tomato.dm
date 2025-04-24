//TODO: Sprites - Racc
/*
	Tomato
	Generic small fruit type that grows fast
*/
/datum/plant_feature/fruit/tomato
	species_name = "lycopersicum solanum"
	name = "tomato"
	icon_state = "tomato"
	fruit_product = /obj/item/food/grown/tomato
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin,
	/datum/plant_trait/fruit/liquid_contents)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/tomato/blood, /datum/plant_feature/fruit/tomato/blue)

/*
	Blue Tomato
*/
/datum/plant_feature/fruit/tomato/blue
	species_name = "lycopersicum caeruleum"
	name = "blue tomato"
	icon_state = "tomato" //TODO: - Racc
	fruit_product = /obj/item/food/grown/tomato/blue
	fast_reagents = list(/datum/reagent/lube = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/tomato/bluespace)

/*
	BlueSpace Tomato
*/
/datum/plant_feature/fruit/tomato/bluespace
	species_name = "lycopersicum caeruleum cerritulus"
	name = "bluespace tomato"
	icon_state = "tomato" //TODO: - Racc
	fruit_product = /obj/item/food/grown/tomato/blue/bluespace
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin,
	/datum/plant_trait/fruit/liquid_contents, /datum/plant_trait/fruit/bluespace)
	fast_reagents = list(/datum/reagent/bluespace = PLANT_REAGENT_SMALL)
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	mutations = list(/datum/plant_feature/fruit/tomato)

/*
	Blood Tomato
*/
/datum/plant_feature/fruit/tomato/blood
	species_name = "lycopersicum sanguis"
	name = "blood tomato"
	icon_state = "tomato" //TODO: - Racc
	fruit_product = /obj/item/food/grown/tomato/blood
	fast_reagents = list(/datum/reagent/blood = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/tomato/killer)

/*
	Killer Tomato
*/
/datum/plant_feature/fruit/tomato/killer
	species_name = "lycopersicum rabidus"
	name = "killer tomato"
	icon_state = "tomato" //TODO: - Racc
	fruit_product = /obj/item/food/grown/tomato/killer
	mutations = list(/datum/plant_feature/fruit/tomato)
	//TODO: Make this a trait, living fruit - Racc
