/obj/item/litany
	name = "litany"
	gender = NEUTER
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "litany_stamp"
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
	///The max amount of litany components this litany can have
	var/max_components = 4
	///The target we're attached to, since we sit in area contents for objective checks
	var/atom/movable/attach_target

//We can attach this item to 'things', like a sticker
/obj/item/litany/afterattack(atom/movable/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	attach_target = target
	//Move this to the area, for objective checks
	forceMove(target)
	//Visual display stuff
	target.vis_contents += src
	var/list/params = params2list(click_parameters)
	pixel_x = text2num(params["icon-x"])-16
	pixel_y = text2num(params["icon-y"])-16
	layer = ABOVE_ALL_MOB_LAYER
	//TODO: Add sticker masking behav - Racc

/obj/item/litany/attack_hand(mob/living/carbon/user)
	. = ..()
	layer = OBJ_LAYER
	pixel_x = 0
	pixel_y = 0
	attach_target?.vis_contents -= src
	attach_target = null

///Logic for adding litany components & overlays associated with that
/obj/item/litany/proc/add_litany_component(datum/litany_component/LC, override_length = 0)
	litany_components += new LC()
	//Create paper visuals
	cut_overlays()
	var/loop_length = (override_length || length(litany_components)) //Logic in loop params is fucky here
	for(var/i in 1 to loop_length)
		var/mutable_appearance/MA = mutable_appearance('icons/obj/bureaucracy.dmi', "litany_paper")
		MA.pixel_y = (-7 * i) + 7 //Todd_Howard.webp
		add_overlay(MA)
