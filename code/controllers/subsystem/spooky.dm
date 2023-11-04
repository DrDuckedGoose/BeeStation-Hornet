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
	///List of weighted active corpses - different from global dead mob list, just tracks carbons & has weights
	var/list/corpses = list()
	///List of weighted areas
	var/list/areas = list()
	///What kind of behaviour does the spooky system have today
	var/datum/spooky_behaviour/current_behaviour = /datum/spooky_behaviour
	///How often do we tick rot?
	var/rot_tick = 10
	var/rot_amount = 0.3

/datum/controller/subsystem/spooky/Initialize(start_timeofday)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_DEATH, PROC_REF(add_corpse))
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_REVIVE, PROC_REF(remove_corpse))

	//Setup spooky behaviour
	current_behaviour = new current_behaviour()
	//Build spooky area list
	for(var/area/a in GLOB.areas)
		if(is_station_level(a.z)) //We only care about the station tbh, don't waste resource making lavaland spooky - It will be spooky when Bacon makes lavaland a ghost
			areas[a] = a?.initial_spooky || 0.1 //we cant have areas be 0, because byond handles associated lists in an odd way

/datum/controller/subsystem/spooky/fire(resumed)
	//Tick rot components
	SEND_SIGNAL(src, SPOOKY_ROT_TICK, rot_amount)
	//Tick the current behaviour
	current_behaviour?.process_currency(src)

///Use to properly adjust spectral trespass - adjust_trespass(who, how_much)
/datum/controller/subsystem/spooky/proc/adjust_trespass(datum/source, amount = TRESPASS_SMALL, log = TRUE, force = FALSE)
	//Don't let lavaland corpses fuck us over
	var/atom/A = source
	if(isatom(source) && !is_station_level(A?.z) && !force)
		return
	// make sure we're not getting boosted by roundstart dead body placers - Better for readability for this to be a seperate IF
	if(!SSticker.HasRoundStarted() && !force)
		return
	//Make sure spectral trespass stays above 0, and below maximum_trespass
	spectral_trespass = min(maximum_trespass, max(0, spectral_trespass+amount))
	if(log)
		log_game("[source || "not specified"] increased spectral trespass by [amount] at [world.time] at [isatom(source) ? get_turf(source) : "not specified"].")
	
/datum/controller/subsystem/spooky/proc/adjust_area_temperature(datum/source, area, amount = 1, log = TRUE)
	if(!areas[area])
		areas[area] = 0.1
	else
		areas[area] += 1
	if(log)
		log_game("[source || "not specified"] increased [area] spectral temperature by [amount] at [world.time] at [isatom(source) ? get_turf(source) : "not specified"].")

/datum/controller/subsystem/spooky/proc/add_corpse(datum/source, mob/corpse, gibbed, force)
	SIGNAL_HANDLER

	//handle weird cases
	if(ismob(source) && !corpse)
		corpse = source
	//Don't possess exploration / lavaland corpses
	if((gibbed || !is_station_level(corpse?.z) || !iscarbon(corpse)) && !force)
		return
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

/proc/make_spooky_indicator(turf/T, result = 0)
	if(T)
		new /obj/effect/spectral_trespass(T, result)
