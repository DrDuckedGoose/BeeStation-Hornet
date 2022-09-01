/obj/machinery/computer/teleporter_control
	name = "dimensional matrix interface"
	desc = "A dimensional matrix control computer."
	///list of plotted points along the given formula
	var/list/plotted_points = list(list("x" = 0, "y" = 0))
	var/list/rounded_plotted_points = list(list("x" = 0, "y" = 0))
	///limit on plotted points, currently
	var/plot_limit = 100
	///Connected matrix, AKA I hope to god he remebers to not let this hard delete
	var/obj/machinery/teleporter_base/connected_base
	///Wether to invert the directional component
	var/invert = 1
	///Stability for plots
	var/max_stability = 100
	var/stability = 100
	///Notes wether the activation will yield an issue
	var/door_fail = FALSE

	var/list/test = list()

/obj/machinery/computer/teleporter_control/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	sync_machines()
	test = SStelescience.blocked_coords
	SStelescience.blocked_coords += list(list("x" = x+10, "y" = y+10))

/obj/machinery/computer/teleporter_control/ui_interact(mob/user, datum/tgui/ui)
	//Ash walkers cannot use the console because they are unga bungas - PowerfulBacon 2021
	if(user.mind?.has_antag_datum(/datum/antagonist/ashwalker))
		to_chat(user, "<span class='warning'>This computer has been designed to keep the natives like you from meddling with it, you have no hope of using it.</span>")
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TeleportControl")
		ui.open()
	ui.set_autoupdate(FALSE)

/obj/machinery/computer/teleporter_control/ui_data(mob/user)
	var/list/data = list()

	data["point_limit"] = plot_limit
	//Float points
	data["points"] = list()
	if(plotted_points.len)
		for(var/i in 1 to plotted_points.len)
			data["points"] += list(list(
				"x" = plotted_points[i]["x"],
				"y" = plotted_points[i]["y"],
			)
			)
	//Rounded points
	data["rounded_points"] = list()
	if(rounded_plotted_points.len)
		for(var/i in 1 to rounded_plotted_points.len)
			data["rounded_points"] += list(list(
				"x" = rounded_plotted_points[i]["x"],
				"y" = rounded_plotted_points[i]["y"],
			)
			)
	//Blocked points, as per SStelescience
	data["blocked_points"] = list()
	if(SStelescience.blocked_coords.len)
		for(var/i in 1 to SStelescience.blocked_coords.len)
			data["blocked_points"] += list(list(
				"x" = SStelescience.blocked_coords[i]["x"]-x,
				"y" = SStelescience.blocked_coords[i]["y"]-y,
			)
			)
	//Inverted status
	data["inverted"] = (invert < 0)
	//Open status
	data["active"] = (connected_base?.door_here ? 1: 0)
	//stability
	data["stability"] = stability/max_stability

	return data

/obj/machinery/computer/teleporter_control/ui_act(action, params)
	. = ..()
	switch(action)
		if("compile_formula")
			//Load in points from UI. Yes, the UI evaluates the formula...
			var/list/points = params["points"]
			compile_ponts(points)
		if("input_limit")
			plot_limit = min(MAX_PLOTS, params["limit"])
		if("invert")
			invert = (invert > 0 ? -1 : 1)
		if("activate")
			//If we're accessing bad space
			if(door_fail && connected_base)
				SStelescience.do_collapse(connected_base, DOOR_EFFECTS)
				return
			//Set updated positions
			connected_base?.target_x = connected_base?.x+rounded_plotted_points[rounded_plotted_points.len]["x"]
			connected_base?.target_y = connected_base?.y+rounded_plotted_points[rounded_plotted_points.len]["y"]
			//Send it!
			connected_base?.activate()
		if("close")
			//Send it the other way!
			connected_base?.close()
		if("swap_door_mode")
			connected_base?.door_mode = !connected_base?.door_mode
		if("swap_transit_mode")
			connected_base?.mode = !connected_base?.mode
	ui_update()

///Compiles a given list of points into local list, compliant with limit
/obj/machinery/computer/teleporter_control/proc/compile_ponts(list/points)
	//Reset current
	plotted_points = list(list("x" = 0, "y" = 0))
	rounded_plotted_points = list(list("x" = 0, "y" = 0))
	stability = max_stability
	door_fail = FALSE
	//Do plots
	for(var/i in 2 to min(plot_limit, points.len))
		plotted_points += list(list("x" = (i-1)*invert, "y" = points[i]*invert))
		rounded_plotted_points += list(list("x" = (i-1)*invert, "y" = round(points[i]*invert, 1)))
		if(get_turf(locate(rounded_plotted_points[i]["x"]+x, rounded_plotted_points[i]["y"]+y, z)) in SStelescience.blocked)
			door_fail = TRUE
		var/dist = get_dist(get_turf(locate(rounded_plotted_points[i]["x"]+x, rounded_plotted_points[i]["y"]+y, z)), get_turf(locate(rounded_plotted_points[i-1]["x"]+x, rounded_plotted_points[i-1]["y"]+y, z)))
		stability -= 10*max(0, dist-1)
	stability = max(0, stability)

///Sync all nearby relevant machinery
/obj/machinery/computer/teleporter_control/proc/sync_machines()
	connected_base = (locate(/obj/machinery/teleporter_base) in orange(SYNC_RANGE, get_turf(src)))
	if(connected_base)
		RegisterSignal(connected_base, COMSIG_PARENT_QDELETING, .proc/handle_del)
	return connected_base

/obj/machinery/computer/teleporter_control/proc/handle_del(atom/A)
	connected_base = null

/obj/machinery/computer/teleporter_control/proc/random_block()
	SStelescience.shuffle_blockers()
