SUBSYSTEM_DEF(botany)
	name = "Botany"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_BOTANY

	///list of plant species - This is used for the discovery component
	var/list/plant_species = list()
	///List of discovered plant species
	var/list/discovered_species = list()
	///List of plant seed tiers, and their seed contents
	var/list/seed_tiers = list()

/datum/controller/subsystem/botany/Initialize(timeofday)
	//build plant seed tiers
	var/list/preset_seeds = subtypesof(/obj/item/plant_seeds/preset)
	for(var/obj/item/plant_seeds/preset/seed as anything in preset_seeds)
		var/tier = initial(seed.tier)
		if(!seed_tiers["[tier]"])
			seed_tiers["[tier]"] = list()
		seed_tiers["[tier]"] += seed
