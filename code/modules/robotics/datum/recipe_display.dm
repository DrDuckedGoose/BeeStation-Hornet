//#define NEXT_PAGE_ID "__next__"
//#define DEFAULT_CHECK_DELAY 20

GLOBAL_LIST_EMPTY(recipe_display_controllers)

//TODO: Please add comments to this - Racc
//TODO: Finish this - Racc

/*
	Generic datum template for recipe display stuff
	I may, or may not have, majorly stole this from radial.dm
*/
/atom/movable/screen/recipe_display
	icon = 'icons/obj/robotics/endo.dmi'
	appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	plane = ABOVE_HUD_PLANE
	var/atom/movable/screen/recipe_display_controller/parent
	pixel_y = 32

/atom/movable/screen/recipe_display/Destroy()
	if(parent)
		parent.elements -= src
		UnregisterSignal(parent, COMSIG_PARENT_QDELETING)
	return ..()

/atom/movable/screen/recipe_display/proc/set_parent(new_value)
	if(parent)
		UnregisterSignal(parent, COMSIG_PARENT_QDELETING)
	parent = new_value
	if(parent)
		RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(handle_parent_del))

/atom/movable/screen/recipe_display/proc/handle_parent_del()
	SIGNAL_HANDLER

	qdel(src)

/*
	Little guy for holding recipe elements
*/
/atom/movable/screen/recipe_display/slice
	icon_state = "middle"
	var/next_page = FALSE

/atom/movable/screen/recipe_display/slice/MouseEntered(location, control, params)
	. = ..()
	//icon_state = "radial_slice_focus"
	openToolTip(usr, src, params, title = name)

/atom/movable/screen/recipe_display/slice/MouseExited(location, control, params)
	. = ..()
	//icon_state = "radial_slice"
	closeToolTip(usr)

/atom/movable/screen/recipe_display/slice/Click(location, control, params)
	if(usr.client == parent.current_user && next_page)
		parent.next_page()

/*
	This big boss controller that all the recipe_display datums are slaved to
	Handles all the important lawgic
*/
/atom/movable/screen/recipe_display_controller
	/// List of choice IDs
	var/list/choices = list()

	/// choice_id -> icon
	var/list/choices_icons = list()

	/// choice_id -> choice
	var/list/choices_values = list()

	/// choice_id -> /atom/movable/screen/recipe_display_controller_choice
	var/list/choice_datums = list()

	var/list/page_data = list() //list of choices per page

	var/list/atom/movable/screen/elements = list()
	var/atom/movable/screen/radial/center/close_button
	var/client/current_user
	var/atom/anchor
	var/image/menu_holder
	var/finished = FALSE
	var/next_check = 0
	var/check_delay = DEFAULT_CHECK_DELAY

	var/max_elements = 10
	var/pages = 1
	var/current_page = 1

	//TRUE to change anchor to user, FALSE to shift by py_shift
	var/hudfix_method = TRUE
	var/py_shift = 0
	var/entry_animation = TRUE

/atom/movable/screen/recipe_display_controller/New()
	close_button = new
	close_button.set_parent(src)

/atom/movable/screen/recipe_display_controller/Destroy()
	QDEL_LIST(elements)
	Reset()
	hide()
	. = ..()

/atom/movable/screen/recipe_display_controller/proc/check_screen_border(mob/user)
	var/atom/movable/AM = anchor
	if(!istype(AM) || !AM.screen_loc)
		return
	if(AM in user.client.screen)
		if(hudfix_method)
			anchor = user
		else
			py_shift = 32

/atom/movable/screen/recipe_display_controller/proc/setup_menu()
	var/paged = max_elements < length(choices)
	if(length(elements) < max_elements)
		var/elements_to_add = max_elements - length(elements)
		for(var/i in 1 to elements_to_add) //Create all elements
			var/atom/movable/screen/recipe_display/slice/new_element = new /atom/movable/screen/recipe_display/slice
			new_element.set_parent(src)
			elements += new_element

	var/page = 1
	page_data = list(null)
	var/list/current = list()
	var/list/choices_left = choices.Copy()
	while(length(choices_left))
		if(current.len == max_elements)
			page_data[page] = current
			page++
			page_data.len++
			current = list()
		if(paged && length(current) == max_elements - 1)
			current += NEXT_PAGE_ID
			continue
		else
			current += popleft(choices_left)
	if(paged && length(current) < max_elements)
		current += NEXT_PAGE_ID

	page_data[page] = current
	pages = page
	current_page = 1
	update_screen_objects(anim = entry_animation)

/atom/movable/screen/recipe_display_controller/proc/update_screen_objects(anim = FALSE)
	var/list/page_choices = page_data[current_page]
	for(var/i in 1 to length(elements))
		var/atom/movable/screen/radial/E = elements[i]
		if(i > page_choices.len)
			HideElement(E)
		else
			SetElement(E,page_choices[i],anim = anim,anim_order = i)

/atom/movable/screen/recipe_display_controller/proc/HideElement(atom/movable/screen/recipe_display/slice/E)
	E.cut_overlays()
	E.alpha = 0
	E.name = "None"
	E.maptext = null
	E.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	E.next_page = FALSE

/atom/movable/screen/recipe_display_controller/proc/SetElement(atom/movable/screen/recipe_display/slice/E, choice_id, anim, anim_order)
//Position
	var/px = (anim_order - (length(choices)/(length(choices) > 1 ? 2 : 1))) * 32
	if(anim)
		var/timing = anim_order * 0.5
		var/matrix/starting = matrix()
		starting.Scale(0.1,0.1)
		E.transform = starting
		var/matrix/TM = matrix()
		animate(E, pixel_x = px, transform = TM, time = timing)
	else
		E.pixel_x = px

