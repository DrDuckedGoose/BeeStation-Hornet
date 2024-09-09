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
	maxHealth = 200
	health = 200
	bubble_icon = "robot"
	designation = "Default" //used for displaying the prefix & getting the current module of cyborg
	has_limbs = TRUE
	hud_type = /datum/hud/new_robot
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE
	light_system = MOVABLE_LIGHT
	light_on = FALSE

	///Reference to the chassis we're built from, used for *most* 'things'
	var/obj/item/endopart/chassis/borg/chassis
	var/datum/component/endopart/chassis/chassis_component //Shortcut for getting things straight from the component
	///What chassis we use as a preset, if we're not given one
	var/preset_chassis = /obj/item/endopart/chassis/borg/transform_machine
	///Is our cover open? Essentially passes inputs to our chassis if it is
	var/cover_open = TRUE//FALSE
	///Overlay for cover
	var/mutable_appearance/cover_overlay
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
	///What access is needed to modify this robot
	var/list/req_access = list(ACCESS_ROBOTICS)
	///Cyborgs will sync their laws with their AI by default
	var/law_update = TRUE
	///Quick ref to our discovery component
	var/datum/component/discoverable/robot/discovery_component

/mob/living/silicon/new_robot/Initialize(mapload, obj/item/endopart/chassis/borg/_chassis)
	. = ..()
//Overlay
	cover_overlay = mutable_appearance('icons/mob/robots.dmi', "", layer = ABOVE_MOB_LAYER)
//Footstep sounds for muh immersion
	AddElement(/datum/element/footstep, FOOTSTEP_OBJ_ROBOT)
//Build our spark effects
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
//wires
	wires = new /datum/wires/robot(src)
	AddElement(/datum/element/empprotection, EMP_PROTECT_WIRES)
	RegisterSignal(src, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(charge))
//Setup stuff from our chassis
	if(!_chassis)
		_chassis = new preset_chassis(get_turf(src))
	chassis = _chassis
	chassis_component = chassis.GetComponent(/datum/component/endopart/chassis)
	if(!chassis_component.assembled_mob)
		chassis_component.build_robot(src)
	//Build access
	var/list/access_modules = list()
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, /obj/item/access_module, access_modules)
	for(var/obj/item/access_module/AM as() in access_modules)
		default_access_list += AM.get_access()
	if(length(access_modules))
		QDEL_NULL(internal_id_card)
		create_access_card(default_access_list)
	//Build hud
	SEND_SIGNAL(chassis, COMSIG_ENDO_APPLY_HUD, hud_used)
	//Grab radio
	var/list/radios = list()
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, /obj/item/radio, radios)
	if(length(radios))
		//If you want to implement more than one radio, good luck
		radio = radios[1]
//Other
	create_modularInterface()
	update_icons()

/mob/living/silicon/new_robot/Destroy()
	. = ..()
	QDEL_NULL(cover_overlay)
//Clean up our spark effects
	QDEL_NULL(spark_system)
//Poot our chassis out
	chassis?.forceMove(get_turf(src))

/mob/living/silicon/new_robot/ComponentInitialize()
	. = ..()
	discovery_component = AddComponent(/datum/component/discoverable/robot)

/mob/living/silicon/new_robot/attackby(obj/item/I, mob/living/user, params)
	//See if we can pass this event onto our chassis
	if(cover_open && user.a_intent == INTENT_HELP)
		chassis?.attackby(I, user, params)
	//THEN see if we're opening our cover or not
	if(istype(I, /obj/item/card) && allowed(user))
		if(!cover_open && !do_after(user, ROBOT_COVER_OPEN_TIME, src))
			return ..()
		to_chat(user, "<span class='warning'>You [!cover_open ? "open" : "close"] [src]'s cover!</span>")
		cover_open = !cover_open
		update_icons()
		return
	else if(!cover_open)
		to_chat(user, "<span class='warning'>[src]'s cover is closed!</span>")
	//Allows borgs to install new programs with human help
	if(istype(I, /obj/item/computer_hardware/hard_drive/portable))
		if(!modularInterface)
			stack_trace("Cyborg [src] ( [type] ) was somehow missing their integrated tablet. Please make a bug report.")
			create_modularInterface()
		var/obj/item/computer_hardware/hard_drive/portable/floppy = I
		if(modularInterface.install_component(floppy, user))
			return
	//Cool hat stuff
	if(I.slot_flags & ITEM_SLOT_HEAD && user.a_intent == INTENT_HELP && can_wear(I))
		to_chat(user, "<span class='notice'>You begin to place [I] on [src]'s head...</span>")
		to_chat(src, "<span class='notice'>[user] is placing [I] on your head...</span>")
		if(do_after(user, 30, target = src))
			if(user.temporarilyRemoveItemFromInventory(I, TRUE))
				place_on_head(I)
		return
	return ..()

