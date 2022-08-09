/// ======= modifies default slime behaviour =======
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

// === Live Feeding - Can attach to subjects like old slimes, and feed on them ===
/datum/xenobiology_trait/behaviour/live_feeding
	signal = COMSIG_MOB_CLICKON

/datum/xenobiology_trait/behaviour/live_feeding/activate(datum/source, atom/A, params)
	. = ..()
	if(isliving(source) && isliving(A) && A != source)
		var/mob/living/M = source
		var/mob/living/target = A
		if(M.buckled != target)
			M.visible_message("<span class='warning'>[M] begins to absorb [target]!</span>", "<span class='warning'>You begin to absorb [target]!</span>")
			target.buckle_mob(M, TRUE)

// === Internal Calcification - Doesn't produce extracts, directly deposits effect instead ===
/datum/xenobiology_trait/behaviour/auto_activation
	signal = COMSIG_ATOM_CREATED

/datum/xenobiology_trait/behaviour/auto_activation/activate(datum/source, atom/A, params)
	. = ..()
	if(istype(source, /obj/item/reagent_containers/slime_produce))
		var/obj/item/reagent_containers/slime_produce/S = source
		S.activate()
