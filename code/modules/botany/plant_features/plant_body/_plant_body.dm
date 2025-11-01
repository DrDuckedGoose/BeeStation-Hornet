/datum/plant_feature/body
	species_name = "testus testium"
	name = "plant body"
	icon = 'icons/obj/hydroponics/features/body.dmi'
	icon_state = "tree"
	plant_needs = list(/datum/plant_need/reagent/water)
	feature_catagories = PLANT_FEATURE_BODY
	trait_type_shortcut = /datum/plant_feature/body

	///Max, natural, harvest
	var/max_harvest = PLANT_BODY_HARVEST_LARGE

	///How many harvests does this plant have?
	var/yields = PLANT_BODY_YIELD_MICRO
	///Time between yields
	var/yield_cooldown_time = 0 SECONDS
	COOLDOWN_DECLARE(yield_cooldown)

	///Reference to the effect we use for the body overlay  / visual content
	var/atom/movable/body_appearance

	///How many planter slots does this feature take up - Typically only bodies use this, but let's try to be flexible
	var/slot_size = PLANT_BODY_SLOT_SIZE_LARGE

	///What's the upper fruit size we can hold?
	var/upper_fruit_size = PLANT_FRUIT_SIZE_LARGE

///Growth cycle
	var/growth_stages = 3
	var/current_stage
	var/growth_time = 1 SECONDS
	var/growth_time_elapsed = 0

///Visual technical
	///Fruit overlays we're responsible for
	var/list/fruit_overlays = list()
	///List of fruit overlay positions
	var/list/overlay_positions = list(list(11, 20), list(16, 30), list(23, 23), list(8, 31))
	///Do we exist over the water? Use this for stuff that should never be drawn under the tray water
	var/draw_below_water = TRUE
	///Do we use the mouse offset when planting?
	var/use_mouse_offset = FALSE

/datum/plant_feature/body/New(datum/component/plant/_parent)
//Appearance bullshit
	//Body appearance
	feature_appearance = mutable_appearance(icon, icon_state)
	body_appearance = new()
	body_appearance.appearance = feature_appearance
	body_appearance.vis_flags = VIS_INHERIT_ID
	return ..()

/datum/plant_feature/body/Destroy(force, ...)
	. = ..()
	parent?.plant_item?.vis_contents -= body_appearance

/datum/plant_feature/body/get_scan_dialogue()
	. = ..()
	. += "<b>Upper fruit size: [upper_fruit_size]</b>"

/datum/plant_feature/body/process(delta_time)
	//If we're done growing, and we're resting, and we're not hosting and fruits, and we have more fruits to give- don't bother sucking up needs
	if(growth_time_elapsed >= growth_time && !COOLDOWN_FINISHED(src, yield_cooldown_time) && !length(fruit_overlays) && yields > 0  || !check_needs(delta_time))
		//TODO: Do we want plants to wither away? It's kind of annoying - Racc
		return
//Growth
	if(growth_time_elapsed < growth_time)
		growth_time_elapsed += delta_time SECONDS
		growth_time_elapsed = min(growth_time, growth_time_elapsed)
		current_stage = max(1, FLOOR((growth_time_elapsed/growth_time)*growth_stages, 1))
		//If our parent is eager to be an adult, used for pre-existing plants
		if(parent?.skip_growth)
			growth_time_elapsed = growth_time
			current_stage = growth_stages
		//Signal for traits and other shit to hook effects into
		if(current_stage >= growth_stages)
			SEND_SIGNAL(src, COMSIG_PLANT_GROW_FINAL)
//Harvests
	if(current_stage >= growth_stages && COOLDOWN_FINISHED(src, yield_cooldown_time) && !length(fruit_overlays) && yields > 0)
		setup_fruit(parent?.skip_growth)
		parent?.skip_growth = FALSE //We can happily set this to false here in any case without issues

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
		UnregisterSignal(parent, COMSIG_PLANT_POLL_TRAY_SIZE)
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
	RegisterSignal(parent, COMSIG_PLANT_POLL_TRAY_SIZE, PROC_REF(catch_occupation))
	//Appearance
	if(parent.use_body_appearance && parent.plant_item)
		parent.plant_item.vis_contents += body_appearance
	//Draw settings
	parent.draw_below_water = draw_below_water
	parent.plant_item.layer = draw_below_water ? OBJ_LAYER : ABOVE_OBJ_LAYER
	parent.use_mouse_offset = use_mouse_offset
	//Start growin'
	START_PROCESSING(SSobj, src)

/datum/plant_feature/body/associate_seeds(obj/item/plant_seeds/seeds)
	. = ..()
	RegisterSignal(seeds, COMSIG_SEEDS_POLL_TRAY_SIZE, PROC_REF(catch_occupation))

/datum/plant_feature/body/unassociate_seeds(obj/item/plant_seeds/seeds)
	. = ..()
	UnregisterSignal(seeds, COMSIG_SEEDS_POLL_TRAY_SIZE)

/datum/plant_feature/body/catch_planted(datum/source, atom/destination)
	. = ..()
	var/datum/component/planter/tray_component = destination.GetComponent(/datum/component/planter)
	if(!tray_component)
		return
	tray_component.plant_slots -= slot_size

/datum/plant_feature/body/catch_uprooted(datum/source, mob/user, obj/item/tool, atom/old_loc)
	. = ..()
	var/datum/component/planter/tray_component = old_loc.GetComponent(/datum/component/planter)
	if(!tray_component)
		return
	tray_component.plant_slots += slot_size

/datum/plant_feature/body/proc/get_harvest()
	if(current_stage < growth_stages)
		return
	//Use a signal so we can allow traits and other outsiders modify our harvest
	return SEND_SIGNAL(src, COMSIG_PLANT_GET_HARVEST, max_harvest) || max_harvest

/datum/plant_feature/body/proc/setup_fruit(skip_growth)
	var/list/visual_fruits = list()
	SEND_SIGNAL(parent, COMSIG_PLANT_REQUEST_FRUIT, get_harvest(), visual_fruits, skip_growth)
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

/datum/plant_feature/body/proc/catch_harvest(datum/source, mob/user, list/temp_fruits, dummy_harvest = FALSE)
	SIGNAL_HANDLER

	yields -= !dummy_harvest
	if(yields <= 0) //If we run out of harvests, it's game over and we delete our entire existance
		qdel(parent.plant_item)
		return
	COOLDOWN_START(src, yield_cooldown, yield_cooldown_time)
	//Remove our fruit overlays
	for(var/fruit_effect as anything in fruit_overlays)
		fruit_overlays -= fruit_effect
		parent.plant_item.vis_contents -= fruit_effect

///Essentially just checks if there's room for us. Also lets some plants have special occupation rules - Please consider substrate stuff for special planting rules before you use this.
/datum/plant_feature/body/proc/catch_occupation(datum/source, atom/location)
	SIGNAL_HANDLER

	var/datum/component/planter/tray_component = location.GetComponent(/datum/component/planter)
	if(!tray_component)
		return
	if(tray_component.plant_slots - slot_size < 0)
		return
	return TRUE
