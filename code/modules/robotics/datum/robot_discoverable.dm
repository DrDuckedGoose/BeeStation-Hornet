/*
	The idea here is, robots can be scanned repeatedly but typically have zero research value.
	When limbs life() tick, they add onto the amount of research points this component has, which
	is set back to zero when it's scanned.
*/

/datum/component/discoverable/robot
	///How much general research do we have stored
	var/general_reward = 0

/datum/component/discoverable/robot/Initialize(point_reward, unique, get_discover_id)
	. = ..()
	src.unique = TRUE

/datum/component/discoverable/robot/discovery_scan(datum/techweb/linked_techweb, mob/user)
	. = ..()
	scanned = FALSE
	//Reward general
	linked_techweb.add_point_type(TECHWEB_POINT_TYPE_GENERIC, general_reward)
	to_chat(user, "<span class='notice'>New datapoint scanned, [point_reward] discovery points gained.</span>")
	//Reset our stores
	point_reward = 0
	general_reward = 0
