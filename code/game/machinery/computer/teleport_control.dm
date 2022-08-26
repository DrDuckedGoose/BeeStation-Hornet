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
		var/y = round(cos(arcsin(x)))
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

#define PARSE_LONG_OPS list("sin", "cos", "tan")

//Converts a formula string to its appropriate numerical form. Based on RPN
/obj/machinery/computer/teleporter_control/proc/parse(string)
	//Stack of operators present in the formula
	var/list/operators = list()
	//Stack of numbers present in the formula
	var/list/output = list()
	//Temporary string to compile larger numbers
	var/long = ""
	//Temporary string to compile larger operators
	var/long_op = ""

	//Load formula into stack
	for(var/i in 1 to length(string))
		if(!istext(string) || !length(string))
			return
		//Any number present is assumed to be apart of a bigger one, seperated by operators
		if(isnum(text2num(string[i])))
			long = "[long][string[i]]"
		else
			//Operator present, number no longer being defined, convert & add to stack
			if(isnum(text2num(long)))
				output.Insert(1, text2num(long))
				long = ""
			//Add insurance for scenarios like "-2"
			if(output.len < 2)
				output += 0
			//Append operator
			for(var/x in 1 to operators.len)
				if(string[i] == "+" || string[i] == "-")
					if(operators[x] != "*" || operators[x] != "/" || operators[x] != "^")
						say("[output[1]] ([string[i]] || [operators[x]]) [output[2]]")
						if((operators[x] == "+" || operators[x] == "-") && output.len >= 2)
							output[1] = (operators[x] == "+" ? output[1]+output[2] : output[1]-output[2])
							output -= output[2]
							operators -= operators[x]
						operators.Insert(x, string[i])
						break
				else if(string[i] == "*" || string[i] == "/")
					if(operators[x] != "^")
						say("[output[1]] ([string[i]] || [operators[x]]) [output[2]]")
						if((operators[x] == "*" || operators[x] == "/") && output.len >= 2)
							output[1] = (operators[x] == "*" ? output[1]*output[2] : output[1]/output[2])
							output -= output[2]
							operators -= operators[x]
						operators.Insert(x, string[i])
						break
				else if(string[i] == "^")
					say("[output[1]] ([string[i]] || [operators[x]]) [output[2]]")
					if(operators[x] == "^" && output.len >= 2)
						output[1] = output[2]**output[1]
						output -= output[2]
						operators -= operators[x]
					operators.Insert(x, string[i])
					break
				else if(string[i] == "(" || string[i] == ")")
					if(output.len >= 2)
						say("[output[1]] ([string[i]] || [operators[x]]) [output[2]]")
					if(string[i] == ")")
						for(var/y in x to 1)
							if(operators[y] == "(")
								break
							if(output.len >= 2)
								say("Operation: [operators[y]] 1: [output[1]] 2: [output[2]]")
								switch(operators[y])
									if("+")
										output[1] += output[2]
									if("-")
										output[1] = output[2]-output[1]
									if("*")
										output[1] *= output[2]
									if("/")
										output[1] /= output[2]
									if("^")
										output[1] = output[2]**output[1]
									if("sin")
										output[1] = sin(output[1])
									if("cos")
										output[1] = cos(output[1])
									if("tan")
										output[1] = tan(output[1])
								if(operators[y] != "(" && operators[y] != ")")
									output -= output[2]
								operators -= operators[y]
					operators.Insert(x, string[i])
					break
				//handle long ops
				else
					long_op += string[i]
					switch(long_op)
						if("sin")
							if(operators[x] == "sin" && output.len >= 1)
								output[1] = sin(output[1])
								operators -= operators[x]
							operators.Insert(x, long_op)
							long_op = ""
							break
						if("cos")
							if(operators[x] == "sin" && output.len >= 1)
								output[1] = cos(output[1])
								operators -= operators[x]
							operators.Insert(x, long_op)
							long_op = ""
							break
						if("tan")
							if(operators[x] == "sin" && output.len >= 1)
								output[1] = tan(output[1])
								operators -= operators[x]
							operators.Insert(x, long_op)
							long_op = ""
							break
					
			if(!operators.len)
				operators.Insert(1, string[i])
	//grab any loose ends
	if(isnum(text2num(long)))
		output.Insert(1, text2num(long))

	for(var/i in output)
		say("Output:")
		say(i)

	for(var/i in operators)
		say("Operators:")
		say(i)
	
	say("Stack loaded")
	//Evaluate stack
	for(var/i in 1 to operators.len)
		if(output.len >= 2)
			say("Operation: [operators[i]] 1: [output[1]] 2: [output[2]]")
			switch(operators[i])
				if("+")
					output[1] += output[2]
				if("-")
					output[1] -= output[2]
				if("*")
					output[1] *= output[2]
				if("/")
					output[1] /= output[2]
				if("^")
					output[1] = output[2]**output[1]
				if("sin")
					output[1] = sin(output[1])
				if("cos")
					output[1] = cos(output[1])
				if("tan")
					output[1] = tan(output[1])
			if(operators[i] != "(" && operators[i] != ")")
				output -= output[2]

	return output[1]
