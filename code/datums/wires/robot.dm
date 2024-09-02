/datum/wires/robot
	holder_type = /mob/living/silicon/new_robot
	randomize = TRUE

/datum/wires/robot/New(atom/holder)
	wires = list(
		WIRE_AI, WIRE_CAMERA,
		WIRE_LAWSYNC, WIRE_LOCKDOWN
	)
	add_duds(2)
	..()

/datum/wires/robot/interactable(mob/user)
	var/mob/living/silicon/new_robot/R = holder
	if(R.wires_exposed)
		return TRUE

/datum/wires/robot/get_status()
	var/mob/living/silicon/new_robot/R = holder
	var/list/status = list()
	status += "The law sync module is [R.laws_synced() ? "on" : "off"]."
	status += "The intelligence link display shows [R.connected_ai ? R.connected_ai.name : "NULL"]."
	status += "The camera light is [!isnull(R.builtInCamera) && R.builtInCamera.status ? "on" : "off"]."
	status += "The lockdown indicator is [R.locked ? "on" : "off"]."
	return status

/datum/wires/robot/on_pulse(wire, user)
	var/mob/living/silicon/new_robot/R = holder
	switch(wire)
		if(WIRE_AI) // Pulse to pick a new AI.
			if(!R.emagged)
				var/new_ai
				if(user)
					new_ai = select_active_ai(user)
				else
					new_ai = select_active_ai(R)
				R.notify_ai(DISCONNECT)
				if(new_ai && (new_ai != R.connected_ai))
					log_combat(usr, R, "synced cyborg [R.connected_ai ? "from [ADMIN_LOOKUP(R.connected_ai)]": "false"] to [ADMIN_LOOKUP(new_ai)]", important = FALSE)
					R.connected_ai = new_ai
					var/obj/item/mmi/ai_brain/shell = R.get_shell()
					if(shell)
						shell.undeploy() //If this borg is an AI shell, disconnect the controlling AI and assign ti to a new AI
						R.notify_ai(AI_SHELL)
					else
						R.notify_ai(TRUE)
		if(WIRE_CAMERA) // Pulse to disable the camera.
			if(!QDELETED(R.builtInCamera) && R.console_visible)
				R.builtInCamera.toggle_cam(usr, FALSE)
				R.visible_message("[R]'s camera lens focuses loudly.", "Your camera lens focuses loudly.")
				log_combat(usr, R, "toggled cyborg camera to [R.builtInCamera.status ? "on" : "off"] via pulse", important = FALSE)
		if(WIRE_LAWSYNC) // Forces a law update if possible.
			if(R.laws_synced())
				R.visible_message("[R] gently chimes.", "LawSync protocol engaged.")
				log_combat(usr, R, "forcibly synced cyborg laws via pulse", important = FALSE)
				// TODO, log the laws they gained here
				R.lawsync()
				R.show_laws()
		if(WIRE_LOCKDOWN)
			R.set_locked(!R.locked) // Toggle
			log_combat(usr, R, "[!R.locked ? "locked down" : "released"] via pulse", important = FALSE)
	ui_update()

/datum/wires/robot/on_cut(wire, mob/user, mend = FALSE)
	var/mob/living/silicon/new_robot/R = holder
	switch(wire)
		if(WIRE_AI) // Cut the AI wire to reset AI control.
			if(!mend)
				R.notify_ai(DISCONNECT)
				if (user)
					log_combat(user, R, "cut AI wire on cyborg[R.connected_ai ? " and disconnected from [ADMIN_LOOKUP(R.connected_ai)]": ""]", important = FALSE)
				var/obj/item/mmi/ai_brain/shell = R?.get_shell()
				if(shell)
					shell.undeploy()
				R.connected_ai = null
			R.logevent("AI connection fault [mend?"cleared":"detected"]")
		if(WIRE_LAWSYNC) // Cut the law wire, and the borg will no longer receive law updates from its AI. Repair and it will re-sync.
			var/obj/item/mmi/ai_brain/shell = R.get_shell()
			if(mend)
				if(!R.emagged)
					R.toggle_law_sync(TRUE)
					log_combat(usr, R, "enabled lawsync via wire", important = FALSE)
			else if(!shell?.deployed) //AI shells must always have the same laws as the AI
				R.toggle_law_sync(FALSE)
				if (user)
					log_combat(user, R, "disabled lawsync via wire")
			R.logevent("Lawsync Module fault [mend?"cleared":"detected"]")
		if (WIRE_CAMERA) // Disable the camera.
			if(!QDELETED(R.builtInCamera) && R.console_visible)
				R.builtInCamera.status = mend
				R.visible_message("[R]'s camera lens focuses loudly.", "Your camera lens focuses loudly.")
				R.logevent("Camera Module fault [mend?"cleared":"detected"]")
				if (user)
					log_combat(user, R, "[mend ? "enabled" : "disabled"] cyborg camera via wire")
		if(WIRE_LOCKDOWN) // Simple lockdown.
			R.set_locked(!mend)
			R.logevent("Motor Controller fault [mend?"cleared":"detected"]")
			if (user)
				log_combat(user, R, "[!R.locked ? "locked down" : "released"] via wire", important = FALSE)
	ui_update()
