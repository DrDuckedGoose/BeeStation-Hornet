/*
	Fireproof, makes the fruit fire proof
	This doesn't make seeds fireproof anymore
*/

/datum/plant_trait/fruit/fireproof
	name = "Fireproof"
	desc = "The fruit is fireproof and will withstand otherwise destructive temperatures. Additionally balances the fruit's genetic composistion."
	genetic_cost = -1

/datum/plant_trait/fruit/bluespace/New(datum/plant_feature/_parent)
	. = ..()
	if(!fruit_parent)
		return
	fruit_parent.resistance_flags |= FIRE_PROOF
