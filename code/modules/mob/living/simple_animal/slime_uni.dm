/mob/living/simple_animal/slime_uni
	name = "slime"
	icon = 'icons/mob/xenobiology/slime.dmi'
	icon_state = "random"
	///Textures, the wacky patterns a slime will have
	var/icon/species_texture
	///Color, slime racism :pensive:
	var/species_color

	var/tex_speed
	var/tex_dir

/mob/living/simple_animal/slime_uni/Initialize(mapload, parent_texture = null, parent_color = null)
	. = ..()
	species_texture = parent_texture
	species_color = parent_color

	//apply textures, colors, and outlines
	setup_texture()
	add_filter("outline", 3, list("type" = "outline", "color" = species_color, "size" = 1))
	add_filter("outline_inner", 2, list("type" = "outline", "color" = "#000000", "size" = 1))

	tex_speed = pick(list(1,2,3))
	tex_dir = pick(list(NORTH, SOUTH, EAST, WEST))
	do_texture_shift()

	var/icon/face = new('icons/mob/xenobiology/slime.dmi', "major_feature_[pick("1", "2", "3)]")
	add_overlay(face)
	face = new('icons/mob/xenobiology/slime.dmi', "minor_feature_[pick("1", "2", "3")]")
	add_overlay(face)

/mob/living/simple_animal/slime_uni/Destroy()
	. = ..()

///initializes texture, adressing species_texture
/mob/living/simple_animal/slime_uni/proc/setup_texture()
	if(!species_texture)
		random_slime_texture()
	if(!species_color)
		//todo: change this to a define somwhere
		species_color = pick(list("#00ff44", "#006eff", "#ff0000", "#f6ff00", "#ff00d9", "#00e5ff"))
	species_texture.ColorTone(species_color)
	apply_texture()

///apply species_texture to mob icon
/mob/living/simple_animal/slime_uni/proc/apply_texture()
	var/icon/temp_icon = new(species_texture)
	var/icon/alpha_mask = new('icons/mob/xenobiology/slime.dmi',"default" )
	temp_icon.AddAlphaMask(alpha_mask)
	icon = temp_icon

///update species_texture to a random, or picked, icon
/mob/living/simple_animal/slime_uni/proc/random_slime_texture(large = FALSE, icon)
	//todo: change this to a define somewhere
	var/list/available_icons = list("polka", "nostalgia", "counterstrike", "alert", "bouncy", "spooky")
	species_texture = new(large ? 'icons/mob/xenobiology/slime_texture_96x96.dmi' : 'icons/mob/xenobiology/slime_texture.dmi', (icon ? icon : pick(available_icons)))

/mob/living/simple_animal/slime_uni/proc/do_texture_shift()
	species_texture.Shift(tex_dir, tex_speed, TRUE)
	apply_texture()
	addtimer(CALLBACK(src, .proc/do_texture_shift), 0 SECONDS)
