/obj/item/litany
	name = "paper"
	gender = NEUTER
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	item_state = "paper"
	custom_fire_overlay = "paper_onfire_overlay"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound =  'sound/items/handling/paper_pickup.ogg'
	throw_range = 1
	throw_speed = 1
	pressure_resistance = 0
	resistance_flags = FLAMMABLE
	max_integrity = 50
	color = COLOR_WHITE
	///List, in order, of litany components we have
	var/list/litany_components = list()
	///The target we're attached to, since we sit in area contents for objective checks
	var/atom/attach_target

//We can attach this item to 'things' like a sticker
/obj/item/litany/afterattack(atom/movable/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	attach_target = target
	//Move this to the area, for objective checks
	loc = target.contents
	//Visual display stuff
	target.vis_contents += src
	//TODO: Add sticker masking behav - Racc
