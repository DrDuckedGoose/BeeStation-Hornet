#define DEFAULT_MAP_SIZE 15

//Typically very similar to regular camera console
/obj/item/portable_display
	name = "portable display"
	desc = "used to remotely interface with portable cameras."
	icon = 'icons/obj/machines/telescience.dmi'
	icon_state = "portable_display"

	var/list/network = list("portable")
	var/obj/machinery/camera/active_camera
	/// The turf where the camera was last updated.
	var/turf/last_camera_turf
	var/list/concurrent_users = list()
	var/long_ranged = FALSE

	// Stuff needed to render the map
	var/map_name
	var/atom/movable/screen/map_view/cam_screen
	var/atom/movable/screen/plane_master/lighting/cam_plane_master
	var/atom/movable/screen/plane_master/o_light_visual/visual_plane_master
	var/atom/movable/screen/background/cam_background

/obj/item/portable_display/Initialize(mapload)
	. = ..()
	// Map name has to start and end with an A-Z character,
	// and definitely NOT with a square bracket or even a number.
	// I wasted 6 hours on this. :agony:
	map_name = "camera_console_[REF(src)]_map"
	// Convert networks to lowercase
	for(var/i in network)
		network -= i
		network += lowertext(i)
	// Initialize map objects
	cam_screen = new
	cam_screen.name = "screen"
	cam_screen.assigned_map = map_name
	cam_screen.del_on_map_removal = FALSE
	cam_screen.screen_loc = "[map_name]:1,1"
	cam_plane_master = new
	cam_plane_master.name = "plane_master"
	cam_plane_master.assigned_map = map_name
	cam_plane_master.del_on_map_removal = FALSE
	cam_plane_master.screen_loc = "[map_name]:CENTER"
	visual_plane_master = new
	visual_plane_master.name = "plane_master"
	visual_plane_master.assigned_map = map_name
	visual_plane_master.del_on_map_removal = FALSE
	visual_plane_master.screen_loc = "[map_name]:CENTER"
	cam_background = new
	cam_background.assigned_map = map_name
	cam_background.del_on_map_removal = FALSE
	START_PROCESSING(SSobj, src)

/obj/item/portable_display/Destroy()
	QDEL_NULL(cam_screen)
	QDEL_NULL(cam_plane_master)
	QDEL_NULL(visual_plane_master)
	QDEL_NULL(cam_background)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/portable_display/process(delta_time)
	say("update")
	update_active_camera_screen()
	ui_update()

/obj/item/portable_display/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	for(var/i in network)
		network -= i
		network += "[idnum][i]"


/obj/item/portable_display/ui_state(mob/user)
	return GLOB.default_state

/obj/item/portable_display/ui_interact(mob/user, datum/tgui/ui)
	// Update UI
	ui = SStgui.try_update_ui(user, src, ui)

	// Update the camera, showing static if necessary and updating data if the location has moved.
	update_active_camera_screen()

	if(!ui)
		var/user_ref = REF(user)
		var/is_living = isliving(user)
		// Ghosts shouldn't count towards concurrent users, which produces
		// an audible terminal_on click.
		if(is_living)
			concurrent_users += user_ref
		// Turn on the console
		if(length(concurrent_users) == 1 && is_living)
			playsound(src, 'sound/machines/terminal_on.ogg', 25, FALSE)
		// Register map objects
		user.client.register_map_obj(cam_screen)
		user.client.register_map_obj(cam_plane_master)
		user.client.register_map_obj(visual_plane_master)
		user.client.register_map_obj(cam_background)
		// Open UI
		ui = new(user, src, "CameraConsole")
		ui.open()
		ui.set_autoupdate(FALSE)

/obj/item/portable_display/ui_data()
	var/list/data = list()
	data["network"] = network
	data["activeCamera"] = null
	if(active_camera)
		data["activeCamera"] = list(
			name = active_camera.c_tag,
			status = active_camera.status,
		)
	return data

