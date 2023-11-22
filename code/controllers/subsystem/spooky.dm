#define TRESPASS_MICRO 1
#define TRESPASS_SMALL 5
#define TRESPASS_MEDIUM 10
#define TRESPASS_LARGE 15

#define SPOOKY_ROT_TICK "rot_tick"

#define LOWER_GAIN 0.05
#define UPPER_GAIN 1

//TODO: fix the station level checks runtiming, the runtime is something like an index thing - Racc

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
	///Knob we can twist if the chaplain is doing *really* well or *really* bad
	var/gain_rate = 1
	///Is there an active chaplain on the station?
	var/mob/active_chaplain
	///List of weighted active corpses - different from global dead mob list, just tracks carbons & has weights
	var/list/corpses = list()
	///List of weighted areas
	var/list/areas = list()
	///What kind of behaviour does the spooky system have today
	var/datum/spooky_behaviour/current_behaviour = /datum/spooky_behaviour
	///How often do we tick rot?
	var/rot_amount = 0.3

/datum/controller/subsystem/spooky/Initialize(start_timeofday)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_DEATH, PROC_REF(add_corpse), TRUE)
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_REVIVE, PROC_REF(remove_corpse), TRUE)
	//Setup spooky behaviour
	current_behaviour = new current_behaviour()

/datum/controller/subsystem/spooky/fire(resumed)
	//Tick rot components
	SEND_SIGNAL(src, SPOOKY_ROT_TICK, rot_amount)
	//Tick the current behaviour
	current_behaviour?.process_currency(src)

///Use to properly adjust spectral trespass - adjust_trespass(who, how_much)
/datum/controller/subsystem/spooky/proc/adjust_trespass(datum/source, amount = TRESPASS_SMALL, log = TRUE, force = FALSE)
	//Don't let lavaland corpses fuck us over
	var/atom/A = source
	var/turf/T = isatom(A) ? get_turf(A?.loc) : null
	if(isatom(source) && !is_station_level(T?.z) && !force)
		return
	// make sure we're not getting boosted by roundstart dead body placers - Better for readability for this to be a seperate IF
	if(!SSticker.HasRoundStarted() && !force)
		return
	//Make sure spectral trespass stays above 0, and below maximum_trespass
	//TODO: Replace these with clamps - Racc
	spectral_trespass = min(maximum_trespass, max(0, spectral_trespass+(amount*gain_rate)))
	if(log)
		log_game("[source || "not specified"] increased spectral trespass by [amount*gain_rate] at [world.time] at [isatom(source) ? get_turf(source) : "not specified"].")
	
/datum/controller/subsystem/spooky/proc/adjust_area_temperature(datum/source, area/_area, amount = 1, log = TRUE)
	//Bunch of checks because areas are bullshit
	var/turf/T = pick(_area?.contained_turfs)
	if(_area && (!is_station_level(T?.z) || is_mining_level(T?.z) || istype(_area, /area/lavaland) || istype(_area, /area/ruin) || istype(_area, /area/ruin/powered)))
		return
	if(!areas[_area])
		areas[_area] = amount
	else
		areas[_area] += amount
	if(log)
		log_game("[source || "not specified"] increased [_area] spectral temperature by [amount] at [world.time] at [isatom(source) ? get_turf(source) : "not specified"].")

/datum/controller/subsystem/spooky/proc/add_corpse(datum/source, mob/corpse, gibbed, force)
	SIGNAL_HANDLER

	//handle weird cases
	if(ismob(source) && !corpse)
		corpse = source
	//Don't possess exploration / lavaland corpses
	var/turf/T = get_turf(corpse?.loc)
	if((gibbed || !is_station_level(T?.z) || !iscarbon(corpse)) && !force)
		return
	//Weighting
	var/datum/component/rot/R = corpse?.GetComponent(/datum/component/rot)
	corpses[corpse] = R?.rot || 0
	//Handle the corpse being destroyed
	RegisterSignal(corpse, COMSIG_PARENT_QDELETING, PROC_REF(remove_corpse), TRUE)

/datum/controller/subsystem/spooky/proc/remove_corpse(datum/source, mob/corpse)
	SIGNAL_HANDLER

	//remove & handle weird cases
	corpses -= source
	corpses -= corpse

/datum/controller/subsystem/spooky/proc/update_corpse(mob/corpse, amount)
	if(corpses[corpse] != null)
		corpses[corpse] = amount || corpses[corpse]

//Procs for tracking the chaplain
/datum/controller/subsystem/spooky/proc/register_chaplain(mob/chaplain)
	RegisterSignal(chaplain, COMSIG_PARENT_QDELETING, PROC_REF(manage_chaplain), TRUE)
	active_chaplain = chaplain

/datum/controller/subsystem/spooky/proc/manage_chaplain(datum/source)
	SIGNAL_HANDLER

	UnregisterSignal(active_chaplain, COMSIG_PARENT_QDELETING)
	active_chaplain = null

/datum/controller/subsystem/spooky/proc/adjust_gain(amount, exact = FALSE)
	if(exact)
		gain_rate = clamp(gain_rate+amount, LOWER_GAIN, UPPER_GAIN)
	else
		gain_rate = clamp(amount, LOWER_GAIN, UPPER_GAIN)

#undef LOWER_GAIN
#undef UPPER_GAIN

/proc/make_spooky_indicator(turf/T, result = 0)
	if(T)
		new /obj/effect/spectral_trespass(T, result)
