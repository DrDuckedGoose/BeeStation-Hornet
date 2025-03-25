//TODO: Customize growth time and reagent volume for all fruits - Racc
/datum/plant_feature/fruit
	icon = 'icons/obj/hydroponics/features/fruit.dmi'
	icon_state = "apple"
	feature_catagories = PLANT_FEATURE_FRUIT

	///What kind of 'fruit' do we produce
	var/obj/item/fruit_product = /obj/item/food/grown/apple
	///list of fruit we have produced, yet to be harvested
	var/list/fruits = list()

	///
	var/growth_time = 1 SECONDS
	var/list/growth_timers = list()

	//TODO: Add a reagent capacity variable - Racc
	///Max amount of reagents we can impart onto our stupid fucking children
	var/total_volume = 10

	///Colour override for greyscale fruits
	var/colour_override ="#fff"

	///List of reagents this fruit has. Saves us making a unique trait for each one. (reagent = percentage)
	var/list/fast_reagents = list()

/datum/plant_feature/fruit/New(datum/component/plant/_parent)
	. = ..()
	feature_appearance.color = colour_override
	//Build our fast chemicals
	if(!length(fast_reagents))
		return
	for(var/datum/reagent/reagent as anything in fast_reagents)
		new /datum/plant_trait/reagent(src, reagent, fast_reagents[reagent])

/datum/plant_feature/fruit/get_ui_data()
	. = ..()
	. += list(PLANT_DATA("Reagent Capacity", "[total_volume] units"), PLANT_DATA("Grow Time", "[growth_time] SECONDS"), PLANT_DATA(null, null))

/datum/plant_feature/fruit/setup_parent(_parent, reset_features)
//Reset
	for(var/timer as anything in growth_timers)
		deltimer(growth_timers[timer])
	for(var/fruit as anything in fruits)
		fruits -= fruit
		qdel(fruit)
	if(parent)
		UnregisterSignal(parent, COMSIG_PLANT_REQUEST_FRUIT)
		UnregisterSignal(parent.plant_item, COMSIG_ATOM_ATTACK_HAND)
	. = ..()
//Pass over
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
	var/obj/item/A = new fruit_product(parent.plant_item)
	var/list/plant_genes = list()
	for(var/datum/plant_feature/gene as anything in parent.plant_features) //TODO: You could probably optimize this - Racc
		plant_genes += gene.copy()
	A.AddElement(/datum/element/plant_genes, plant_genes)
	fruits += A
	SEND_SIGNAL(parent, COMSIG_PLANT_FRUIT_BUILT, A)

/datum/plant_feature/fruit/proc/catch_attack_hand(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!length(fruits))
		return
	var/list/temp_fruits = list()
	for(var/obj/item/fruit as anything in fruits)
		fruits -= fruit
		temp_fruits += fruit
		fruit.forceMove(get_turf(user))
	SEND_SIGNAL(parent, COMSIG_PLANT_ACTION_HARVEST, user, temp_fruits)
