/obj/item/plant_tray
	name = "plant tray"
	desc = "A fifth generation space compatible botanical growing tray."
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "tray"
	appearance_flags = TILE_BOUND|PIXEL_SCALE|LONG_GLIDE|KEEP_TOGETHER
	density = TRUE
	interaction_flags_item = NONE
	layer = OBJ_LAYER
	///Reagents volume
	var/buffer = 200
	///Do we want the plumbing shit?
	var/plumbing = TRUE
	///Tray component
	var/datum/component/planter/tray_component
//Effects
	var/atom/movable/plant_tray_reagents/tray_reagents
	var/icon/mask
//Tray indicators
	var/use_indicators = TRUE
	///Indicator for when the plant is ready to harvest
	var/obj/effect/tray_indicator/harvest
	var/list/harvestable_components = list()
	//Indicator for when the plant's needs are not met
	var/obj/effect/tray_indicator/need
	var/list/needy_features = list()
	//Indicator for when the plant has 'problem'
	var/obj/effect/tray_indicator/problem
	var/list/problem_features = list()

/obj/item/plant_tray/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	create_reagents(buffer, TRANSPARENT | REFILLABLE)
	if(plumbing)
		AddComponent(/datum/component/plumbing/tank, FALSE)
		AddComponent(/datum/component/simple_rotation)
//Tray component setup
	tray_component = AddComponent(/datum/component/planter, 12)
	RegisterSignal(tray_component, COMSIG_PLANTER_UPDATE_SUBSTRATE_SETUP, PROC_REF(remove_substrate))
	RegisterSignal(tray_component, COMSIG_PLANTER_UPDATE_SUBSTRATE, PROC_REF(add_substrate))
//Build effects
	//mask for plants
	mask = icon('icons/obj/hydroponics/features/generic.dmi', "[icon_state]_mask")
	//Reagents, for reagents
	tray_reagents = new(src, icon_state, layer)
	vis_contents += tray_reagents
	//Bottom most underlay
	underlays += mutable_appearance('icons/obj/hydroponics/features/generic.dmi', "[icon_state]_bottom", layer-0.1)
//reagents
	tray_reagents.color = mix_color_from_reagents(reagents.reagent_list)
//Build tray indicatos
	if(!use_indicators)
		return
	harvest = new(src, "#0f0", 1)
	need = new(src, "#ff9100", 2)
	problem = new(src, "#f00", 3)

/obj/item/plant_tray/process(delta_time)
	//Need to update this semi-constantly so it works with plumbing
	update_reagents()
	//Problems
	SEND_SIGNAL(src, COMSIG_PLANT_NEEDS_PAUSE, null, problem_features)
	if(length(problem_features))
		vis_contents |= problem

/obj/item/plant_tray/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	//Quick feedback
	update_reagents()

//When a plant is inserted / planted
/obj/item/plant_tray/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	var/datum/component/plant/plant_component = arrived.GetComponent(/datum/component/plant)
//Start listening to component for signals, for indicators
	//Harvest
	RegisterSignal(plant_component, COMSIG_FRUIT_BUILT, PROC_REF(catch_plant_harvest_ready))
	RegisterSignal(plant_component, COMSIG_PLANT_ACTION_HARVEST, PROC_REF(catch_plant_harvest_collected))
	//Needs
	RegisterSignal(plant_component, COMSIG_PLANT_NEEDS_FAILS, PROC_REF(catch_plant_need_fail))
	RegisterSignal(plant_component, COMSIG_PLANT_NEEDS_PASS, PROC_REF(catch_plant_need_pass))
//Visuals
	//Masking
	if(plant_component?.draw_below_water)
		arrived.add_filter("plant_tray_mask", 1, alpha_mask_filter(y = -12, icon = mask, flags = MASK_INVERSE))

//When a plant is uprooted / ceases to exist
/obj/item/plant_tray/Exited(atom/movable/gone, direction)
	. = ..()
//Visuals
	//Remove visuals from previous step
	gone.remove_filter("plant_tray_mask")
	vis_contents -= gone//Do this here because plants don't clean up for themselves
//Component related
	var/datum/component/plant/plant_component = gone.GetComponent(/datum/component/plant)
	if(!plant_component)
		return
	UnregisterSignal(plant_component, COMSIG_FRUIT_BUILT)
	UnregisterSignal(plant_component, COMSIG_PLANT_ACTION_HARVEST)
	UnregisterSignal(plant_component, COMSIG_PLANT_NEEDS_FAILS)
	UnregisterSignal(plant_component, COMSIG_PLANT_NEEDS_PASS)
//Indicators
	//Harvest light
	harvestable_components -= plant_component
	if(!length(harvestable_components))
		vis_contents -= harvest
	//Need light
	for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
		needy_features -= feature
	if(!length(needy_features))
		vis_contents -= need
	//Problem light
	for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
		problem_features -= feature
	if(!length(problem_features))
		vis_contents -= problem

///Helpers to handle substrate vvisuals
/obj/item/plant_tray/proc/add_substrate(_substrate)
	var/datum/plant_subtrate/substrate = tray_component.substrate
	underlays += substrate.substrate_appearance

/obj/item/plant_tray/proc/remove_substrate(_substrate)
	underlays -= tray_component.substrate?.substrate_appearance

/*
	Signal handlers for plant harvest
*/

/obj/item/plant_tray/proc/catch_plant_harvest_ready(datum/source)
	SIGNAL_HANDLER

	harvestable_components |= source
	vis_contents |= harvest

/obj/item/plant_tray/proc/catch_plant_harvest_collected(datum/source)
	SIGNAL_HANDLER

	harvestable_components -= source
	if(!length(harvestable_components))
		vis_contents -= harvest

/*
	Signal handlers for plant needs
*/

/obj/item/plant_tray/proc/catch_plant_need_fail(datum/source, datum/plant_feature/_needy)
	SIGNAL_HANDLER

	needy_features |= _needy
	vis_contents |= need

/obj/item/plant_tray/proc/catch_plant_need_pass(datum/source, datum/plant_feature/_passy)
	SIGNAL_HANDLER

	needy_features -= _passy
	if(!length(needy_features))
		vis_contents -= need

/obj/item/plant_tray/proc/update_reagents()
	tray_reagents.color = mix_color_from_reagents(reagents.reagent_list)
	if(reagents.total_volume <= 0)
		tray_reagents.color ="#0000"

/*
	Some effects live down here
		- Water overlay
*/

//Reagents overlay
/atom/movable/plant_tray_reagents
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "tray_water"
	vis_flags = VIS_INHERIT_ID
	appearance_flags = KEEP_APART
	layer = BELOW_OBJ_LAYER
	color = "#fff0"
	///Water rendered over the plant
	var/mutable_appearance/over_water

/atom/movable/plant_tray_reagents/Initialize(mapload, key = "tray", layer_override)
	. = ..()
	icon_state = "[key]_water"
	layer = layer_override
	over_water = mutable_appearance('icons/obj/hydroponics/features/generic.dmi', "[key]_water_over", layer_override+0.1)
	add_overlay(over_water)
