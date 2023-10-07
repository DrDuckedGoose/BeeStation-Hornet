#define TRESPASS_SMALL 5
#define TRESPASS_MEDIUM 10
#define TRESPASS_LARGE 15

#define SPOOKY_ROT_TICK "rot_tick"

//Subsystem for handling chaplain's spooky adventures - spawns ghosts, possesions, ect
SUBSYSTEM_DEF(spooky)
	name = "Spooky"
	flags = FIRE_PRIORITY_SPOOKY
	init_order = INIT_ORDER_SPOOKY
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	
	///Our total budget for spooky thing
	var/spectral_trespass = 0
	var/maximum_trespass = 100
	///Is there an active chaplain on the station?
	var/active_chaplain = FALSE
	///List of weighted active corpses - different from global dead mob list, just tracks carbons
	var/list/corpses = list()
	///What kind of behaviour does the spooky system have today
		//TODO
	///How often do we tick rot?
	var/rot_tick = 10
	var/rot_amount = 0.3

/datum/controller/subsystem/spooky/Initialize(start_timeofday)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_DEATH, PROC_REF(add_corpse))
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_REVIVE, PROC_REF(remove_corpse))

/datum/controller/subsystem/spooky/fire(resumed)
	//Tick rot components
	SEND_SIGNAL(src, SPOOKY_ROT_TICK, rot_amount)

///Use to properly adjust spectral trespass - adjust_trespass(who, how_much)
/datum/controller/subsystem/spooky/proc/adjust_trespass(datum/source, amount = TRESPASS_SMALL, log = TRUE)
	//Make sure spectral trespass stays above 0, and below maximum_trespass
	spectral_trespass = min(maximum_trespass, max(0, spectral_trespass-amount))
	if(log)
		log_game("[source || "not specified"] increased spectral trespass by [amount] at [world.time] at [isatom(source) ? get_turf(source) : "not specified"].")

/datum/controller/subsystem/spooky/proc/add_corpse(datum/source, mob/corpse, gibbed)
	SIGNAL_HANDLER

	//Don't possess exploration corpses
	if(gibbed || !is_station_level(corpse?.z) || !iscarbon(corpse))
		return
	//handle weird cases
	if(ismob(source) && !corpse)
		corpse = source
	//Weighting
	var/datum/component/rot/R = corpse?.GetComponent(/datum/component/rot)
	corpses[corpse] = R?.rot || 0
	//Handle the corpse being destroyed
	RegisterSignal(corpse, COMSIG_PARENT_QDELETING, PROC_REF(remove_corpse))

/datum/controller/subsystem/spooky/proc/remove_corpse(datum/source, mob/corpse)
	SIGNAL_HANDLER

	//remove & handle weird cases
	corpses -= source
	corpses -= corpse

/datum/controller/subsystem/spooky/proc/update_corpse(mob/corpse, amount)
	if(corpses[corpse] != null)
		corpses[corpse] = amount || corpses[corpse]
