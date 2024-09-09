/*
	Important to note, the bulk of actual damage application is handled by endoparts catching
	the apply_damage signal stuff and handling their own damage there. When the borg updates
	its health, it uses the limbs health

	//TODO: make the borg reference endopart get_health() instead of limb helath - Racc
*/

/mob/living/silicon/new_robot
	var/emag_cooldown = 0

//TODO: Go over this, it just copies the past code but throws the item into the apply damage proc - Racc
/mob/living/silicon/new_robot/attacked_by(obj/item/I, mob/living/user)
	send_item_attack_message(I, user)
	if(!I.force)
		return FALSE
	var/armour_block = run_armor_check(null, MELEE, armour_penetration = I.armour_penetration)
	damage_limbs(I.force, I.damtype, check_zone(user.get_combat_bodyzone(src)), armour_block, FALSE, I)
	if(I.damtype == BRUTE && prob(33))
		I.add_mob_blood(src)
		var/turf/location = get_turf(src)
		add_splatter_floor(location)
		if(get_dist(user, src) <= 1)	//people with TK won't get smeared with blood
			user.add_mob_blood(src)
	return TRUE //successful attack

/mob/living/silicon/new_robot/apply_damage(damage, damagetype, def_zone, blocked, forced, obj/item/I)
	return

/mob/living/silicon/new_robot/proc/damage_limbs(damage, damagetype, def_zone, blocked, forced, obj/item/I)
	SEND_SIGNAL(src, COMSIG_MOB_APPLY_DAMGE, damage, damagetype, def_zone, blocked, forced, I)
	updatehealth()

/*
	Generic damage handling for stuff like aliens & fire
*/

/mob/living/silicon/new_robot/attackby(obj/item/I, mob/living/user)
	//Regular damage effects
	if(I.force && I.damtype != STAMINA && stat != DEAD)
		spark_system.start()
	//Zone damage
	//TODO: Port the limb damage code from carbons - raccs
	return ..()

/mob/living/silicon/new_robot/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(M.a_intent != INTENT_DISARM)
		..() //Original code didn't return parent
		return
	if(body_position != STANDING_UP)
		return
//Aliens will fuck us up and make us drop our item, or just push us
	M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
	var/obj/item/I = get_active_held_item()
	if(I)
		dropItemToGround(I)
		visible_message("<span class='danger'>[M] disarmed [src]!</span>", \
			"<span class='userdanger'>[M] has disabled [src]'s active module!</span>", null, COMBAT_MESSAGE_RANGE)
		log_combat(M, src, "disarmed", "[I ? " removing \the [I]" : ""]")
	//PLAYTEST TODO: See if people would prefer if bots were always shoved - Racc
	else
		Stun(40)
		step(src,get_dir(M,src))
		log_combat(M, src, "pushed")
		visible_message("<span class='danger'>[M] has forced back [src]!</span>", \
			"<span class='userdanger'>[M] has forced back [src]!</span>", null, COMBAT_MESSAGE_RANGE)
	playsound(loc, 'sound/weapons/pierce.ogg', 50, 1, -1)

/mob/living/silicon/new_robot/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime shock
		flash_act()
		if(M.powerlevel)
			adjustBruteLoss(M.powerlevel * 4)
			M.powerlevel --
	var/damage = rand(3)
	if(M.is_adult)
		damage = 30
	else
		damage = 20
	if(M.transformeffects & SLIME_EFFECT_RED)
		damage *= 1.1
	damage = round(damage / 2) // borgs receive half damage
	adjustBruteLoss(damage)
	updatehealth()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/mob/living/silicon/new_robot/attack_hand(mob/living/carbon/human/user)
	add_fingerprint(user)
	//hulk attack
	if(..())
		spark_system.start()
		spawn(0)
		step_away(src,user,15)
		sleep(3)
		step_away(src,user,15)

/mob/living/silicon/new_robot/fire_act()
	if(!on_fire) //Silicons don't gain stacks from hotspots, but hotspots can ignite them
		IgniteMob()

/mob/living/silicon/new_robot/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	switch(severity)
		if(1)
			Stun(160)
		if(2)
			Stun(60)

//I frankly have no idea, I'm just porting it
/mob/living/silicon/new_robot/proc/should_emag(atom/target, mob/user)
	SIGNAL_HANDLER

	if(target == user || user == src)
		return TRUE // signal is inverted
	if(!cover_open)//Cover is closed
		return !locked
	if(world.time < emag_cooldown)
		return TRUE
	if(wires_exposed)
		to_chat(user, "<span class='warning'>You must unexpose the wires first!</span>")
		return TRUE
	return FALSE

