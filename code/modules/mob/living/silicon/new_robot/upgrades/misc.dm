//Rename
/obj/item/borg/upgrade/rename
	name = "cyborg reclassification board"
	desc = "Used to rename a cyborg."
	icon_state = "cyborg_upgrade1"
	one_use = TRUE
	///The current custom name we're rocking with
	var/current_name = ""

/obj/item/borg/upgrade/rename/attack_self(mob/user)
	current_name = sanitize_name(stripped_input(user, "Enter new robot name", "Cyborg Reclassification", current_name, MAX_NAME_LEN))
	log_game("[key_name(user)] have set \"[current_name]\" as a name in a cyborg reclassification board at [loc_name(user)]")

/obj/item/borg/upgrade/rename/install(obj/item/new_robot_module/module, mob/living/silicon/new_robot/R, mob/user)
	if(R?.get_shell())
		return
	. = ..()
	var/oldname = R.real_name
	var/oldkeyname = key_name(R)
	R.custom_name = current_name
	R.updatename()
	if(oldname == R.real_name)
		R.notify_ai(RENAME, oldname, R.real_name)
	to_chat(user, "<span class='notice'>You install [src] onto [R], changing their name to [R].</span>")
	log_game("[key_name(user)] have used a cyborg reclassification board to rename [oldkeyname] to [key_name(R)] at [loc_name(user)]")

//Restart
/obj/item/borg/upgrade/restart
	name = "cyborg emergency reboot module"
	desc = "Used to force a reboot of a disabled-but-repaired cyborg, bringing it back online."
	icon_state = "cyborg_upgrade1"
	one_use = TRUE

/obj/item/borg/upgrade/restart/install(obj/item/new_robot_module/module, mob/living/silicon/new_robot/R, mob/user)
	. = ..()
	if(R.health < 0)
		to_chat(user, "<span class='warning'>You have to repair the cyborg before using this module!</span>")
		return FALSE

	if(R.mind)
		R.mind.grab_ghost()
		playsound(loc, 'sound/voice/liveagain.ogg', 75, 1)

	R.revive()
	R.logevent("WARN -- System recovered from unexpected shutdown.")
	R.logevent("System brought online.")

//Ion pulse
/obj/item/borg/upgrade/item/ion_pulse
	name = "ion thruster upgrade"
	desc = "An energy-operated thruster system for cyborgs."
	icon_state = "cyborg_upgrade3"
	upgrade_item = /obj/item/borg/ion_thing

/obj/item/borg/ion_thing
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"

/obj/item/borg/ion_thing/attack_robot(mob/living/user)
	. = ..()
	var/mob/living/silicon/new_robot/R = loc
	if(istype(R))
		RegisterSignal(R, COMSIG_ROBOT_HAS_IONPULSE, PROC_REF(catch_ion_pulse))

/obj/item/borg/ion_thing/dropped(mob/user, silent)
	. = ..()
	UnregisterSignal(user, COMSIG_ROBOT_HAS_IONPULSE)

/obj/item/borg/ion_thing/proc/catch_ion_pulse(datum/source)
	SIGNAL_HANDLER

	return TRUE

//Mag pulse
/obj/item/borg/upgrade/item/mag_pulse
	name = "mag pulse upgrade"
	desc = "An energy-operated mag pulse system for cyborgs."
	icon_state = "cyborg_upgrade3"
	upgrade_item = /obj/item/borg/mag_thing

/obj/item/borg/mag_thing
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"

/obj/item/borg/mag_thing/attack_robot(mob/living/user)
	. = ..()
	var/mob/living/silicon/new_robot/R = loc
	if(istype(R))
		RegisterSignal(R, COMSIG_ROBOT_HAS_MAGPULSE, PROC_REF(catch_mag_pulse))

/obj/item/borg/mag_thing/dropped(mob/user, silent)
	. = ..()
	UnregisterSignal(user, COMSIG_ROBOT_HAS_MAGPULSE)

/obj/item/borg/mag_thing/proc/catch_mag_pulse(datum/source)
	SIGNAL_HANDLER

	return TRUE
