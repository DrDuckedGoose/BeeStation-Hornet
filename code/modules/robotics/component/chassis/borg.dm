/datum/component/endopart/chassis/borg
	assembly_mob = /mob/living/silicon/new_robot
	required_assembly = list(/datum/endo_assembly/endopart/functional_limb/arm/left, /datum/endo_assembly/endopart/functional_limb/arm/right,
	/datum/endo_assembly/endopart/functional_limb/leg/left, /datum/endo_assembly/endopart/functional_limb/leg/right, /datum/endo_assembly/endopart/functional_limb/head,
	/datum/endo_assembly/endopart/functional_limb/chest)

/datum/component/endopart/chassis/borg/assemble_mob()
	//Overwrite parent so we can slot some custom arguments into the robot creation
	var/mob/living/silicon/new_robot/R = new assembly_mob(get_turf(parent), parent)
	return R

//Prebuilt stuff for milf AI transform machine
/datum/component/endopart/chassis/borg/transform_machine
	start_finished = TRUE
	required_assembly = list(/datum/endo_assembly/endopart/functional_limb/arm/left, /datum/endo_assembly/endopart/functional_limb/arm/right,
	/datum/endo_assembly/endopart/functional_limb/leg/left, /datum/endo_assembly/endopart/functional_limb/leg/right, /datum/endo_assembly/endopart/functional_limb/head,
	/datum/endo_assembly/endopart/functional_limb/chest/transform_machine)
