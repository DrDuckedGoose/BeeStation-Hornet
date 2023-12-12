/obj/effect/water_ripple
	icon_state = "water_ripple"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blend_mode = BLEND_ADD
	plane = FLOOR_PLANE
	///What color is our water? - This IS distinct for our color
	var/water_color = "#fff"
	///Do we have a puddle mask we want to use?
	var/puddle_mask

/obj/effect/water_ripple/blue
	water_color = "#7cd5ff"

/obj/effect/water_ripple/blue/puddle
	puddle_mask = "puddle_mask1"

/obj/effect/water_ripple/Initialize(mapload)
	. = ..()
	//Build color overlay
	var/mutable_appearance/MA = mutable_appearance(icon, "solid")
	MA.blend_mode = BLEND_MULTIPLY
	MA.color = water_color
	add_overlay(MA)
	//Masking
	if(puddle_mask)
		add_filter("puddle_mask", 1, alpha_mask_filter(icon = icon(src.icon, puddle_mask)))
