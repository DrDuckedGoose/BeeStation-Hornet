/datum/plant_feature/body
	icon = 'icons/obj/hydroponics/features/body.dmi'
	icon_state = "tree"
	//plant_needs = list(/datum/plant_need/reagent/water)
	feature_catagories = PLANT_FEATURE_BODY

	//TODO: Consider swapping harvest and yield terms - Racc
	///Max, natural, harvest
	var/max_harvest = 10

	///How many harvests does this plant have?
	var/yields = 1
	///Time between yields
	var/yield_cooldown_time = 0 SECONDS
	COOLDOWN_DECLARE(yield_cooldown)

	///Reference to the effect we use for the body overlay  / visual content
	var/atom/movable/body_appearance

///Growth cycle
	var/growth_stages = 3
	var/current_stage
	var/growth_time = 1 SECONDS
	var/growth_time_elapsed = 0

	///Fruit overlays we're responsible for
	var/list/fruit_overlays = list()
	///List of fruit overlay positions
	var/list/overlay_positions = list(list(11, 20), list(16, 30), list(23, 23), list(8, 31))

/datum/plant_feature/body/New(datum/component/plant/_parent)
//Appearance bullshit
	feature_appearance = mutable_appearance(icon, icon_state)
	body_appearance = new()
	body_appearance.appearance = feature_appearance
	body_appearance.vis_flags = VIS_INHERIT_ID
	return ..()

/datum/plant_feature/body/Destroy(force, ...)
	. = ..()
	parent?.plant_item?.vis_contents -= body_appearance

/datum/plant_feature/body/process(delta_time)
	if(!check_needs())
		//TODO: Do we want plants to wither away? It's kind of annoying - Racc
		return
//Growth
	if(growth_time_elapsed < growth_time)
		growth_time_elapsed += delta_time SECONDS
		growth_time_elapsed = min(growth_time, growth_time_elapsed)
		current_stage = max(1, FLOOR((growth_time_elapsed/growth_time)*growth_stages, 1))
		//Little bit of nesting, as a treat
		if(current_stage >= growth_stages)
			SEND_SIGNAL(src, COMSIG_PLANT_GROW_FINAL)
//Harvests
	if(current_stage >= growth_stages && COOLDOWN_FINISHED(src, yield_cooldown_time) && !length(fruit_overlays) && yields > 0)
		setup_fruit()

/datum/plant_feature/body/get_ui_data()
	. = ..()
	. += list(PLANT_DATA("Harvest", max_harvest), PLANT_DATA("Yields", yields), PLANT_DATA("Growth Time", "[growth_time] SECONDS"), PLANT_DATA(null, null))

/datum/plant_feature/body/setup_parent(_parent, reset_features = TRUE)
//Undo any sins
	//Fruit overlay clean up
	for(var/overlay as anything in fruit_overlays)
		parent?.plant_item?.vis_contents -= overlay
		fruit_overlays -= overlay
		qdel(overlay)
	//Remove any old signals or misc overlays
	if(parent)
		UnregisterSignal(parent, COMSIG_PLANT_ACTION_HARVEST)
		parent.plant_item.vis_contents -= body_appearance
	//Reset our growth, yield, etc.
	if(reset_features)
		current_stage = initial(current_stage)
		yields = initial(yields)
	growth_time_elapsed = 0 //just in-case idk
//Start a new life
	. = ..()
	if(!parent)
		return
	RegisterSignal(parent, COMSIG_PLANT_ACTION_HARVEST, PROC_REF(catch_harvest))
	//Appearance
	if(parent.use_body_appearance && parent.plant_item)
		parent.plant_item.vis_contents += body_appearance
	//Start growin'
	START_PROCESSING(SSobj, src)

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

	yields--
	COOLDOWN_START(src, yield_cooldown, yield_cooldown_time)
	//Remove our fruit overlays
	for(var/fruit_effect as anything in fruit_overlays)
		fruit_overlays -= fruit_effect
		parent.plant_item.vis_contents -= fruit_effect
