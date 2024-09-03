/*
	This is like a backpack for our robot. All our robot's tools and items live here
*/
/obj/item/new_robot_module
	name = "Default"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	w_class = WEIGHT_CLASS_GIGANTIC
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	flags_1 = CONDUCT_1

	///Items we start with
	var/list/basic_items = list(/obj/item/assembly/flash/cyborg)
	///Items we gain when emagged
	var/list/emag_items = list(/obj/item/melee/transforming/energy/sword/cyborg)
	///Items we gain when we join clockcult
	var/list/clockcult_items = list(/obj/item/clockwork/weapon/brass_spear)

	///External items that have been added to us by some non-standard method
	var/list/external_items = list()

	///List of storage datums for item stacks
	var/list/storages = list()

	///List of all our items, for display stuff
	var/list/all_items = list()
	///List of all the items that are currenty  equipped, alo for display stuff
	var/list/equipped_items = list()

	///Ref to our assoiated hud element for updates
	var/atom/movable/screen/new_robot/module/module_hud
	///Ref to our papa, for convenicence
	var/mob/living/silicon/new_robot/robot_parent //The assembly recipe sets this for us <3

	///Which icon we're rocking with
	var/module_icon = "nomod"

/obj/item/new_robot_module/Initialize(mapload)
	. = ..()
	populate_module_items()
	hide_module_items(MODULE_ITEM_CATEGORY_EMAGGED | MODULE_ITEM_CATEGORY_CLOCKCULT)

/obj/item/new_robot_module/Destroy()
	. = ..()
	//Clean up our items
	basic_items.Cut()
	emag_items.Cut()
	clockcult_items.Cut()

/obj/item/new_robot_module/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	//TODO: Go over this code, it weirds me out - Racc
	var/list/choices = list()
	var/list/assoc = list()
	for(var/obj/item/borg/upgrade/upgrade in contents)
		var/image/image = new()
		image.appearance = upgrade.appearance
		choices += list("[ref(upgrade)]" = image)
		assoc += list("[ref(upgrade)]" = upgrade)
	var/choice = show_radial_menu(user, isturf(loc) ? src : get_turf(src), choices, require_near = TRUE, tooltips = TRUE)
	var/obj/item/borg/upgrade/upgrade = assoc[choice]
	upgrade.remove(src, robot_parent, user)
	upgrade.forceMove(get_turf(src))
	user.put_in_hands(upgrade)

/obj/item/new_robot_module/proc/add_parent(mob/M)
	robot_parent = M

/obj/item/new_robot_module/proc/remove_parent()
	robot_parent = null

///Populate this modules item lists with instances
/obj/item/new_robot_module/proc/populate_module_items(category = MODULE_ITEM_CATEGORY_BASIC | MODULE_ITEM_CATEGORY_EMAGGED | MODULE_ITEM_CATEGORY_CLOCKCULT)
	//This code is a little duplicate-ish, but it's a little more readable over the small sacrifice of a micro-micro optimization
//Basic
	if((category & MODULE_ITEM_CATEGORY_BASIC))
		for(var/item_index as() in basic_items)
			basic_items -= item_index
			basic_items += prepare_item(new item_index(src))
//Emagged
	if((category & MODULE_ITEM_CATEGORY_EMAGGED))
		for(var/item_index as() in emag_items)
			emag_items -= item_index
			emag_items += prepare_item(new item_index(src))
//Clockcult
	if((category & MODULE_ITEM_CATEGORY_CLOCKCULT))
		for(var/item_index as() in clockcult_items)
			clockcult_items -= item_index
			clockcult_items += prepare_item(new item_index(src))

///Prepare items made during population, adds some cool traits and sets up stacks if they are one
/obj/item/new_robot_module/proc/prepare_item(obj/item/I, nonstandard)
	if(I.loc != src)
		I.forceMove(src)
	if(nonstandard)
		external_items += I
	ADD_TRAIT(I, TRAIT_NODROP, CYBORG_ITEM_TRAIT)
	RegisterSignal(I, COMSIG_ATOM_ATTACK_ROBOT, PROC_REF(catch_robot_attack))
	all_items += I
	//Special handling for material stacks, since they're a little goofy
	if(istype(I, /obj/item/stack))
		//Generic stack
		var/obj/item/stack/sheet_module = I
		if(ispath(sheet_module.source, /datum/robot_energy_storage))
			sheet_module.source = get_or_create_estorage(sheet_module.source)
		//Special case for a special boy
		if(istype(sheet_module, /obj/item/stack/sheet/rglass/cyborg))
			var/obj/item/stack/sheet/rglass/cyborg/rglass_module = sheet_module
			if(ispath(rglass_module.glasource, /datum/robot_energy_storage))
				rglass_module.glasource = get_or_create_estorage(rglass_module.glasource)
		//Patch any holes that might exist
		if(istype(sheet_module.source))
			sheet_module.cost = max(sheet_module.cost, 1) // Must not cost 0 to prevent div/0 errors.
			sheet_module.is_cyborg = TRUE //IDK why we wouldn't do this always, but I'm not going to tempt fate
	if(module_hud?.display_module)
		module_hud.update_inventory(usr, TRUE)
	return I

