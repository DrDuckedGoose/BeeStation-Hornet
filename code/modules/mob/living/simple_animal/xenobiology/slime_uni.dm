///Universal slimes, not University slimes
/mob/living/simple_animal/slime_uni
	name = "slime"
	desc = "A squishy disco-party!"
	icon = 'icons/mob/xenobiology/slime.dmi'
	icon_state = "random"
	alpha = 210
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	blood_volume = BLOOD_VOLUME_MAXIMUM
	///Slime DNA, contains traits and visual features
	var/datum/slime_dna/dna
	///Icon the actual mob uses, contains animated frames
	var/icon/final_icon
	///texture for overlay reference
	var/icon/animated_texture
	///technical name seen by science goggles
	var/species_name = ""

/mob/living/simple_animal/slime_uni/Initialize(mapload, var/mob/living/simple_animal/slime_uni/parent, texture, mask, sub_mask, color, rotation, pan)
	..()
	//Setup dna
	dna = new(src, parent, texture, mask, sub_mask, color, rotation, pan)

	//apply textures, colors, and outlines
	setup_texture()
	add_filter("outline", 2, list("type" = "outline", "color" = gradient(dna.features["color"], "#000000ff", 0.59), "size" = 1))

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
	animated_texture = new(final_icon)
	final_icon.AddAlphaMask(alpha_mask)
	icon = final_icon
