/datum/chaplain_trail
	///What are we called
	var/name = ""
	///Description like every other atom
	var/desc = ""

/datum/chaplain_trail/proc/apply_nail_effect(mob/living/carbon/target)
	return

/datum/chaplain_trail/proc/remove_nail_effect(mob/living/carbon/target)
	return
/*
	Trial of Sanity
		Every nail makes the chaplain more insane	
*/
/datum/chaplain_trail/sanity
	name = "Trial of Sanity"
	desc = "A trial of sanity. Every nail will apply a small amount of damage to the chaplain's brain, and increase their insanity. \
	Removing a nail will reverse the effects."

/datum/chaplain_trail/sanity/apply_nail_effect(mob/living/carbon/target)
	. = ..()
	//Drain bamage
	target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
	//Crazy visions
	var/datum/hallucination/H = pick(GLOB.hallucination_list)
	H = new H(target, TRUE)
	//Uh oh message
	target.balloon_alert(target, "Your head hurts.")
	to_chat(target, "<span class='warning'>Your head hurts.</span>")

/datum/chaplain_trail/sanity/remove_nail_effect(mob/living/carbon/target)
	. = ..()
	target.adjustOrganLoss(ORGAN_SLOT_BRAIN, -10)
