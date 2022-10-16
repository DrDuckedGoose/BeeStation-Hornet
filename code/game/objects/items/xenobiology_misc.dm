//Tool to move slimes around
/obj/item/slime_gun
	name = "slime vacuum"
	desc = "It really sucks."
	icon = 'icons/obj/xenobiology.dmi'
	icon_state = "slime_gun"
	///Maximum distance a slime can be picked up from
	var/max_distance_input = 6
	///Maximum distance a slime can be placed down from
	var/max_distance_output = 3
	///Max capacity for how many slimes we can hold
	var/max_capacity = 3

/obj/item/slime_gun/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(istype(target, /mob/living/simple_animal/slime_uni) && get_dist(get_turf(src), get_turf(target)) < max_distance_input && contents.len < max_capacity) //inhale
		var/atom/movable/AM = target
		AM.throw_at(get_turf(src), get_dist(get_turf(src), get_turf(target)), 1, force = MOVE_FORCE_EXTREMELY_WEAK)
		RegisterSignal(AM, COMSIG_MOVABLE_IMPACT, .proc/inhale, AM)
	else if(isturf(target) && contents.len && get_dist(get_turf(src), target) < max_distance_output) //exhale
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
	var/icon/mask = new('icons/obj/xenobiology.dmi', "slime_gun_mask")
	overlay.AddAlphaMask(mask)
	add_overlay(overlay)

//debug
/obj/item/slime_wand
	name = "slime wand"
	desc = "Breed & make slimes."
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "revivewand"
	var/list/targets = list()

/obj/item/slime_wand/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(istype(target, /mob/living/simple_animal/slime_uni) && targets.len < 2)
		targets += target
	else if(targets.len >= 2)
		var/mob/living/simple_animal/slime_uni/O = targets[1]
		var/mob/living/simple_animal/slime_uni/T = targets[2]
		new /mob/living/simple_animal/slime_uni/(get_turf(target), 
		18, //instability
		pick(O?.dna.features["texture_path"], T?.dna.features["texture_path"]),
		pick(O?.dna.features["mask_path"], T?.dna.features["mask_path"]),
		pick(O?.dna.features["sub_mask"], T?.dna.features["sub_mask"]),
		pick(O?.dna.features["color_path"], T?.dna.features["color_path"]),
		pick(O?.dna.features["rotation"], T?.dna.features["rotation"]),
		pick(O?.dna.features["direction"], T?.dna.features["direction"]))
		targets = list()
	else
		new /mob/living/simple_animal/slime_uni(get_turf(target))

/obj/item/cell_sampler
	name = "cell sampler"
	desc = "A device used to collect cell samples from various living animals"
	icon = 'icons/obj/xenobiology.dmi'
	icon_state = "slime_sampler"
	///Taken samples
	var/list/samples = list()
	///Combined samples
	var/list/combined = list()
	///Mask used to create a slime
	var/icon/mask
	///Ref to generated slime
	var/mob/living/simple_animal/slime_uni/held_slime

/obj/item/cell_sampler/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(isliving(target) && proximity_flag && do_after(user, 3 SECONDS, FALSE, target))
		samples += list(icon(target.icon, target.appearance.icon_state))
		to_chat(user, "<span class='notcie'>You take a cell sample  of [target].</span>")

/obj/item/cell_sampler/AltClick(mob/user)
	. = ..()
	to_chat(user, "<span class='warning'>You clear the sample buffer</span>")
	new /obj/effect/decal/cleanable/blood(get_turf(src))
	samples.Cut(1,0)
	combined.Cut(1,0)
	QDEL_NULL(mask)

/obj/item/cell_sampler/interact(mob/user)
	. = ..()
	var/list/commands = list(
		"Preview combination" = image(icon = 'icons/obj/xenobiology.dmi', icon_state = "slime_sampler-make_slime"),
		"Combine samples" = image(icon = 'icons/obj/xenobiology.dmi', icon_state = "slime_sampler-combine_samples"),
		"Select samples" = image(icon = 'icons/obj/xenobiology.dmi', icon_state = "slime_sampler-select_samples"),
		"Clear combination" = image(icon = 'icons/obj/xenobiology.dmi', icon_state = "slime_sampler-clear_combinations"))
	var/choice = show_radial_menu(user, user, commands, tooltips = TRUE)
	switch(choice)
		if("Select samples")
			commands = list()
			for(var/i in 1 to samples.len)
				commands += list("[i]" = samples[i])
			choice = show_radial_menu(user, user, commands)
			combined += list(samples[text2num(choice)])
		if("Combine samples")
			if(!combined.len)
				return
			mask = icon(combined[1])
			for(var/i in 1 to combined.len)
				mask.Blend(combined[i], ICON_OVERLAY)
			if(!mask)
				say("Error: No selected samples.")
				return
			QDEL_NULL(held_slime)
			var/mob/living/simple_animal/slime_uni/S = new()
			S.name = "Cell Sample"
			S.dna.features["mask"] = mask
			S.setup_texture()
			held_slime = S
		if("Preview combination")
			commands = list("E" = held_slime.appearance)
			choice = show_radial_menu(user, user, commands)
		if("Clear combination")
			combined = list()
			QDEL_NULL(mask)
		else
			return
