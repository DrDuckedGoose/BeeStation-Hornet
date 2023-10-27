#define LIFETIME_STAGE_0 0 MINUTES
#define LIFETIME_STAGE_1 3 MINUTES
#define LIFETIME_STAGE_2 5 MINUTES
#define LIFETIME_STAGE_3 8 MINUTES

/datum/spooky_event/haunt_room
	name = "haunt room"
	///Area we're responsible for haunting
	var/area/target_room
	///When did the spook first spook?
	var/initial_time
	///What stage of spook are we at?
	var/stage = 0
	///Are we on timeout for crimes against the crew?
	var/timeout = FALSE
	var/timeout_timer

/datum/spooky_event/haunt_room/setup(datum/controller/subsystem/spooky/SS)
	..()
	//logging
	var/area/A = pick_weight(SS?.areas)
	if(!A)
		log_game("[name]([src]) failed to create at [world.time]. No area available.")
		qdel(src)
		return FALSE
	log_game("[name]([src]) was created at [world.time], located in [A].")
	//Our unique logic
	target_room = A
	initial_time = world.time
	//Inform ghosts
	notify_ghosts("[A] has been haunted!", source = pick(A.contained_turfs))

/datum/spooky_event/haunt_room/process(delta_time)
	if(timeout)
		return
	timeout = TRUE
	switch(abs(initial_time-world.time))
		//First stage - flicker lights
		if(LIFETIME_STAGE_0 to LIFETIME_STAGE_1)
			target_room.lightswitch = FALSE
			target_room.power_change()
			target_room.lightswitch = TRUE
			target_room.power_change()

			//Timeout logic
			addtimer(CALLBACK(PROC_REF(toggle_timeout)), 10 SECONDS, TIMER_STOPPABLE)
		if(LIFETIME_STAGE_1 to LIFETIME_STAGE_2)
			target_room.lightswitch = FALSE
			target_room.power_change()
			target_room.lightswitch = TRUE
			target_room.power_change()

			//Timeout logic
			addtimer(CALLBACK(PROC_REF(toggle_timeout)), 10 SECONDS, TIMER_STOPPABLE)
		if(LIFETIME_STAGE_2 to LIFETIME_STAGE_3)
			target_room.lightswitch = FALSE
			target_room.power_change()
			target_room.lightswitch = TRUE
			target_room.power_change()

			//Timeout logic
			addtimer(CALLBACK(PROC_REF(toggle_timeout)), 10 SECONDS, TIMER_STOPPABLE)

/datum/spooky_event/haunt_room/proc/toggle_timeout(state = FALSE)
	timeout = state

#undef LIFETIME_STAGE_0
#undef LIFETIME_STAGE_1
#undef LIFETIME_STAGE_2
#undef LIFETIME_STAGE_3
