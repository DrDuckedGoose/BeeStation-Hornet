///Universal slimes, not University slimes
/mob/living/simple_animal/slime_uni
	name = "slime"
	icon = 'icons/mob/xenobiology/slime.dmi'
	icon_state = "random"
	alpha = 210
	///Slime DNA, contains traits and visual features
	var/datum/slime_dna/dna
	///Icon the actual mob uses, contains animated frames
	var/icon/final_icon

	var/tex_speed = 1
	var/tex_dir = NORTH

/mob/living/simple_animal/slime_uni/Initialize(mapload, var/mob/living/simple_animal/slime_uni/parent)
	. = ..()
	//Setup dna
	dna = (parent ? new(parent?.dna) : new())

	//apply textures, colors, and outlines
	//var/icon/M = new('icons/mob/xenobiology/slime.dmi', "tumor")
	//dna.combine_alpha_masks(list(M))
	setup_texture()
	add_filter("outline", 2, list("type" = "outline", "color" = gradient(dna.features["color"], "#000000ff", 0.56), "size" = 1))
	//add_filter("outline_outer", 3, list("type" = "outline", "color" = dna.features["color"], "size" = 1))

/mob/living/simple_animal/slime_uni/Destroy()
	. = ..()

///Animates texture for final use from dna
/mob/living/simple_animal/slime_uni/proc/setup_texture()
	//typecast to access procs & features
	var/icon/hold = dna.features["texture"]
	final_icon = new(hold)
	final_icon.Insert(hold)
	for(var/i in 2 to 32) //Make adjustments, animaton
		hold.Shift(dna.features["direction"], dna.features["speed"], TRUE) //update texture
		final_icon.Insert(hold, frame=i) //insert frames into icon
	var/icon/alpha_mask = dna.features["mask"] //Alpha mask for cutting out excess
	final_icon.AddAlphaMask(alpha_mask)
	icon = final_icon

///:pensive:
/mob/living/simple_animal/slime_uni/proc/reproduce()
	//todo: consider using max() here
	dna.instability += (XENOB_INSTABILITY_MOD + dna.instability > 100 ? XENOB_INSTABILITY_MOD-(XENOB_INSTABILITY_MOD+dna.instability-100) : XENOB_INSTABILITY_MOD)
	adjustHealth((health < 5 ? health : health * ((20+dna.instability)/100)))
	new /mob/living/simple_animal/slime_uni/(get_step(src, pick(NORTH, SOUTH, EAST, WEST)), src)

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
	if(get_dist(get_turf(src), get_turf(target)) <= 2)
		target?.forceMove(src)	
		//set gun overylay to slime texture
		if(istype(target, /mob/living/simple_animal/slime_uni))
			change_overlay(target)


/obj/item/slime_gun/proc/change_overlay(var/mob/living/simple_animal/slime_uni/slime)
	cut_overlays()
	var/icon/overlay = new(slime.final_icon)
	overlay.Shift(NORTH, 5, TRUE)
	overlay.Shift(EAST, 3, TRUE)
	var/icon/mask = new('icons/obj/guns/energy.dmi', "slime_overlay")
	overlay.AddAlphaMask(mask)
	add_overlay(overlay)

/obj/item/slime_wand
	name = "slime wand"
	desc = "slime...NOW!"
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "revivewand"

/obj/item/slime_wand/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(istype(target, /mob/living/simple_animal/slime_uni))
		var/mob/living/simple_animal/slime_uni/S = target
		S.reproduce()
	else
		new /mob/living/simple_animal/slime_uni/(get_turf(target))
