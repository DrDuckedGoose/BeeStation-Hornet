/obj/machinery/plumbing/tank/plant_tray
	name = "plant tray"
	desc = "A fifth generation space compatible botanical growing tray."
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "tray"
	appearance_flags = TILE_BOUND|PIXEL_SCALE|LONG_GLIDE|KEEP_TOGETHER
	reagent_flags = TRANSPARENT | REFILLABLE
	buffer = 200
	///What kind of substrate do we have?
	var/datum/plant_subtrate/substrate
//Effects
	var/atom/movable/plant_tray_face/face_plate
	var/atom/movable/plant_tray_reagents/tray_reagents
	var/icon/mask

/obj/machinery/plumbing/tank/plant_tray/Initialize(mapload)
	. = ..()
	//TODO: consider making this an element with a 'planting' capacity - Racc
	ADD_TRAIT(src, TRAIT_PLANTER, INNATE_TRAIT)
//Build effects
	//mask for plants
	mask = icon('icons/obj/hydroponics/features/generic.dmi', "tray_mask")
	add_filter("mask", 1, alpha_mask_filter(icon = mask, flags = MASK_INVERSE))
	//Face plate to return click-ability
	face_plate = new(src)
	vis_contents += face_plate
	//Reagents, for reagents
	tray_reagents = new(src)
	vis_contents += tray_reagents
//reagents
	tray_reagents.color = mix_color_from_reagents(reagents.reagent_list)

/obj/machinery/plumbing/tank/plant_tray/examine(mob/user)
	. = ..()
	if(substrate)
		. += "<span class='notice'>[src] is filled with [substrate.name].\n[substrate.tooltip]</span>"
	//TODO: Throw some more tray info in here - Racc

/obj/machinery/plumbing/tank/plant_tray/AltClick(mob/user)
	return ..()

/obj/machinery/plumbing/tank/plant_tray/wrench_act(mob/living/user, obj/item/I)
	..()
	default_unfasten_wrench(user, I)
	return TRUE

/obj/machinery/plumbing/tank/plant_tray/attackby(obj/item/C, mob/user)
	. = ..()
	if(IS_EDIBLE(C) || istype(C, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/reagent_source = C
		if(!reagent_source.reagents.total_volume) //It aint got no gas in it
			to_chat(user, span_notice("[reagent_source] is empty."))
			return TRUE
		//Transfer reagents
		reagent_source.reagents.trans_to(src, reagent_source.amount_per_transfer_from_this, transfered_by = user)
		//Update liquid color
		tray_reagents.color = mix_color_from_reagents(reagents.reagent_list)
		return TRUE

/obj/machinery/plumbing/tank/plant_tray/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	arrived.pixel_y += 8

/obj/machinery/plumbing/tank/plant_tray/Exited(atom/movable/gone, direction)
	. = ..()
	gone.pixel_y -= 8

/obj/machinery/plumbing/tank/plant_tray/proc/set_substrate(_substrate)
	if(substrate)
		underlays -= substrate.substrate_appearance
		QDEL_NULL(substrate)
	substrate = new _substrate(src)
	underlays += substrate.substrate_appearance

//Plant tray's face
/atom/movable/plant_tray_face
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "tray_face"
	vis_flags = VIS_INHERIT_ID
	appearance_flags = KEEP_APART

//Reagents overlay
/atom/movable/plant_tray_reagents
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "tray_water"
	vis_flags = VIS_INHERIT_ID | VIS_UNDERLAY
	appearance_flags = KEEP_APART
	layer = BELOW_OBJ_LAYER
	///
	var/mutable_appearance/over_water

/atom/movable/plant_tray_reagents/Initialize(mapload)
	. = ..()
	//
	over_water = mutable_appearance('icons/obj/hydroponics/features/generic.dmi', "tray_water_over", ABOVE_OBJ_LAYER)
	add_overlay(over_water)
