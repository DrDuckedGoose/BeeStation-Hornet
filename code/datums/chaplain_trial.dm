/datum/chaplain_trail
	///What are we called
	var/name = ""
	///Description like every other atom
	var/desc = ""
	///Icon stuff
	var/icon = 'icons/obj/religion.dmi'
	var/icon_state = ""

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
	icon_state = "trial_sanity"

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

/*
	Trial of Apprenticeship
		Does nuthin', other than reduce rewards for being weak
*/
/datum/chaplain_trail/apprenticeship
	name = "Trial of Apprenticeship"
	desc = "The trial undertaken by new and old chaplains alike. \
	Reduces all rewards by 20%."
	icon_state = "trial_whimp"

/datum/chaplain_trail/apprenticeship/New()
	. = ..()
	GLOB.spooky_reward_gain = 0.8 //TODO: Consider changing this to be a hidden stat, and making other trials give +20% in text - Racc

/*
	Trial of Abstinence
		Having nails makes the chaplain progressively more drunk
*/
/datum/chaplain_trail/abstinence
	name = "Trial of Abstinence"
	desc = "A trial of abstinence. Every nail will make the chaplain progressively more drunk. \
	Removing a nail will reverse the effects."
	icon_state = "trial_drunk"
	///Who are we making drunk?
	var/mob/living/carbon/chap //TODO: Stop this hard-deleting - Racc
	///How many drunk stacks do we have
	var/drunk_stacks = 0
	var/drunk_gain = 0.1

/datum/chaplain_trail/abstinence/New()
	. = ..()
	START_PROCESSING(SSobj, src) //TODO: Consider making a custom processors for this - Racc

/datum/chaplain_trail/abstinence/apply_nail_effect(mob/living/carbon/target)
	. = ..()
	chap = target
	drunk_stacks += 1

/datum/chaplain_trail/abstinence/remove_nail_effect(mob/living/carbon/target)
	. = ..()
	drunk_stacks -= 1

/datum/chaplain_trail/abstinence/process(delta_time)
	if(drunk_stacks && chap)
		chap.reagents.add_reagent(/datum/reagent/consumable/ethanol, drunk_stacks * drunk_gain)
