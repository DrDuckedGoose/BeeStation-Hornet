/*
	Keep reagents in the fruit seperated until something triggers it
	Juts uses NO_REACT flags
*/

/datum/plant_trait/fruit/dense_contents
	name = "Densified Contents"
	desc = "The fruit's reagent capacity is increased."
	scales = "Reagent capacity scales with trait power."

/datum/plant_trait/fruit/dense_contents/Destroy(force, ...)
	var/datum/plant_feature/fruit/fruit_parent = parent
	fruit_parent.total_volume = initial(fruit_parent.total_volume)
	return ..()

/datum/plant_trait/fruit/dense_contents/setup_parent(_parent)
	. = ..()
	if(!istype(parent))
		return
	var/datum/plant_feature/fruit/fruit_parent = parent
	fruit_parent.total_volume = initial(fruit_parent.total_volume) * (max(fruit_parent.trait_power, 1.5))
