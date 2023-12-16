/datum/surgery/embalm_corpse
	name = "Embalm Corpse"
	desc = "A surgical procedure that embalms. Be sure to perform this surgery on an embalming table."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/saw,
				/datum/surgery_step/embalm_corpse,
				/datum/surgery_step/close)

	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = TRUE
	ignore_clothes = FALSE

/datum/surgery/embalm_corpse/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(target.stat != DEAD || HAS_TRAIT(target, TRAIT_EMBALMED))
		return FALSE

/datum/surgery/embalm_corpse/complete(mob/user)
	. = ..()
	//Do pre-rewards for organs removed & formaldehyde used
	var/total_reward = 0
	//organ reward
	var/list/reward_oragns = list(/obj/item/organ/stomach, /obj/item/organ/lungs, /obj/item/organ/liver, /obj/item/organ/heart)
	for(var/i in reward_oragns)
		total_reward += TRESPASS_SMALL / length(reward_oragns)
	//formaldehyde reward
	var/datum/reagent/toxin/formaldehyde/F = target?.reagents?.get_reagent(/datum/reagent/toxin/formaldehyde)
	if(F?.volume > 5)
		total_reward += TRESPASS_SMALL
	//Do remaining table check
	var/turf/T = get_turf(target)
	//Only succeeed if using enbalming table
	if(locate(/obj/structure/table/optable/embalming_table) in T.contents)
		//handle spooky rewards
		SSspooky.adjust_trespass(user, -(TRESPASS_LARGE+total_reward))
		var/datum/component/rot/R = target.GetComponent(/datum/component/rot)
		R?.favor_modifier += 0.5
		make_spooky_indicator(get_turf(src), TRUE)
	else
		//handle spooky consequcnes
		target.add_splatter_floor()
		target.spawn_gibs()
		SSspooky.adjust_trespass(user, TRESPASS_LARGE)
		var/area/A = get_area(target)
		SSspooky.adjust_area_temperature(user, A, 1)
		make_spooky_indicator(get_turf(src))
	
	ADD_TRAIT(target, TRAIT_EMBALMED , ORGAN_TRAIT)

/datum/surgery_step/embalm_corpse
	name = "Scoop corpse"
	implements = list(/obj/item/scoop = 95)
	repeatable = TRUE
	time = 10 SECONDS
	success_sound = 'sound/surgery/organ1.ogg'
	///Probability to remove an organ
	var/organ_prob = 25

/datum/surgery_step/embalm_corpse/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail)
	. = ..()
	if(!length(target.internal_organs))
		return FALSE

/datum/surgery_step/embalm_corpse/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	. = ..()
	if(!length(target.internal_organs))
		return
	var/obj/item/organ/O = pick(target.internal_organs)
	//Chance to remove an ogran
	var/datum/reagent/toxin/formaldehyde/F = target.reagents?.get_reagent(/datum/reagent/toxin/formaldehyde)
	var/status = 0
	if(prob(organ_prob * (F ? 2 : 1)))
		O?.Remove(target)
		O?.forceMove(get_turf(target))
		status = 1
	to_chat(user, "<span class='[status ? "notice" : "warning"]'>You [status ? "succeed" : "fail"] to remove [O].</span>")
	//Remove some blood
	target.bleed(target.blood_volume / 5)
