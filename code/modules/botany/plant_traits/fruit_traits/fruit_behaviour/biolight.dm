/*
	Bioluminescence, makes the fruit glow
*/

/datum/plant_trait/fruit/biolight
	name = "Bioluminescence"
	desc = "Makes the fruit glow."
///Glow characteristics
	var/glow_color = "#ffffff"
	//Minimums
	var/glow_range = 2
	var/glow_power = 3

/datum/plant_trait/fruit/biolight/New(datum/plant_feature/_parent)
	. = ..()
	if(!fruit_parent)
		return
	fruit_parent.light_system = MOVABLE_LIGHT
	fruit_parent.AddComponent(/datum/component/overlay_lighting, glow_range*parent.trait_power, glow_power*parent.trait_power, glow_color)

//TODO: Add the other colours - Racc
//Yellow
/datum/plant_trait/fruit/biolight/yellow
	name = "Yellow Bioluminescence"
	desc = "Makes the fruit glow yellow."
	glow_color = "#fbff00"

//Orange
/datum/plant_trait/fruit/biolight/orange
	name = "Orange Bioluminescence"
	desc = "Makes the fruit glow orange."
	glow_color = "#ff8800"


//Green
/datum/plant_trait/fruit/biolight/green
	name = "Green Bioluminescence"
	desc = "Makes the fruit glow green."
	glow_color = "#66ff00"

//Red
/datum/plant_trait/fruit/biolight/red
	name = "Red Bioluminescence"
	desc = "Makes the fruit glow red."
	glow_color = "#ff0000"
