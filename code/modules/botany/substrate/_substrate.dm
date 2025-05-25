/*
	Plant substrate, the stuff you plant plants in. Stuff like dirt.
	This has various effects
	TODO: Develop this into an actual idea - Racc
*/
/datum/plant_subtrate
	var/name = "generic substrate"
	var/tooltip = "It has no special effects!"
	///What kinds of substrate is this substrate
	var/substrate_flags = PLANT_SUBSTRATE_DIRT | PLANT_SUBSTRATE_SAND |  PLANT_SUBSTRATE_CLAY | PLANT_SUBSTRATE_DEBRIS
