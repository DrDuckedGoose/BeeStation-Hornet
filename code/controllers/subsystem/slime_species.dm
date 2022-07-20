//todo: load database into slime_species roundstart
///Slime species data container for slime species subsystem
/datum/slime_species
	///Species name
	var/name = ""
	///List of visual features
	var/list/features = list("texture" = null, "texture_path" = "", "mask" = null, "mask_path" = null, "sub_mask" = null, "color" = null, "color_path" = null, "sub_color" = null, "exotic_color" = null, "speed" = null, "direction" = null, "rotation" = null)
	///List of physical mutations
	var/list/traits = list()

SUBSYSTEM_DEF(slime_species)
	name = "slime Species"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_ACHIEVEMENTS
	///If enabled, species this round will be saved to the database
	var/save_round_end = TRUE
	///List of all player logged species
	var/list/datum/slime_species = list()
	///List of every species, ever...
	var/list/datum/slime_species_all = list()
	///Cached icons for slime species
	var/list/cached_icons = list()

/datum/controller/subsystem/slime_species/Initialize(timeofday)
	. = ..()
	if(!SSdbcore.Connect())
		return

/datum/controller/subsystem/slime_species/Shutdown()
	if(slime_species.len) //save any appended species to the database
		save_species_to_db()

///Insert new slime species into slime_species list
/datum/controller/subsystem/slime_species/proc/append_species(var/mob/living/simple_animal/slime_uni/S, checking = FALSE, add_to_discovered = TRUE)
	if(S && !slime_species[S?.species_name])
		if(!checking)
			var/datum/slime_species/SP = new()
			SP.name = S.species_name
			SP.features = S.dna.features
			SP.traits = S.dna.traits
			if(add_to_discovered)
				slime_species[S.species_name] = SP
			slime_species_all[S.species_name] = SP
		return TRUE //Sucessfully added new species
	else
		return FALSE //Failed to add species, usually means it already exists

///Save new slime species to database
/datum/controller/subsystem/slime_species/proc/save_species_to_db()
	if(!save_round_end)
		return
	var/list/species_to_save = list()
	for(var/datum/slime_species/S in slime_species)
		species_to_save += S
	SSdbcore.MassInsert(format_table_name("slime_species"),species_to_save,duplicate_key = TRUE)
