/*
	Behaviour for spooky subsystem
	This datum handles purchasing spooky events and such

	
*/

///How much time has to pass before we can spook again
#define MINIMUM_SPOOK_TIME 3 MINUTES
///If the last spook was this time ago, we need to spook NOW!
#define MAXIMUM_SPOOK_TIME 7 MINUTES

//What mode to generate a goal in
#define GOAL_MODE_CASUAL 1
#define GOAL_MODE_PANIC 2

//Default frugal behaviour
/datum/spooky_behaviour
	///Spending goal - what the system currently *wants* to buy
	var/spending_goal = /datum/spooky_event
	///How long it's been since something spooky happened - Leave this at 0, so we don't get possessions round start
	var/last_spook = 0
	///What are our spending options [thing = cost]
	var/list/spending_options = list(/datum/spooky_event/possession = 1, /datum/spooky_event/ghost = 1)
	///What active spooky events are... active - Pretty much for admin goofs
	var/list/active_products = list()

/datum/spooky_behaviour/New()
	. = ..()
	//Get initial goal
	spending_goal = generate_goal()

//Manage the current subsystem's currency, maybe purchase a spook or two
/datum/spooky_behaviour/proc/process_currency(datum/controller/subsystem/spooky/SS)
	//Check if we need to, and can, panic buy something if we're taking too long
	if(world.time > last_spook + MAXIMUM_SPOOK_TIME)
		spending_goal = generate_goal(GOAL_MODE_PANIC, SS.spectral_trespass)

	//Handle purchases
	if(spending_options[spending_goal] <= SS.spectral_trespass && world.time > last_spook+MINIMUM_SPOOK_TIME)
		//Purchase the thing:tm:
		var/datum/spooky_event/SE = new spending_goal()
		//Take our toll if we successfully do the thing
		if(SE?.setup(SS))
			SS.adjust_trespass(src, -spending_options[spending_goal], FALSE)
			spending_goal = generate_goal()
			last_spook = world.time
			//If the product doesn't remove itself straight away, we probably want to track it
			if(!QDELING(SE))
				active_products += SE
		else
			//Clean up datums that failed to setup
			qdel(SE)

//Get a spending goal for the system
/datum/spooky_behaviour/proc/generate_goal(goal_type = GOAL_MODE_CASUAL, available_currency = 0)
	switch(goal_type)
		if(GOAL_MODE_CASUAL)
			//Just pick anything, it doesn't matter
			return pick(spending_options)
		if(GOAL_MODE_PANIC)
			//WE NEED TO PICK SOMETHING WE CAN AFFORD NOW!
			var/picked_option
			for(var/i in spending_options)
				if(spending_options[i] <= available_currency)
					picked_option = i
			return picked_option

//For admins mostly
/datum/spooky_behaviour/proc/force_event(datum/spooky_event/event, datum/controller/subsystem/spooky/SS = SSspooky, do_cost = FALSE, do_cooldown = FALSE)
	//Purchase the thing:tm:
	var/datum/spooky_event/SE = new event
	//Take our toll if we successfully do the thing
	if(SE?.setup(SS))
		if(do_cost)
			SS.adjust_trespass(src, -spending_options[spending_goal], FALSE)
		if(do_cooldown)
			last_spook = world.time

//Avoid hard dels when a spooky events sepukus
/datum/spooky_behaviour/proc/handle_product(datum/source)
	SIGNAL_HANDLER

	active_products -= source

#undef MINIMUM_SPOOK_TIME
#undef MAXIMUM_SPOOK_TIME
#undef GOAL_MODE_CASUAL
#undef GOAL_MODE_PANIC
