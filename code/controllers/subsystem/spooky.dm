#define TRESPASS_SMALL 5
#define TRESPASS_MEDIUM 10
#define TRESPASS_LARGE 15

#define SPOOKY_ROT_TICK "rot_tick"

//Subsystem for handling chaplain's spooky adventures - spawns ghosts, possesions, ect
SUBSYSTEM_DEF(spooky)
	name = "Spooky"
	flags = SS_NO_FIRE
	init_order = FIRE_PRIORITY_SPOOKY
	
	///Our total budget for spooky thing
	var/spectral_trespass = 0
	var/maximum_trespass = 100
	///Is there an active chaplain on the station?
	var/active_chaplain = FALSE
	///List of active corpses
	var/list/corpses = list()
	///What kind of behaviour does the spooky system have today
		//TODO
	///How often do we tick rot?
	var/rot_tick = 10
	var/rot_amount = 1

/datum/controller/subsystem/spooky/Initialize(start_timeofday)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_DEATH, PROC_REF(add_corpse))
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_REVIVE, PROC_REF(remove_corpse))

/datum/controller/subsystem/spooky/process(delta_time)
	//Tick rot components
	if(world.time % rot_tick == 0)
		SEND_SIGNAL(src, SPOOKY_ROT_TICK, rot_amount)

///Use to properly adjust spectral trespass - adjust_trespass(who, how_much)
/datum/controller/subsystem/spooky/proc/adjust_trespass(datum/source, amount = TRESPASS_SMALL)
	//Make sure spectral trespass stays above 0, and below maximum_trespass
	spectral_trespass = min(maximum_trespass, max(0, spectral_trespass-amount))
	log_game("[source || "not specified"] increased spectral trespass by [amount] at [world.time] at [isatom(source) ? get_turf(source) : "not specified"].")

/datum/controller/subsystem/spooky/proc/add_corpse(datum/source, gibbed)
	SIGNAL_HANDLER

	var/mob/M = source
	if(gibbed || !is_station_level(M.z))
		return
	corpses |= source
	RegisterSignal(source, COMSIG_PARENT_QDELETING, PROC_REF(remove_corpse))

/datum/controller/subsystem/spooky/proc/remove_corpse(datum/source, gibbed)
	SIGNAL_HANDLER

	corpses -= source
