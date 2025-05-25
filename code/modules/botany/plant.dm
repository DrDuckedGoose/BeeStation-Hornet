/*
	The plant component is basically a central hub for plant features to send signals from
	The majority of implementation should happen in the plant feature datums
*/

/datum/component/plant
	///The object acting as our plant
	var/obj/item/plant_item
	///Species ID, used for stuff like book keeping
	var/species_id
	///Our plant feature limits - this can typically be improved by traits
	//TODO: Implement this - Racc
	var/list/plant_feature_limits = list()
	///Our plant features
	var/list/plant_features = list(/datum/plant_feature/body, /datum/plant_feature/fruit, /datum/plant_feature/roots)

//Appearnace
	var/use_body_appearance = TRUE

/datum/component/plant/Initialize(obj/item/_plant_item, list/_plant_features, _species_id)
	. = ..()
	plant_item = _plant_item
//Species ID setup
	if(!_species_id)
		compile_species_id()
	else
		species_id = _species_id
//Plant features
	plant_features = _plant_features?.Copy() || plant_features
	for(var/datum/plant_feature/feature as anything in plant_features)
		plant_features -= feature
		if(ispath(feature))
			plant_features += new feature(src)
		else
			plant_features += feature
			feature.setup_parent(src)
//Add discoverable component for discovering this discoverable discovery
	plant_item.AddComponent(/datum/component/discoverable/plant, 500) //TODO: Consider making this variable / sane - Racc

/datum/component/plant/Destroy(force, silent)
	. = ..()
	for(var/feature as anything in plant_features)
		qdel(feature)

//Set a new species ID
/datum/component/plant/proc/compile_species_id()
	var/new_species_id = "[get_species_id()]"
	if(new_species_id in SSbotany.plant_species)
		return FALSE
	SSbotany.plant_species |= new_species_id
	species_id = new_species_id
	return TRUE

//Formatted like "[feature](trait-types)-[feature](trait-types)-[feature](trait-types)"
//Use this to generate a species ID based on our feature's and their traits
/datum/component/plant/proc/get_species_id()
	var/new_species_id = ""
	for(var/datum/plant_feature/feature as anything in plant_features)
		var/traits = ""
		for(var/datum/plant_trait/trait as anything in feature.plant_traits)
			traits = "[traits]-[trait?.get_id()]"
		new_species_id = "[new_species_id][feature?.species_name]-([traits])-"
	return new_species_id
