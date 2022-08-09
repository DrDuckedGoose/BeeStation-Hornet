/datum/xenobiology_trait
	var/name
	var/desc
	var/atom/owner
	///Rarity
	var/weight = 50
	///List of possible demands the trait can have
	var/list/possible_targets = list(/datum/reagent/toxin/plasma)

//This is the same as other components, I think?
/datum/xenobiology_trait/New(list/raw_args)
	. = ..()
	owner = raw_args?.len ? raw_args[1] : null
	initialize()
  
//This doesn't have a traditional initialize() otherwise
/datum/xenobiology_trait/proc/initialize()
	return

/datum/xenobiology_trait/Destroy(force, ...)
	. = ..()

//Used for trait use / function
/datum/xenobiology_trait/proc/activate()
	return
