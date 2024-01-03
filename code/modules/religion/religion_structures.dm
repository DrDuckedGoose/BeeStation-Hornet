/obj/structure/altar_of_gods
	name = "\improper Altar of the Gods"
	desc = "An altar which allows the head of the church to choose a sect of religious teachings as well as provide sacrifices to earn favor."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "convertaltar"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	pass_flags_self = LETPASSTHROW
	can_buckle = TRUE
	buckle_lying = 90 //we turn to you!
	resistance_flags = INDESTRUCTIBLE
	///Avoids having to check global everytime by referencing it locally.
	var/datum/religion_sect/sect_to_altar

/obj/structure/altar_of_gods/Initialize(mapload)
	. = ..()
	reflect_sect_in_icons()
	AddElement(/datum/element/climbable)

/obj/structure/altar_of_gods/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/religious_tool, ALL, FALSE, CALLBACK(src, PROC_REF(reflect_sect_in_icons)))

/obj/structure/altar_of_gods/attack_hand(mob/living/user)
	if(!Adjacent(user) || !user.pulling || !isliving(user.pulling))
		new /obj/effect/bible_indicator(get_turf(src))
		return ..()
	var/mob/living/pushed_mob = user.pulling
	if(pushed_mob.buckled)
		to_chat(user, "<span class='warning'>[pushed_mob] is buckled to [pushed_mob.buckled]!</span>")
		return ..()
	to_chat(user,"<span class='notice>You try to coax [pushed_mob] onto [src]...</span>")
	if(!do_after(user,(5 SECONDS),target = pushed_mob))
		return ..()
	pushed_mob.forceMove(loc)
	return ..()

/obj/structure/altar_of_gods/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/nullrod))
		if(user.mind?.holy_role == NONE)
			to_chat(user, "<span class='warning'>Only the faithful may control the disposition of [src]!</span>")
			return
		anchored = !anchored
		if(GLOB.religious_sect)
			GLOB.religious_sect.altar_anchored = anchored //Having more than one altar of the gods is only possible through adminbus so this should screw with normal gameplay
		user.visible_message("<span class ='notice'>[user] [anchored ? "" : "un"]anchors [src] [anchored ? "to" : "from"] the floor with [I].</span>", "<span class ='notice'>You [anchored ? "" : "un"]anchor [src] [anchored ? "to" : "from"] the floor with [I].</span>")
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		user.do_attack_animation(src)
		return
	if(I.tool_behaviour == TOOL_WRENCH)
		return
	return ..()

/obj/structure/altar_of_gods/proc/reflect_sect_in_icons()
	if(GLOB.religious_sect)
		sect_to_altar = GLOB.religious_sect
		if(sect_to_altar.altar_icon)
			icon = sect_to_altar.altar_icon
		if(sect_to_altar.altar_icon_state)
			icon_state = sect_to_altar.altar_icon_state

/obj/structure/destructible/religion
	density = TRUE
	anchored = FALSE
	icon = 'icons/obj/religion.dmi'
	light_power = 2
	var/cooldowntime = 0
	break_sound = 'sound/effects/glassbr2.ogg'

/obj/structure/destructible/religion/nature_pylon
	name = "Orb of Nature"
	desc = "A floating crystal that slowly heals all plantlife and holy creatures. It can be anchored with a null rod."
	icon_state = "nature_orb"
	anchored = FALSE
	light_range = 5
	light_color = LIGHT_COLOR_GREEN
	break_message = "<span class='warning'>The luminous green crystal shatters!</span>"
	var/heal_delay = 20
	var/last_heal = 0
	var/spread_delay = 45
	var/last_spread = 0

/obj/structure/destructible/religion/nature_pylon/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/destructible/religion/nature_pylon/LateInitialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/destructible/religion/nature_pylon/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/structure/destructible/religion/nature_pylon/process(delta_time)
	if(last_heal <= world.time)
		last_heal = world.time + heal_delay
		for(var/mob/living/L in range(5, src))
			if(L.health == L.maxHealth)
				continue
			if(!ispodperson(L) && !L.mind?.holy_role)
				continue
			new /obj/effect/temp_visual/heal(get_turf(src), "#47ac05")
			if(ispodperson(L) || L.mind?.holy_role)
				L.adjustBruteLoss(-2*delta_time, 0)
				L.adjustToxLoss(-2*delta_time, 0)
				L.adjustOxyLoss(-2*delta_time, 0)
				L.adjustFireLoss(-2*delta_time, 0)
				L.adjustCloneLoss(-2*delta_time, 0)
				L.updatehealth()
				if(L.blood_volume < BLOOD_VOLUME_NORMAL)
					L.blood_volume += 1.0
			CHECK_TICK
	if(last_spread <= world.time)
		var/list/validturfs = list()
		var/list/natureturfs = list()
		for(var/T in circleviewturfs(src, 5))
			if(istype(T, /turf/open/floor/grass))
				natureturfs |= T
				continue
			var/static/list/blacklisted_pylon_turfs = typecacheof(list(
				/turf/closed,
				/turf/open/floor/grass,
				/turf/open/space,
				/turf/open/lava,
				/turf/open/chasm))
			if(is_type_in_typecache(T, blacklisted_pylon_turfs))
				continue
			else
				validturfs |= T

		last_spread = world.time + spread_delay

		var/turf/T = safepick(validturfs)
		if(T)
			if(istype(T, /turf/open/floor/plating))
				T.PlaceOnTop(pick(/turf/open/floor/grass, /turf/open/floor/grass/fairy/green), flags = CHANGETURF_INHERIT_AIR)
			else
				T.ChangeTurf(pick(/turf/open/floor/grass, /turf/open/floor/grass/fairy/green), flags = CHANGETURF_INHERIT_AIR)
		else
			var/turf/open/floor/grass/F = safepick(natureturfs)
			if(F)
				new /obj/effect/temp_visual/religion/turf/floor(F)
			else
				// Are we in space or something? No grass turfs or
				// convertable turfs?
				last_spread = world.time + spread_delay*2

