/atom/movable/lighting_normal_mask
	name = ""
	anchored = TRUE
	icon = LIGHTING_ICON
	icon_state = "transparent"
	color = LIGHTING_BASE_MATRIX
	plane = LIGHTING_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_LIGHTING

/atom/movable/lighting_normal_mask/Initialize(mapload)
	. = ..()

/atom/movable/lighting_object/Destroy(var/force)
	if (force)
		return ..()

	else
		return QDEL_HINT_LETMELIVE
