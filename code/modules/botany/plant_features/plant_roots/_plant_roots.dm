/datum/plant_feature/roots

/datum/plant_feature/roots/New(datum/component/plant/_parent)
	. = ..()

/datum/plant_feature/roots/setup_parent(_parent, reset_features)
	if(parent)
		UnregisterSignal(parent, COMSIG_PLANT_REQUEST_REAGENTS)
	. = ..()
	if(!parent)
		return
	RegisterSignal(parent, COMSIG_PLANT_REQUEST_REAGENTS, PROC_REF(setup_reagents))

/datum/plant_feature/roots/proc/setup_reagents(datum/source, list/reagent_holders, datum/requestor)
	SIGNAL_HANDLER

	if(!check_needs() && requestor != src)
		return
	var/atom/location = parent.plant_item?.loc
	reagent_holders += location?.reagents
