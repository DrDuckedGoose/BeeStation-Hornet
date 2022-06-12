///Universal slimes, not University slimes
/mob/living/simple_animal/slime_uni
	name = "slime"
	icon = 'icons/mob/xenobiology/slime.dmi'
	icon_state = "random"
	alpha = 200
	//alpha = 127
	appearance_flags = KEEP_TOGETHER
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
	setup_texture()
	add_filter("outline", 3, list("type" = "outline", "color" = gradient(dna.features["color"], "#000000ff", 0.7), "size" = 1))

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
	dna.instability += XENOB_INSTABILITY
	new /mob/living/simple_animal/slime_uni/(get_step(src, pick(NORTH, SOUTH, EAST, WEST)), src)

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
