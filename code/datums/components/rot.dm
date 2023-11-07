#define MAX_FUNERAL_GARNISH 0.5
#define GENERIC_ROT_REDUCTION 0.9

//Component for rotting corpses
/datum/component/rot
	///Typecasted parent
	var/mob/living/carbon/owner
	///How rotted this corpse currently is
	var/rot = 0
	///Resets for area stuff, when we make it smell
	var/old_area_bonus = 0
	var/old_area_message = ""
	///Has this rot been blessed?
	var/blessed = FALSE

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
	if(rot >= 100 || amount == 0 || owner.stat != DEAD)
		return

	//Modifiers - readability over... the other thing
	if(HAS_TRAIT(owner, TRAIT_EMBALMED))
		amount *= GENERIC_ROT_REDUCTION
	//Spacing corpses *does* reduce rot, but it has a consequence
	if(isspaceturf(get_turf(owner.loc)))
		amount *= GENERIC_ROT_REDUCTION
		//The consequence
	if(istype(owner?.loc, /obj/structure/closet/crate/coffin) || istype(owner?.loc, /obj/structure/bodycontainer))
		//Calculate garnish stuff
		if(istype(owner?.loc, /obj/structure/closet/crate/coffin))
			var/obj/structure/closet/crate/coffin/C = owner?.loc
			amount *= max((length(C.garnishes) * 0.1) - 1, MAX_FUNERAL_GARNISH)
			//TODO: Implement document features - Racc
		else
			amount *= GENERIC_ROT_REDUCTION
	if(blessed)
		amount *= GENERIC_ROT_REDUCTION
	//handle rot value
	var/area/A = get_area(owner) //handle rot mods
	var/rot_mod = 1
	if(A) //becuase the rot mod can be 0, don't just check that variable
		rot_mod = A?.rot_modifier

	rot = max(0, min(100, rot+amount * rot_mod))
	SSspooky.update_corpse(owner, rot)

/datum/component/rot/proc/manage_effects(do_checks = TRUE, custom_amount)
	switch(custom_amount || rot)
		//lowest rot
		if(0 to 30)
			owner?.remove_emitter("rot")
			owner?.remove_emitter("stink")
			return
		//medium rot
		if(31 to 50)
			//funky particles
			if(!owner?.master_holder?.emitters["rot"])
				owner?.add_emitter(/obj/emitter/flies, "rot", 10, -1)
			//Spooky punishment
			SSspooky.adjust_trespass(owner, TRESPASS_SMALL / 10, FALSE)
			//Area flavor / detective hints
			if(do_checks)
				if(!(istype(owner?.loc, /obj/structure/closet/crate/coffin) || istype(owner?.loc, /obj/structure/bodycontainer)))
					var/area/A = get_area(owner)
					A?.mood_bonus = -1
					A?.mood_message = "<span class='warning'>It smells in here.</span>"
		//max rot
		if(51 to 100)
			//They ROTTED
			owner.become_husk()
			//funky particles
			if(!owner?.master_holder?.emitters["rot"])
				owner?.add_emitter(/obj/emitter/flies, "rot", 10, -1)
			if(!owner?.master_holder?.emitters["stink"])
				owner?.add_emitter(/obj/emitter/stink_lines, "stink", 11, -1)
			//Spooky punishment
			SSspooky.adjust_trespass(owner, TRESPASS_SMALL / 5, FALSE)
			//Area flavor / detective hints
			if(do_checks)
				if(!istype(owner?.loc, /obj/structure/closet/crate/coffin))
					var/area/A = get_area(owner)
					A?.mood_bonus = -2
					A?.mood_message = "<span class='warning'>It reeks in here!</span>"

/datum/component/rot/proc/bless(mob/living/chap)
	if(!chap?.mind?.holy_role)
		return
	var/datum/religion_sect/R = GLOB.religious_sect
	var/prompt = alert(chap, "Do you want to bless [owner || "this body"] for 50 favor?", "Bless Corpse", "Yes", "No")
	if(R?.favor <= 50 || !chap || prompt != "Yes")
		if(R?.favor <= 50 )
			to_chat(chap, "<span class='warning'>You don't have enough favor!</span>")
		return
	R.adjust_favor(50, chap)
	SSspooky.remove_corpse(owner)
	blessed = TRUE

/datum/component/rot/proc/handle_owner()
	//Typically spooky removes it owns corpses, but we might get removed by an admin or something else I forgor
	SSspooky.remove_corpse(owner)
	RemoveComponent()

#undef MAX_FUNERAL_GARNISH
#undef GENERIC_ROT_REDUCTION