//Visuals
	//Generic settings
	E.alpha = 255
	E.mouse_opacity = MOUSE_OPACITY_ICON
	E.cut_overlays()
	E.vis_contents.Cut()
	//Overlays for start and finish
	var/icon/wing_icon
	if(anim_order == 1)
		wing_icon = icon('icons/obj/robotics/endo.dmi', "start")
		E.add_overlay(wing_icon)
	if(anim_order == length(choices))
		wing_icon = icon('icons/obj/robotics/endo.dmi', "finish")
		E.add_overlay(wing_icon)
	//If this slice is just used as a 'next-page' button
	if(choice_id == NEXT_PAGE_ID)
		E.name = "Next Page"
		E.next_page = TRUE
		E.add_overlay("radial_next")
		return
	//Legitimate slice
	if(istext(choices_values[choice_id]))
		E.name = choices_values[choice_id]
	else if(ispath(choices_values[choice_id],/atom))
		var/atom/A = choices_values[choice_id]
		E.name = initial(A.name)
	else
		var/atom/movable/AM = choices_values[choice_id] //Movables only
		E.name = AM.name
	E.maptext = null
	E.next_page = FALSE
	if(choices_icons[choice_id])
		E.add_overlay(choices_icons[choice_id])
	if (choice_datums[choice_id])
		var/atom/movable/screen/recipe_display_controller_choice/choice_datum = choice_datums[choice_id]
		if (choice_datum.info)
			var/obj/effect/abstract/info/info_button = new(E, choice_datum.info)
			info_button.plane = ABOVE_HUD_PLANE
			info_button.layer = RADIAL_CONTENT_LAYER
			E.vis_contents += info_button

/atom/movable/screen/recipe_display_controller/proc/Reset()
	choices.Cut()
	choices_icons.Cut()
	choices_values.Cut()
	current_page = 1

/atom/movable/screen/recipe_display_controller/proc/get_next_id()
	return "c_[choices.len]"

/atom/movable/screen/recipe_display_controller/proc/set_choices(list/new_choices, use_tooltips)
	if(choices.len)
		Reset()
	for(var/E in new_choices)
		var/id = get_next_id()
		choices += id
		choices_values[id] = E
		if(new_choices[E])
			var/I = extract_image(new_choices[E])
			if(I)
				choices_icons[id] = I

			if (istype(new_choices[E], /atom/movable/screen/recipe_display_controller_choice))
				choice_datums[id] = new_choices[E]
	setup_menu(use_tooltips)

/atom/movable/screen/recipe_display_controller/proc/extract_image(to_extract_from)
	if (istype(to_extract_from, /atom/movable/screen/recipe_display_controller_choice))
		var/atom/movable/screen/recipe_display_controller_choice/choice = to_extract_from
		to_extract_from = choice.image

	var/mutable_appearance/MA = new /mutable_appearance(to_extract_from)
	if(MA)
		MA.plane = ABOVE_HUD_PLANE
		MA.layer = RADIAL_CONTENT_LAYER
		MA.appearance_flags |= RESET_TRANSFORM
	return MA


/atom/movable/screen/recipe_display_controller/proc/next_page()
	if(pages > 1)
		current_page = WRAP(current_page + 1,1,pages+1)
		update_screen_objects()

/atom/movable/screen/recipe_display_controller/proc/show_to(mob/M)
	if(current_user)
		hide()
	if(!M.client || !anchor)
		return
	current_user = M.client
	//Blank
	menu_holder = image(icon='icons/effects/effects.dmi',loc=anchor,icon_state="nothing", layer = RADIAL_BACKGROUND_LAYER)
	menu_holder.plane = ABOVE_HUD_PLANE
	menu_holder.appearance_flags |= KEEP_APART
	menu_holder.vis_contents += elements + close_button
	current_user.images += menu_holder

/atom/movable/screen/recipe_display_controller/proc/hide()
	if(current_user)
		current_user.images -= menu_holder

/atom/movable/screen/recipe_display_controller/proc/wait(atom/user, atom/anchor, require_near = FALSE)
	while(current_user && !finished)
		if(require_near && !in_range(anchor, user))
			return
		if(next_check < world.time)
			next_check = world.time + check_delay
		stoplag(1)

/*
	Presents radial menu to user anchored to anchor (or user if the anchor is currently in users screen)
	Choices should be a list where list keys are movables or text used for element names and return value
	and list values are movables/icons/images used for element icons
*/
/proc/show_recipe_display_controller(mob/user, atom/anchor, list/choices, uniqueid, datum/callback/custom_check, require_near = FALSE, tooltips = FALSE)
	if(!user || !anchor || !length(choices))
		return
	if(!uniqueid)
		uniqueid = "defmenu_[REF(user)]_[REF(anchor)]"

	if(GLOB.recipe_display_controllers[uniqueid])
		return

	var/atom/movable/screen/recipe_display_controller/menu = new
	GLOB.recipe_display_controllers[uniqueid] = menu
	menu.anchor = anchor
	menu.check_screen_border(user) //Do what's needed to make it look good near borders or on hud
	menu.set_choices(choices, tooltips)
	menu.show_to(user)
	menu.wait(user, anchor, require_near)
	qdel(menu)
	GLOB.recipe_display_controllers -= uniqueid

/// Can be provided to choices in radial menus if you want to provide more information
/atom/movable/screen/recipe_display_controller_choice
	/// Required -- what to display for this button
	var/image

	/// If provided, will display an info button that will put this text in your chat
	var/info

/atom/movable/screen/recipe_display_controller_choice/Destroy(force, ...)
	. = ..()
	QDEL_NULL(image)
