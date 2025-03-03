/datum/plant_feature/fruit
	icon = 'icons/obj/hydroponics/features/fruit.dmi'
	icon_state = "apple"

	///list of fruit we have produced, yet to be harvested
	var/list/fruits = list()

	///
	var/growth_time = 1 SECONDS
	var/list/growth_timers = list()

/datum/plant_feature/fruit/New(datum/component/plant/_parent)
	. = ..()
	if(!parent)
		return
	RegisterSignal(parent, COMSIG_PLANT_REQUEST_FRUIT, PROC_REF(setup_fruit))
	RegisterSignal(parent.plant_item, COMSIG_ATOM_ATTACK_HAND, PROC_REF(catch_attack_hand))

/datum/plant_feature/fruit/proc/setup_fruit(datum/source, harvest_amount, list/visual_fruits)
	SIGNAL_HANDLER

	if(!check_needs())
		return
	for(var/fruit_index in 1 to harvest_amount)
	//Build our yummy fruit :)
		growth_timers["[fruit_index]"] = addtimer(CALLBACK(src, PROC_REF(build_fruit)), growth_time, TIMER_STOPPABLE)
	//Give away an overlay as a gift
		var/obj/effect/fruit_effect = new()
		fruit_effect.appearance = feature_appearance
		fruit_effect.vis_flags = VIS_INHERIT_ID
		//Grow, visually, the fruit over time
		var/matrix/new_transform = new(fruit_effect.transform)
		fruit_effect.transform = fruit_effect.transform.Scale(0.1, 0.1)
		animate(fruit_effect, transform = new_transform, time = growth_time)

		visual_fruits += fruit_effect

/datum/plant_feature/fruit/proc/build_fruit()
	var/obj/item/food/grown/apple/A = new(parent.plant_item)
	fruits += A

/datum/plant_feature/fruit/proc/catch_attack_hand(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!length(fruits))
		return
	for(var/obj/item/fruit as anything in fruits)
		fruits -= fruit
		fruit.forceMove(get_turf(user))
	SEND_SIGNAL(parent, COMSIG_PLANT_ACTION_HARVEST, user)
