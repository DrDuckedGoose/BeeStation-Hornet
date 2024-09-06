/datum/component/endopart/chassis/bot/assemble_mob()
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
		if((outcome & ENDO_ASSEMBLY_INCOMPLETE))
			broken_assembly(.)
			return

/datum/component/endopart/chassis/bot/proc/broken_assembly(mob/M)
	return

/*
	Cleanbot chassis
*/

/datum/component/endopart/chassis/bot/cleanbot
	assembly_mob = /mob/living/simple_animal/bot/cleanbot
	required_assembly = list(/datum/endo_assembly/item/proximity_sensor,
	/datum/endo_assembly/endopart/functional_limb/arm, /datum/endo_assembly/item/interaction/tool/screwdriver)

/datum/component/endopart/chassis/bot/cleanbot/broken_assembly(mob/M)
	. = ..()
	var/mob/living/simple_animal/bot/cleanbot/C = M
	C.can_clean = FALSE

/*
	Medibot chassis
*/

/datum/component/endopart/chassis/bot/medibot
	assembly_mob = /mob/living/simple_animal/bot/medbot
	required_assembly = list(/datum/endo_assembly/item/proximity_sensor, /datum/endo_assembly/item/healthanalyzer,
	/datum/endo_assembly/endopart/functional_limb/arm, /datum/endo_assembly/item/interaction/tool/screwdriver)

/datum/component/endopart/chassis/bot/medibot/broken_assembly(mob/M)
	. = ..()
	var/mob/living/simple_animal/bot/medbot/medbot = M
	medbot.can_heal = FALSE

/*
	Secbot chassis
*/

/datum/component/endopart/chassis/bot/secbot
	assembly_mob = /mob/living/simple_animal/bot/secbot
	required_assembly = list(/datum/endo_assembly/item/welder, /datum/endo_assembly/item/proximity_sensor, /datum/endo_assembly/item/signaler,
	/datum/endo_assembly/endopart/functional_limb/arm, /datum/endo_assembly/item/stun_baton, /datum/endo_assembly/item/interaction/tool/screwdriver)

/datum/component/endopart/chassis/bot/secbot/broken_assembly(mob/M)
	. = ..()
	//TODO: - Racc

/*
	Larry chassis
*/

/datum/component/endopart/chassis/bot/cleanbot/larry
	assembly_mob = /mob/living/simple_animal/bot/cleanbot/larry

/*
	Atmosbot chassis
*/

/datum/component/endopart/chassis/bot/atmos
	assembly_mob = /mob/living/simple_animal/bot/atmosbot
	required_assembly = list(/datum/endo_assembly/item/proximity_sensor, /datum/endo_assembly/endopart/functional_limb/arm,
	/datum/endo_assembly/item/oxygen, /datum/endo_assembly/item/analyzer, /datum/endo_assembly/item/interaction/tool/screwdriver)

/datum/component/endopart/chassis/bot/atmos/broken_assembly(mob/M)
	. = ..()
	//TODO: - Racc

/*
	Floorbot chassis
*/

/datum/component/endopart/chassis/bot/floor
	assembly_mob = /mob/living/simple_animal/bot/floorbot
	required_assembly = list(/datum/endo_assembly/item/proximity_sensor, /datum/endo_assembly/endopart/functional_limb/arm,
	/datum/endo_assembly/item/toolbox, /datum/endo_assembly/item/tiles, /datum/endo_assembly/item/interaction/tool/screwdriver)

/datum/component/endopart/chassis/bot/floor/broken_assembly(mob/M)
	. = ..()
	//TODO: - Racc

/*
	Honk chassis
*/

/datum/component/endopart/chassis/bot/clown
	assembly_mob = /mob/living/simple_animal/bot/honkbot
	required_assembly = list(/datum/endo_assembly/item/proximity_sensor, /datum/endo_assembly/endopart/functional_limb/arm,
	/datum/endo_assembly/item/clown_horn, /datum/endo_assembly/item/interaction/tool/screwdriver)

/datum/component/endopart/chassis/bot/clown/broken_assembly(mob/M)
	. = ..()
	//TODO: - Racc

/*
	Firebot chassis
*/

/datum/component/endopart/chassis/bot/fire
	assembly_mob = /mob/living/simple_animal/bot/firebot
	required_assembly = list(/datum/endo_assembly/item/proximity_sensor, /datum/endo_assembly/endopart/functional_limb/arm,
	/datum/endo_assembly/item/hardhat, /datum/endo_assembly/item/interaction/tool/screwdriver)

/datum/component/endopart/chassis/bot/fire/broken_assembly(mob/M)
	. = ..()
	//TODO: - Racc

/*
	ED209 chassis
*/

/datum/component/endopart/chassis/bot/ed209
	assembly_mob = /mob/living/simple_animal/bot/ed209
	required_assembly = list(/datum/endo_assembly/item/proximity_sensor, /datum/endo_assembly/item/cell, /datum/endo_assembly/item/disabler,
	/datum/endo_assembly/item/interaction/stack/wire, /datum/endo_assembly/endopart/functional_limb/leg, /datum/endo_assembly/endopart/functional_limb/leg,
	/datum/endo_assembly/item/helmet, /datum/endo_assembly/item/vest, /datum/endo_assembly/item/interaction/stack/iron,
	/datum/endo_assembly/item/interaction/tool/welder)

/datum/component/endopart/chassis/bot/ed209/broken_assembly(mob/M)
	. = ..()
	//TODO: - Racc

/obj/item/endopart/chassis/ed209
	name = "ed209 chassis"
	desc = "A chassis for a ed209 robot"
	endo_component = /datum/component/endopart/chassis/bot/ed209
