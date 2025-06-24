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
	///Tray we're in
	var/obj/machinery/plumbing/tank/plant_tray/tray_parent
///The appearance for this substrate, usually a flat texture
	var/icon = 'icons/obj/hydroponics/features/substrate.dmi'
	var/icon_state = "dirt"
	var/mutable_appearance/substrate_appearance

/datum/plant_subtrate/New(_tray)
	. = ..()
	tray_parent = _tray
	substrate_appearance = mutable_appearance(icon, icon_state, LOW_OBJ_LAYER, appearance_flags = KEEP_APART)
