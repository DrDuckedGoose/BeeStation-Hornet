//todo: move these to a dedicated define file
///rareness weight defines
#define XENOB_COMMON 5
#define XENOB_UNCOMMON 3
#define XENOB_RARE 1
///List of available textures for slimes
#define XENOB_TEXTURES list("polka", "nostalgia", "counterstrike", "alert", "bouncy", "spooky", "alphabet", "unpacking", "default")
///List of approved colors for slimes
#define XENOB_COLORS list("#00ff44", "#006eff", "#ff0000", "#f6ff00", "#ff00d9", "#00e5ff")

/mob/living/simple_animal/slime_uni
	name = "slime"
	icon = 'icons/mob/xenobiology/slime.dmi'
	icon_state = "random"
	///Textures, the wacky patterns a slime will have
	var/icon/species_texture
	///Color, slime racism :pensive:
	var/species_color
	///Icon the actual mob uses, contains animated frames
	var/icon/final_icon

	var/tex_speed = 1
	var/tex_dir = NORTH

/mob/living/simple_animal/slime_uni/Initialize(mapload, parent_texture = null, parent_color = null)
	. = ..()
	species_texture = parent_texture
	species_color = parent_color

	tex_speed = pick(list(1,2,3))
	tex_dir = pick(list(NORTH, SOUTH, EAST, WEST))

	//apply textures, colors, and outlines
	setup_texture()
	add_filter("outline", 3, list("type" = "outline", "color" = species_color, "size" = 1))
	add_filter("outline_inner", 2, list("type" = "outline", "color" = "#000000", "size" = 1))

	var/icon/dynamic = new('icons/mob/xenobiology/slime.dmi', "dynamic")
	dynamic.ChangeOpacity(0.45)
	add_overlay(dynamic)

/mob/living/simple_animal/slime_uni/Destroy()
	. = ..()

///initializes texture, adressing species_texture & color, calls texture application
/mob/living/simple_animal/slime_uni/proc/setup_texture(large = FALSE, icon = null)
	//Grab missing textures & colors, if needed
	if(!species_texture)
		species_texture = new(large ? 'icons/mob/xenobiology/slime_texture_96x96.dmi' : 'icons/mob/xenobiology/slime_texture.dmi', (icon ? icon : pick(XENOB_TEXTURES)))
	if(!species_color)
		species_color = pick(XENOB_COLORS)
	species_texture.ColorTone(species_color)

	apply_texture()

///Animate and apply final icon from species_texture
/mob/living/simple_animal/slime_uni/proc/apply_texture()
	final_icon = new(species_texture)
	final_icon.Insert(species_texture)

	for(var/i in 2 to 32)
		species_texture.Shift(tex_dir, tex_speed, TRUE) //update texure
		final_icon.Insert(species_texture, frame=i) //insert frames into icon

	var/icon/alpha_mask = new('icons/mob/xenobiology/slime.dmi',"default" ) //Alpha mask for cutting out excess
	final_icon.AddAlphaMask(alpha_mask)
	icon = final_icon
