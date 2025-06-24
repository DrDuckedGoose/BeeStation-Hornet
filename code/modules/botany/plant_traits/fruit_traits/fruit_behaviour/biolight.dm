/*
	Bioluminescence, makes the fruit glow
*/

/datum/plant_trait/fruit/biolight
	name = "Bioluminescence"
	desc = "Makes the fruit glow."
///Glow characteristics
	var/glow_color = "#ffffff"
	//TODO: Consider making these scale with something - Racc
	var/glow_range = 2
	var/glow_power = 3

/datum/plant_trait/fruit/biolight/New(datum/plant_feature/_parent)
	. = ..()
	if(!fruit_parent)
		return
	fruit_parent.light_system = MOVABLE_LIGHT
	fruit_parent.AddComponent(/datum/component/overlay_lighting, glow_range, glow_power, glow_color)

//TODO: Add the other colours - Racc
