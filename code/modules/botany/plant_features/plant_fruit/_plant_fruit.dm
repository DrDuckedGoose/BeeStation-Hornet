//TODO: Customize growth time and reagent volume for all fruits - Racc
//TODO: port flowers, weeds, and mushrooms - Racc
//TODO: Replace meatweat with several rare-ish meat fruits based on types of meat - Racc
/datum/plant_feature/fruit
	icon = 'icons/obj/hydroponics/features/fruit.dmi'
	icon_state = "apple"
	feature_catagories = PLANT_FEATURE_FRUIT

	///What kind of 'fruit' do we produce
	var/obj/item/fruit_product = /obj/item/food/grown/apple
	///list of fruit we have produced, yet to be harvested
	var/list/fruits = list()
	var/list/visual_fruits = list()

	///
	var/growth_time = PLANT_FRUIT_GROWTH_FAST
	var/growth_time_elapsed = 0
	var/list/growth_timers = list()

	//TODO: Add a reagent capacity variable - Racc
	///Max amount of reagents we can impart onto our stupid fucking children
	var/total_volume = PLANT_FRUIT_VOLUME_SMALL

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

/datum/plant_feature/fruit/Destroy(force, ...)
	. = ..()
	if(!catch_attack_hand(src, null))
		SEND_SIGNAL(parent, COMSIG_PLANT_ACTION_HARVEST, src, null, TRUE)

/datum/plant_feature/fruit/process(delta_time)
	if(!check_needs() || !length(growth_timers))
		return
//Growing
	for(var/timer as anything in growth_timers)
		growth_timers[timer] -= delta_time SECONDS
		//Visuals
		var/obj/effect/fruit_effect = visual_fruits[timer]
		var/matrix/new_transform = new()
		var/progress = min(1, max(0.1, abs(growth_timers[timer]-growth_time) / growth_time))
		new_transform.Scale(progress, progress)
		animate(fruit_effect, transform = new_transform, time = delta_time SECONDS)
		//Offload finished fruits
		if(growth_timers[timer] <= 0)
			growth_timers -= timer
			visual_fruits -= timer
			build_fruit()

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
	START_PROCESSING(SSobj, src)

/datum/plant_feature/fruit/proc/setup_fruit(datum/source, harvest_amount, list/_visual_fruits)
	SIGNAL_HANDLER

	if(!check_needs())
		return
	for(var/fruit_index in 1 to harvest_amount)
	//Build our yummy fruit :)
		growth_timers["[fruit_index]"] = growth_time
	//Give away an overlay as a gift
		var/obj/effect/fruit_effect = new()
		fruit_effect.appearance = feature_appearance
		fruit_effect.vis_flags = VIS_INHERIT_ID
		_visual_fruits += fruit_effect
		visual_fruits["[fruit_index]"] = fruit_effect
		//Shrink fruit, we'll grow it later
		fruit_effect.transform = fruit_effect.transform.Scale(0.1, 0.1)

/datum/plant_feature/fruit/proc/build_fruit()
	var/obj/item/A = new fruit_product(parent.plant_item)
	var/list/plant_genes = list()
	for(var/datum/plant_feature/gene as anything in parent.plant_features) //TODO: You could probably optimize this - Racc
		if(QDELETED(gene))
			continue
		plant_genes += gene.copy()
	A.AddElement(/datum/element/plant_genes, plant_genes, parent.species_id)
	fruits += A
	SEND_SIGNAL(parent, COMSIG_PLANT_FRUIT_BUILT, A)

/datum/plant_feature/fruit/proc/catch_attack_hand(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!length(fruits))
		return
	var/list/temp_fruits = list()
	var/turf/T = user ? get_turf(user) : get_turf(parent.plant_item)
	for(var/obj/item/fruit as anything in fruits)
		fruits -= fruit
		temp_fruits += fruit
		fruit.forceMove(T)
	SEND_SIGNAL(parent, COMSIG_PLANT_ACTION_HARVEST, user, temp_fruits, FALSE)
	return TRUE
