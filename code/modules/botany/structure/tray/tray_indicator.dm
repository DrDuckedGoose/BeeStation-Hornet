/obj/effect/tray_indicator
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	vis_flags = 0
	appearance_flags = TILE_BOUND|LONG_GLIDE|KEEP_APART
	vis_flags = VIS_INHERIT_ID

/obj/effect/tray_indicator/Initialize(mapload, _name, _color, _index)
	. = ..()
//Base setup
	name = _name //TODO: remove this - Racc //TODO: maybe dont remove this, helps know what it does - Racc
	color = _color
	icon_state = "tray_light_[_index]"
//Emmisive
	//TODO: Do this properly - Racc
	var/mutable_appearance/emissive = new()
	emissive.appearance = appearance
	emissive.blend_mode = BLEND_INSET_OVERLAY
	emissive.plane = LIGHTING_PLANE
	add_overlay(emissive)
//Animation - Do this post appearance copying to avoid headache
	animate(src, alpha = 0, time = 0.5 SECONDS, loop = -1)
	animate(alpha = 255, time = 0.25 SECONDS)
