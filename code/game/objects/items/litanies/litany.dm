//64 characters available, should be enough
#define MAX_LITANY_CHAR_X 8
#define MAX_LITANY_CHAR_Y 8
#define LITANY_CHARACTER_SIZE 16
#define GENERIC_OFFSET 8

/obj/item/litany
	name = "litany"
	desc = "A piece of holy parchment."
	icon = 'icons/obj/religion.dmi'
	icon_state = "litany_stamp"
	item_state = "paper"
	custom_fire_overlay = "paper_onfire_overlay"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound =  'sound/items/handling/paper_pickup.ogg'
	throw_range = 1
	throw_speed = 1
	pressure_resistance = 0
	resistance_flags = FLAMMABLE
	max_integrity = 50
	vis_flags = VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
	///List, in order, of litany components we have
	var/list/litany_components = list()
	///The max amount of litany components this litany can have
	var/max_components = 6
	var/max_visual_components = 5 //Admin fuckery approved
	///The info stack litany components typically effect
	var/list/info_stack = list()
	///The target we're attached to, since we sit in area contents for objective checks
	var/atom/movable/attach_target
	///Is this litany blessed - aka enabled or in edit mode
	var/blessed = FALSE
	///The image used to display components
	var/image/display_component
	var/mob/display_user
	///Time between uses, so people dont spam attaching & detaching
	var/cooldown_time = 5 SECONDS
	var/cooldown_timer

/obj/item/litany/Destroy()
	. = ..()
	for(var/datum/litany_component/LC as() in litany_components)
		litany_components -= LC
		qdel(LC)

/obj/item/litany/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_INDIANA_JONES))
		//generic info
		. += "<span class='notice'>Interact to add litany components.\nBless to finalize, and activate.</span>"
		//Info stack
		. += "<span class='notice'>Contained info:</span>"
		for(var/i in info_stack)
			. += "<span class='notice'>\[[i]]</span>"

/obj/item/litany/interact(mob/user)
	. = ..()
	if(!blessed)
		edit_components(user)

