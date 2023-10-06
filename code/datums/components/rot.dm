
//TODO: ask if this would be better as an element - it might be
//Component for rotting corpses
/datum/component/rot
	///Typecasted parent
	var/mob/living/carbon/owner
	///How rotted this corpse currently is
	var/rot = 0

/datum/component/rot/Initialize(...)
	. = ..()
	owner = parent
	RegisterSignal(SSspooky, SPOOKY_ROT_TICK, PROC_REF(tick_rot))

/datum/component/rot/Destroy(force, silent)
	. = ..()
	owner?.remove_emitter("rot")
	owner?.remove_emitter("stink")
	owner = null

/datum/component/rot/proc/tick_rot(datum/source, var/amount = 0)
	SIGNAL_HANDLER

	if(rot >= 100 || amount == 0)
		return

	//Modifiers
	if(HAS_TRAIT(owner, TRAIT_EMBALMED))
		amount *= 0.9
	if(isspaceturf(get_turf(owner)))
		amount *= 0.9
	if(istype(owner?.loc, /obj/structure/closet/crate/coffin))
		amount *= 0.9
	//handle rot value
	rot = max(0, min(100, rot+amount))
	SSspooky.update_corpse(owner, rot)
	switch(rot)
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
			SSspooky.adjust_trespass(owner, TRESPASS_MEDIUM / 10, FALSE)

/datum/component/rot/proc/bless()
	SSspooky.remove_corpse(owner)
