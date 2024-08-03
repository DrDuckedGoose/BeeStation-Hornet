/*
	Our
		Life
		Inventory
		Defense
	is handled in another castle for readability / sanity. Should be in the same folder as this file
*/
/mob/living/silicon/new_robot
	name = JOB_NAME_CYBORG //"Cyborg"
	real_name = JOB_NAME_CYBORG
	icon = 'icons/obj/robotics/endo.dmi'
	icon_state = "robot"
	maxHealth = 200 //TODO: This will be effected by endo parts - Racc
	health = 200
	bubble_icon = "robot"
	designation = "Default" //used for displaying the prefix & getting the current module of cyborg
	has_limbs = 1
	hud_type = /datum/hud/new_robot //TODO: - Racc
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE
	light_system = MOVABLE_LIGHT
	light_on = FALSE
	///Reference to the chassis we're built from, used for *most* 'things'
	var/obj/item/endopart/chassis/borg/chassis
	///Is our cover open? Essentially passes inputs to our chassis if it is
	var/cover_open = FALSE
	///What's the ambient cell draw of the this robbit
	//TODO: Consider moving this to the life() of endoparts - Racc
	var/ambient_draw = 1
	///The AI we're connected to, our master
	var/mob/living/silicon/ai/connected_ai = null
	///Are we locked down
	var/locked = FALSE
	///When were we last flashed? Used for balancing flash times
	var/last_flashed
	///Is this borg visible in consoles?
	var/console_visible = TRUE
	///Does this borg have juice to run? Handled by our chest components, don't be mad
	var/powered = TRUE
	///Are our wires accesible? Pretty similar to cover_open, but this can have an extra layer of protection
	var/wires_exposed = FALSE
	///Little helper for making sparks on the fly
	var/datum/effect_system/spark_spread/spark_system

	//TODO: Implement these a little more modularly. I don't really want them here. Maybe in a part. - Racc
	var/shell = FALSE
	var/deployed = FALSE
	var/mob/living/silicon/ai/mainframe = null
	var/datum/action/innate/undeployment/undeployment_action = new


//TODO: Consider if this is the best approach, with trying to make it all modular - Racc
//hand stuff
	///List of our hands
	var/list/available_hands = list()

/mob/living/silicon/new_robot/Initialize(mapload, obj/item/endopart/chassis/borg/_chassis)
	. = ..()
//Build our spark effects
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
//Setup stuff from our chassis
	if(_chassis)
		chassis = _chassis
	//Build access
	var/list/access_modules = list()
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, /obj/item/access_module, access_modules)
	if(length(access_modules))
		var/obj/item/access_module/AM = access_modules[1]
		default_access_list = AM.get_access() //TODO: See if you can implement multiple access without this breaking - Racc
	//Build hud
	poll_hud()
	//Grab radio
	var/list/radios = list()
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, /obj/item/radio, radios)
	if(length(radios))
		radio = radios[1] //TODO: See if you can implement multiple radios without this breaking - Racc
	//Grab hands
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, /datum/component/endopart/arm, available_hands)
	if(length(available_hands))
		active_hand_index = 1

/mob/living/silicon/new_robot/Destroy()
	. = ..()
//Clean up our spark effects
	QDEL_NULL(spark_system)
//Poot our chassis out
	chassis?.forceMove(get_turf(src))

/mob/living/silicon/new_robot/attackby(obj/item/I, mob/living/user, params)
	//See if we can pass this event onto our chassis
	if(cover_open)
		chassis?.attackby(I, user, params)
	//THEN see if we're opening our cover or not
	if(istype(I, /obj/item/card)) //TODO: Set this up properly, to be an emag or robo ID - Racc
		to_chat(user, "<span class='warning'>You [!cover_open ? "open" : "close"] [src]'s cover!</span>")
		cover_open = !cover_open
		return
	else if(!cover_open)
		to_chat(user, "<span class='warning'>[src]'s cover is closed!</span>")
	return ..()

/mob/living/silicon/new_robot/tool_act(mob/living/user, obj/item/I, tool_type)
	. = ..()
	if(cover_open)
		return chassis?.tool_act(user, I, tool_type)
	else
		to_chat(user, "<span class='warning'>[src]'s cover is closed!</span>")

//Display our stats on the side tab
/mob/living/silicon/new_robot/get_stat_tab_status()
	var/list/tab_data = ..()
//What's our cell/s charge at?
	var/list/cells = list()
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, /obj/item/stock_parts/cell, cells)
	for(var/obj/item/stock_parts/cell/cell as() in cells)
		if(cell)
			tab_data["[cell]: Charge Left"] = GENERATE_STAT_TEXT("[cell.charge]/[cell.maxcharge]")
	if(!length(cells))
		tab_data["Charge Left"] = GENERATE_STAT_TEXT("No Cell Inserted!")
	return tab_data
//What modules are we rocking with
//Which AI are we connected to

/mob/living/silicon/new_robot/proc/consume_energy(amount)
	return SEND_SIGNAL(chassis, COMSIG_ENDO_CONSUME_ENERGY, amount)

//TODO: This is probably temporary - Racc
/mob/living/silicon/new_robot/proc/poll_hud()
	SEND_SIGNAL(chassis, COMSIG_ENDO_APPLY_HUD, hud_used)

///Returns wether this borg is free or not
/mob/living/silicon/new_robot/proc/is_free()
	//TODO: - Racc
	//Must not be connected to an AI, emagged, scrambled, or a shell
	return TRUE

///Helper to check if something can ride us, checks with the chassis
/mob/living/silicon/new_robot/proc/can_ride(mob/M)
	//TODO: - Racc
	//Mkae sure this checks the chassis, as that decides the rules
	return TRUE

