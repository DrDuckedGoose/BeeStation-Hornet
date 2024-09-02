/obj/item/gun/energy/kinetic_accelerator
	name = "proto-kinetic accelerator"
	desc = "A self recharging, ranged mining tool that does increased damage in low pressure."
	automatic_charge_overlays = FALSE
	icon_state = "kineticgun"
	item_state = "kineticgun"
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic)
	cell_type = /obj/item/stock_parts/cell/emproof
	item_flags = NONE
	obj_flags = UNIQUE_RENAME
	weapon_weight = WEAPON_LIGHT
	automatic_charge_overlays = FALSE
	var/overheat_time = 16
	var/holds_charge = FALSE
	var/unique_frequency = FALSE // modified by KA modkits
	var/overheat = FALSE
	can_bayonet = TRUE
	knife_x_offset = 20
	knife_y_offset = 12
	has_weapon_slowdown = FALSE

	var/max_mod_capacity = 100
	var/list/modkits = list()

	var/recharge_timerid

/obj/item/gun/energy/kinetic_accelerator/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 15, \
		overlay_y = 9)

/obj/item/gun/energy/kinetic_accelerator/examine(mob/user)
	. = ..()
	if(max_mod_capacity)
		. += "<b>[get_remaining_mod_capacity()]%</b> mod capacity remaining."
		for(var/A in get_modkits())
			var/obj/item/borg/upgrade/modkit/M = A
			. += "<span class='notice'>[icon2html(M, user)] There is \a [M] installed, using <b>[M.cost]%</b> capacity.</span>"

/obj/item/gun/energy/kinetic_accelerator/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(modkits.len)
		to_chat(user, "<span class='notice'>You pry the modifications out.</span>")
		I.play_tool_sound(src, 100)
		for(var/obj/item/borg/upgrade/modkit/M in modkits)
			M.unmount(src)
	else
		to_chat(user, "<span class='notice'>There are no modifications currently installed.</span>")

/obj/item/gun/energy/kinetic_accelerator/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/borg/upgrade/modkit))
		var/obj/item/borg/upgrade/modkit/MK = I
		MK.unmount(src, user)
	else
		..()

/obj/item/gun/energy/kinetic_accelerator/proc/get_remaining_mod_capacity()
	var/current_capacity_used = 0
	for(var/A in get_modkits())
		var/obj/item/borg/upgrade/modkit/M = A
		current_capacity_used += M.cost
	return max_mod_capacity - current_capacity_used

/obj/item/gun/energy/kinetic_accelerator/proc/get_modkits()
	. = list()
	for(var/A in modkits)
		. += A

/obj/item/gun/energy/kinetic_accelerator/proc/modify_projectile(obj/projectile/kinetic/K)
	K.kinetic_gun = src //do something special on-hit, easy!
	for(var/A in get_modkits())
		var/obj/item/borg/upgrade/modkit/M = A
		M.modify_projectile(K)

/obj/item/gun/energy/kinetic_accelerator/cyborg
	holds_charge = TRUE
	unique_frequency = TRUE
	requires_wielding = FALSE
	max_mod_capacity = 80

/obj/item/gun/energy/kinetic_accelerator/minebot
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	overheat_time = 20
	holds_charge = TRUE
	requires_wielding = FALSE
	unique_frequency = TRUE

/obj/item/gun/energy/kinetic_accelerator/Initialize(mapload)
	. = ..()
	if(!holds_charge)
		empty()

/obj/item/gun/energy/kinetic_accelerator/shoot_live_shot(mob/user)
	. = ..()
	attempt_reload(user)

/obj/item/gun/energy/kinetic_accelerator/equipped(mob/user)
	. = ..()
	if(!can_shoot())
		attempt_reload(user)

/obj/item/gun/energy/kinetic_accelerator/dropped()
	..()
	if(!QDELING(src) && !holds_charge)
		// Put it on a delay because moving item from slot to hand
		// calls dropped().
		addtimer(CALLBACK(src, PROC_REF(empty_if_not_held)), 2)

/obj/item/gun/energy/kinetic_accelerator/proc/empty_if_not_held()
	if(!ismob(loc))
		empty()

