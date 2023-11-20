#define MAX_FUNERAL_GARNISH 0.5
#define FUNERAL_GARNISH_SWAP_LIMIT 3
#define GENERIC_ROT_REDUCTION 0.9
#define SMALL_TRESPASS_MOD 10
#define MEDIUM_TREPASS_MOD 6
#define MAX_ROT 100
#define MAX_SPACE_ROT 31

//Component for rotting corpses
/datum/component/rot
	///Typecasted parent
	var/mob/living/carbon/owner
	///How rotted this corpse currently is
	var/rot = 0
	var/max_rot = MAX_ROT
	///Resets for area stuff, when we make it smell
	var/old_area_bonus = 0
	var/old_area_message = ""
	///Has this rot been blessed?
	var/blessed = FALSE
	///Rot state for icon / effect stuff, reduces overhead
	var/rot_state
	var/atom/movable/rot_skeleton_underlay/skeleton_underlay
	///Is this corpse generating holy favour
	var/make_favor = FALSE
	///Extra modifer to encourage stuff like embalming
	var/favor_modifier = 1

/datum/component/rot/Initialize(...)
	. = ..()
	owner = parent
	//signals
	RegisterSignal(SSspooky, SPOOKY_ROT_TICK, PROC_REF(tick_rot))
	RegisterSignal(owner, COMSIG_GLOB_MOB_REVIVE, PROC_REF(handle_owner))
	//area
	var/area/A = get_area(owner)
	old_area_bonus = A?.mood_bonus
	old_area_message = A?.mood_message

/datum/component/rot/RemoveComponent()
	. = ..()
	qdel(src)

/datum/component/rot/Destroy(force, silent)
	owner?.remove_emitter("rot")
	owner?.remove_emitter("stink")
	manage_filters(0)
	owner = null
	var/area/A = get_area(owner)
	A?.mood_bonus = old_area_bonus
	A?.mood_message = old_area_message

	return ..()

/datum/component/rot/proc/set_rot(var/amount = 0)
	if(rot == amount)
		return
	rot = amount
	SSspooky.update_corpse(owner, rot)

/datum/component/rot/proc/tick_rot(datum/source, var/amount = 0)
	SIGNAL_HANDLER

	manage_effects()

	//Don't rot too much, too little, or while we're alive
	if(rot >= max_rot || amount == 0 || owner.stat != DEAD)
		return

	//Modifiers - readability over... the other thing
	if(HAS_TRAIT(owner, TRAIT_EMBALMED))
		amount *= GENERIC_ROT_REDUCTION
	if(istype(owner?.loc, /obj/structure/closet/crate/coffin) || istype(owner?.loc, /obj/structure/bodycontainer))
		//Calculate garnish stuff
		if(istype(owner?.loc, /obj/structure/closet/crate/coffin))
			var/obj/structure/closet/crate/coffin/C = owner?.loc
			amount *= max((length(C.garnishes) * 0.1) - 1, MAX_FUNERAL_GARNISH)
			if(length(C.garnishes) >= FUNERAL_GARNISH_SWAP_LIMIT)
				make_favor = TRUE
				//Effect
				var/atom/target = isturf(owner.loc) ? owner : owner.loc
				var/filter = target.get_filter("garnish_outline")
				if(!filter)
					target.add_filter("garnish_outline", 10, outline_filter(0, rgb(255, 255, 50)))
					filter = target.get_filter("garnish_outline")
				animate(filter, size = (max_rot == MAX_SPACE_ROT ? 1 : 2), time = 1 SECONDS)
				animate(size = 0, time = 2 SECONDS)
			else
				make_favor = FALSE
		else
			amount *= GENERIC_ROT_REDUCTION
	//Spacing corpses *does* reduce rot, but it has a consequence
	if(isspaceturf(get_turf(owner.loc)))
		amount *= GENERIC_ROT_REDUCTION
		make_favor = FALSE
		max_rot = MAX_SPACE_ROT
	else
		max_rot = MAX_ROT
	//Generic blessing flag for litanies
	if(blessed)
		amount *= GENERIC_ROT_REDUCTION
		SSspooky.remove_corpse(owner)
	else
		SSspooky.add_corpse(owner)
	//handle rot value
	var/area/A = get_area(get_turf(owner)) //handle rot mods
	var/rot_mod = 1
	if(A) //becuase the rot mod can be 0, don't just check that variable
		rot_mod = A?.rot_modifier

	if(rot < max_rot)
		rot = max(0, min(max_rot, rot+amount * rot_mod))
	SSspooky.update_corpse(owner, rot)

