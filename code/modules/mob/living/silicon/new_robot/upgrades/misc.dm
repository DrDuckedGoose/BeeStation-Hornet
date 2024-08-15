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