/obj/item/portable_display/ui_static_data()
	var/list/data = list()
	data["mapRef"] = map_name
	var/list/cameras = get_available_cameras()
	data["cameras"] = list()
	for(var/i in cameras)
		var/obj/machinery/camera/C = cameras[i]
		data["cameras"] += list(list(
			name = C.c_tag,
		))
	return data

/obj/item/portable_display/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(action == "switch_camera")
		var/c_tag = params["name"]
		var/list/cameras = get_available_cameras()
		var/obj/machinery/camera/C = cameras[c_tag]
		active_camera = C
		ui_update()
		playsound(src, get_sfx("terminal_type"), 25, FALSE)

		if(!C)
			return TRUE

		update_active_camera_screen()

		return TRUE

/obj/item/portable_display/proc/update_active_camera_screen()
	// Show static if can't use the camera
	if(!active_camera?.can_use())
		show_camera_static()
		return

	var/list/visible_turfs = list()

	// Is this camera located in or attached to a living thing? If so, assume the camera's loc is the living thing.
	var/atom/cam_location = isliving(active_camera.loc) ? active_camera.loc : active_camera

	// If we're not forcing an update for some reason and the cameras are in the same location,
	// we don't need to update anything.
	// Most security cameras will end here as they're not moving.
	var/newturf = get_turf(cam_location)
	if(last_camera_turf == newturf)
		return

	// Cameras that get here are moving, and are likely attached to some moving atom such as cyborgs.
	last_camera_turf = get_turf(cam_location)

	if(active_camera.isXRay(TRUE))	//ignore_malf_upgrades = TRUE
		visible_turfs += RANGE_TURFS(active_camera.view_range, cam_location)
	else
		for(var/turf/T in view(active_camera.view_range, cam_location))
			visible_turfs += T

	var/list/bbox = get_bbox_of_atoms(visible_turfs)
	var/size_x = bbox[3] - bbox[1] + 1
	var/size_y = bbox[4] - bbox[2] + 1

	cam_screen.vis_contents = visible_turfs
	cam_background.icon_state = "clear"
	cam_background.fill_rect(1, 1, size_x, size_y)

/obj/item/portable_display/ui_close(mob/user, datum/tgui/tgui)
	var/user_ref = REF(user)
	var/is_living = isliving(user)
	// Living creature or not, we remove you anyway.
	concurrent_users -= user_ref
	// Unregister map objects
	user.client.clear_map(map_name)
	// Turn off the console
	if(length(concurrent_users) == 0 && is_living)
		active_camera = null
		playsound(src, 'sound/machines/terminal_off.ogg', 25, FALSE)

/obj/item/portable_display/proc/show_camera_static()
	cam_screen.vis_contents.Cut()
	cam_background.icon_state = "scanline2"
	cam_background.fill_rect(1, 1, DEFAULT_MAP_SIZE, DEFAULT_MAP_SIZE)

// Returns the list of cameras accessible from this computer
/obj/item/portable_display/proc/get_available_cameras()
	var/list/L = list()
	for (var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		if((is_away_level(z) || is_away_level(C.z)) && (C.get_virtual_z_level() != get_virtual_z_level()))//if on away mission, can only receive feed from same z_level cameras
			continue
		L.Add(C)
	var/list/D = list()
	for(var/obj/machinery/camera/C in L)
		if(!C.network)
			stack_trace("Camera in a cameranet has no camera network")
			continue
		if(!(islist(C.network)))
			stack_trace("Camera in a cameranet has a non-list camera network")
			continue
		var/list/tempnetwork = C.network & network
		if(tempnetwork.len)
			D["[C.c_tag]"] = C
	return D

#undef DEFAULT_MAP_SIZE

/obj/machinery/camera/portable
	name = "security camera"
	desc = "A wireless camera used to monitor rooms. It is powered by a long-life internal battery."
	icon = 'icons/obj/machines/telescience.dmi'
	icon_state = "portable_camera"
	use_power = NO_POWER_USE
	layer = OBJ_LAYER
	max_integrity = 500
	network = list("portable")
	c_tag = "portable"
	start_active = TRUE
	view_range = 4
	anchored = FALSE
	density = TRUE

/obj/machinery/camera/portable/update_icon()
	return
