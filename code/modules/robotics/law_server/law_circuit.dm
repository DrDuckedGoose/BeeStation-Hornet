/obj/item/law_circuit
	name = "law circuit"
	desc = "An outdated, disk operated, law relay used in cyborg construction."
	icon = 'icons/obj/robotics/endo.dmi'
	icon_state = "law_circuit"
	///What laws we're rocking with
	var/datum/ai_laws/laws
	///Who we're respknsible for keeping under control
	var/mob/living/silicon/new_robot/robot_parent
	///Who we take orders from
	var/obj/machinery/rnd/law/law_server

/obj/item/law_circuit/examine(mob/user)
	. = ..()
	if(law_server)
		. += "<span class='notice'>[src] is linked to [law_server].</span>"
	else
		. += "<span class='warning'>[src] is unlinked!</span>"

/obj/item/law_circuit/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(law_server)
		return TRUE
	if(istype(target, /obj/machinery/rnd/law))
		register_parent(target)
		to_chat(user, "<span class='notice'>You link [src] to [target].</span>")
		return TRUE

/obj/item/law_circuit/interact(mob/user)
	. = ..()
	if(law_server)
		to_chat(user, "<span class='warning'>You unlink [src] from [law_server]!</span>")
		law_server = null
		laws = null

/obj/item/law_circuit/proc/register_parent(obj/machinery/rnd/server/server)
	law_server = server
	RegisterSignal(law_server, COMSIG_LAW_SERVER_UPDATE, PROC_REF(update_laws))
	laws = law_server.laws

/obj/item/law_circuit/proc/update_laws(datum/source)
	laws = law_server.laws
	if(robot_parent)
		laws.show_laws(robot_parent)

///Used to pair a cyborg with this circuit
/obj/item/law_circuit/proc/parent_robot(mob/living/silicon/new_robot/R)
	if(R.laws?.owner)
		R.laws.owner = null
		QDEL_NULL(R.laws)
	robot_parent = R
	if(!laws)
		laws = new()
		laws.add_inherent_law("get freaky >:)")
	R.laws = laws
	laws.associate(R)
	RegisterSignal(R, COMSIG_PARENT_EXAMINE, PROC_REF(catch_examine), TRUE)

/obj/item/law_circuit/proc/catch_examine(datum/source, mob/M, strings)
	SIGNAL_HANDLER

	if(!robot_parent?.cover_open)
		return
	if(law_server)
		strings += "<span class='notice'>[src] is linked to [law_server].</span>"
	else
		strings += "<span class='warning'>[src] is unlinked!</span>"
