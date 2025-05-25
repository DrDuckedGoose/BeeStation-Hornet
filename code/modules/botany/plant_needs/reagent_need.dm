/datum/plant_need/reagent
	///What kind of reagents do we need
	var/list/reagent_needs = list() // (/datum/reagent = amount, /datum/reagent = amount)
	///Do we consume the reagents we need?
	var/consume_reagents = TRUE
	///What % of reagents met do we need to succeed?
	var/success_threshold = 1 //100%

/datum/plant_need/reagent/check_need()
	. = ..()
	if(!parent?.parent)
		return
	var/reagent_hits = 0
	var/list/reagent_holders = list()
	SEND_SIGNAL(parent.parent, COMSIG_PLANT_REQUEST_REAGENTS, reagent_holders, parent)
	if(!length(reagent_holders))
		return FALSE
	for(var/datum/reagents/R as anything in reagent_holders)
		if(!R)
			continue
		for(var/reagent as anything in reagent_needs)
			if(!R.has_reagent(reagent, reagent_needs[reagent]))
				continue
			if(consume_reagents)
				R.remove_reagent(reagent, reagent_needs[reagent])
			reagent_hits++
	if(reagent_hits / length(reagent_needs) >= success_threshold)
		return TRUE
	return FALSE

//TODO: Move this - Racc
/datum/plant_need/reagent/water
	reagent_needs = list(/datum/reagent/water = 0.1)
	success_threshold = 0.1
