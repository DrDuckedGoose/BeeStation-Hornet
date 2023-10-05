
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

/datum/component/rot/proc/tick_rot(datum/source, amount)
	SIGNAL_HANDLER

	//handle rot value
	rot = max(0, min(100, rot+amount))
	if(rot != 0 && rot != 100 && amount != 0)
		SSspooky.update_corpse(src)
	//Some special cases
	if(rot >= 100)
		return
	owner?.remove_emitter("rot")
	owner?.remove_emitter("stink")
	switch(rot)
		//lowest rot
		if(0 to 30)
			return
		//medium rot
		if(31 to 50)
			owner?.add_emitter(/obj/emitter/flies, "rot", 10, -1)
		//max rot
		if(51 to 100)
			owner.become_husk()
			owner?.add_emitter(/obj/emitter/flies, "rot", 11, -1)
			owner?.add_emitter(/obj/emitter/stink_lines, "stink", 11, -1)

/datum/component/rot/proc/bless()
	Ssspooky.remove_corpse(owner)
