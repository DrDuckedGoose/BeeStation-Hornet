/datum/tutorial/ss13/controls
	name = "Space Station 13 - Basic Controls"
	desc = "Learn the very basics of Space Station 13. Recommended if you haven't played before."
	tutorial_id = "ss13_basic_1"
	tutorial_template = /datum/map_template/tutorial/controls

/datum/tutorial/ss13/controls/start_tutorial(mob/starting_mob)
	. = ..()
	init_mob()

	message_to_player("This is the tutorial for the basics of <b>Space Station 13</b>.")
	addtimer(CALLBACK(src, PROC_REF(require_move)), 4 SECONDS) // check if this is a good amount of time

//Teach them to move
/datum/tutorial/ss13/controls/proc/require_move()
	message_to_player("Move in any direction using <b>[retrieve_bind("move_north")]</b>, <b>[retrieve_bind("move_west")]</b>, <b>[retrieve_bind("move_south")]</b>, or <b>[retrieve_bind("move_east")]</b>.")

	RegisterSignal(tutorial_mob, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

//Teach them to pick stuff up
/datum/tutorial/ss13/controls/proc/on_move(datum/source, actually_moving, direction, specific_direction)
	SIGNAL_HANDLER

	UnregisterSignal(tutorial_mob, COMSIG_MOVABLE_MOVED)

	message_to_player("Pick up the <b>backpack</b> and equip it with <b>[retrieve_bind("quick_equip")]</b>.")
	RegisterSignal(tutorial_mob, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_backpack_equip))

//Unlock the door infront of them & Teach them to swap hands
/datum/tutorial/ss13/controls/proc/on_backpack_equip(datum/source, obj/item/equiped, slot)
	SIGNAL_HANDLER

	if(slot != ITEM_SLOT_BACK)
		return

	UnregisterSignal(tutorial_mob, COMSIG_MOB_EQUIPPED_ITEM)

	message_to_player("Switch hands with <b>[retrieve_bind("swap_hands")]</b>.")
	RegisterSignal(tutorial_mob, COMSIG_MOB_SWAP_HANDS, PROC_REF(on_hand_swap))

//Setup section tiggers
/datum/tutorial/ss13/controls/proc/on_hand_swap(datum/source)
	SIGNAL_HANDLER

	UnregisterSignal(tutorial_mob, COMSIG_MOB_SWAP_HANDS)

	var/obj/machinery/door/airlock/A = locate(/obj/machinery/door/airlock) in loc_from_corner(3, 12)
	A?.unbolt()

	for(var/i in 1 to 3)
		var/turf/T = loc_from_corner(7, 10+i)
		if(T)
			RegisterSignal(T, COMSIG_ATOM_ENTERED, PROC_REF(on_section_entered))

//Make 'em grab a fireaxe
/datum/tutorial/ss13/controls/proc/on_section_entered()
	SIGNAL_HANDLER

	for(var/i in 1 to 3)
		var/turf/T = loc_from_corner(7, 10+i)
		if(T)
			UnregisterSignal(T, COMSIG_ATOM_ENTERED)

	message_to_player("Items like the <b>fireaxe</b> can be used deal large amounts of damage. Pick up the <b>fireaxe</b>.")
	RegisterSignal(tutorial_mob, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_fireaxe_equip))

//Inform them about intents
/datum/tutorial/ss13/controls/proc/on_fireaxe_equip(datum/source, obj/item/equiped, slot)
	SIGNAL_HANDLER

	if(!istype(equiped, /obj/item/fireaxe))
		return

	UnregisterSignal(tutorial_mob, COMSIG_MOB_EQUIPPED_ITEM)

	message_to_player("You can change your character's intent with <b>[retrieve_bind("select_help_intent")]</b>, <b>[retrieve_bind("select_disarm_intent")]</b>, \
	<b>[retrieve_bind("select_grab_intent")]</b> and <b>[retrieve_bind("select_harm_intent")]</b>. Your character's intent will affect how you use items.\n Select \
	the harm intent, with <b>[retrieve_bind("select_harm_intent")]</b>.")
	RegisterSignal(tutorial_mob, COMSIG_MOB_INTENT_CHANGE, PROC_REF(on_help_intent))

//Make them do mean shit
/datum/tutorial/ss13/controls/proc/on_help_intent(datum/source, input)
	SIGNAL_HANDLER

	if(input != INTENT_HARM)
		return

	UnregisterSignal(tutorial_mob, COMSIG_MOB_INTENT_CHANGE)

	var/obj/machinery/door/airlock/A = locate(/obj/machinery/door/airlock) in loc_from_corner(11, 10)
	A?.unbolt()

	message_to_player("Good job. The tutorial will end shortly.")
	tutorial_end_in(8 SECONDS, TRUE)