/mob/living/silicon/new_robot/tool_act(mob/living/user, obj/item/I, tool_type)
	. = ..()
	if(cover_open && do_after(user, ROBOT_MODIFY_TIME, src))
		return chassis?.tool_act(user, I, tool_type)
	else if(!cover_open)
		to_chat(user, "<span class='warning'>[src]'s cover is closed!</span>")

/mob/living/silicon/new_robot/regenerate_icons()
	return update_icons()

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
//Module energy stuff
	var/list/modules = list()
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, /obj/item/new_robot_module, modules)
	for(var/obj/item/new_robot_module/module as() in modules)
		for(var/datum/robot_energy_storage/st in module.storages)
			tab_data["[st.name]"] = GENERATE_STAT_TEXT("[st.energy]/[st.max_energy]")
//Which AI are we connected to
	if(connected_ai)
		tab_data["Master AI"] = GENERATE_STAT_TEXT("[connected_ai.name]")
//How much research do we have built up?
	tab_data["Stored Discovery"] = GENERATE_STAT_TEXT("[discovery_component.point_reward]")
	tab_data["Stored Generic"] = GENERATE_STAT_TEXT("[discovery_component.general_reward]")

	return tab_data

///Easy way for getting our cell for other code stuff
/mob/living/silicon/new_robot/get_cell(index = 1)
	var/list/cells = list()
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, /obj/item/stock_parts/cell, cells)
	if(!length(cells))
		return FALSE
	return cells[min(index, length(cells))]

/mob/living/silicon/new_robot/create_mob_hud()
	. = ..()
	SEND_SIGNAL(chassis, COMSIG_ENDO_APPLY_HUD, hud_used)

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

/mob/living/silicon/new_robot/mouse_buckle_handling(mob/living/M, mob/living/user)
	//Don't try buckling on INTENT_HARM so that silicons can search people's inventories without loading them
	if(can_buckle && istype(M) && !(M in buckled_mobs) && ((user!=src)||(a_intent != INTENT_HARM)))
		return user_buckle_mob(M, user, check_loc = FALSE)

/mob/living/silicon/new_robot/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
//Personal checks
	if(stat || incapacitated())
		return
//Chassis checks
	if(!chassis_component.can_ride(M))
		M.visible_message("<span class='warning'>[M] really can't seem to mount [src]...</span>")
		return
//Riding component checks
	var/datum/component/riding/riding_datum = LoadComponent(/datum/component/riding/cyborg)
	if(has_buckled_mobs())
		if(buckled_mobs.len >= max_buckled_mobs)
			return
		if(M in buckled_mobs)
			return
	if(iscarbon(M) && (!riding_datum.equip_buckle_inhands(M, 1)))
		if(M.usable_hands == 0)
			M.visible_message("<span class='boldwarning'>[M] can't climb onto [src] because [M.p_they()] don't have any usable arms!</span>")
		else
			M.visible_message("<span class='boldwarning'>[M] can't climb onto [src] because [M.p_their()] hands are full!</span>")
		return
	. = ..(M, force, check_loc)

/mob/living/silicon/new_robot/unbuckle_mob(mob/user, force=FALSE)
	if(iscarbon(user))
		var/datum/component/riding/riding_datum = GetComponent(/datum/component/riding)
		if(istype(riding_datum))
			riding_datum.unequip_buckle_inhands(user)
			riding_datum.restore_position(user)
	. = ..(user)

