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
	var/datum/spooky_event/spending_goal = /datum/spooky_event
	///How long it's been since something spooky happened - Leave this at 0, so we don't get possessions round start
	var/last_spook = 0
	///What are our spending options [thing = weight]
	var/list/spending_options = list(/datum/spooky_event/possession = 1, /datum/spooky_event/ghost = 1, /datum/spooky_event/haunt_room = 1)
	///What active spooky events are... active - Pretty much for admin goofs
	var/list/active_products = list()
	var/list/nails = list()
	///What message the chaplain gets when we spawn an event - Pretty much for admin goofs 
	var/chaplain_message = "A terrible chill runs up your spine..."

/datum/spooky_behaviour/New()
	. = ..()
	//Get initial goal
	spending_goal = generate_goal()

//Manage the current subsystem's currency, maybe purchase a spook or two
/datum/spooky_behaviour/proc/process_currency(datum/controller/subsystem/spooky/SS)
	//Check if we need to, and can, panic buy something if we're taking too long
	if(world.time > last_spook + MAXIMUM_SPOOK_TIME)
		spending_goal = generate_goal(GOAL_MODE_PANIC)
	//Check if the current goal is allowed with the current chaplain status
	if((initial(spending_goal.requires_chaplain) && (SS.active_chaplain?.stat == DEAD || !SS.active_chaplain)) || !spending_goal)
		spending_goal = generate_goal()	
	//Handle purchases
	var/datum/spooky_event/SE = spending_goal
	if(initial(SE.cost) <= SS.spectral_trespass && world.time > last_spook+MINIMUM_SPOOK_TIME)
		//Purchase the thing:tm:
		SE = new spending_goal()
		//Take our toll if we successfully do the thing
		if(SE?.setup(SS))
			SS.adjust_trespass(src, -SE.cost, FALSE)
			last_spook = world.time
			//Alert the chaplain something *terrible* has happened
			var/mob/M = SS.active_chaplain
			if(M?.stat != DEAD)
				M.balloon_alert(M, chaplain_message)
				to_chat(M, "<span class='warning'>[chaplain_message]</span>")
			//If the product doesn't remove itself straight away, we probably want to track it
			if(!QDELING(SE))
				RegisterSignal(SE, COMSIG_PARENT_QDELETING, PROC_REF(handle_product))
				if(M)
					var/atom/movable/sin_nail/S = new(get_turf(M), M)
					S.name = SE.name
					nails += list("[SE]" = S)
				active_products += SE
		else
			//Clean up datums that failed to setup
			if(!QDELETED(SE))
				qdel(SE)
		spending_goal = generate_goal()	

//Get a spending goal for the system
/datum/spooky_behaviour/proc/generate_goal(goal_type = GOAL_MODE_CASUAL, available_currency = SSspooky.spectral_trespass)
	switch(goal_type)
		if(GOAL_MODE_CASUAL)
			//Just pick anything, it doesn't matter
			return pick_weight(spending_options)
		if(GOAL_MODE_PANIC)
			//WE NEED TO PICK SOMETHING WE CAN AFFORD NOW!
			var/list/options = list()
			for(var/i in spending_options)
				var/datum/spooky_event/SE = i
				if(initial(SE.cost) <= available_currency)
					options += i
			return pick(options)

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

	var/atom/movable/sin_nail/S = nails["[source]"]
	if(S)
		nails -= "[source]"
		qdel(S)
	active_products -= source

#undef MINIMUM_SPOOK_TIME
#undef MAXIMUM_SPOOK_TIME
#undef GOAL_MODE_CASUAL
#undef GOAL_MODE_PANIC

//Sin nail this system uses communicate the current products to the chaplain
/atom/movable/sin_nail
	plane = HUD_PLANE
	//TODO: Consider disabling the mouse opacity - Racc

/atom/movable/sin_nail/Initialize(mapload, atom/target)
	. = ..()
	if(!target)
		return INITIALIZE_HINT_QDEL
	//Build the appearance
	var/image/I = image(icon = 'icons/obj/religion.dmi', icon_state = "nail_normal", layer = ABOVE_MOB_LAYER, loc = src)
	//Filter
	I.filters += filter(type = "outline", size = 1, color = "#ffffffaa")
	//Only the chosen can see it
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/holyAware, "spectral trespass", I)
	//Make it orbit
	var/icon/TI = icon(target.icon,target.icon_state,target.dir)
	var/orbitsize = (TI.Width()+TI.Height())*0.5
	orbitsize -= (orbitsize/world.icon_size)*(world.icon_size*0.25)
	orbit(target, orbitsize, rand(0, 1), rand(10, 20), 36)

/atom/movable/sin_nail/can_be_pulled(user, grab_state, force)
	return FALSE
	