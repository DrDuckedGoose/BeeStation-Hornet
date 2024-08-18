/*
	Designs for cyborg upgrades
*/


//TODO: Implement these - Racc

/datum/design/borg_upgrade_rename
	name = "Cyborg Upgrade (Rename Board)"
	id = "borg_upgrade_rename"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/rename
	materials = list(/datum/material/iron = 5000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_restart
	name = "Cyborg Upgrade (Emergency Reboot Board)"
	id = "borg_upgrade_restart"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/restart
	materials = list(/datum/material/iron = 20000 , /datum/material/glass = 5000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_thrusters
	name = "Cyborg Upgrade (Ion Thrusters)"
	id = "borg_upgrade_thrusters"
	build_type = MECHFAB
	//build_path = /obj/item/borg/upgrade/thrusters
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 6000, /datum/material/plasma = 5000, /datum/material/uranium = 6000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_disablercooler
	name = "Cyborg Upgrade (Rapid Disabler Cooling Module)"
	id = "borg_upgrade_disablercooler"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/disablercooler
	materials = list(/datum/material/iron = 20000 , /datum/material/glass = 6000, /datum/material/gold = 2000, /datum/material/diamond = 2000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_diamonddrill
	name = "Cyborg Upgrade (Diamond Drill)"
	id = "borg_upgrade_diamonddrill"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/item/ddrill
	materials = list(/datum/material/iron=10000, /datum/material/glass = 6000, /datum/material/diamond = 2000)
	construction_time = 80
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_holding
	name = "Cyborg Upgrade (Ore Satchel of Holding)"
	id = "borg_upgrade_holding"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/item/soh
	materials = list(/datum/material/iron = 10000, /datum/material/gold = 2000, /datum/material/uranium = 1000)
	construction_time = 40
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_cutter
	name = "Cyborg Upgrade (Plasma Cutter)"
	id = "borg_upgrade_cutter"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/item/cutter
	materials = list(/datum/material/iron = 10000, /datum/material/gold = 2000, /datum/material/uranium = 1000)
	construction_time = 40
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_lavaproof
	name = "Cyborg Upgrade (Lavaproof Tracks)"
	id = "borg_upgrade_lavaproof"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/lavaproof
	materials = list(/datum/material/iron = 10000, /datum/material/plasma = 4000, /datum/material/titanium = 5000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_syndicate_module
	name = "Cyborg Upgrade (Illegal Modules)"
	id = "borg_syndicate_module"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/syndicate
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 15000, /datum/material/diamond = 10000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_expandedsynthesiser
	name = "Cyborg Upgrade (Hypospray Expanded Synthesiser)"
	id = "borg_upgrade_expandedsynthesiser"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/hypospray/expanded
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 15000, /datum/material/plasma = 8000, /datum/material/uranium = 8000)
	construction_time = 80
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_piercinghypospray
	name = "Cyborg Upgrade (Piercing Hypospray)"
	id = "borg_upgrade_piercinghypospray"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/piercing_hypospray
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 15000, /datum/material/titanium = 5000, /datum/material/diamond = 3000)
	construction_time = 80
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_defibrillator
	name = "Cyborg Upgrade (Defibrillator)"
	id = "borg_upgrade_defibrillator"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/item/defib
	materials = list(/datum/material/iron = 8000, /datum/material/glass = 5000, /datum/material/silver = 4000, /datum/material/gold = 3000)
	construction_time = 80
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_surgicalprocessor
	name = "Cyborg Upgrade (Surgical Processor)"
	id = "borg_upgrade_surgicalprocessor"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/item/processor
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 4000, /datum/material/silver = 4000)
	construction_time = 40
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_trashofholding
	name = "Cyborg Upgrade (Trash Bag of Holding)"
	id = "borg_upgrade_trashofholding"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/item/tboh
	materials = list(/datum/material/gold = 2000, /datum/material/uranium = 1000)
	construction_time = 40
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_advancedmop
	name = "Cyborg Upgrade (Advanced Mop)"
	id = "borg_upgrade_advancedmop"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/item/amop
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 2000)
	construction_time = 40
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_rped
	name = "Cyborg Upgrade (RPED)"
	id = "borg_upgrade_rped"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/item/rped
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 5000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_circuit_app
	name = "Cyborg Upgrade (Circuit Manipulator)"
	id = "borg_upgrade_circuitapp"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/item/circuit_app
	materials = list(/datum/material/iron = 2000, /datum/material/titanium = 500)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_beaker_app
	name = "Cyborg Upgrade (Beaker Storage)"
	id = "borg_upgrade_beakerapp"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/item/beaker_app
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 2250) //Need glass for the new beaker too
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_pinpointer
	name = "Cyborg Upgrade (Crew pinpointer)"
	id = "borg_upgrade_pinpointer"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/item/pinpointer
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