/mob/living/silicon/new_robot/update_icons()
	SEND_SIGNAL(chassis, COMSIG_ROBOT_UPDATE_ICONS, src)
	//Cover overlays
	cut_overlay(cover_overlay)
	if(cover_open)
		if(wires_exposed)
			cover_overlay.icon_state = "ov-opencover +w"
		else if(get_cell())
			cover_overlay.icon_state =  "ov-opencover +c"
		else
			cover_overlay.icon_state = "ov-opencover -c"
		add_overlay(cover_overlay)
	//FIRE FIRE FIRE!
	update_fire()

/mob/living/silicon/new_robot/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(check_access(null))
		return TRUE
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(check_access(H.get_active_held_item()) || check_access(H.wear_id))
			return TRUE
	else if(ismonkey(M))
		var/mob/living/carbon/monkey/george = M
		//they can only hold things :(
		if(isitem(george.get_active_held_item()))
			return check_access(george.get_active_held_item())
	return FALSE

/mob/living/silicon/new_robot/proc/check_access(obj/item/card/id/I)
	if(!istype(req_access, /list)) //something's very wrong
		return 1

	var/list/L = req_access
	if(!L.len) //no requirements
		return 1

	if(!istype(I, /obj/item/card/id) && isitem(I))
		I = I.GetID()

	if(!I || !length(I.access)) //not ID or no access
		return 0
	for(var/req in req_access)
		if(!(req in I.access))
			return 0 //doesn't have this access
	return 1

/mob/living/silicon/new_robot/proc/consume_energy(amount)
	return SEND_SIGNAL(chassis, COMSIG_ROBOT_CONSUME_ENERGY, amount)

///Returns wether this borg is free or not
/mob/living/silicon/new_robot/proc/is_free()
	var/list/ai_brains = list()
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, /obj/item/mmi/ai_brain, ai_brains)
	//Must not be connected to an AI, emagged, scrambled, or a shell
	if(connected_ai || emagged || console_visible || length(ai_brains))
		return FALSE
	return TRUE

/mob/living/silicon/new_robot/proc/get_part_datum(path, index = 1)
	var/list/parts = list()
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, path, parts)
	if(!length(parts))
		return
	var/atom/part_parent = parts[min(length(parts), index)]
	return part_parent.GetComponent(path)

/mob/living/silicon/new_robot/proc/place_on_head(obj/item/new_hat)
	var/datum/component/endopart/head/head_component = get_part_datum(/datum/component/endopart/head)
	head_component?.place_on_head(new_hat)

///Helper to check if we're allowed to wear a particular hat, checks with the chassis
/mob/living/silicon/new_robot/proc/can_wear(var/obj/item/clothing/head/hat)
	var/datum/component/endopart/head/head_component = get_part_datum(/datum/component/endopart/head)
	return head_component?.can_wear(hat)

/mob/living/silicon/new_robot/proc/can_dispose()
	return chassis_component.can_dispose

///Change our emagged state
/mob/living/silicon/new_robot/proc/set_emagged(new_state)
	emagged = new_state
	if(emagged)
		throw_alert("hacked", /atom/movable/screen/alert/hacked)
	else
		clear_alert("hacked")
	SEND_SIGNAL(chassis, COMSIG_ROBOT_SET_EMAGGED, new_state)
	//Update our integrated tablet to look gangster
	set_modularInterface_theme()

/mob/living/silicon/new_robot/proc/set_modularInterface_theme()
	if(emagged)
		modularInterface.device_theme = THEME_SYNDICATE
		modularInterface.icon_state = "tablet-silicon-syndicate"
		modularInterface.icon_state_powered = "tablet-silicon-syndicate"
		modularInterface.icon_state_unpowered = "tablet-silicon-syndicate"
	else
		modularInterface.device_theme = THEME_NTOS
		modularInterface.icon_state = "tablet-silicon"
		modularInterface.icon_state_powered = "tablet-silicon"
		modularInterface.icon_state_unpowered = "tablet-silicon"
	modularInterface.update_icon()

/mob/living/silicon/new_robot/proc/set_ratvar(new_state)
	ratvar = new_state
	if(ratvar)
		internal_clock_slab = new(src)
		throw_alert("ratvar", /atom/movable/screen/alert/ratvar)
	else
		qdel(internal_clock_slab)
		clear_alert("ratvar")

