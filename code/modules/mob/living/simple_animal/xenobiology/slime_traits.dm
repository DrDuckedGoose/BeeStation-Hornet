/datum/xenobiology_trait
	var/name
	var/desc
	var/atom/owner
	///Rarity
	var/weight = 50

//This is practically the same as other components, how can you blame me?
/datum/xenobiology_trait/New(list/raw_args)
	. = ..()
	owner = raw_args?.len ? raw_args[1] : null
	initialize()
  
//This doesn't have a traditional initialize() otherwise
/datum/xenobiology_trait/proc/initialize()
	return

/datum/xenobiology_trait/Destroy(force, ...)
	. = ..()
	owner = null

//Used for trait use / function
/datum/xenobiology_trait/proc/activate()
	return

/// === produces a material, amount based on happiness if coming directly from a slime ===
/datum/xenobiology_trait/material
	///produced material
	var/obj/item/stack/material

/datum/xenobiology_trait/material/activate()
	var/amount = 10
	if(istype(owner, /mob/living/simple_animal/slime_uni))
		var/mob/living/simple_animal/slime_uni/S = owner
		amount = 25*(S.happiness/100)
	new material(get_turf(owner), amount)

// === Bananium production ===
/datum/xenobiology_trait/material/bananium
	name = "Bananium Production"
	material = /obj/item/stack/sheet/mineral/bananium
	weight = 25
	
/// === modifies default behaviour ===
/datum/xenobiology_trait/behaviour
	///What signal triggers behaviour
	var/signal

/datum/xenobiology_trait/behaviour/initialize()
	. = ..()
	if(signal && isliving(owner))
		RegisterSignal(owner, signal, .proc/activate)

/datum/xenobiology_trait/behaviour/Destroy(force, ...)
	. = ..()
	UnregisterSignal(owner, signal)

// === Live Feeding ===
/datum/xenobiology_trait/behaviour/live_feeding
	signal = COMSIG_MOB_CLICKON

/datum/xenobiology_trait/behaviour/live_feeding/activate(datum/source, atom/A, params)
	. = ..()
	if(isliving(source) && isliving(A) && A != source)
		var/mob/living/M = source
		var/mob/living/target = A
		if(M.buckled != target)
			M.visible_message("[M] begins to absorb [target]!")
			target.buckle_mob(M, TRUE)