/datum/component/rot/proc/manage_effects(do_checks = TRUE, custom_amount)
	switch(custom_amount || rot)
		//lowest rot
		if(0 to 30)
			owner?.remove_emitter("rot")
			owner?.remove_emitter("stink")
			manage_filters(rot)
			return
		//medium rot
		if(31 to 50)
			//funky particles
			if(!owner?.master_holder?.emitters["rot"])
				owner?.add_emitter(/obj/emitter/flies, "rot", 10, 8)
			//Spooky punishment
			SSspooky.adjust_trespass(owner, TRESPASS_SMALL / SMALL_TRESPASS_MOD, FALSE)
			//Holy benehfits
			if(make_favor)
				var/datum/religion_sect/R = GLOB.religious_sect
				R?.adjust_favor((TRESPASS_SMALL / SMALL_TRESPASS_MOD) * favor_modifier)
			//Area flavor / detective hints
			if(do_checks)
				if(!(istype(owner?.loc, /obj/structure/closet/crate/coffin) || istype(owner?.loc, /obj/structure/bodycontainer)))
					var/area/A = get_area(owner)
					A?.mood_bonus = -1
					A?.mood_message = "<span class='warning'>It smells in here.</span>"
			//Filters
			manage_filters(rot)
		//max rot
		if(51 to 100)
			//They ROTTED
			owner.become_husk()
			//funky particles
			if(!owner?.master_holder?.emitters["rot"])
				owner?.add_emitter(/obj/emitter/flies, "rot", 10, 8)
			if(!owner?.master_holder?.emitters["stink"])
				owner?.add_emitter(/obj/emitter/stink_lines, "stink", 11, 30)
			//Make sure spaced bodies never exceed small rot punishments
			var/rot_consequence = max_rot == MAX_SPACE_ROT ? SMALL_TRESPASS_MOD : MEDIUM_TREPASS_MOD
			//Spooky punishment
			SSspooky.adjust_trespass(owner, TRESPASS_SMALL / rot_consequence, FALSE)
			//Holy benehfits
			if(make_favor)
				var/datum/religion_sect/R = GLOB.religious_sect
				R?.adjust_favor((TRESPASS_SMALL / rot_consequence) * favor_modifier)
			//Area flavor / detective hints
			if(do_checks)
				if(!istype(owner?.loc, /obj/structure/closet/crate/coffin))
					var/area/A = get_area(owner)
					A?.mood_bonus = -2
					A?.mood_message = "<span class='warning'>It reeks in here!</span>"
			//Filters
			manage_filters(rot)

/datum/component/rot/proc/handle_owner()
	//Typically spooky removes it owns corpses, but we might get removed by an admin or something else I forgor
	SSspooky.remove_corpse(owner)
	RemoveComponent()

//TODO: Fix the skeleton underlay not rendering - Racc
//Used to make the owner rot away and show their skeleton underneath
/datum/component/rot/proc/manage_filters(_rot = 0)
	var/t_rot_state
	switch(_rot)
		if(20 to 31)
			t_rot_state = "rot_1"
		if(32 to 50)
			t_rot_state = "rot_2"
		if(50 to 100)
			t_rot_state = "rot_3"
	if(t_rot_state == rot_state) //if the state hasn't changed, don't do all this again
		return
	owner.remove_filter("rot_mask")
	owner.vis_contents -= skeleton_underlay
	QDEL_NULL(skeleton_underlay)
	rot_state = t_rot_state
	if(!rot_state)
		return
	//Build icons
	var/icon/I = icon('icons/effects/rot.dmi', icon_state = rot_state) //Generic rot mask
	var/icon/limb
	var/icon/skeleton_icon = icon('icons/mob/human_parts.dmi', "skeleton_chest")
	var/list/full = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	for(var/i in full)
		if(owner.get_bodypart(i))
			//snowflake code for hands
			if((i == BODY_ZONE_R_ARM || i == BODY_ZONE_L_ARM) && owner.get_bodypart(i))
				limb = icon('icons/mob/human_parts.dmi', icon_state = "skeleton_[i == BODY_ZONE_R_ARM ? "r_hand" : "l_hand"]")
				skeleton_icon.Blend(limb, ICON_OVERLAY)
			//otherwise
			limb = icon('icons/mob/human_parts.dmi', icon_state = "skeleton_[i]")
			skeleton_icon.Blend(limb, ICON_OVERLAY)
	skeleton_underlay = new()
	skeleton_underlay.appearance = skeleton_icon
	skeleton_underlay.appearance_flags = KEEP_APART //This gets reset just above
	skeleton_underlay.vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE | VIS_INHERIT_LAYER | VIS_INHERIT_ID //good lird
	skeleton_underlay.add_filter("rot_mask", 10, alpha_mask_filter(icon = I, flags = MASK_INVERSE))
	//Apply filters
	owner.vis_contents += skeleton_underlay
	owner.add_filter("rot_mask", 10, alpha_mask_filter(icon = I))

//What's the fucking point of this shit if it gets overridden
//TODO: Consider removing this - Racc
/atom/movable/rot_skeleton_underlay
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE | VIS_INHERIT_LAYER | VIS_INHERIT_ID
	appearance_flags = KEEP_APART

#undef MAX_FUNERAL_GARNISH
#undef FUNERAL_GARNISH_SWAP_LIMIT
#undef GENERIC_ROT_REDUCTION
#undef SMALL_TRESPASS_MOD
#undef MEDIUM_TREPASS_MOD
#undef MAX_ROT
#undef MAX_SPACE_ROT