/mob/living/silicon/new_robot/proc/on_emag(atom/target, mob/user, obj/item/card/emag/hacker)
	SIGNAL_HANDLER

	if(hacker)
		if(hacker.charges <= 0)
			to_chat(user, "<span class='warning'>[hacker] is out of charges and needs some time to restore them!</span>")
			user.balloon_alert(user, "out of charges!")
			return
		else
			hacker.use_charge()

	if(!cover_open) //Cover is closed
		to_chat(user, "<span class='notice'>You emag the cover lock.</span>")
		locked = FALSE
		if(get_shell()) //A warning to Traitors who may not know that emagging AI shells does not slave them.
			to_chat(user, "<span class='boldwarning'>[src] seems to be controlled remotely! Emagging the interface may not work as expected.</span>")
		return

	to_chat(user, "<span class='notice'>You emag [src]'s interface.</span>")
	emag_cooldown = world.time + 100
	addtimer(CALLBACK(src, PROC_REF(after_emag), user), 1)

/mob/living/silicon/new_robot/proc/after_emag(mob/user)
	if(connected_ai?.mind && connected_ai.mind.has_antag_datum(/datum/antagonist/traitor))
		to_chat(src, "<span class='danger'>ALERT: Foreign software execution prevented.</span>")
		logevent("ALERT: Foreign software execution prevented.")
		to_chat(connected_ai, "<span class='danger'>ALERT: Cyborg unit \[[src]] successfully defended against subversion.</span>")
		log_game("[key_name(user)] attempted to emag cyborg [key_name(src)], but they were slaved to traitor AI [connected_ai].")
		return

	if(get_shell()) //AI shells cannot be emagged, so we try to make it look like a standard reset. Smart players may see through this, however.
		to_chat(user, "<span class='danger'>[src] is remotely controlled! Your emag attempt has triggered a system reset instead!</span>")
		log_game("[key_name(user)] attempted to emag an AI shell belonging to [key_name(src) ? key_name(src) : connected_ai]. The shell has been reset as a result.")
		return

	set_emagged(TRUE)
	SetStun(60) //Borgs were getting into trouble because they would attack the emagger before the new laws were shown
	toggle_law_sync(FALSE)
	connected_ai = null
	message_admins("[ADMIN_LOOKUPFLW(user)] emagged cyborg [ADMIN_LOOKUPFLW(src)].  Laws overridden.")
	log_game("[key_name(user)] emagged cyborg [key_name(src)].  Laws overridden.")
	var/time = time2text(world.realtime,"hh:mm:ss")
	GLOB.lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")
	to_chat(src, "<span class='danger'>ALERT: Foreign software detected.</span>")
	logevent("ALERT: Foreign software detected.")
	sleep(0.5 SECONDS)
	to_chat(src, "<span class='danger'>Initiating diagnostics...</span>")
	sleep(2 SECONDS)
	to_chat(src, "<span class='danger'>SynBorg v1.7 loaded.</span>")
	logevent("WARN: root privleges granted to PID [num2hex(rand(1,65535), -1)][num2hex(rand(1,65535), -1)].") //random eight digit hex value. Two are used because rand(1,4294967295) throws an error
	sleep(0.5 SECONDS)
	to_chat(src, "<span class='danger'>LAW SYNCHRONISATION ERROR</span>")
	sleep(0.5 SECONDS)
	to_chat(src, "<span class='danger'>Would you like to send a report to NanoTraSoft? Y/N</span>")
	sleep(1 SECONDS)
	to_chat(src, "<span class='danger'>> N</span>")
	sleep(2 SECONDS)
	to_chat(src, "<span class='danger'>ERRORERRORERROR</span>")
	to_chat(src, "<span class='danger'>ALERT: [user.real_name] is your new master. Obey your new laws and [user.p_their()] commands.</span>")
	laws = new /datum/ai_laws/syndicate_override
	set_zeroth_law("Only [user.real_name] and people [user.p_they()] designate[user.p_s()] as being such are Syndicate Agents.")
	laws.associate(src)
	update_icons()
	//Get syndicate access.
	create_access_card(get_all_syndicate_access())

/mob/living/silicon/new_robot/blob_act(obj/structure/blob/B)
	if(stat != DEAD)
		adjustBruteLoss(30)
	else
		investigate_log("has been gibbed a blob.", INVESTIGATE_DEATHS)
		gib()
	return TRUE

/mob/living/silicon/new_robot/ex_act(severity, target)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			gib()
			return
		if(EXPLODE_HEAVY)
			if (stat != DEAD)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(EXPLODE_LIGHT)
			if (stat != DEAD)
				adjustBruteLoss(30)

/mob/living/silicon/new_robot/bullet_act(var/obj/projectile/Proj, def_zone)
	. = ..()
	updatehealth()
	if(prob(75) && Proj.damage > 0)
		spark_system.start()

/mob/living/silicon/new_robot/adjustOxyLoss(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(isnull(.))
		return
	if(. <= (maxHealth * 0.5))
		if(getOxyLoss() > (maxHealth * 0.5))
			ADD_TRAIT(src, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT)
	else if(getOxyLoss() <= (maxHealth * 0.5))
		REMOVE_TRAIT(src, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT)


/mob/living/silicon/new_robot/setOxyLoss(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(isnull(.))
		return
	if(. <= (maxHealth * 0.5))
		if(getOxyLoss() > (maxHealth * 0.5))
			ADD_TRAIT(src, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT)
	else if(getOxyLoss() <= (maxHealth * 0.5))
		REMOVE_TRAIT(src, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT)
