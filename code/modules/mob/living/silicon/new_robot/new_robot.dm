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
	base_icon_state  = "robot"
	maxHealth = 200 //TODO: This will be effected by endo parts - Racc
	health = 200
	bubble_icon = "robot"
	designation = "Default" //used for displaying the prefix & getting the current module of cyborg
	has_limbs = 1
	hud_type = /datum/hud/new_robot
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE
	light_system = MOVABLE_LIGHT
	light_on = FALSE
	///Reference to the chassis we're built from, used for *most* 'things'
	var/obj/item/endopart/chassis/borg/chassis
	var/datum/component/endopart/chassis/chassis_component //Shortcut for getting things straight from the component
	///Is our cover open? Essentially passes inputs to our chassis if it is
	var/cover_open = FALSE
	///What's the ambient cell draw of the this robbit
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
	///Has this robbit been emagged
	var/emagged = FALSE
	///Used for name changing and interfacing with robot name PREFS
	var/custom_name = ""
	///Has this robbit been ratvar'd
	var/ratvar = FALSE
	///So this is a lil' stinky, but it's very convenient 'n I'm a big ol' lazy bastard who's incapable of being loved or giving love, lord help me. Bacon had this on the original robot.dm
	var/obj/item/clockwork/clockwork_slab/internal_clock_slab = null
	///List of our hands
	var/list/available_hands = list()

/mob/living/silicon/new_robot/Initialize(mapload, obj/item/endopart/chassis/borg/_chassis)
	. = ..()
//Build our spark effects
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
//wires
	wires = new /datum/wires/robot(src)
	AddElement(/datum/element/empprotection, EMP_PROTECT_WIRES)
	RegisterSignal(src, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(charge))
//Setup stuff from our chassis
	if(_chassis)
		chassis = _chassis
		chassis_component = chassis.GetComponent(/datum/component/endopart/chassis)
	//Build access
	var/list/access_modules = list()
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, /obj/item/access_module, access_modules)
	if(length(access_modules))
		var/obj/item/access_module/AM = access_modules[1]
		default_access_list = AM.get_access() //TODO: See if you can implement multiple access without this breaking - Racc
		QDEL_NULL(internal_id_card)
		create_access_card(default_access_list)
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
	set_hand_index(active_hand_index)

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
		tab_data["Charge Left"] = GENERATE_STAT_TEXT("No Cells Inserted!")
/*
//TODO: This is related to module items that use energy or something? - Racc
if(module)
		for(var/datum/robot_energy_storage/st in module.storages)
			tab_data["[st.name]"] = GENERATE_STAT_TEXT("[st.energy]/[st.max_energy]")
*/
//Which AI are we connected to
	if(connected_ai)
		tab_data["Master AI"] = GENERATE_STAT_TEXT("[connected_ai.name]")
	return tab_data

///Easy way for getting our cell for other code stuff
//TODO: Make sure overwriting this isn't bad news - Racc
/mob/living/silicon/new_robot/get_cell()
	//TODO: Revisit this, maybe return the least charged cell? - Racc
	var/list/cells = list()
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, /obj/item/stock_parts/cell, cells)
	if(!length(cells))
		return FALSE
	return cells[1]

/mob/living/silicon/new_robot/create_mob_hud()
	. = ..()
	poll_hud()

/mob/living/silicon/new_robot/fully_replace_character_name(oldname, newname)
	..()
	if(oldname != real_name)
		notify_ai(RENAME, oldname, newname)
	if(!QDELETED(builtInCamera))
		builtInCamera.c_tag = real_name
		modularInterface.saved_identification = real_name
	custom_name = newname

/mob/living/silicon/new_robot/revive(full_heal = 0, admin_revive = 0)
	if(..()) //successfully ressuscitated from death
		if(!QDELETED(builtInCamera) && !wires.is_cut(WIRE_CAMERA))
			builtInCamera.toggle_cam(src,0)
		if(admin_revive)
			locked = TRUE
		notify_ai(NEW_BORG)
		wires.ui_update()
		. = 1 //Should this be TRUE? The parent proc also sets it to 1.

