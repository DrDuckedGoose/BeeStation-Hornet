#define MODULE_ITEM_CATEGORY_BASIC (1<<0)
#define MODULE_ITEM_CATEGORY_EMAGGED (1<<1)
#define MODULE_ITEM_CATEGORY_CLOCKCULT (1<<2)

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
	var/list/basic_items = list(/obj/item/paper)
	///Items we gain when emagged
	var/list/emag_items = list(/obj/item/paper)
	///Items we gain when we join clockcult
	var/list/clockcult_items = list(/obj/item/paper)

	///List of all our items, for display stuff
	var/list/all_items = list()
	///List of all the items that are currenty  equipped, alo for display stuff
	var/list/equipped_items = list()

	///Ref to our assoiated hud element for updates
	var/atom/movable/screen/new_robot/module/module_hud

/obj/item/new_robot_module/Initialize(mapload)
	. = ..()
	populate_module_items(MODULE_ITEM_CATEGORY_BASIC)

/obj/item/new_robot_module/Destroy()
	. = ..()
	//Clean up our items
	basic_items.Cut()
	emag_items.Cut()
	clockcult_items.Cut()

///Populate this modules item lists with instances
/obj/item/new_robot_module/proc/populate_module_items(category = MODULE_ITEM_CATEGORY_BASIC | MODULE_ITEM_CATEGORY_EMAGGED | MODULE_ITEM_CATEGORY_CLOCKCULT)
	//This code is a little duplicate-ish, but it's a little more readable over the small sacrifice of a micro-micro optimization
	//TODO: Consider condesning this - Racc
//Basic
	if((category & MODULE_ITEM_CATEGORY_BASIC))
		for(var/item_index as() in basic_items)
			basic_items -= item_index
			var/obj/item/I = new item_index(src)
			basic_items += I
			all_items += I
			RegisterSignal(I, COMSIG_ATOM_ATTACK_ROBOT, PROC_REF(catch_robot_attack))
//Emagged
	if((category & MODULE_ITEM_CATEGORY_EMAGGED))
		for(var/item_index as() in basic_items)
			emag_items -= item_index
			var/obj/item/I = new item_index(src)
			emag_items += I
			all_items += I
			RegisterSignal(I, COMSIG_ATOM_ATTACK_ROBOT, PROC_REF(catch_robot_attack))
//Clockcult
	if((category & MODULE_ITEM_CATEGORY_CLOCKCULT))
		for(var/item_index as() in basic_items)
			clockcult_items -= item_index
			var/obj/item/I = new item_index(src)
			clockcult_items += I
			all_items += I
			RegisterSignal(I, COMSIG_ATOM_ATTACK_ROBOT, PROC_REF(catch_robot_attack))

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
	module_hud.update_inventory(usr)
	//Undo above changes
	//I.plane = ABOVE_HUD_PLANE
	item.forceMove(src)
	return TRUE

//TODO: Implement this - Racc
/obj/item/new_robot_module/proc/respawn_consumable(mob/living/silicon/robot/R, coeff = 1)
	/*
	for(var/datum/robot_energy_storage/st in storages)
		st.energy = min(st.max_energy, st.energy + coeff * st.recharge_rate)

	for(var/obj/item/I in get_usable_modules())
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

	R.toner = R.tonermax
	*/
	return

#undef MODULE_ITEM_CATEGORY_BASIC
#undef MODULE_ITEM_CATEGORY_EMAGGED
#undef MODULE_ITEM_CATEGORY_CLOCKCULT
