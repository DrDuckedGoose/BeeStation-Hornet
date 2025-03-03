/*
	The plant component is basically a central hub for plant features to send signals from
	The majority of implementation should happen in the plant feature datums
*/

#define COMSIG_PLANT_ACTION_HARVEST "COMSIG_PLANT_ACTION_HARVEST"

#define COMSIG_PLANT_REQUEST_FRUIT "COMSIG_PLANT_REQUEST_FRUIT"

#define COMSIG_PLANT_REQUEST_REAGENTS "COMSIG_PLANT_REQUEST_REAGENTS"

/datum/component/plant
	///The object acting as our plant
	var/obj/item/plant_item

	///Our plant features
	var/list/plant_features = list(/datum/plant_feature/body, /datum/plant_feature/fruit, /datum/plant_feature/roots)

//Appearnace
	var/use_body_appearance = TRUE

/datum/component/plant/Initialize(obj/item/_plant_item, list/_plant_features)
	. = ..()
	plant_item = _plant_item
//Plant features
	plant_features = _plant_features || plant_features
	for(var/feature as anything in plant_features)
		plant_features -= feature
		plant_features += new feature(src)