/mob/living/silicon/new_robot/proc/consume_energy(amount)
	return SEND_SIGNAL(chassis, COMSIG_ROBOT_CONSUME_ENERGY, amount)

//TODO: This is probably temporary - Racc
/mob/living/silicon/new_robot/proc/poll_hud()
	SEND_SIGNAL(chassis, COMSIG_ENDO_APPLY_HUD, hud_used)

///Returns wether this borg is free or not
/mob/living/silicon/new_robot/proc/is_free()
	//TODO: - Racc
	//Must not be connected to an AI, emagged, scrambled, or a shell
	return TRUE

//TODO: Consider implementing this in the chassis instead - Racc
///Helper to check if we're allowed to wear a particular hat, checks with the chassis
/mob/living/silicon/new_robot/proc/can_wear(var/obj/item/clothing/head/hat)
	return chassis_component.can_wear(hat)

//TODO: Consider implementing this in the chassis instead - Racc
/mob/living/silicon/new_robot/proc/can_dispose()
	return TRUE

///Change our emagged state
/mob/living/silicon/new_robot/proc/set_emagged(new_state)
	emagged = new_state
	if(emagged)
		throw_alert("hacked", /atom/movable/screen/alert/hacked)
	else
		clear_alert("hacked")
	SEND_SIGNAL(chassis, COMSIG_ROBOT_SET_EMAGGED, new_state)
	//TODO: Implement this - Racc
	/*
	set_modularInterface_theme()
	*/

/mob/living/silicon/new_robot/proc/set_ratvar(new_state)
	ratvar = new_state
	if(ratvar)
		internal_clock_slab = new(src)
		throw_alert("ratvar", /atom/movable/screen/alert/ratvar)
	else
		qdel(internal_clock_slab)
		clear_alert("ratvar")

///Easy way for getting our MMI, if we have one
/mob/living/silicon/new_robot/proc/get_mmi(index = 1)
	//TODO: Revisit this, particularly how we decide which MMI to return - Racc
	var/list/mmi = list()
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, /obj/item/mmi, mmi)
	if(!length(mmi))
		return FALSE
	return mmi[min(index, length(mmi))]

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

///Helper for getting our AI boris module, if we have one
/mob/living/silicon/new_robot/proc/get_shell()
	//You should only ever have one boris module, but you can never be too sure
	var/list/brains = list()
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, /obj/item/food/bbqribs/ai_brain, brains)
	if(!length(brains))
		return
	return brains[1]

/mob/living/silicon/new_robot/proc/updatename(client/C)
	if(get_shell())
		return
	if(!C)
		C = client
	var/changed_name = ""
	if(custom_name)
		changed_name = custom_name
	if(changed_name == "" && C && C.prefs.read_character_preference(/datum/preference/name/cyborg) != DEFAULT_CYBORG_NAME)
		if(apply_pref_name(/datum/preference/name/cyborg, C))
			return //built in camera handled in proc
	if(!changed_name)
		changed_name = get_standard_name()
	real_name = changed_name
	name = real_name
	if(!QDELETED(builtInCamera))
		builtInCamera.c_tag = real_name	//update the camera name too

//TODO: - Racc
/mob/living/silicon/new_robot/proc/get_standard_name()
	//return "[(designation ? "[designation] " : "")][mmi.braintype]-[ident]"

/mob/living/silicon/new_robot/proc/charge(datum/source, amount, repairs)
	SIGNAL_HANDLER

	respawn_consumable(amount * 0.00)
	var/obj/item/stock_parts/cell/cell = get_cell()
	if(cell)
		cell.charge = min(cell.charge + amount, cell.maxcharge)
	//TODO: I don't like this - Racc
	if(repairs)
		heal_bodypart_damage(repairs, repairs - 1)

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
