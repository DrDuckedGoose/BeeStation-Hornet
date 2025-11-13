/obj/machinery/plant_machine/plant_mutator
	name = "plant mutator"
	desc = "An advanced device designed to gawk gawk."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "dnamod"
	density = TRUE
	pass_flags = PASSTABLE
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND

	///Last 'command' for UI stuff
	var/last_command = ""

	///Catalyst item we use for source of rads
	var/obj/item/catalyst
	///Shortcut to catalyst's radiation component
	var/datum/component/radioactive/radiation

	///The plant we're michael-waving
	var/obj/item/plant
	///Shortcut to component
	var/datum/component/plant/plant_component
	///Currently selected feature
	var/datum/plant_feature/current_feature
	var/current_feature_ref

	///UI confirmation switch so we don't have accidents
	var/confirm_radiation = FALSE
	///Are we under going the process of mutating?
	var/working = FALSE
	var/working_time = 5 SECONDS

//Insert
/obj/machinery/plant_machine/plant_mutator/attackby(obj/item/C, mob/user)
	. = ..()
	if(working)
		return
//Catalyst
	radiation = radiation || C.GetComponent(/datum/component/radioactive)
	if(radiation && !catalyst)
		C.forceMove(src)
		catalyst = C
		ui_update()
		return TRUE
//Spade / Plant
	if(!istype(C, /obj/item/shovel/spade))
		return
	//Return plant to spade, to remove it
	if(plant && plant_component.async_catch_attackby(C, user))
		plant = null
		plant_component = null
		current_feature = null
		current_feature_ref = null
		ui_update()
		return TRUE
	//Insert plant from spade
	var/datum/component/plant/comp
	var/obj/item/plant_item
	for(var/obj/item/potential_plant in C.contents)
		comp = potential_plant.GetComponent(/datum/component/plant)
		plant_item = potential_plant
		if(!C)
			continue
		break
	if(!comp)
		return
	C.vis_contents -= plant_item
	plant_item.forceMove(src)
	plant = plant_item
	plant_component = comp
	ui_update()
	return TRUE

//Remove
/obj/machinery/plant_machine/plant_mutator/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(working)
		return
	if(!catalyst)
		return
	catalyst.forceMove(get_turf(src))
	user.put_in_active_hand(catalyst)
	catalyst = null
	radiation = null

/obj/machinery/plant_machine/plant_mutator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlantMutator")
		ui.open()

/obj/machinery/plant_machine/plant_mutator/ui_data(mob/user)
	var/list/data = list()
	//last command, cosmetic
	data["last_command"] = last_command
	//generic stats
	data["plant_feature_data"] = list()
	if(plant_component)
		for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
			data["plant_feature_data"] += list(feature.get_ui_stats())
	//current feature
	data["current_feature"] = current_feature_ref
	data["current_feature_data"] = current_feature?.get_ui_data()
	data["current_feature_traits"] = current_feature?.get_ui_traits()
	//Current inserted plant's name
	data["inserted_plant"] = capitalize(plant?.name)
	//Catalyst info
	data["catalyst"] = capitalize(catalyst?.name)
	data["catalyst_desc"] = catalyst?.desc
	data["catalyst_strength"] = radiation?.strength
	//Machine info
	data["confirm_radiation"] = confirm_radiation
	data["working"] = working
	return data

/obj/machinery/plant_machine/plant_mutator/ui_act(action, params)
	if(..())
		return
	playsound(src, get_sfx("keyboard"), 30, TRUE)
	switch(action)
		if("select_feature")
			current_feature_ref = current_feature_ref == params["key"] ? null : params["key"]
			current_feature = locate(current_feature_ref)
			last_command = "pit feature select -m [params["key"]]"
			ui_update()
		if("cancel")
			confirm_radiation = FALSE
			ui_update()
		if("mutate")
			//Fix focus
			if(current_feature_ref != params["key"])
				current_feature_ref = params["key"]
				current_feature = locate(current_feature_ref)
				ui_update()
			//Confirmation
			if(!confirm_radiation)
				confirm_radiation = TRUE
				ui_update()
				return
			//Nuke the SOB
			last_command = "per kiln heat -f -k -m [params["key"]]"
			confirm_radiation = FALSE
			ui_update()
			if(!catalyst)
				playsound(src, 'sound/machines/terminal_error.ogg', 60)
				say("ERROR: No catalyst inserted!")
				return
			if(!radiation?.strength > 0) //TODO: Revise how this works, how much rads we need, and how we spend it - Racc
				playsound(src, 'sound/machines/terminal_error.ogg', 60)
				say("ERROR: Catalyst lacks adequate radioactivity!")
				return
			var/datum/plant_feature/feature = locate(current_feature_ref)
			if(!length(feature.mutations))
				playsound(src, 'sound/machines/terminal_error.ogg', 60)
				say("ERROR: Feature lacks genetic avenues!")
				return
			//Tax radiation before checks becuase fuck you >:)
			//TODO: rework this cost system - Racc
			radiation.strength -= 1
			//Check compatibility
			var/datum/plant_feature/new_feature = pick(feature.mutations)
			new_feature = new new_feature(plant_component)
			for(var/datum/plant_feature/current_feature as anything in plant_component.plant_features)
				//Is this feature blacklisted from another feature
				if(is_type_in_typecache(new_feature, current_feature.blacklist_features))
					playsound(src, 'sound/machines/terminal_error.ogg', 60)
					say("ERROR: Seed composition not compatible with selected feature!")
					qdel(new_feature)
					return
				//If a feature has a whitelist, are we in it?
				if(length(current_feature.whitelist_features) && !is_type_in_typecache(new_feature, current_feature.whitelist_features))
					playsound(src, 'sound/machines/terminal_error.ogg', 60)
					say("ERROR: Seed composition not compatible with selected feature!")
					qdel(new_feature)
					return
			//Rip out old feature
			plant_component.plant_features -= feature
			qdel(feature)
			//Throw new bad boy in
			if(!QDELING(new_feature))
				plant_component.plant_features += new_feature
			//Reset species id so a new one can be made
			plant_component.compile_species_id()
			//TODO: Make the plant's fruit drop off or be destroyed - Racc
			//TODO: transfer traits between features, if you can - Racc
			//Reset the plant's growth
			for(var/datum/plant_feature/body/body_feature in plant_component.plant_features)
				body_feature.growth_time_elapsed = 0
				body_feature.current_stage = 0
			working = TRUE
			addtimer(CALLBACK(src, PROC_REF(reset_working)), working_time)
			ui_update()

/obj/machinery/plant_machine/plant_mutator/proc/reset_working()
	working = FALSE
	ui_update()
