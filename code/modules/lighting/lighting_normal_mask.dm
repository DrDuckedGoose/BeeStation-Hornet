/atom/movable/lighting_normal_mask
	name = ""
	anchored = TRUE
	icon = 'icons/effects/normals.dmi'
	icon_state = "normal_light"
	plane = NORMAL_LIGHT_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_LIGHTING

/atom/movable/lighting_normal_mask/Initialize(mapload)
	. = ..()

/atom/movable/lighting_object/Destroy(var/force)
	if (force)
		return ..()

	else
		return QDEL_HINT_LETMELIVE
/*
	We reference our associated lighting object and turn of our left/right/top lighting component based of its value
*/
/atom/movable/lighting_normal_mask/proc/update(list/_color = list())
	//
	/*
		var/left_percentage_enabled = clamp((left_side_colour_1 / 255) + (left_side_colour_2 / 255), 0, 255)
	*/
	var/left = clamp( ( ((_color[1]+_color[2]+_color[3])/3/255) +  ((_color[9]+_color[10]+_color[11])/3/255) ) / 2, 0, 255)
	var/right = clamp( ( ((_color[5]+_color[6]+_color[7])/3/255) +  ((_color[13]+_color[14]+_color[15])/3/255) ) / 2, 0, 255)
	var/top = 0//clamp(left/right, 0, 1)

	/*
		Setup our color aka disable / enable our faces
		green = right
		red = left
		blue = top
	*/
	if(left > right)
		color = list(rgb(0, 0, 0), rgb(0, 255, 255), rgb(0, 0, 0), rgb(0,0,0))
	else
		color = list(rgb(255, 0, 255), rgb(0, 0, 0), rgb(0, 0, 0), rgb(0,0,0))

