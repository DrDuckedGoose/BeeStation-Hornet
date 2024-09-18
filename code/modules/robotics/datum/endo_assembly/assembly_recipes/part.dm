/datum/endo_assembly/endopart/functional_limb
	assembly_integral = TRUE

/datum/endo_assembly/endopart/functional_limb/check_completion()
	. = ..()
	if(. & ENDO_ASSEMBLY_INCOMPLETE)
		return
	var/outcome
	for(var/obj/item/I as() in parts)
		var/datum/component/endopart/E = I.GetComponent(/datum/component/endopart)
		outcome = E?.check_completion()
		if((outcome & ENDO_ASSEMBLY_INCOMPLETE) && !(outcome & ENDO_ASSEMBLY_NON_INTEGRAL))
			return outcome
	return (assembly_integral ? outcome & ENDO_ASSEMBLY_NON_INTEGRAL : outcome)

/*
	Arms
*/
/datum/endo_assembly/endopart/functional_limb/arm
	component_requirment = /datum/component/endopart/arm
	poll_path = /datum/component/endopart/arm
	allow_poll = TRUE
	ideal_part_parent = /obj/item/bodypart/l_arm/robot
	hint_state = "robotic_l_arm"

/datum/endo_assembly/endopart/functional_limb/arm/left
	ideal_part_parent = /obj/item/bodypart/l_arm/robot
	required_offset_key = ENDO_OFFSET_KEY_ARM(1)

/datum/endo_assembly/endopart/functional_limb/arm/right
	ideal_part_parent = /obj/item/bodypart/r_arm/robot
	required_offset_key = ENDO_OFFSET_KEY_ARM(2)
	hint_state = "robotic_r_arm"

/*
	Legs
*/
/datum/endo_assembly/endopart/functional_limb/leg
	component_requirment = /datum/component/endopart/leg
	poll_path = /datum/component/endopart/leg
	allow_poll = TRUE
	ideal_part_parent = /obj/item/bodypart/l_leg/robot
	hint_state = "robotic_l_leg"

/datum/endo_assembly/endopart/functional_limb/leg/left
	ideal_part_parent = /obj/item/bodypart/l_leg/robot
	required_offset_key = ENDO_OFFSET_KEY_LEG(1)

/datum/endo_assembly/endopart/functional_limb/leg/right
	ideal_part_parent = /obj/item/bodypart/r_leg/robot
	required_offset_key = ENDO_OFFSET_KEY_LEG(2)
	hint_state = "robotic_r_leg"

//Track subtypes from transform machine
/datum/endo_assembly/endopart/functional_limb/leg/left/track
	ideal_part_parent = /obj/item/bodypart/l_leg/robot/track

/datum/endo_assembly/endopart/functional_limb/leg/right/track
	ideal_part_parent = /obj/item/bodypart/r_leg/robot/track

/*
	Head
*/
/datum/endo_assembly/endopart/functional_limb/head
	component_requirment = /datum/component/endopart/head
	poll_path = /datum/component/endopart/head
	allow_poll = TRUE
	ideal_part_parent = /obj/item/bodypart/head/robot

/*
	Chest
*/
/datum/endo_assembly/endopart/functional_limb/chest
	component_requirment = /datum/component/endopart/chest
	poll_path = /datum/component/endopart/chest
	allow_poll = TRUE
	ideal_part_parent = /obj/item/bodypart/chest/robot
	hint_state = "robotic_chest"

/datum/endo_assembly/endopart/functional_limb/chest/transform_machine
	component_requirment = /datum/component/endopart/chest/transform_machine