///Remove an item from this module
/obj/item/new_robot_module/proc/remove_item(obj/item/I)
			basic_items -= I
			emag_items -= I
			clockcult_items -= I
			external_items -= I
			all_items -= I
			equipped_items -= I
			UnregisterSignal(I, COMSIG_ATOM_ATTACK_ROBOT)
			UnregisterSignal(I, COMSIG_ITEM_DROPPED)
			I.forceMove(get_turf(src))

/obj/item/new_robot_module/proc/get_or_create_estorage(storage_type)
	return (locate(storage_type) in storages) || new storage_type(src)

///Used to remove emag and such items from the item list, if we're un-emagged, without potentially creating more overhead
/obj/item/new_robot_module/proc/hide_module_items(category = MODULE_ITEM_CATEGORY_BASIC | MODULE_ITEM_CATEGORY_EMAGGED | MODULE_ITEM_CATEGORY_CLOCKCULT)
	if((category & MODULE_ITEM_CATEGORY_BASIC))
		all_items -= basic_items
		for(var/obj/item/item as() in basic_items & equipped_items)
			item.dropped(item.loc)
	if((category & MODULE_ITEM_CATEGORY_EMAGGED))
		all_items -= emag_items
		for(var/obj/item/item as() in emag_items & equipped_items)
			item.dropped(item.loc)
	if((category & MODULE_ITEM_CATEGORY_CLOCKCULT))
		all_items -= clockcult_items
		for(var/obj/item/item as() in clockcult_items & equipped_items)
			item.dropped(item.loc)

///Used to respawn mats and recharge stuff like energy guns
/obj/item/new_robot_module/proc/respawn_consumable(mob/living/silicon/new_robot/R, coeff = 1)
	for(var/datum/robot_energy_storage/st as() in storages)
		st.energy = min(st.max_energy, st.energy + coeff * st.recharge_rate)

	//TODO: i don't like how hardcoded this is, it should live on the item in a dedicated proc - Racc
	for(var/obj/item/I in all_items & equipped_items)
		if(istype(I, /obj/item/assembly/flash))
			var/obj/item/assembly/flash/F = I
			F.bulb.charges_left = INFINITY
			F.burnt_out = FALSE
			F.update_icon()
		else if(istype(I, /obj/item/melee/baton))
			var/obj/item/melee/baton/B = I
			if(B.cell)
				B.cell.charge = B.cell.maxcharge
		else if(istype(I, /obj/item/gun/energy))
			var/obj/item/gun/energy/EG = I
			if(!EG.chambered)
				EG.recharge_newshot() //try to reload a new shot.
		else if(istype(I, /obj/item/camera/siliconcam/robot_camera))
			var/obj/item/camera/siliconcam/robot_camera/RC = I
			RC.toner = RC.tonermax

///Inverse of above
/obj/item/new_robot_module/proc/show_module_items(category = MODULE_ITEM_CATEGORY_BASIC | MODULE_ITEM_CATEGORY_EMAGGED | MODULE_ITEM_CATEGORY_CLOCKCULT)
	if((category & MODULE_ITEM_CATEGORY_BASIC))
		all_items |= basic_items
	if((category & MODULE_ITEM_CATEGORY_EMAGGED))
		all_items |= emag_items
	if((category & MODULE_ITEM_CATEGORY_CLOCKCULT))
		all_items |= clockcult_items

/obj/item/new_robot_module/proc/catch_robot_attack(datum/source, mob/M)
	SIGNAL_HANDLER

	//See if the robot can even equip this, maybe they don't have hands
	var/mob/living/silicon/new_robot/R = M
	if(!istype(R) || !R.can_equip(source))
		return
	var/obj/item/item = source
	if(item in equipped_items)
		item.dropped(M)
	//Equip the item to the hand
	if(!R.try_equip(source))
		return
	equipped_items += item
	RegisterSignal(item, COMSIG_ITEM_DROPPED, PROC_REF(catch_unequipped))
	module_hud.update_inventory(M)
	item.equipped(M, ITEM_SLOT_HANDS)
	item.plane = ABOVE_HUD_PLANE
	item.forceMove(M) //We move it inside the, presumably, borg so it's easier to code stuff looking for the borg, they can just use 'loc'
	return TRUE

/obj/item/new_robot_module/proc/catch_unequipped(datum/source)
	SIGNAL_HANDLER

	var/obj/item/item = source
	equipped_items -= item
	UnregisterSignal(item, COMSIG_ITEM_DROPPED)
	module_hud.update_inventory(usr, module_hud.display_module)
	//Undo above changes
	//I.plane = ABOVE_HUD_PLANE
	item.forceMove(src)
	return TRUE
