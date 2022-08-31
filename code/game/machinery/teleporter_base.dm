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

//General proc used to teleport
/obj/machinery/teleporter_base/proc/activate()
	//Adjust telescience weight
	SStelescience.weight += emmission

	//door stuck
	close()
	//Handle new doors
	if(door_mode == TELE_MODE_OPEN)
		//instantiate
		door_here = new(get_turf(src))
		door_there = new(locate(target_x, target_y, target_z))
		//setup appearences
		door_here.build_appearance(locate(target_x, target_y, target_z))
		door_there.build_appearance(get_turf(src))
		//signals for teleporting
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

//Delete  doors
/obj/machinery/teleporter_base/proc/close()
	if(door_here)
		qdel(door_here)
		door_here = null
	if(door_there)
		qdel(door_there)
		door_there = null

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
	layer = 4 //Hopefully the highest layer
	anchored = TRUE
	appearance_flags = TILE_BOUND|PIXEL_SCALE|KEEP_TOGETHER
	vis_flags = VIS_INHERIT_PLANE|VIS_HIDE
	var/image/render
	var/turf/mirror_loc

/obj/structure/teleporter_door/Initialize(mapload)
	. = ..()
	//If space is occupied
	for(var/obj/structure/teleporter_door/D in get_turf(src))
		if(D != src)
			SStelescience.do_door_collapse(src)
			qdel(D)
			qdel(src)
	//handle on-enter
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	//Start processing
	START_PROCESSING(SSobj, src)

/obj/structure/teleporter_door/Destroy()
	. = ..()
	//Kill render
	for(var/mob/living/M in GLOB.mob_list)
		M.client?.images -= render
	qdel(render)
	//stahp processing
	STOP_PROCESSING(SSobj, src)

/obj/structure/teleporter_door/attack_hand(mob/user)
	. = ..()
	on_entered(src, user)

/obj/structure/teleporter_door/proc/on_entered(datum/source, H as mob|obj)
	if(SStelescience.last_effect  != world.time)
		SStelescience.last_effect = world.time
		SEND_SIGNAL(src, COMSIG_ATOM_ENTERED, H)

///Build appearance from given turf
/obj/structure/teleporter_door/proc/build_appearance(turf/T)
	//When trying to access outer map
	if(!T)
		return
	//setup image
	render = new(T.icon, T.icon_state)
	render.appearance_flags |= KEEP_TOGETHER
	render.plane = 0
	render.loc = loc
	//filters
	add_filter("outline_inner", 1.2, outline_filter(1, "#421c77"))
	add_filter("outline_outer", 1.3, outline_filter(1, "#7684ff"))
	apply_wibbly_filters(src, 0.2)
	render.filters += filter(type="alpha", icon = icon('icons/obj/machines/telescience.dmi', "door_mask"))
	//visuals
	render.vis_contents = T
	mirror_loc = T
	for(var/mob/living/M in GLOB.mob_list)
		M.client?.images += render

//Update visuals
/obj/structure/teleporter_door/process(delta_time)
	render?.vis_contents = mirror_loc
	
