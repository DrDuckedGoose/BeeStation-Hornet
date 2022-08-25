/obj/machinery/computer/teleporter_control
	name = "dimensional matrix interface"
	desc = "A dimensional matrix control computer."
	///plotting formula
	var/list/formula = list()
	///list of plotted points along the given formula
	var/list/plotted_points = list(list("x" = 0, "y" = 0))
	///limit to plotted points
	var/plot_limit = 100

/obj/machinery/computer/teleporter_control/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	for(var/i in 1 to plot_limit)
		var/x = i
		var/y = round(sin(x)*700)
		plotted_points += list(list("x" = x, "y" = y))

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

	data["points"] = list()
	if(plotted_points.len)
		for(var/i in 1 to plotted_points.len)
			data["points"] += list(list(
				"x" = plotted_points[i]["x"],
				"y" = plotted_points[i]["y"],
			)
			)

	return data

/obj/machinery/computer/teleporter_control/ui_act(action, params)
	. = ..()
	switch(action)
		if("add-point")
			plotted_points += list(list("x" = 0, "y" = 0))
			say(params["coordinate"])
