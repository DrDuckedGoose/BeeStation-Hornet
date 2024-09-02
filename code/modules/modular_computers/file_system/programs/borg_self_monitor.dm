/datum/computer_file/program/borg_self_monitor
	filename = "borg_self_monitor"
	filedesc = "Cyborg Self-Monitoring"
	extended_desc = "A built-in app for cyborg self-management and diagnostics."
	ui_header = "borg_self_monitor.gif" //DEBUG -- new icon before PR
	program_icon_state = "command"
	requires_ntnet = FALSE
	available_on_ntnet = FALSE
	unsendable = TRUE
	undeletable = TRUE
	usage_flags = PROGRAM_TABLET
	size = 5
	tgui_id = "NtosCyborgSelfMonitor"
	///A typed reference to the computer, specifying the borg tablet type
	var/obj/item/modular_computer/tablet/integrated/tablet

/datum/computer_file/program/borg_self_monitor/Destroy()
	tablet = null
	return ..()

/datum/computer_file/program/borg_self_monitor/on_start(mob/living/user)
	if(!istype(computer, /obj/item/modular_computer/tablet/integrated))
		to_chat(user, "<span class='warning'>A warning flashes across \the [computer]: Device Incompatible.</span>")
		return FALSE
	. = ..()
	if(.)
		tablet = computer
		if(tablet.device_theme == THEME_SYNDICATE)
			program_icon_state = "command-syndicate"
		return TRUE
	return FALSE

//TODO: Add signal list thing for endoparts and items to feed in their own data - Racc
/datum/computer_file/program/borg_self_monitor/ui_data(mob/user)
	var/list/data = list()
	if(!iscyborg(user))
		return data
	var/mob/living/silicon/new_robot/borgo = tablet.borgo

	data["name"] = borgo.name
	data["designation"] = borgo.designation //Borgo module type
	data["masterAI"] = borgo.connected_ai //Master AI

	var/charge = 0
	var/maxcharge = 1
	var/obj/item/stock_parts/cell/cell = borgo?.get_cell()
	if(cell)
		charge = cell.charge
		maxcharge = cell.maxcharge
	data["charge"] = charge //Current cell charge
	data["maxcharge"] = maxcharge //Cell max charge
	data["integrity"] = (borgo.health / borgo.maxHealth) * 100 //Borgo health, as percentage
	data["sensors"] = "[borgo.sensors_on?"ACTIVE":"DISABLED"]"
	data["printerPictures"] = borgo.connected_ai ? length(borgo.connected_ai.aicamera?.stored) : length(borgo.aicamera?.stored) //Number of pictures taken, synced to AI if available
	data["selfDestructAble"] = (borgo.emagged || istype(borgo, /mob/living/silicon/new_robot/syndicate))
	data["cameraRadius"] = isnull(borgo.aicamera) ? 1 : borgo.aicamera.picture_size_x // picture_size_x and picture_size_y should always be the same.
	//Cover, TRUE for locked
	data["cover"] = "[borgo.cover_open? "UNLOCKED":"LOCKED"]"
	//Ability to move. FAULT if lockdown wire is cut, DISABLED if borg locked, ENABLED otherwise
	data["locomotion"] = "[borgo.wires.is_cut(WIRE_LOCKDOWN)?"FAULT":"[borgo.locked?"DISABLED":"ENABLED"]"]"
	//DEBUG -- Camera(net) wire. FAULT if cut (or no cameranet camera), DISABLED if pulse-disabled, NOMINAL otherwise
	data["wireCamera"] = "[!borgo.builtInCamera || borgo.wires.is_cut(WIRE_CAMERA)?"FAULT":"[borgo.builtInCamera.can_use()?"NOMINAL":"DISABLED"]"]"
	//AI wire. FAULT if wire is cut, CONNECTED if connected to AI, READY otherwise
	data["wireAI"] = "[borgo.wires.is_cut(WIRE_AI)?"FAULT":"[borgo.connected_ai?"CONNECTED":"READY"]"]"
	//Law sync wire. FAULT if cut, NOMINAL otherwise
	data["wireLaw"] = "[borgo.wires.is_cut(WIRE_LAWSYNC)?"FAULT":"NOMINAL"]"

	return data