///Easy way for getting our MMI, if we have one
/mob/living/silicon/new_robot/proc/get_mmi(index = 1) //I added an index option just incase in the far future we actually want TWO mmis
	var/list/mmi = list()
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, /obj/item/mmi, mmi)
	if(!length(mmi))
		return FALSE
	return mmi[min(index, length(mmi))]

/mob/living/silicon/new_robot/proc/self_destruct()
	var/turf/groundzero = get_turf(src)
	message_admins("<span class='notice'>[ADMIN_LOOKUPFLW(usr)] detonated [key_name_admin(src, client)] at [ADMIN_VERBOSEJMP(groundzero)]!</span>")
	log_game("\<span class='notice'>[key_name(usr)] detonated [key_name(src)]!</span>")
	log_combat(usr, src, "detonated cyborg", "cyborg_detonation")
	if(connected_ai)
		to_chat(connected_ai, "<br><br><span class='alert'>ALERT - Cyborg detonation detected: [name]</span><br>")
	if(emagged)
		explosion(src.loc,1,2,4,flame_range = 2)
	else
		explosion(src.loc,-1,0,2)
	investigate_log("has self-destructed.", INVESTIGATE_DEATHS)
	gib()

/mob/living/silicon/new_robot/proc/set_locked(state = TRUE)
	if(locked == state)
		return
	. = locked
	locked = state
	if(locked)
		if(!.)
			ADD_TRAIT(src, TRAIT_IMMOBILIZED, LOCKED_BORG_TRAIT)
	else if(.)
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LOCKED_BORG_TRAIT)
	logevent("System lockdown [locked?"triggered":"released"].")

//Helper to respawn the consumables for our modules
/mob/living/silicon/new_robot/proc/respawn_consumable(coeff = 1)
	var/list/modules = list()
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, /obj/item/new_robot_module, modules)
	for(var/obj/item/new_robot_module/module as() in modules)
		module.respawn_consumable(src, coeff)

//Helper for checking flash
/mob/living/silicon/new_robot/proc/try_flash()
	if(last_flashed + FLASHED_COOLDOWN < world.time)
		last_flashed = world.time
		return TRUE

/mob/living/silicon/new_robot/proc/TryConnectToAI()
	connected_ai = select_active_ai_with_fewest_borgs()
	if(connected_ai)
		connected_ai.connected_robots += src
		law_sync()
		toggle_law_sync(TRUE)
		wires.ui_update()
		return TRUE
	picturesync()
	wires.ui_update()
	return FALSE

///Helper to check if our head, if we have one, has its laws set to be synced
/mob/living/silicon/new_robot/proc/laws_synced()
	//TODO: Make this and other law stuff controlled by the head - Racc
	return law_update

///Helper to toggle law sync mode
/mob/living/silicon/new_robot/proc/toggle_law_sync(mode)
	law_update = isnull(mode) ? !law_update : mode
	return law_update

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
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, /obj/item/mmi/ai_brain, brains)
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

/mob/living/silicon/new_robot/proc/get_standard_name()
	var/obj/item/mmi/mmi = get_mmi()
	return "[(designation ? "[designation] " : "")][mmi.braintype]-[rand(1, 999)]"

/mob/living/silicon/new_robot/proc/charge(datum/source, amount, repairs)
	SIGNAL_HANDLER

	respawn_consumable(amount * 0.00)
	var/obj/item/stock_parts/cell/cell = get_cell()
	if(cell)
		cell.charge = min(cell.charge + amount, cell.maxcharge)
	//TODO: I don't like this - Racc
	if(repairs)
		heal_bodypart_damage(repairs, repairs - 1)

/mob/living/silicon/new_robot/proc/picturesync()
	if(!connected_ai || !connected_ai.aicamera || !aicamera)
		return
	for(var/i in aicamera.stored)
		connected_ai.aicamera.stored[i] = TRUE
	for(var/i in connected_ai.aicamera.stored)
		aicamera.stored[i] = TRUE

/mob/living/silicon/new_robot/proc/toggle_headlamp(turn_off = FALSE, update_color = FALSE)
	var/list/lamps = list()
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, /datum/endo_assembly/item/lamp, lamps)
	for(var/datum/endo_assembly/item/lamp/L as() in lamps)
		L.lamp_functional = FALSE
		L.lamp.toggle_headlamp(src, turn_off, update_color)
