///Universal slimes, not University slimes
/mob/living/simple_animal/slime_uni
	name = "slime"
	icon = 'icons/mob/xenobiology/slime.dmi'
	icon_state = "random"
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
	add_filter("outline", 3, list("type" = "outline", "color" = dna.features["color"], "size" = 1))
	add_filter("outline_inner", 2, list("type" = "outline", "color" = "#000000", "size" = 1))

	var/icon/dynamic = new('icons/mob/xenobiology/slime.dmi', "dynamic")
	dynamic.ChangeOpacity(0.45)
	add_overlay(dynamic)

/mob/living/simple_animal/slime_uni/Destroy()
	. = ..()

///Animates texture for final use from dna
/mob/living/simple_animal/slime_uni/proc/setup_texture()
	//typecast to access procs & features
	var/icon/hold = dna.features["texture"]

	final_icon = new(hold)
	final_icon.Insert(hold)
	for(var/i in 2 to 32)
		hold.Shift(dna.features["direction"], dna.features["speed"], TRUE) //update texure
		final_icon.Insert(hold, frame=i) //insert frames into icon

	var/icon/alpha_mask = new('icons/mob/xenobiology/slime.dmi',"default") //Alpha mask for cutting out excess
	final_icon.AddAlphaMask(alpha_mask)
	icon = final_icon

///Just found out naked people hug, that sucks :pensive:
/mob/living/simple_animal/slime_uni/proc/reproduce()
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
