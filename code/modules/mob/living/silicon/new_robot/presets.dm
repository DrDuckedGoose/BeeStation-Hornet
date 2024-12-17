/*
	Syndicte
*/

/mob/living/silicon/new_robot/syndicate
	preset_chassis = /obj/item/endopart/chassis/borg/syndicate

/mob/living/silicon/new_robot/syndicate/set_modularInterface_theme()
	modularInterface.device_theme = THEME_SYNDICATE
	modularInterface.icon_state = "tablet-silicon-syndicate"
	modularInterface.icon_state_powered = "tablet-silicon-syndicate"
	modularInterface.icon_state_unpowered = "tablet-silicon-syndicate"
	modularInterface.update_icon()

/mob/living/silicon/new_robot/syndicate/medical

/mob/living/silicon/new_robot/syndicate/saboteur

/*
	Salvage
*/

/mob/living/silicon/new_robot/salvage
	preset_chassis = /obj/item/endopart/chassis/borg/salvage
