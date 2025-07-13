/obj/machinery/plumbing/tank/plant_tray
	name = "plant tray"
	desc = "A fifth generation space compatible botanical growing tray."
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "tray"
	appearance_flags = TILE_BOUND|PIXEL_SCALE|LONG_GLIDE|KEEP_TOGETHER
	reagent_flags = TRANSPARENT | REFILLABLE
	buffer = 200
	///How many available slots do we have for plants
	var/plant_slots = PLANT_BODY_SLOT_SIZE_LARGE
	///What kind of substrate do we have?
	var/datum/plant_subtrate/substrate
//Effects
	var/atom/movable/plant_tray_reagents/tray_reagents
	var/icon/mask
//Tray indicators
	///Indicator for when the plant is ready to harvest
	var/obj/effect/tray_indicator/harvest
	//Indicator for when the plant's needs are not met
	var/obj/effect/tray_indicator/need
	var/list/needy_features = list()
	//Indicator for when the plant has 'problem'
	var/obj/effect/tray_indicator/problem

/obj/machinery/plumbing/tank/plant_tray/Initialize(mapload)
	. = ..()
	//TODO: consider making this an element with a 'planting' capacity - Racc
	ADD_TRAIT(src, TRAIT_PLANTER, INNATE_TRAIT)
//Build effects
	//mask for plants
	mask = icon('icons/obj/hydroponics/features/generic.dmi', "tray_mask")
	//Reagents, for reagents
	tray_reagents = new(src)
	vis_contents += tray_reagents
	//Bottom most underlay
	underlays += mutable_appearance('icons/obj/hydroponics/features/generic.dmi', "tray-bottom", ABOVE_NORMAL_TURF_LAYER)
//Build tray indicatos
	harvest = new(src, "plant harvest indicator", "#0f0", 1)
	need = new(src, "plant need indicator", "#ff0", 2)
	problem = new(src, "plant problem indicator", "#f00", 3)
//reagents
	tray_reagents.color = mix_color_from_reagents(reagents.reagent_list)

/obj/machinery/plumbing/tank/plant_tray/examine(mob/user)
	. = ..()
	if(substrate)
		. += "<span class='notice'>[src] is filled with [substrate.name].\n[substrate.tooltip]</span>"

/*
/obj/machinery/plumbing/tank/plant_tray/wrench_act(mob/living/user, obj/item/I)
	..()
	default_unfasten_wrench(user, I)
	return TRUE
*/

/obj/machinery/plumbing/tank/plant_tray/attackby(obj/item/C, mob/user)
	. = ..()
	if(!IS_EDIBLE(C) && !istype(C, /obj/item/reagent_containers))
		return
	//Let people fill trays with reagents by hand
	var/obj/item/reagent_containers/reagent_source = C
	if(!reagent_source.reagents.total_volume) //It aint got no gas in it
		to_chat(user, span_warning("[reagent_source] is empty!"))
		return TRUE
	//Transfer reagents
	reagent_source.reagents.trans_to(src, reagent_source.amount_per_transfer_from_this, transfered_by = user)
	//Update liquid color
	//TODO: need a better way to do this, so it updates with plumbing too - Racc
	tray_reagents.color = mix_color_from_reagents(reagents.reagent_list)
	return TRUE

//When a plant is inserted / planted
/obj/machinery/plumbing/tank/plant_tray/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
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
	//Add visuals, move the plant upwards to make it look like it's inside us
	arrived.pixel_y += 12
	//Masking
	if(!plant_component)
		return
	if(plant_component.draw_below_water)
		arrived.add_filter("plant_tray_mask", 1, alpha_mask_filter(y = -12, icon = mask, flags = MASK_INVERSE))

//When a plant is uprooted / ceases to exist
/obj/machinery/plumbing/tank/plant_tray/Exited(atom/movable/gone, direction)
	. = ..()
//Visuals
	//Remove visuals from previous step
	gone.pixel_y -= 12
	gone.remove_filter("plant_tray_mask")

///Helper to set out substrate
/obj/machinery/plumbing/tank/plant_tray/proc/set_substrate(_substrate)
	if(substrate)
		underlays -= substrate.substrate_appearance
		QDEL_NULL(substrate)
	substrate = new _substrate(src)
	underlays += substrate.substrate_appearance

/*
	Signal handlers for plant harvest
*/

/obj/machinery/plumbing/tank/plant_tray/proc/catch_plant_harvest_ready(datum/source)
	SIGNAL_HANDLER

	vis_contents |= harvest

/obj/machinery/plumbing/tank/plant_tray/proc/catch_plant_harvest_collected(datum/source)
	SIGNAL_HANDLER

	vis_contents -= harvest

/*
	Signal handlers for plant needs
*/

/obj/machinery/plumbing/tank/plant_tray/proc/catch_plant_need_fail(datum/source, datum/plant_feature/_needy)
	SIGNAL_HANDLER

	needy_features |= _needy
	vis_contents |= need

/obj/machinery/plumbing/tank/plant_tray/proc/catch_plant_need_pass(datum/source, datum/plant_feature/_passy)
	SIGNAL_HANDLER

	needy_features -= _passy
	if(!length(needy_features))
		vis_contents -= need

/*
	Signal handlers for plant problems
*/
//TODO: - Racc

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
	///
	var/mutable_appearance/over_water

/atom/movable/plant_tray_reagents/Initialize(mapload)
	. = ..()
	//
	over_water = mutable_appearance('icons/obj/hydroponics/features/generic.dmi', "tray_water_over", ABOVE_OBJ_LAYER)
	add_overlay(over_water)
