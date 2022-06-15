//Tool to move slimes around
/obj/item/slime_gun
	name = "slime gun"
	desc = "It really sucks."
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "slime"
	///Maximum distance a slime can be picked up from
	var/max_distance_input = 6
	///Maximum distance a slime can be placed down from
	var/max_distance_output = 3

/obj/item/slime_gun/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(istype(target, /mob/living/simple_animal/slime_uni) && get_dist(get_turf(src), get_turf(target)) < max_distance_input)
		var/atom/movable/AM = target
		AM.throw_at(get_turf(src), get_dist(get_turf(src), get_turf(target)), 1, force = 0)
		RegisterSignal(AM, COMSIG_MOVABLE_IMPACT, .proc/inhale, AM)
	else if(contents.len && get_dist(get_turf(src), get_turf(target)) < max_distance_output)
		var/atom/movable/AM = contents[contents.len]
		AM.forceMove(get_turf(target))
		if(contents.len && istype(contents[contents.len], /mob/living/simple_animal/slime_uni))
			change_overlay(contents[contents.len])
		else
			cut_overlays()

///move targets inside the gun
/obj/item/slime_gun/proc/inhale(atom/movable/target)
	if(get_dist(get_turf(src), get_turf(target)) <= 1)
		target?.forceMove(src)	
		//set gun overylay to slime texture
		if(istype(target, /mob/living/simple_animal/slime_uni))
			change_overlay(target)


/obj/item/slime_gun/proc/change_overlay(var/mob/living/simple_animal/slime_uni/slime)
	cut_overlays()
	var/icon/overlay = new(slime.animated_texture)
	var/icon/mask = new('icons/obj/guns/energy.dmi', "slime_overlay")
	overlay.AddAlphaMask(mask)
	add_overlay(overlay)

//debug
/obj/item/slime_wand
	name = "slime wand"
	desc = "slime...NOW!"
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "revivewand"
	var/targets = list()

/obj/item/slime_wand/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(istype(target, /mob/living/simple_animal/slime_uni) && targets < 2)
		targets += target
	//else if(targets >= 2)
		//continue
	else
		new /mob/living/simple_animal/slime_uni/(get_turf(target))