/obj/item/gun/energy/kinetic_accelerator/proc/empty()
	if(cell)
		cell.use(cell.charge)
	update_icon()

/obj/item/gun/energy/kinetic_accelerator/proc/attempt_reload(mob/user, recharge_time)
	if(!cell)
		return
	if(overheat)
		return
	if(!recharge_time)
		recharge_time = overheat_time
	overheat = TRUE

	var/carried = 0
	if(!unique_frequency)
		for(var/obj/item/gun/energy/kinetic_accelerator/K in loc.GetAllContents())
			if(!K.unique_frequency)
				carried++

		carried = max(carried, 1)
	else
		carried = 1

	// If we are overriding a crosshair, then clear it
	if (deltimer(recharge_timerid))
		user?.client.clear_cooldown_cursor()
	recharge_timerid = addtimer(CALLBACK(src, PROC_REF(reload)), recharge_time * carried, TIMER_STOPPABLE)
	user?.client?.give_cooldown_cursor(recharge_time * carried + 1)

/obj/item/gun/energy/kinetic_accelerator/proc/reload()
	cell.give(cell.maxcharge)
	if(!suppressed)
		playsound(src.loc, 'sound/weapons/kenetic_reload.ogg', 60, 1)
	else
		to_chat(loc, "<span class='warning'>[src] silently charges up.</span>")
	update_icon()
	overheat = FALSE

/obj/item/gun/energy/kinetic_accelerator/update_overlays()
	. = ..()
	if(!can_shoot())
		. += "[icon_state]_empty"

//Casing
/obj/item/ammo_casing/energy/kinetic
	projectile_type = /obj/projectile/kinetic
	select_name = "kinetic"
	e_cost = 500
	fire_sound = 'sound/weapons/kenetic_accel.ogg' // fine spelling there chap

/obj/item/ammo_casing/energy/kinetic/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	if(loc && istype(loc, /obj/item/gun/energy/kinetic_accelerator))
		var/obj/item/gun/energy/kinetic_accelerator/KA = loc
		KA.modify_projectile(BB)

//Projectiles
/obj/projectile/kinetic
	name = "kinetic force"
	icon_state = null
	damage = 20
	damage_type = BRUTE
	armor_flag = BOMB
	range = 3
	log_override = TRUE

	var/pressure_decrease_active = FALSE
	var/pressure_decrease = 0.5
	var/obj/item/gun/energy/kinetic_accelerator/kinetic_gun

/obj/projectile/kinetic/Destroy()
	kinetic_gun = null
	return ..()

/obj/projectile/kinetic/prehit_pierce(atom/target)
	. = ..()
	if(. == PROJECTILE_PIERCE_PHASE)
		return
	if(kinetic_gun)
		var/list/mods = kinetic_gun.get_modkits()
		for(var/obj/item/borg/upgrade/modkit/modkit in mods)
			modkit.projectile_prehit(src, target, kinetic_gun)
	if(!pressure_decrease_active && !lavaland_equipment_pressure_check(get_turf(target)))
		name = "weakened [name]"
		damage = damage * pressure_decrease
		pressure_decrease_active = TRUE

/obj/projectile/kinetic/on_range()
	strike_thing()
	..()

/obj/projectile/kinetic/on_hit(atom/target)
	strike_thing(target)
	. = ..()

/obj/projectile/kinetic/proc/strike_thing(atom/target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		target_turf = get_turf(src)
	if(kinetic_gun) //hopefully whoever shot this was not very, very unfortunate.
		var/list/mods = kinetic_gun.get_modkits()
		for(var/obj/item/borg/upgrade/modkit/M in mods)
			M.projectile_strike_predamage(src, target_turf, target, kinetic_gun)
		for(var/obj/item/borg/upgrade/modkit/M in mods)
			M.projectile_strike(src, target_turf, target, kinetic_gun)
	if(ismineralturf(target_turf))
		var/turf/closed/mineral/M = target_turf
		M.gets_drilled(firer)
	var/obj/effect/temp_visual/kinetic_blast/K = new /obj/effect/temp_visual/kinetic_blast(target_turf)
	K.color = color

//mecha_kineticgun version of the projectile
/obj/projectile/kinetic/mech
	range = 5
