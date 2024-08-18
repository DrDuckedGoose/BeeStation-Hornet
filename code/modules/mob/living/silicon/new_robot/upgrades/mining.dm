//Diamond Drill
/obj/item/borg/upgrade/item/ddrill
	name = "mining cyborg diamond drill"
	desc = "A diamond drill replacement for the mining module's standard drill."
	icon_state = "cyborg_upgrade3"
	compatible_modules = list(/obj/item/new_robot_module/miner)
	module_flags = BORG_MODULE_MINER
	upgrade_item = /obj/item/pickaxe/drill/cyborg/diamond

//Satchel of Holding
/obj/item/borg/upgrade/item/soh
	name = "mining cyborg satchel of holding"
	desc = "A satchel of holding replacement for mining cyborg's ore satchel module."
	icon_state = "cyborg_upgrade3"
	compatible_modules = list(/obj/item/new_robot_module/miner)
	module_flags = BORG_MODULE_MINER
	upgrade_item = /obj/item/storage/bag/ore/holding

//Plasma cutter
/obj/item/borg/upgrade/item/cutter
	name = "mining cyborg plasma cutter"
	desc = "An upgrade to the mining module granting a self-recharging plasma cutter."
	icon_state = "cyborg_upgrade3"
	compatible_modules = list(/obj/item/new_robot_module/miner)
	module_flags = BORG_MODULE_MINER
	upgrade_item = /obj/item/gun/energy/plasmacutter/cyborg

/obj/item/borg/upgrade/lavaproof
	name = "mining cyborg lavaproof chassis"
	desc = "An upgrade kit to apply specialized coolant systems and insulation layers to a mining cyborg's chassis, enabling them to withstand exposure to molten rock."
	icon_state = "ash_plating"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	compatible_modules = list(/obj/item/new_robot_module/miner)
	module_flags = BORG_MODULE_MINER

/obj/item/borg/upgrade/lavaproof/install(obj/item/new_robot_module/module, mob/living/silicon/new_robot/R, mob/user)
	. = ..()
	if(.)
		R.weather_immunities += "lava"

/obj/item/borg/upgrade/lavaproof/remove(obj/item/new_robot_module/module, mob/living/silicon/new_robot/R, mob/user)
	. = ..()
	if(.)
		R.weather_immunities -= "lava"

/*
	Kinetic acccelerator stuff lives down here
*/

//Base template
/obj/item/borg/upgrade/modkit
	name = "kinetic accelerator modification kit"
	desc = "An upgrade for kinetic accelerators."
	icon = 'icons/obj/objects.dmi'
	icon_state = "modkit"
	w_class = WEIGHT_CLASS_SMALL
	compatible_modules = list(/obj/item/new_robot_module/miner)
	module_flags = BORG_MODULE_MINER

	///How many times can we use this type of upgrade
	var/maximum_of_type = -1
	///How much space does this upgrade take up
	var/cost = 30
	///For use in any mod kit that has numerical modifiers
	var/modifier = 1
	///Is this upgrade exclusively for the bastard minebot
	var/minebot_upgrade = FALSE

/obj/item/borg/upgrade/modkit/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Occupies <b>[cost]%</b> of mod capacity.</span>"

//Allows borgs to install mods
/obj/item/borg/upgrade/modkit/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/gun/energy/kinetic_accelerator) && !issilicon(user))
		install(A, user)
	else
		..()

/obj/item/borg/upgrade/modkit/install(obj/item/new_robot_module/module, mob/living/silicon/new_robot/R, mob/user)
	. = ..()
	if(!.)
		return
	for(var/obj/item/gun/energy/kinetic_accelerator/cyborg/gun in module.all_items)
		if(mount(gun, user))
			return

/obj/item/borg/upgrade/modkit/proc/mount(obj/item/gun/energy/kinetic_accelerator/KA, mob/user)
//Minebot stuff
	if(minebot_upgrade && !istype(KA.loc, /mob/living/simple_animal/hostile/mining_drone))
		to_chat(user, "<span class='warning'>The modkit you're trying to install is only rated for minebot use.</span>")
		return
	else if(istype(KA.loc, /mob/living/simple_animal/hostile/mining_drone))
		to_chat(user, "<span class='warning'>The modkit you're trying to install is not rated for minebot use.</span>")
		return
