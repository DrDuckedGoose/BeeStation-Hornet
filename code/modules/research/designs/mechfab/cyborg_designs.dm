/*
	Chassis
*/

//Borg chassis
/datum/design/borg_chassis
	name = "Cyborg Chassis"
	id = "borg_chassis"
	build_type = MECHFAB
	build_path = /obj/item/endopart/chassis/borg
	materials = list(/datum/material/iron=15000)
	construction_time = 500
	category = list("Cyborg")

/*
	Chest
*/

/datum/design/borg_chest
	name = "Cyborg Torso"
	id = "borg_chest"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/chest/robot/endopart
	materials = list(/datum/material/iron=40000)
	construction_time = 350
	category = list("Cyborg")

/*
	Head
*/

/datum/design/borg_head
	name = "Cyborg Head"
	id = "borg_head"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/head/robot/endopart
	materials = list(/datum/material/iron=5000)
	construction_time = 350
	category = list("Cyborg")

/*
	Arm
*/

/datum/design/borg_l_arm
	name = "Cyborg Left Arm"
	id = "borg_l_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/l_arm/robot
	materials = list(/datum/material/iron=10000)
	construction_time = 200
	category = list("Cyborg")

/datum/design/borg_r_arm
	name = "Cyborg Right Arm"
	id = "borg_r_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/r_arm/robot/endopart
	materials = list(/datum/material/iron=10000)
	construction_time = 200
	category = list("Cyborg")

/*
	leg
*/

/datum/design/borg_l_leg
	name = "Cyborg Left Leg"
	id = "borg_l_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/l_leg/robot/endopart
	materials = list(/datum/material/iron=10000)
	construction_time = 200
	category = list("Cyborg")

/datum/design/borg_r_leg
	name = "Cyborg Right Leg"
	id = "borg_r_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/r_leg/robot/endopart
	materials = list(/datum/material/iron=10000)
	construction_time = 200
	category = list("Cyborg")

