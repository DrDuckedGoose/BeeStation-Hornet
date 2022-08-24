/obj/machinery/computer/teleport_control
	name = "dimensional matrix interface"
	desc = "A dimensional matrix control computer."
	///plotting formula
	var/list/formula = list()
	///list of plotted points along the given formula
	var/list/plotted_points = list()
	///limit to plotted points
	var/plot_limit = 100

/obj/machinery/computer/teleport_control/ui_interact(mob/user, datum/tgui/ui)
	//Ash walkers cannot use the console because they are unga bungas - PowerfulBacon 2021
	if(user.mind?.has_antag_datum(/datum/antagonist/ashwalker))
		to_chat(user, "<span class='warning'>This computer has been designed to keep the natives like you from meddling with it, you have no hope of using it.</span>")
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TeleportControl")
		ui.open()
	ui.set_autoupdate(FALSE)

/obj/machinery/computer/teleport_control/ui_data(mob/user)
	var/list/data = list()
	data["points"] = list()
	var/list/points = list(0, 10, 20, 30)
	for(var/i in 0 to points.len)
		data["points"] = list(list(
			"x" = points[i]
		)
		)

	return data
