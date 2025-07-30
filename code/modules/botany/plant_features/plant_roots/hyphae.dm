/datum/plant_feature/roots/hyphae
	species_name = "test" //TODO: - Racc
	name = "hyphae"
	compatible_substrate = PLANT_SUBSTRATE_DIRT | PLANT_SUBSTRATE_SAND |  PLANT_SUBSTRATE_CLAY | PLANT_SUBSTRATE_DEBRIS
	plant_traits = list(/datum/plant_trait/roots/strangling)
	//We can pair with only mushroom traits
	whitelist_features = list(/datum/plant_feature/fruit/mushroom, /datum/plant_feature/body/mushroom)