//Proper module stuff
	//Check if we even have room fer enother mod
	if(KA.get_remaining_mod_capacity() < cost)
		to_chat(user, "<span class='warning'>You don't have room(<b>[KA.get_remaining_mod_capacity()]%</b> remaining, [cost]% needed) to install this modkit. Use a crowbar to remove existing modkits.</span>")
		return
	//maximum type checks
	var/number_of_denied = 0
	for(var/A in KA.get_modkits())
		var/obj/item/borg/upgrade/modkit/M = A
		if(istype(M, type))
			number_of_denied++
		if(number_of_denied >= maximum_of_type && maximum_of_type > 0)
			to_chat(user, "<span class='notice'>The modkit you're trying to install would conflict with an already installed modkit. Use a crowbar to remove existing modkits.</span>")
			return
	//We're chilling
	if(!user.transferItemToLoc(src, KA))
		return
	to_chat(user, "<span class='notice'>You install [src] onto [KA].</span>")
	playsound(loc, 'sound/items/screwdriver.ogg', 100, 1)
	KA.modkits += src
	return TRUE

/obj/item/borg/upgrade/modkit/remove(obj/item/new_robot_module/module, mob/living/silicon/new_robot/R, mob/user)
	. = ..()
	if(!.)
		return
	for(var/obj/item/gun/energy/kinetic_accelerator/cyborg/KA in module.all_items)
		unmount(KA)

/obj/item/borg/upgrade/modkit/proc/unmount(obj/item/gun/energy/kinetic_accelerator/KA)
	forceMove(get_turf(KA))
	KA.modkits -= src