//We can attach this item to 'things', like a sticker
/obj/item/litany/afterattack(atom/movable/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	attach_target = target
	//Move this to the area, for objective checks
	forceMove(target)
	//Visual display stuff
	target.vis_contents += src
	var/list/params = params2list(click_parameters)
	pixel_x = text2num(params["icon-x"])-16
	pixel_y = text2num(params["icon-y"])-16
	layer = ABOVE_ALL_MOB_LAYER
	activate()

/obj/item/litany/attack_hand(mob/living/carbon/user)
	. = ..()
	layer = OBJ_LAYER
	pixel_x = 0
	pixel_y = 0
	attach_target?.vis_contents -= src
	attach_target = null
	SEND_SIGNAL(src, COMSIG_LITANY_REMOVE)

/obj/item/litany/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	attach_target?.attackby(I, user, params)

/obj/item/litany/update_appearance(updates, override_length = 0)
	cut_overlays()
	var/loop_length = (override_length || length(litany_components)) //Logic in loop params is fucky here
	for(var/i in 1 to loop_length)
		if(i >= max_visual_components)
			break
		var/mutable_appearance/MA = mutable_appearance('icons/obj/religion.dmi', "litany_paper")
		MA.pixel_y = (-7 * i) + 7 //Todd_Howard.webp
		add_overlay(MA)
	return ..()

/obj/item/litany/proc/activate(force)
	if((!blessed || cooldown_timer) && !force)
		return
	if(cooldown_timer)
		clear_timer()
	cooldown_timer = addtimer(CALLBACK(src, PROC_REF(clear_timer)), cooldown_time+get_extra_time(), TIMER_STOPPABLE)
	SEND_SIGNAL(src, COMSIG_LITANY_ACTIVATE)
	//TODO: Temporary animation, consider giving it a proper one - Racc
	var/matrix/n_transform = transform
	var/matrix/o_transform = transform
	n_transform.Scale(0.85, 1.15)
	animate(src, transform = n_transform, time = 0.25 SECONDS, easing = BACK_EASING | EASE_OUT)
	animate(transform = o_transform, time = 0.15 SECONDS, easing = LINEAR_EASING)

///Logic for adding litany components & overlays associated with that
/obj/item/litany/proc/add_litany_component(datum/litany_component/LC)
	if(LC && length(litany_components) < max_components)
		litany_components += new LC(src)
	update_appearance()

///Interface for editing this litany's components
/obj/item/litany/proc/edit_components(mob/user, _litanies, _associated_litanies)
	if(!user || !user?.client)
		return
	display_user = user
	display_component = display_components(display_user)
	var/list/litanies = list()
	var/list/litany_choices = list()
	var/list/associated_litany = list()
	//If we have to generate the symbols / choice lists
	if(!_litanies && !_associated_litanies)
		litanies = GLOB.chaplain_known_runes
		for(var/datum/litany_component/i as() in litanies)
			var/datum/radial_menu_choice/RC = new()
			RC.image = image(initial(i.icon), icon_state = initial(i.icon_state))
			RC.info = "[initial(i.desc)]"
			litany_choices += list("[initial(i.name)]" = RC)
			associated_litany += list("[initial(i.name)]" = i)
	//otherwise, save some time
	else
		litany_choices = _litanies
		associated_litany = _associated_litanies
	var/choice = show_radial_menu(display_user, src, litany_choices, tooltips = TRUE)
	//Remove the display components
	display_user.client.images -= display_component
	qdel(display_component)
	if(!choice)
		display_user = null
		return
	//Add the chosen component
	add_litany_component(associated_litany[choice])
	if(length(litany_components) >= max_components)
		to_chat(user, "<span class='warning'>Too many components!</span>")
	//Loop
	edit_components(display_user, litany_choices, associated_litany)

/obj/item/litany/proc/display_components(mob/user)
	//Menu containing all the elements
	var/image/M = new()
	M.loc = src
	//Generate an appearance for each component
	var/count = 0
	for(var/datum/litany_component/i as() in litany_components)
		//If someone achieves this, there is a 99% chance they're fucking around and finding out
		if(round(count / MAX_LITANY_CHAR_X) >= MAX_LITANY_CHAR_Y)
			continue
		var/atom/movable/screen/litany_component/new_element = new /atom/movable/screen/litany_component(null, src, i)
		new_element.appearance = icon(i.icon, i.icon_state)
		//Calculate offsets - slightly spooky, sorry
		new_element.pixel_x = GENERIC_OFFSET + (((count % MAX_LITANY_CHAR_X) * LITANY_CHARACTER_SIZE) - ((min(length(litany_components), 8)-1) * (LITANY_CHARACTER_SIZE / 2)))
		new_element.pixel_y = (round(count / MAX_LITANY_CHAR_X) * -LITANY_CHARACTER_SIZE) + round((length(litany_components)-1) / 8) * LITANY_CHARACTER_SIZE
		M.vis_contents += new_element
		count += 1
	user.client?.images += M
	return M

/obj/item/litany/proc/clear_timer()
	if(cooldown_timer)
		deltimer(cooldown_timer)
	cooldown_timer = null

///Returns the total cost of all its components
/obj/item/litany/proc/get_cost()
	. = 0
	for(var/datum/litany_component/LC as() in litany_components)
		. += LC.cost

///Get extra time from present components
/obj/item/litany/proc/get_extra_time()
	. = 0
	for(var/datum/litany_component/LC as() in litany_components)
		. += LC.cooldown

/obj/item/litany/bless(mob/living/carbon/user, obj/item/bless_tool)
	. = ..()
	if(blessed)
		return
	var/datum/religion_sect/R = GLOB.religious_sect
	if(!user?.mind?.holy_role || !R)
		if(!R)
			balloon_alert(user, "No active sect!")
			to_chat(user, "<span class='warning'>No active sect!</span>")
		return
	var/prompt = tgui_alert(user, "Do you want to bless [src] for [get_cost()] favor?", "Bless litany", list("Yes", "No"))
	if(R?.favor < get_cost() || prompt != "Yes")
		if(R?.favor < get_cost())
			to_chat(user, "<span class='warning'>You don't have enough favor!</span>")
		return
	if(do_after(user, 40, target = src))
		R.adjust_favor(get_cost(), user)
		blessed = TRUE

//Debug
/obj/item/litany/pregenerated
	///list of litany components to add
	var/list/to_add_components = list(/datum/litany_component/alpha, /datum/litany_component/beta)

/obj/item/litany/pregenerated/Initialize(mapload)
	. = ..()
	for(var/LC in to_add_components)
		add_litany_component(LC)
	update_appearance()

/atom/movable/screen/litany_component
	plane = HUD_PLANE
	///The litany component we're associated with with
	var/obj/item/litany/litany_parent
	///The component we're associated with
	var/datum/litany_component/litany_component

/atom/movable/screen/litany_component/Initialize(mapload, obj/item/litany/_litany, datum/litany_component/_litany_component)
	. = ..()
	//Setup
	litany_parent = _litany
	litany_component = _litany_component
	//Fancy stuff
	//TODO: Add animation - Racc

/atom/movable/screen/litany_component/Click(location, control, params)
	. = ..()
	litany_parent?.litany_components -= litany_component
	QDEL_NULL(litany_component)
	litany_parent.update_appearance()
	color = "#000"
	//TODO: Animate it shrinking - Racc

#undef MAX_LITANY_CHAR_X
#undef MAX_LITANY_CHAR_Y
#undef LITANY_CHARACTER_SIZE
#undef GENERIC_OFFSET
