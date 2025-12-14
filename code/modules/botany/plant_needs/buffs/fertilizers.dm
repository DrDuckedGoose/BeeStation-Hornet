/*
	Robust Harvest, increases harvest
*/
/datum/plant_need/reagent/buff/robust
	need_description = "Improves plant harvests by half their max harvest."
	reagent_needs = list(/datum/reagent/plantnutriment/robustharvestnutriment = 5)

/datum/plant_need/reagent/buff/robust/apply_buff()
	. = ..()
	var/datum/plant_feature/body/body_feature = parent
	if(!istype(body_feature))
		return
	body_feature.max_harvest += max(1, initial(body_feature.max_harvest) / 2)

/datum/plant_need/reagent/buff/robust/remove_buff()
	. = ..()
	var/datum/plant_feature/body/body_feature = parent
	if(!istype(body_feature))
		return
	body_feature.max_harvest -= max(1, initial(body_feature.max_harvest) / 2)
