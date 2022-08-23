///Teleport type go to
#define TELE_MODE_PUSH "tele_mode_push"
///Teleport type get from
#define TELE_MODE_PULL "tele_mode_pull"

///Teleport type stay open
#define TELE_MODE_OPEN "tele_mode_open"
///Teleport type quickly open & close
#define TELE_MODE_QUICK "tele_mode_quick"

/obj/machinery/teleporter_base
	name = "dimensional matrix"
	desc = "A neutral point in space. Utilized to wrap 3D spaces around one another."
	icon = 'icons/obj/machines/telescience.dmi'
	icon_state = "base"
	pass_flags_self = NONE
	///target position for transform
	var/target_x
	var/target_y
	var/target_z
	///mode type, pull / push
	var/mode = TELE_MODE_PUSH
	///door mode, stay open or briefy open
	var/door_mode = TELE_MODE_OPEN
	///rate of telescience SS weight increase
	var/emmission = 10
	///doors for TELE_MODE_QUICK / OPEN
	var/obj/structure/teleporter_door/door_here
	var/obj/structure/teleporter_door/door_there

/obj/machinery/teleporter_base/Initialize(mapload)
	. = ..()
	target_x = x
	target_y = y
	target_z = z

/obj/machinery/teleporter_base/AltClick(mob/user)
	. = ..()
	activate()

//General proc used to teleport
/obj/machinery/teleporter_base/proc/activate()
	//Adjust telescience weight
	SStelescience.weight += emmission

	//Delete any old doors
	if(door_here)
		qdel(door_here)
	if(door_there)
		qdel(door_here)
	//Handle new doors
	if(door_mode == TELE_MODE_OPEN)
		door_here = new(get_turf(src))
		door_there = new(locate(target_x, target_y, target_z))
		RegisterSignal(door_here, COMSIG_ATOM_ENTERED, .proc/push)
		RegisterSignal(door_there, COMSIG_ATOM_ENTERED, .proc/pull)
		return

	//get all viable targets
	var/list/targets = list()
	for(var/atom/movable/M in (mode == TELE_MODE_PUSH ? get_turf(src) : locate(target_x, target_y, target_z)))
		if(!M.anchored && M != src)
			targets += M
	if(!targets.len)
		say("No valid targets") //todo: move this to computer
		return
	//get destination
	var/turf/destination = (mode == TELE_MODE_PUSH ? locate(target_x, target_y, target_z) : get_turf(src))
	if(!destination)
		say("Invalid destination") //todo: move this to computer
		return
	//Move targets
	//todo: each moved target drains powernet
	for(var/atom/movable/M as() in targets)
		do_teleport(M, destination, 0)

//Used for door stuff
/obj/machinery/teleporter_base/proc/push(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	teleport_unique(TELE_MODE_PUSH, AM)

/obj/machinery/teleporter_base/proc/pull(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	teleport_unique(TELE_MODE_PULL, AM)

/obj/machinery/teleporter_base/proc/teleport_unique(mode, atom/movable/AM)
	var/turf/T = (mode == TELE_MODE_PUSH ? locate(target_x, target_y, target_z) : get_turf(src))
	if(T && AM)
		do_teleport(AM, T, 0)

/obj/structure/teleporter_door
	name = "dimensional fold"
	desc = "Folded space curved around a central axis, dsitributed between two points."
	icon = 'icons/obj/machines/telescience.dmi'
	icon_state = "door_mask"

/obj/structure/teleporter_door/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/teleporter_door/proc/on_entered(datum/source, H as mob|obj)
	if(SStelescience.last_effect  != world.time)
		SStelescience.last_effect = world.time
		SEND_SIGNAL(src, COMSIG_ATOM_ENTERED, H)
