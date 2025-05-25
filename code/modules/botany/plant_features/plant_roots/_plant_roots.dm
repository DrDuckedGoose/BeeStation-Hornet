/datum/plant_feature/roots
	feature_catagories = PLANT_FEATURE_ROOTS
	///Where can we pull reagents from
	//TODO: change this to the proper type list thing - Racc
	var/list/access_whitelist = list(/obj/machinery/plumbing/tank/plant_tray)
	///What kinda of substrate can we grow in?
	var/compatible_substrate //= PLANT_SUBSTRATE_DIRT | PLANT_SUBSTRATE_SAND |  PLANT_SUBSTRATE_CLAY | PLANT_SUBSTRATE_DEBRIS
	///Set to TRUE if you want our desired substrate to have all the ones we're compatible with, instead of one
	var/substrate_strict = FALSE

/datum/plant_feature/roots/New(datum/component/plant/_parent)
	. = ..()

/datum/plant_feature/roots/setup_parent(_parent, reset_features)
	if(parent)
		UnregisterSignal(parent, COMSIG_PLANT_REQUEST_REAGENTS)
	. = ..()
	if(!parent)
		return
	RegisterSignal(parent, COMSIG_PLANT_REQUEST_REAGENTS, PROC_REF(setup_reagents))

/datum/plant_feature/roots/associate_seeds(obj/item/plant_seeds/seeds)
	. = ..()
	RegisterSignal(seeds, COMSIG_SEEDS_POLL_ROOT_SUBSTRATE, PROC_REF(catch_substrate))

/datum/plant_feature/roots/proc/catch_substrate(datum/source, polling_substrate)
	SIGNAL_HANDLER

	if((compatible_substrate == polling_substrate) && substrate_strict || (compatible_substrate & polling_substrate) && !substrate_strict)
		return TRUE
	if(!compatible_substrate) //If there's no specified substrate stuff, plant it anywhere
		return TRUE

/datum/plant_feature/roots/proc/setup_reagents(datum/source, list/reagent_holders, datum/requestor)
	SIGNAL_HANDLER

	if(!check_needs() && requestor != src)
		return
	var/atom/location = parent.plant_item?.loc
	if(!(locate(location.type) in access_whitelist))
		return
	reagent_holders += location?.reagents
