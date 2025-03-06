/datum/plant_feature/body
	icon = 'icons/obj/hydroponics/features/body.dmi'
	icon_state = "tree"
	plant_needs = list(/datum/plant_need/reagent/water)

	///Max, natural, harvest
	var/max_harvest = 10

	///How many harvests does this plant have?
	var/yields = 1

	///Reference to the effect we use for the body overlay  / visual content
	var/atom/movable/body_appearance

///Growth cycle
	var/growth_stages = 3
	var/current_stage = 1
	var/growth_time = 1 SECONDS
	var/growth_timer

	///Fruit overlays we're responsible for
	var/list/fruit_overlays = list()
	///List of fruit overlay positions
	var/list/overlay_positions = list(list(11, 20), list(16, 30), list(23, 23), list(8, 31))

/datum/plant_feature/body/New(datum/component/plant/_parent)
	. = ..()
	if(!parent)
		return
	RegisterSignal(parent, COMSIG_PLANT_ACTION_HARVEST, PROC_REF(catch_harvest))
	//Appearance
	body_appearance = new()
	body_appearance.vis_flags = VIS_INHERIT_ID
	body_appearance.appearance = feature_appearance
	if(parent.use_body_appearance && parent.plant_item)
		parent.plant_item.vis_contents += body_appearance
	//Start growin'
	bump_growth()

/datum/plant_feature/body/Destroy(force, ...)
	. = ..()
	parent?.plant_item?.vis_contents -= body_appearance

/datum/plant_feature/body/proc/bump_growth()
//Technical
	if(current_stage >= growth_stages)
		//Harvest setup, now we're grown
		SEND_SIGNAL(src, COMSIG_PLANT_GROW_FINAL)
		setup_fruit()
		return
	growth_timer = addtimer(CALLBACK(src, PROC_REF(bump_growth)), growth_time, TIMER_STOPPABLE)
	if(check_needs())
		current_stage++

/datum/plant_feature/body/proc/get_harvest()
	if(current_stage < growth_stages)
		return
	return SEND_SIGNAL(src, COMSIG_PLANT_GET_HARVEST, max_harvest) || max_harvest

/datum/plant_feature/body/proc/setup_fruit()
	var/list/visual_fruits = list()
	SEND_SIGNAL(parent, COMSIG_PLANT_REQUEST_FRUIT, get_harvest(), visual_fruits)
	var/list/available_positions = overlay_positions.Copy()
	for(var/obj/effect/fruit_effect as anything in visual_fruits)
		if(!length(fruit_effect))
			available_positions = overlay_positions.Copy()
		var/list/position = pick(available_positions)
		available_positions -= position
		apply_fruit_overlay(fruit_effect, position[1], position[2])

///Position and manipulate fruit overlays
/datum/plant_feature/body/proc/apply_fruit_overlay(obj/effect/fruit_effect, offset_x, offset_y)
	fruit_effect.pixel_x = offset_x-16
	fruit_effect.pixel_y = offset_y-16
	parent.plant_item.vis_contents += fruit_effect
	fruit_overlays += fruit_effect
	return

/datum/plant_feature/body/proc/catch_harvest(datum/source)
	SIGNAL_HANDLER

	//Remove our fruit overlays
	for(var/fruit_effect as anything in fruit_overlays)
		fruit_overlays -= fruit_effect
		parent.plant_item.vis_contents -= fruit_effect
	//Try make another crop
	yields--
	if(yields > 0)
		setup_fruit()