/obj/item/borg/upgrade/modkit/proc/modify_projectile(obj/projectile/kinetic/K)
//use this one for effects you want to trigger before any damage is done at all and before damage is decreased by pressure
/obj/item/borg/upgrade/modkit/proc/projectile_prehit(obj/projectile/kinetic/K, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
//use this one for effects you want to trigger before mods that do damage
/obj/item/borg/upgrade/modkit/proc/projectile_strike_predamage(obj/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
//and this one for things that don't need to trigger before other damage-dealing mods
/obj/item/borg/upgrade/modkit/proc/projectile_strike(obj/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)

//Range
/obj/item/borg/upgrade/modkit/range
	name = "range increase"
	desc = "Increases the range of a kinetic accelerator when installed."
	modifier = 1
	cost = 25

/obj/item/borg/upgrade/modkit/range/modify_projectile(obj/projectile/kinetic/K)
	K.range += modifier

//Damage
/obj/item/borg/upgrade/modkit/damage
	name = "damage increase"
	desc = "Increases the damage of kinetic accelerator when installed."
	modifier = 10

/obj/item/borg/upgrade/modkit/damage/modify_projectile(obj/projectile/kinetic/K)
	K.damage += modifier

//Cooldown
/obj/item/borg/upgrade/modkit/cooldown
	name = "cooldown decrease"
	desc = "Decreases the cooldown of a kinetic accelerator. Not rated for minebot use."
	modifier = 3.2
	minebot_upgrade = FALSE

/obj/item/borg/upgrade/modkit/cooldown/mount(obj/item/gun/energy/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(.)
		KA.overheat_time -= modifier

/obj/item/borg/upgrade/modkit/cooldown/unmount(obj/item/gun/energy/kinetic_accelerator/KA)
	KA.overheat_time += modifier
	..()

/obj/item/borg/upgrade/modkit/cooldown/minebot
	name = "minebot cooldown decrease"
	desc = "Decreases the cooldown of a kinetic accelerator. Only rated for minebot use."
	icon_state = "door_electronics"
	icon = 'icons/obj/module.dmi'
	modifier = 5
	cost = 0
	minebot_upgrade = TRUE
	maximum_of_type = 1

//AoE blasts
/obj/item/borg/upgrade/modkit/aoe
	modifier = 0
	///Do we have an area of effect
	var/turf_aoe = FALSE
	///I genuinely don't know or care what this does
	var/stats_stolen = FALSE

/obj/item/borg/upgrade/modkit/aoe/mount(obj/item/gun/energy/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(!.)
		return
	for(var/obj/item/borg/upgrade/modkit/aoe/AOE in KA.modkits) //make sure only one of the aoe modules has values if somebody has multiple
		if(AOE.stats_stolen || AOE == src)
			continue
		modifier += AOE.modifier //take its modifiers
		AOE.modifier = 0
		turf_aoe += AOE.turf_aoe
		AOE.turf_aoe = FALSE
		AOE.stats_stolen = TRUE

/obj/item/borg/upgrade/modkit/aoe/unmount(obj/item/gun/energy/kinetic_accelerator/KA)
	..()
	modifier = initial(modifier) //get our modifiers back
	turf_aoe = initial(turf_aoe)
	stats_stolen = FALSE

/obj/item/borg/upgrade/modkit/aoe/modify_projectile(obj/projectile/kinetic/K)
	K.name = "kinetic explosion"

/obj/item/borg/upgrade/modkit/aoe/projectile_strike(obj/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
	if(stats_stolen)
		return
	new /obj/effect/temp_visual/explosion/fast(target_turf)
	if(turf_aoe)
		for(var/turf/closed/mineral/M in RANGE_TURFS(1, target_turf) - target_turf)
			M.gets_drilled(K.firer)
	if(modifier)
		for(var/mob/living/L in range(1, target_turf) - K.firer - target)
			var/armor = L.run_armor_check(K.def_zone, K.armor_flag, "", "", K.armour_penetration)
			L.apply_damage(K.damage*modifier, K.damage_type, K.def_zone, armor)
			to_chat(L, "<span class='userdanger'>You're struck by a [K.name]!</span>")

/obj/item/borg/upgrade/modkit/aoe/turfs
	name = "mining explosion"
	desc = "Causes the kinetic accelerator to destroy rock in an AoE."
	maximum_of_type = 1
	turf_aoe = TRUE

/obj/item/borg/upgrade/modkit/aoe/turfs/andmobs
	name = "offensive mining explosion"
	desc = "Causes the kinetic accelerator to destroy rock and damage mobs in an AoE."
	maximum_of_type = 3
	modifier = 0.25

/obj/item/borg/upgrade/modkit/aoe/mobs
	name = "offensive explosion"
	desc = "Causes the kinetic accelerator to damage mobs in an AoE."
	modifier = 0.2

//Minebot passthrough
/obj/item/borg/upgrade/modkit/minebot_passthrough
	name = "minebot passthrough"
	desc = "Causes kinetic accelerator shots to pass through minebots."
	cost = 0

//Repeater
/obj/item/borg/upgrade/modkit/cooldown/repeater
	name = "rapid repeater"
	desc = "Quarters the kinetic accelerator's cooldown on striking a living target, but greatly increases the base cooldown."
	maximum_of_type = 1
	modifier = -14 //Makes the cooldown 3 seconds(with no cooldown mods) if you miss. Don't miss.
	cost = 50

/obj/item/borg/upgrade/modkit/cooldown/repeater/projectile_strike_predamage(obj/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
	var/valid_repeat = FALSE
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat != DEAD)
			valid_repeat = TRUE
	if(ismineralturf(target_turf))
		valid_repeat = TRUE
	if(valid_repeat)
		KA.overheat = FALSE
		KA.attempt_reload(K.firer, KA.overheat_time * 0.25) //If you hit, the cooldown drops to 0.75 seconds.

//Lifesteal
/obj/item/borg/upgrade/modkit/lifesteal
	name = "lifesteal crystal"
	desc = "Causes kinetic accelerator shots to slightly heal the firer on striking a living target."
	icon_state = "modkit_crystal"
	modifier = 2.5 //Not a very effective method of healing.
	cost = 10
	///Healing priority
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)

/obj/item/borg/upgrade/modkit/lifesteal/projectile_prehit(obj/projectile/kinetic/K, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
	if(isliving(target) && isliving(K.firer))
		var/mob/living/L = target
		if(L.stat == DEAD)
			return
		L = K.firer
		L.heal_ordered_damage(modifier, damage_heal_order)

//Resonator
/obj/item/borg/upgrade/modkit/resonator_blasts
	name = "resonator blast"
	desc = "Causes kinetic accelerator shots to leave and detonate resonator blasts."
	maximum_of_type = 1
	cost = 30
	modifier = 0.25 //A bonus 15 damage if you burst the field on a target, 60 if you lure them into it.

/obj/item/borg/upgrade/modkit/resonator_blasts/projectile_strike(obj/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
	if(target_turf && !ismineralturf(target_turf)) //Don't make fields on mineral turfs.
		var/obj/effect/temp_visual/resonance/R = locate(/obj/effect/temp_visual/resonance) in target_turf
		if(R)
			R.damage_multiplier = modifier
			R.burst()
			return
		new /obj/effect/temp_visual/resonance(target_turf, K.firer, null, 30)

//Bounty
/obj/item/borg/upgrade/modkit/bounty
	name = "death syphon"
	desc = "Killing or assisting in killing a creature permanently increases your damage against that type of creature."
	maximum_of_type = 1
	modifier = 1.25
	cost = 30
	///maximum reward
	var/maximum_bounty = 25
	///Rewards we've already acquired
	var/list/bounties_reaped = list()

/obj/item/borg/upgrade/modkit/bounty/projectile_prehit(obj/projectile/kinetic/K, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
	if(isliving(target))
		var/mob/living/L = target
		var/list/existing_marks = L.has_status_effect_list(STATUS_EFFECT_SYPHONMARK)
		for(var/i in existing_marks)
			var/datum/status_effect/syphon_mark/SM = i
			if(SM.reward_target == src) //we want to allow multiple people with bounty modkits to use them, but we need to replace our own marks so we don't multi-reward
				SM.reward_target = null
				qdel(SM)
		L.apply_status_effect(STATUS_EFFECT_SYPHONMARK, src)

/obj/item/borg/upgrade/modkit/bounty/projectile_strike(obj/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
	if(isliving(target))
		var/mob/living/L = target
		if(bounties_reaped[L.type])
			var/kill_modifier = 1
			if(K.pressure_decrease_active)
				kill_modifier *= K.pressure_decrease
			var/armor = L.run_armor_check(K.def_zone, K.armor_flag, "", "", K.armour_penetration)
			L.apply_damage(bounties_reaped[L.type]*kill_modifier, K.damage_type, K.def_zone, armor)

/obj/item/borg/upgrade/modkit/bounty/proc/get_kill(mob/living/L)
	var/bonus_mod = 1
	if(ismegafauna(L)) //megafauna reward
		bonus_mod = 4
	if(!bounties_reaped[L.type])
		bounties_reaped[L.type] = min(modifier * bonus_mod, maximum_bounty)
	else
		bounties_reaped[L.type] = min(bounties_reaped[L.type] + (modifier * bonus_mod), maximum_bounty)

//Indoors
/obj/item/borg/upgrade/modkit/indoors
	name = "decrease pressure penalty"
	desc = "A syndicate modification kit that increases the damage a kinetic accelerator does in high pressure environments."
	modifier = 2
	maximum_of_type = 1
	cost = 35

/obj/item/borg/upgrade/modkit/indoors/modify_projectile(obj/projectile/kinetic/K)
	K.pressure_decrease *= modifier

//Trigger Guard
/obj/item/borg/upgrade/modkit/trigger_guard
	name = "modified trigger guard"
	desc = "Allows creatures normally incapable of firing guns to operate the weapon when installed."
	cost = 20
	maximum_of_type = 1

/obj/item/borg/upgrade/modkit/trigger_guard/mount(obj/item/gun/energy/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(.)
		KA.trigger_guard = TRIGGER_GUARD_ALLOW_ALL

/obj/item/borg/upgrade/modkit/trigger_guard/unmount(obj/item/gun/energy/kinetic_accelerator/KA)
	KA.trigger_guard = TRIGGER_GUARD_NORMAL
	..()

//Cosmetic

/obj/item/borg/upgrade/modkit/chassis_mod
	name = "super chassis"
	desc = "Makes your KA yellow. All the fun of having a more powerful KA without actually having a more powerful KA."
	cost = 0
	maximum_of_type = 1
	var/chassis_icon = "kineticgun_u"
	var/chassis_name = "super-kinetic accelerator"

/obj/item/borg/upgrade/modkit/chassis_mod/mount(obj/item/gun/energy/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(.)
		KA.icon_state = chassis_icon
		KA.name = chassis_name

/obj/item/borg/upgrade/modkit/chassis_mod/unmount(obj/item/gun/energy/kinetic_accelerator/KA)
	KA.icon_state = initial(KA.icon_state)
	KA.name = initial(KA.name)
	..()

/obj/item/borg/upgrade/modkit/chassis_mod/orange
	name = "hyper chassis"
	desc = "Makes your KA orange. All the fun of having explosive blasts without actually having explosive blasts."
	chassis_icon = "kineticgun_h"
	chassis_name = "hyper-kinetic accelerator"

//Tracer
/obj/item/borg/upgrade/modkit/tracer
	name = "white tracer bolts"
	desc = "Causes kinetic accelerator bolts to have a white tracer trail and explosion."
	cost = 0
	maximum_of_type = 1
	var/bolt_color = "#FFFFFF"

/obj/item/borg/upgrade/modkit/tracer/modify_projectile(obj/projectile/kinetic/K)
	K.icon_state = "ka_tracer"
	K.color = bolt_color

/obj/item/borg/upgrade/modkit/tracer/adjustable
	name = "adjustable tracer bolts"
	desc = "Causes kinetic accelerator bolts to have an adjustable-colored tracer trail and explosion. Use in-hand to change color."

/obj/item/borg/upgrade/modkit/tracer/adjustable/attack_self(mob/user)
	bolt_color = tgui_color_picker(user,"","Choose Color",bolt_color)
