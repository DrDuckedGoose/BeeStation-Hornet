
//Component for rotting corpses
/datum/component/rot
	///Typecasted parent
	var/mob/living/carbon/owner
	///How rotted this corpse currently is
	var/rot = 0
	////Is this corpse blessed
	var/blessed = FALSE

/datum/component/rot/Initialize(...)
	. = ..()
	RegisterSignal(SSspooky, SPOOKY_ROT_TICK, PROC_REF(tick_rot))

/datum/component/rot/Destroy(force, silent)
	. = ..()
	owner = null

/datum/component/rot/proc/tick_rot(datum/source, amount)
	SIGNAL_HANDLER

	rot = max(0, min(100, rot+amount))
