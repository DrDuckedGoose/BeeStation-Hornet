/datum/component/endopart/chassis/bot/assembled_mob()
	. = ..()
	/*
		Typically you handle your special missing assembly behaviour in the component with apply_assembly(datum/source, mob/target),
		but this is non standard behaviour specific to bots
	*/
	//Check if our arm assembly is properly complete, specifically if it's wired
	var/datum/endo_assembly/endopart/functional_limb/arm/A = locate(/datum/endo_assembly/endopart/functional_limb/arm) in required_assembly
	for(var/obj/item/I as() in A?.parts)
		var/datum/component/endopart/E = I.GetComponent(/datum/component/endopart)
		var/outcome = E.check_completion()
		if((outcome & ENDO_ASSEMBLY_INCOMPLETE) && (outcome & ENDO_ASSEMBLY_NON_INTEGRAL))
			broken_assembly(.)
			return

/datum/component/endopart/chassis/bot/proc/broken_assembly(mob/M)
	return

/*
	Cleanbot chassis
*/

/obj/item/endopart/chassis/cleanbot
	name = "cleanbot chassis"
	desc = "A chassis for a cleanbot"
	endo_component = /datum/component/endopart/chassis/bot/cleanbot

/datum/component/endopart/chassis/bot/cleanbot
	assembly_mob = /mob/living/simple_animal/bot/cleanbot
	required_assembly = list(/datum/endo_assembly/item/bucket, /datum/endo_assembly/item/proximity_sensor,
	/datum/endo_assembly/endopart/functional_limb/arm, /datum/endo_assembly/item/interaction/tool/screwdriver)

/datum/component/endopart/chassis/bot/cleanbot/broken_assembly(mob/M)
	. = ..()
	var/mob/living/simple_animal/bot/cleanbot/C = M
	C.can_clean = FALSE

/*
	Medibot chassis
*/

/obj/item/endopart/chassis/medibot
	name = "medibot chassis"
	desc = "A chassis for a medibot"
	endo_component = /datum/component/endopart/chassis/bot/medibot

/datum/component/endopart/chassis/bot/medibot
	assembly_mob = /mob/living/simple_animal/bot/medbot
	required_assembly = list(/datum/endo_assembly/item/medkit, /datum/endo_assembly/item/proximity_sensor, /datum/endo_assembly/item/healthanalyzer,
	/datum/endo_assembly/endopart/functional_limb/arm, /datum/endo_assembly/item/interaction/tool/screwdriver)

/datum/component/endopart/chassis/bot/medibot/broken_assembly(mob/M)
	. = ..()
	var/mob/living/simple_animal/bot/medbot/medbot = M
	medbot.can_heal = FALSE

/*
	Medibot chassis
*/

/obj/item/endopart/chassis/simplebot
	name = "simplebot chassis"
	desc = "A chassis for a simplebot"
	endo_component = /datum/component/endopart/chassis/bot/simplebot

/datum/component/endopart/chassis/bot/simplebot
	assembly_mob = /mob/living/simple_animal/bot/medbot
	required_assembly = list(/datum/endo_assembly/endopart/functional_limb/leg
)
