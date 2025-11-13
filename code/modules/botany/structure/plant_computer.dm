/obj/machinery/computer/plant_machine_controller
	name = "hydroponics machine terminal"
	desc = "A proprietary terminal made by Yamato to control Yamato machines."
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "pc"
	///List of linked machines
	var/list/machines = list()
	///List of assembled machine options
	var/list/machine_options = list()
	var/list/option_links = list()

/obj/machinery/computer/plant_machine_controller/LateInitialize()
	. = ..()
	locate_machines()

/obj/machinery/computer/plant_machine_controller/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	var/result = show_radial_menu(user, src, machine_options)
	if(!result)
		return
	var/obj/machinery/machine = option_links[result]
	machine.ui_interact(user)

/obj/machinery/computer/plant_machine_controller/proc/locate_machines()
	//Link machines
	//TODO: Could probably clean this up with signals - Racc
	for(var/obj/machinery/machine in range(1, src))
		if(machine_options["[machine]"])
			continue
		if(!istype(machine, /obj/machinery/plant_machine))
			continue
		var/obj/machinery/plant_machine/plant_machine = machine
		plant_machine.controller = src
		machines += machine
	assemble_menu()

/obj/machinery/computer/plant_machine_controller/proc/assemble_menu()

	for(var/obj/machinery/machine as anything in machines)
		var/image/image = new()
		image.appearance = machine.appearance
		machine_options["[machine]"] = image
		option_links["[machine]"] = machine
