//TODO: Rewrite this to be compatible with new borg stuff - Racc
/datum/admins/proc/open_borgopanel(borgo in GLOB.silicon_mobs)
	set category = "Admin"
	set name = "Show Borg Panel"
	set desc = "Show borg panel"

	if(!check_rights(R_ADMIN))
		return

	//If borgo isn't a borg, prompt user to pick one
	if(!istype(borgo, /mob/living/silicon/new_robot))
		borgo = input("Select a borg", "Select a borg", null, null) as null|anything in sort_names(GLOB.silicon_mobs)
	//If the one they picked ALSO isn't a borg
	if(!istype(borgo, /mob/living/silicon/new_robot))
		to_chat(usr, "<span class='warning'>Borg is required for borgpanel</span>")

	var/datum/borgpanel/borgpanel = new(usr, borgo)

	borgpanel.ui_interact(usr)



/datum/borgpanel
	var/mob/living/silicon/new_robot/borg
	var/user

/datum/borgpanel/New(to_user, mob/living/silicon/robot/to_borg)
	if(!istype(to_borg))
		qdel(src)
		CRASH("Borg panel is only available for borgs")
	user = CLIENT_FROM_VAR(to_user)

	if (!user)
		CRASH("Borg panel attempted to open to a mob without a client")

	borg = to_borg


/datum/borgpanel/ui_state(mob/user)
	return GLOB.admin_state

/datum/borgpanel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BorgPanel", "Borging Panel")
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/borgpanel/ui_data(mob/user)
	. = list()
	.["borg"] = list(
		"ref" = REF(borg),
		"name" = "[borg]",
		"emagged" = borg.emagged,
		"lawupdate" = borg.laws_synced(),
		"lockdown" = borg.locked,
		"scrambledcodes" = borg.console_visible
	)
	//Modules
	var/list/modules = list()
	SEND_SIGNAL(borg.chassis, COMSIG_ENDO_LIST_PART, /obj/item/new_robot_module, modules)
	for(var/obj/item/new_robot_module/module as() in modules)
		.["active_module"] = "[module], [.["active_module"] ]"
	//Upgrades
	.["upgrades"] = list()
	for(var/upgradetype in subtypesof(/obj/item/borg/upgrade)-/obj/item/borg/upgrade/hypospray)
		var/obj/item/borg/upgrade/upgrade = upgradetype
		var/installed = FALSE
		for(var/obj/item/new_robot_module/module as() in modules)
			if(locate(upgrade) in module.contents)
				installed = TRUE
		.["upgrades"] += list(list("name" = initial(upgrade.name), "installed" = installed, "type" = upgradetype))
	//Other lame shit
	.["laws"] = borg.laws ? borg.laws.get_law_list(include_zeroth = TRUE) : list()
	.["channels"] = list()
	for (var/k in GLOB.radiochannels)
		if (k == RADIO_CHANNEL_COMMON)
			continue
		.["channels"] += list(list("name" = k, "installed" = (k in borg.radio.channels)))
	var/obj/item/stock_parts/cell/cell = borg.get_cell()
	.["cell"] = cell ? list("missing" = FALSE, "maxcharge" = cell.maxcharge, "charge" = cell.charge) : list("missing" = TRUE, "maxcharge" = 1, "charge" = 0)
	.["modules"] = list()
	for(var/moduletype in typesof(/obj/item/robot_module))
		var/obj/item/robot_module/module = moduletype
		.["modules"] += list(list(
			"name" = initial(module.name),
			"type" = "[module]"
		))
	.["ais"] = list(list("name" = "None", "ref" = "null", "connected" = isnull(borg.connected_ai)))
	for(var/mob/living/silicon/ai/ai in GLOB.ai_list)
		.["ais"] += list(list("name" = ai.name, "ref" = REF(ai), "connected" = (borg.connected_ai == ai)))