//TODO: Consider implementing this in the chassis instead - Racc
///Helper to check if we're allowed to wear a particular hat, checks with the chassis
/mob/living/silicon/new_robot/proc/can_wear(var/obj/item/clothing/head/hat)
	return TRUE

//TODO: Consider implementing this in the chassis instead - Racc
/mob/living/silicon/new_robot/proc/can_dispose()
	return TRUE

///Change our emagged state
/mob/living/silicon/new_robot/proc/set_emagged(new_state)
	//TODO: Implement this - Racc
	/*
	emagged = new_state
	module.rebuild_modules()
	update_icons()
	if(emagged)
		throw_alert("hacked", /atom/movable/screen/alert/hacked)
	else
		clear_alert("hacked")
	set_modularInterface_theme()
	*/

///Easy way for getting our cell for other code stuff
//TODO: Make sure overwriting this isn't bad news - Racc
/mob/living/silicon/new_robot/get_cell()
	//TODO: Revisit this, maybe return the least charged cell? - Racc
	var/list/cells = list()
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, /obj/item/stock_parts/cell, cells)
	if(!length(cells))
		return FALSE
	return cells[1]

///Easy way for getting our MMI, if we have one
/mob/living/silicon/new_robot/proc/get_mmi(index = 1)
	//TODO: Revisit this, particularly how we decide which MMI to return - Racc
	var/list/mmi = list()
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, /obj/item/mmi, mmi)
	if(!length(mmi))
		return FALSE
	return mmi[min(index, length(mmi))]

///TODO: Implement this - Racc
/mob/living/silicon/new_robot/proc/is_emagged()
	return FALSE

///TODO: Implement this - Racc
/mob/living/silicon/new_robot/proc/self_destruct()
	return

///TODO: Implement this - Racc
/mob/living/silicon/new_robot/proc/set_locked(state = TRUE)
	return

//Helper to respawn the consumables for our modules
/mob/living/silicon/new_robot/proc/respawn_consumable(coeff = 1)
	var/list/modules = list()
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, /obj/item/new_robot_module, modules)
	for(var/obj/item/new_robot_module/module as() in modules)
		module.respawn_consumable(src, coeff)

//Helper for flashing
//TODO: Find where this is used and try standarizing it, messaged and such - Racc
/mob/living/silicon/new_robot/proc/try_flash()
	if(last_flashed + FLASHED_COOLDOWN < world.time)
		last_flashed = world.time
		return TRUE

///TODO: Implement this - Racc
/mob/living/silicon/new_robot/proc/TryConnectToAI()
	return
	/*
	connected_ai = select_active_ai_with_fewest_borgs()
	if(connected_ai)
		connected_ai.connected_robots += src
		lawsync()
		lawupdate = TRUE
		wires.ui_update()
		return TRUE
	picturesync()
	wires.ui_update()
	return FALSE
	*/

///Helper to check if our head, if we have one, has its laws set to be synced
/mob/living/silicon/new_robot/proc/laws_synced()
	//TODO: - Racc
	return TRUE

///Helper to toggle law sync mode
/mob/living/silicon/new_robot/proc/toggle_law_sync(mode)
	//TODO: If no mode provided, just toggle, thing = !thing - Racc
	return TRUE

//TODO: Go over this - Racc
/mob/living/silicon/new_robot/proc/notify_ai(notifytype, oldname, newname)
	if(!connected_ai)
		return
	switch(notifytype)
		if(NEW_BORG) //New Cyborg
			to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - New cyborg connection detected: <a href='?src=[REF(connected_ai)];track=[html_encode(name)]'>[name]</a></span><br>")
		if(NEW_MODULE) //New Module
			to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - Cyborg module change detected: [name] has loaded the [designation] module.</span><br>")
		if(RENAME) //New Name
			to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - Cyborg reclassification detected: [oldname] is now designated as [newname].</span><br>")
		if(AI_SHELL) //New Shell
			to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - New cyborg shell detected: <a href='?src=[REF(connected_ai)];track=[html_encode(name)]'>[name]</a></span><br>")
		if(DISCONNECT) //Tampering with the wires
			to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - Remote telemetry lost with [name].</span><br>")

/mob/living/silicon/new_robot/proc/lawsync()
	return
	//TODO: - Racc
	/*
	laws_sanity_check()
	var/datum/ai_laws/master = connected_ai?.laws
	var/temp
	if (master)
		laws.devillaws.len = master.devillaws.len
		for (var/index = 1, index <= master.devillaws.len, index++)
			temp = master.devillaws[index]
			if (length(temp) > 0)
				laws.devillaws[index] = temp

		laws.ion.len = master.ion.len
		for (var/index in 1 to master.ion.len)
			temp = master.ion[index]
			if (length(temp) > 0)
				laws.ion[index] = temp

		laws.hacked.len = master.hacked.len
		for (var/index in 1 to master.hacked.len)
			temp = master.hacked[index]
			if (length(temp) > 0)
				laws.hacked[index] = temp

		if(master.zeroth_borg) //If the AI has a defined law zero specifically for its borgs, give it that one, otherwise give it the same one. --NEO
			temp = master.zeroth_borg
		else
			temp = master.zeroth
		laws.zeroth = temp

		laws.inherent.len = master.inherent.len
		for (var/index in 1 to master.inherent.len)
			temp = master.inherent[index]
			if (length(temp) > 0)
				laws.inherent[index] = temp

		laws.supplied.len = master.supplied.len
		for (var/index in 1 to master.supplied.len)
			temp = master.supplied[index]
			if (length(temp) > 0)
				laws.supplied[index] = temp

		var/datum/computer_file/program/borg_self_monitor/program = modularInterface.get_self_monitoring()
		if(program)
			program.force_full_update()

	picturesync()
	*/
