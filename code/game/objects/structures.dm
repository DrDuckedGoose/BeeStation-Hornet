/// Inert structures, such as girders, machine frames, and crates/lockers.
/obj/structure
	icon = 'icons/obj/structures.dmi'
	pressure_resistance = 8
	max_integrity = 300
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT
	layer = BELOW_OBJ_LAYER
	flags_ricochet = RICOCHET_HARD
	ricochet_chance_mod = 0.5
	pass_flags_self = PASSSTRUCTURE
	var/broken = FALSE
	armor_type = /datum/armor/obj_structure

/datum/armor/obj_structure
	fire = 50
	acid = 50

/obj/structure/Initialize(mapload)
	. = ..()
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH(src)
		QUEUE_SMOOTH_NEIGHBORS(src)
		icon_state = ""
	GLOB.cameranet.updateVisibility(src)

/obj/structure/Destroy()
	GLOB.cameranet.updateVisibility(src)
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH_NEIGHBORS(src)
	var/turf/current_turf = loc
	. = ..()
	// Attempt zfalling for anything standing on this structure
	if(!isopenspace(current_turf))
		return
	for(var/atom/movable/A in current_turf)
		current_turf.try_start_zFall(A)

/obj/structure/ui_act(action, params)
	. = ..()
	add_fingerprint(usr)

/obj/structure/examine(mob/user)
	. = ..()
	if(!(resistance_flags & INDESTRUCTIBLE))
		if(resistance_flags & ON_FIRE)
			. += span_warning("It's on fire!")
		if(broken)
			. += span_notice("It appears to be broken.")
		var/examine_status = examine_status(user)
		if(examine_status)
			. += examine_status

/obj/structure/proc/examine_status(mob/user) //An overridable proc, mostly for falsewalls.
	var/healthpercent = (atom_integrity/max_integrity) * 100
	switch(healthpercent)
		if(50 to 99)
			return  "It looks slightly damaged."
		if(25 to 50)
			return  "It appears heavily damaged."
		if(0 to 25)
			if(!broken)
				return  span_warning("It's falling apart!")

/obj/structure/examine_descriptor(mob/user)
	return "structure"

/obj/structure/rust_heretic_act()
	take_damage(500, BRUTE, MELEE, 1)
	return TRUE