//Misc
/datum/design/mecha_tracking
	name = "Exosuit Tracker (Exosuit Tracking Beacon)"
	id = "mecha_tracking"
	build_type = MECHFAB
	build_path =/obj/item/mecha_parts/mecha_tracking
	materials = list(/datum/material/iron=500)
	construction_time = 50
	category = list("Exosuit Equipment")

/datum/design/mecha_tracking_ai_control
	name = "AI Control Beacon"
	id = "mecha_tracking_ai_control"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_tracking/ai_control
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500, /datum/material/silver = 200)
	construction_time = 50
	category = list("Control Interfaces")

/datum/design/synthetic_flash
	name = "Flash"
	desc = "When a problem arises, SCIENCE is the solution."
	id = "sflash"
	build_type = MECHFAB
	materials = list(/datum/material/iron = 750, /datum/material/glass = 750)
	construction_time = 100
	build_path = /obj/item/assembly/flash/handheld/weak
	category = list("Misc")

// IPC Replacement Parts

/datum/design/robotic_liver
	name = "Substance Processor"
	id = "robotic_liver"
	build_type = MECHFAB
	build_path = /obj/item/organ/liver/cybernetic/upgraded/ipc
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000)
	construction_time = 100
	category = list("IPC Components")

/datum/design/robotic_eyes
	name = "Basic Robotic Eyes"
	id = "robotic_eyes"
	build_type = MECHFAB
	build_path = /obj/item/organ/eyes/robotic
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 2000)
	construction_time = 100
	category = list("IPC Components")

/datum/design/robotic_tongue
	name = "Robotic Voicebox"
	id = "robotic_tongue"
	build_type = MECHFAB
	build_path = /obj/item/organ/tongue/robot
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000)
	construction_time = 100
	category = list("IPC Components")

/datum/design/robotic_stomach
	name = "Micro-cell"
	id = "robotic_stomach"
	build_type = MECHFAB
	build_path = /obj/item/organ/stomach/battery/ipc
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 2000, /datum/material/plasma = 200)
	construction_time = 100
	category = list("IPC Components")

/datum/design/robotic_ears
	name = "Auditory Sensors"
	id = "robotic_ears"
	build_type = MECHFAB
	build_path = /obj/item/organ/ears/robot
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000)
	construction_time = 100
	category = list("IPC Components")

/datum/design/power_cord
	name = "Recharging Electronics"
	id = "power_cord"
	build_type = MECHFAB
	build_path = /obj/item/organ/cyberimp/arm/power_cord
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000)
	construction_time = 100
	category = list("IPC Components")

//service modules

/datum/design/borg_upgrade_botany
	name = "Cyborg Speciality (Botany)"
	id = "borg_upgrade_botany"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/speciality/botany
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000)
	construction_time = 40
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_kitchen
	name = "Cyborg Speciality (Cooking)"
	id = "borg_upgrade_kitchen"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/speciality/kitchen
	materials = list(/datum/material/iron = 2000, /datum/material/silver = 500)
	construction_time = 40
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_casino
	name = "Cyborg Speciality (Casino)"
	id = "borg_upgrade_casino"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/speciality/casino
	materials = list(/datum/material/iron = 2000, /datum/material/gold = 500)
	construction_time = 40
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_party
	name = "Cyborg Speciality (Party)"
	id = "borg_upgrade_party"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/speciality/party
	materials = list(/datum/material/iron = 2000, /datum/material/diamond = 500)
	construction_time = 40
	category = list("Cyborg Upgrade Modules")