/obj/structure/destructible/religion/nature_pylon/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/nullrod))
		if(user.mind?.holy_role == NONE)
			to_chat(user, "<span class='warning'>Only the faithful may control the disposition of [src]!</span>")
			return
		anchored = !anchored
		user.visible_message("<span class ='notice'>[user] [anchored ? "" : "un"]anchors [src] [anchored ? "to" : "from"] the floor with [I].</span>", "<span class ='notice'>You [anchored ? "" : "un"]anchor [src] [anchored ? "to" : "from"] the floor with [I].</span>")
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		user.do_attack_animation(src)
		return
	if(I.tool_behaviour == TOOL_WRENCH)
		return
	return ..()

////Shadow Sect //Original code by DingoDongler

/obj/structure/destructible/religion/shadow_obelisk
	name = "Shadow Obelisk"
	desc = "Grants favor from being shrouded in shadows."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "shadow-obelisk"
	anchored = FALSE
	break_message = "<span class='warning'>The Obelisk crumbles before you!</span>"

/obj/structure/destructible/religion/shadow_obelisk/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/nullrod))
		if(user.mind?.holy_role == NONE)
			to_chat(user, "<span class='warning'>Only the faithful may control the disposition of [src]!</span>")
			return
		anchored = !anchored
		user.visible_message("<span class ='notice'>[user] [anchored ? "" : "un"]anchors [src] [anchored ? "to" : "from"] the floor with [I].</span>", "<span class ='notice'>You [anchored ? "" : "un"]anchor [src] [anchored ? "to" : "from"] the floor with [I].</span>")
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		user.do_attack_animation(src)
		return
	if(I.tool_behaviour == TOOL_WRENCH)
		return
	return ..()

// Favor generator component. Used on the altar and obelisks
/datum/component/dark_favor //Original code by DingoDongler
	var/mob/living/creator

/datum/component/dark_favor/Initialize(mob/living/L)
	. = ..()
	if(!L)
		return
	creator = L
	START_PROCESSING(SSobj, src)

/datum/component/dark_favor/Destroy() //Original code by DingoDongler
	. = ..()
	STOP_PROCESSING(SSobj, src)

/datum/component/dark_favor/process(delta_time) //Original code by DingoDongler
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!istype(parent, /atom) || !istype(creator) || !istype(sect))
		return
	var/atom/P = parent
	var/turf/T = P.loc
	if(!istype(T))
		return
	var/light_amount = T.get_lumcount()
	var/favor_gained = max(1 - light_amount, 0) * delta_time
	sect.adjust_favor(favor_gained, creator)

/obj/effect/bible_indicator
	icon = 'icons/obj/storage.dmi'
	icon_state = "bible"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_y = 32
	alpha = 200

/obj/effect/bible_indicator/Initialize(mapload)
	. = ..()
	for(var/obj/effect/bible_indicator/B in loc)
		if(B != src)
			return INITIALIZE_HINT_QDEL
	animate(src, alpha = 0, time = 0.5 SECONDS, loop = -1, easing = JUMP_EASING)
	animate(alpha = 255, time = 0.5 SECONDS, easing = JUMP_EASING)
	addtimer(CALLBACK(src, PROC_REF(self_destruct)), 3 SECONDS)

/obj/effect/bible_indicator/proc/self_destruct()
	qdel(src)
	
///Wall cross to show the chaplain's achievments, and help track events
/obj/structure/religion/wall_cross
	icon = 'icons/obj/religion.dmi'
	icon_state = "cross"
	name = "wooden cross"
	desc = "An icon of religion. It has many twisted nails hanging from it."
	density = FALSE
	///Reference to nail overlay
	var/mutable_appearance/nail_overlay
	var/nail_stage = 0
	//nail name stuff
	var/list/nail_names = list()

/obj/structure/religion/wall_cross/Initialize(mapload)
	. = ..()
	GLOB.reward_cross = src

/obj/structure/religion/wall_cross/examine(mob/user)
	. = ..()
	if(!length(nail_names))
		return
	for(var/i in nail_names)
		. += "<span class='notice'>There [nail_names[i] > 1 ? "are" : "is"] [nail_names[i]] nail[nail_names[i] > 1 ? "s" : ""] for [i].</span>"

/obj/structure/religion/wall_cross/proc/bump_nails(datum/spooky_event/SE)
	if(nail_overlay)
		cut_overlay(nail_overlay)
	nail_stage += 1
	var/nail_state
	//Add more states if you add more icons
	switch(nail_stage)
		if(1 to 2)
			nail_state = "cross_nail_low"
		if(3 to 5)
			nail_state = "cross_nail_medium"
		if(6 to 10)
			nail_state = "cross_nail_high"
		else
			nail_state = "cross_nail_gold"
	nail_overlay = mutable_appearance(src.icon, nail_state)
	add_overlay(nail_overlay)
	//Description stuff
	nail_names[SE.name] += 1
