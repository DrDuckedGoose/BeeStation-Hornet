/datum/plant_need/reagent/water
	reagent_needs = list(/datum/reagent/water = 1, /datum/reagent/medicine/earthsblood = 0)
	success_threshold = 0.5
	overdraw_need = TRUE

/datum/plant_need/reagent/water/fufill_need(atom/location)
	location.reagents.add_reagent(/datum/reagent/water, location?.reagents.maximum_volume)

/datum/plant_need/reagent/blood
	reagent_needs = list(/datum/reagent/water = 1)
	success_threshold = 1
	overdraw_need = TRUE