/datum/borgpanel/ui_act(action, params)
	if(..())
		return
	var/obj/item/stock_parts/cell/cell = borg.get_cell()
	switch (action)
		if ("set_charge")
			var/newcharge = input("New charge (0-[cell?.maxcharge]):", borg.name, cell?.charge) as num|null
			if (newcharge)
				cell.charge = clamp(newcharge, 0, cell.maxcharge)
				message_admins("[key_name_admin(user)] set the charge of [ADMIN_LOOKUPFLW(borg)] to [cell.charge].")
				log_admin("[key_name(user)] set the charge of [key_name(borg)] to [cell.charge].")
		if ("remove_cell")
			QDEL_NULL(cell)
			message_admins("[key_name_admin(user)] deleted the cell of [ADMIN_LOOKUPFLW(borg)].")
			log_admin("[key_name(user)] deleted the cell of [key_name(borg)].")
		if ("change_cell")
			var/chosen = pick_closest_path(null, make_types_fancy(typesof(/obj/item/stock_parts/cell)))
			if (!ispath(chosen))
				chosen = text2path(chosen)
			if (chosen)
				if (cell)
					QDEL_NULL(cell)
				var/new_cell = new chosen(borg)
				cell = new_cell
				cell.charge = cell.maxcharge
				borg.diag_hud_set_borgcell()
				message_admins("[key_name_admin(user)] changed the cell of [ADMIN_LOOKUPFLW(borg)] to [new_cell].")
				log_admin("[key_name(user)] changed the cell of [key_name(borg)] to [new_cell].")
		if ("toggle_emagged")
			borg.set_emagged(!borg.emagged)
			if (borg.emagged)
				message_admins("[key_name_admin(user)] emagged [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] emagged [key_name(borg)].")
			else
				message_admins("[key_name_admin(user)] un-emagged [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] un-emagged [key_name(borg)].")
		if ("toggle_lawupdate")
			borg.toggle_law_sync()
			if (borg.laws_synced())
				message_admins("[key_name_admin(user)] enabled lawsync on [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] enabled lawsync on [key_name(borg)].")
			else
				message_admins("[key_name_admin(user)] disabled lawsync on [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] disabled lawsync on [key_name(borg)].")
		if ("toggle_lockdown")
			borg.set_locked(!borg.locked)
			if (borg.locked)
				message_admins("[key_name_admin(user)] locked down [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] locked down [key_name(borg)].")
			else
				message_admins("[key_name_admin(user)] released [ADMIN_LOOKUPFLW(borg)] from lockdown.")
				log_admin("[key_name(user)] released [key_name(borg)] from lockdown.")
		if ("toggle_scrambledcodes")
			borg.console_visible = !borg.console_visible
			if (borg.console_visible)
				message_admins("[key_name_admin(user)] enabled scrambled codes on [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] enabled scrambled codes on [key_name(borg)].")
			else
				message_admins("[key_name_admin(user)] disabled scrambled codes on [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] disabled scrambled codes on [key_name(borg)].")
		if ("rename")
			var/new_name = stripped_input(user,"What would you like to name this cyborg?","Input a name",borg.real_name,MAX_NAME_LEN)
			if(!new_name)
				return
			message_admins("[key_name_admin(user)] renamed [ADMIN_LOOKUPFLW(borg)] to [new_name].")
			log_admin("[key_name(user)] renamed [key_name(borg)] to [new_name].")
			borg.fully_replace_character_name(borg.real_name,new_name)
		/*
		//TODO: - Racc
		if ("toggle_upgrade")
			var/upgradepath = text2path(params["upgrade"])
			var/obj/item/borg/upgrade/installedupgrade = locate(upgradepath) in borg
			if (installedupgrade)
				installedupgrade.deactivate(borg, user)
				borg.upgrades -= installedupgrade
				message_admins("[key_name_admin(user)] removed the [installedupgrade] upgrade from [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] removed the [installedupgrade] upgrade from [key_name(borg)].")
				qdel(installedupgrade)
			else
				var/obj/item/borg/upgrade/upgrade = new upgradepath(borg)
				upgrade.action(borg, user)
				borg.upgrades += upgrade
				message_admins("[key_name_admin(user)] added the [upgrade] borg upgrade to [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] added the [upgrade] borg upgrade to [key_name(borg)].")
		*/
		if ("toggle_radio")
			var/channel = params["channel"]
			if (channel in borg.radio.channels) // We're removing a channel
				if (!borg.radio.keyslot) // There's no encryption key. This shouldn't happen but we can cope
					borg.radio.channels -= channel
					if (channel == RADIO_CHANNEL_SYNDICATE)
						borg.radio.syndie = FALSE
					else if (channel == "CentCom")
						borg.radio.independent = FALSE
				else
					borg.radio.keyslot.channels -= channel
					if (channel == RADIO_CHANNEL_SYNDICATE)
						borg.radio.keyslot.syndie = FALSE
					else if (channel == "CentCom")
						borg.radio.keyslot.independent = FALSE
				message_admins("[key_name_admin(user)] removed the [channel] radio channel from [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] removed the [channel] radio channel from [key_name(borg)].")
			else	// We're adding a channel
				if (!borg.radio.keyslot) // Assert that an encryption key exists
					borg.radio.keyslot = new (borg.radio)
				borg.radio.keyslot.channels[channel] = 1
				if (channel == RADIO_CHANNEL_SYNDICATE)
					borg.radio.keyslot.syndie = TRUE
				else if (channel == "CentCom")
					borg.radio.keyslot.independent = TRUE
				message_admins("[key_name_admin(user)] added the [channel] radio channel to [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] added the [channel] radio channel to [key_name(borg)].")
			borg.radio.recalculateChannels()
		/*
		TODO: - Racc
		if ("setmodule")
			var/newmodulepath = text2path(params["module"])
			if (ispath(newmodulepath))
				borg.module.transform_to(newmodulepath)
				message_admins("[key_name_admin(user)] changed the module of [ADMIN_LOOKUPFLW(borg)] to [newmodulepath].")
				log_admin("[key_name(user)] changed the module of [key_name(borg)] to [newmodulepath].")
		*/
		if ("slavetoai")
			var/mob/living/silicon/ai/newai = locate(params["slavetoai"]) in GLOB.ai_list
			var/obj/item/food/bbqribs/ai_brain/shell = borg.get_shell()
			if (newai && newai != borg.connected_ai)
				borg.notify_ai(DISCONNECT)
				if(shell)
					shell.undeploy()
				borg.connected_ai = newai
				borg.notify_ai(TRUE)
				message_admins("[key_name_admin(user)] slaved [ADMIN_LOOKUPFLW(borg)] to the AI [ADMIN_LOOKUPFLW(newai)].")
				log_admin("[key_name(user)] slaved [key_name(borg)] to the AI [key_name(newai)].")
			else if (params["slavetoai"] == "null")
				borg.notify_ai(DISCONNECT)
				if(shell)
					shell.undeploy()
				borg.connected_ai = null
				message_admins("[key_name_admin(user)] freed [ADMIN_LOOKUPFLW(borg)] from being slaved to an AI.")
				log_admin("[key_name(user)] freed [key_name(borg)] from being slaved to an AI.")
			if (borg.laws_synced())
				borg.lawsync()

	. = TRUE