/datum/computer_file/program/borg_self_monitor/ui_static_data(mob/user)
	var/list/data = list()
	if(!iscyborg(user))
		return data
	var/mob/living/silicon/robot/borgo = user

	data["Laws"] = borgo.laws.get_law_list(TRUE, TRUE, FALSE)
	data["borgLog"] = tablet.borglog
	return data

/datum/computer_file/program/borg_self_monitor/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/mob/living/silicon/new_robot/borgo = tablet.borgo

	switch(action)
		if("coverunlock")
			if(borgo.locked)
				borgo.locked = FALSE
				borgo.update_icons()
				if(borgo.emagged)
					borgo.logevent("ChÃ¥vÃis cover lock has been [borgo.locked ? "engaged" : "released"]") //"The cover interface glitches out for a split second"
				else
					borgo.logevent("Chassis cover lock has been [borgo.locked ? "engaged" : "released"]")

		if("lawchannel")
			borgo.set_autosay()

		if("lawstate")
			borgo.checklaws()

		if("alertPower")
			if(borgo.stat == CONSCIOUS)
				var/obj/item/stock_parts/cell/cell = borgo?.get_cell()
				if(!cell || !cell.charge)
					borgo.visible_message("<span class='notice'>The power warning light on <span class='name'>[borgo]</span> flashes urgently.</span>", \
						"You announce you are operating in low power mode.")
					playsound(borgo, 'sound/machines/buzz-two.ogg', 50, FALSE)

		if("toggleSensors")
			borgo.toggle_sensors()

		if("viewImage")
			if(borgo.connected_ai)
				borgo.connected_ai.aicamera?.viewpictures(usr)
			else
				borgo.aicamera?.viewpictures(usr)

		if("printImage")
			var/obj/item/camera/siliconcam/robot_camera/borgcam = borgo.aicamera
			borgcam?.borgprint(usr)

		if("lampIntensity")
			var/list/lamps = list()
			SEND_SIGNAL(borgo.chassis, COMSIG_ENDO_LIST_PART, /datum/endo_assembly/item/lamp, lamps)
			if(length(lamps))
				var/datum/endo_assembly/item/lamp/lamp = lamps[1]
				lamp.lamp_intensity = clamp(text2num(params["ref"]), 1, 5)
				lamp.lamp.toggle_headlamp(borgo, FALSE, TRUE)

		if("cameraRadius")
			var/obj/item/camera/siliconcam/robot_camera/borgcam = borgo.aicamera
			if(isnull(borgcam))
				CRASH("Cyborg embedded AI camera is null somehow, was it qdeleted?")
			var/desired_radius = text2num(params["ref"])
			if(isnull(desired_radius))
				return
			// respect the limits
			if(desired_radius > borgcam.picture_size_x_max || desired_radius < borgcam.picture_size_x_min)
				log_href_exploit(usr, " attempted to select an invalid borg camera size '[desired_radius]'.")
				return
			borgcam.picture_size_x = desired_radius
			borgcam.picture_size_y = desired_radius

		if("selfDestruct")
			if(borgo.stat || borgo.locked) //No detonation while stunned or locked down
				return
			if(borgo.emagged || istype(borgo, /mob/living/silicon/new_robot/syndicate)) //This option shouldn't even be showing otherwise
				borgo.self_destruct(borgo)

/**
  * Forces a full update of the UI, if currently open.
  *
  * Forces an update that includes refreshing ui_static_data. Called by
  * law changes and borg log additions.
  */
/datum/computer_file/program/borg_self_monitor/proc/force_full_update()
	if(tablet)
		var/datum/tgui/active_ui = SStgui.get_open_ui(tablet.borgo, src)
		if(active_ui)
			active_ui.send_full_update(bypass_cooldown = TRUE)
