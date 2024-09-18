/*
	Like an RND server, but maintiains borg law circuits
*/

/obj/machinery/rnd/law
	name = "\improper R&D law Server"
	desc = "A modified R&D Server used to maintain cyborg law systems."
	icon_state = "law-server-on"
	///What laws we're rocking with
	var/datum/ai_laws/laws = new()
	///How many law module slots do we have
	var/max_modules = 3
	///List of modules we're using
	var/list/active_modules = list()

/obj/machinery/rnd/law/update_icon()
	if (panel_open)
		icon_state = "law-server-on_t"
		return
	if (machine_stat & EMPED || machine_stat & NOPOWER)
		icon_state = "law-server-off"
		return
	if (machine_stat & (TURNED_OFF|OVERHEATED))
		icon_state = "law-server-halt"
		return
	icon_state = "law-server-on"

/obj/machinery/rnd/law/examine(mob/user)
	. = ..()
	var/list/law_list = laws.get_law_list()
	. += "<span class='notice'>The current laws are: </span>"
	for(var/law in law_list)
		. += "<span class='notice'>[law]</span>"

/obj/machinery/rnd/law/attackby(obj/item/O, mob/user, params)
	. = ..()
	var/obj/item/law_module/module = O
	if(istype(module) && length(active_modules) < max_modules)
		laws.add_inherent_law(module.law_text)
		module.forceMove(src)
		active_modules += list("[length(active_modules)]" = module)
		SEND_SIGNAL(src, COMSIG_LAW_SERVER_UPDATE)
		return TRUE

/obj/machinery/rnd/law/attack_hand(mob/living/user)
	. = ..()
	var/list/choices = list()
	for(var/index in active_modules)
		var/obj/item/law_module/module = active_modules[index]
		var/image/display = new()
		display.appearance = module.appearance
		choices[index] = display
	var/choosen_index = show_radial_menu(user, src, choices)
	laws.remove_law(text2num(choosen_index))
	SEND_SIGNAL(src, COMSIG_LAW_SERVER_UPDATE)

/obj/machinery/rnd/law/attack_robot(mob/user)
	. = ..()
	attack_hand(user)
