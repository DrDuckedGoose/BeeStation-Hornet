/*
	Borg chassis
*/
/obj/item/endopart/chassis/borg
	name = "bipedal chassis"
	desc = "A chassis for a bipedal robot"
	endo_component = /datum/component/endopart/chassis/borg

//Component stuff
/datum/component/endopart/chassis/borg
	assembly_mob = /mob/living/silicon/new_robot
	required_assembly = list(/datum/endo_assembly/endopart/functional_limb/arm, /datum/endo_assembly/endopart/functional_limb/arm,
	/datum/endo_assembly/endopart/functional_limb/leg, /datum/endo_assembly/endopart/functional_limb/leg, /datum/endo_assembly/endopart/functional_limb/head,
	/datum/endo_assembly/endopart/functional_limb/chest)

/datum/component/endopart/chassis/borg/assembled_mob()
	//Overwrite parent so we can slot some custom arguments into the robot creation
	var/mob/living/silicon/new_robot/R = new assembly_mob(get_turf(parent), parent)
	return R
