#define PLANT_REAGENT_SMALL 15
#define PLANT_REAGENT_MEDIUM 25
#define PLANT_REAGENT_LARGE 45
#define PLANT_REAGENT_EXTRA 75

/datum/plant_trait/reagent/fruit
	plant_feature_compat = /datum/plant_feature/fruit

//Blood
/datum/plant_trait/reagent/fruit/blood
	reagent = /datum/reagent/blood
	volume_percentage = PLANT_REAGENT_MEDIUM

//Nutriment
/datum/plant_trait/reagent/fruit/nutriment
	reagent = /datum/reagent/consumable/nutriment
	volume_percentage = PLANT_REAGENT_MEDIUM

/datum/plant_trait/reagent/fruit/nutriment/large
	volume_percentage = PLANT_REAGENT_LARGE

//Vitamin
/datum/plant_trait/reagent/fruit/vitamin
	reagent = /datum/reagent/consumable/nutriment/vitamin
	volume_percentage = PLANT_REAGENT_SMALL

/datum/plant_trait/reagent/fruit/vitamin/large
	volume_percentage = PLANT_REAGENT_MEDIUM

//Water
/datum/plant_trait/reagent/fruit/water
	reagent = /datum/reagent/water
	volume_percentage = PLANT_REAGENT_MEDIUM

//Coffee Powder
/datum/plant_trait/reagent/fruit/coffee_powder
	reagent = /datum/reagent/toxin/coffeepowder
	volume_percentage = PLANT_REAGENT_MEDIUM

//Ephedrine
/datum/plant_trait/reagent/fruit/ephedrine
	reagent = /datum/reagent/medicine/ephedrine
	volume_percentage = PLANT_REAGENT_MEDIUM

//Hydrogen
/datum/plant_trait/reagent/fruit/hydrogen
	reagent = /datum/reagent/hydrogen
	volume_percentage = PLANT_REAGENT_SMALL

/datum/plant_trait/reagent/fruit/hydrogen/large
	volume_percentage = PLANT_REAGENT_MEDIUM

//Oxygen
/datum/plant_trait/reagent/fruit/oxygen
	reagent = /datum/reagent/oxygen
	volume_percentage = PLANT_REAGENT_SMALL

/datum/plant_trait/reagent/fruit/oxygen/large
	volume_percentage = PLANT_REAGENT_MEDIUM

//Radium
/datum/plant_trait/reagent/fruit/radium
	reagent = /datum/reagent/uranium/radium
	volume_percentage = PLANT_REAGENT_SMALL

/datum/plant_trait/reagent/fruit/radium/large
	volume_percentage = PLANT_REAGENT_MEDIUM

//Iodine
/datum/plant_trait/reagent/fruit/iodine
	reagent = /datum/reagent/iodine
	volume_percentage = PLANT_REAGENT_SMALL

/datum/plant_trait/reagent/fruit/iodine/large
	volume_percentage = PLANT_REAGENT_MEDIUM
