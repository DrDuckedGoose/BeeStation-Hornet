/*
	Base component for endo parts
*/
/datum/component/endopart
	///What's the name of this endo component? Used for examine hint stuff
	var/name = "endopart"

	///List of items we require for assembly
	var/list/required_assembly = list()
	///List of items currently used for assembly
	var/list/current_assembly = list()

	///The mob we allegedly made using this part
	var/mob/assembled_mob

	///Assembly overlay
	var/mutable_appearance/assembly_overlay
	///Overlay offset key
	var/offset_key
	///Offset dictionary
	var/list/assembly_offsets = list(ENDO_OFFSET_KEY_ARM(1) = list(0, 0), ENDO_OFFSET_KEY_ARM(2) = list(0, 0),
	ENDO_OFFSET_KEY_LEG(1) = list(0, 0), ENDO_OFFSET_KEY_LEG(2) = list(0, 0), ENDO_OFFSET_KEY_HEAD(1) = list(0, 0),
	ENDO_OFFSET_KEY_CHEST(1) = list(0, 0))

	///Do we generate pre-done?
	var/start_finished = FALSE

	///What compatabilities does this part have
	var/compatibility_flags = ENDO_COMPATIBILITY_GENERIC

	///What is this part's ambient draw?
	var/ambient_draw = 0

	///How much discovery research does this limb generate per life() tick
	var/discovery_tick = 0.1
	///How much general research
	var/general_tick = 0.5

///Modifiers for damage
	var/brutemod = 1
	var/burnmod = 1

/datum/component/endopart/Initialize(_start_finished)
	. = ..()
	if(!parent)
		return
	//Setup our signals
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(attach_part))
	RegisterSignal(parent, COMSIG_ENDO_ATTACHED, PROC_REF(attach_to))
	RegisterSignal(parent, COMSIG_ENDO_REMOVED, PROC_REF(remove_from))

	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER), PROC_REF(catch_screwdriver))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(catch_examine))

	RegisterSignal(parent, COMSIG_ENDO_APPLY_OFFSET, PROC_REF(apply_offset))
	RegisterSignal(parent, COMSIG_ENDO_LIST_PART, PROC_REF(list_part))
	RegisterSignal(parent, COMSIG_ENDO_APPLY_LIFE, PROC_REF(life))
	RegisterSignal(parent, COMSIG_ENDO_APPLY_HUD, PROC_REF(apply_hud))

	RegisterSignal(parent, COMSIG_BODYPART_ATTACHED, PROC_REF(apply_assembly))

	RegisterSignal(parent, COMSIG_ROBOT_CONSUME_ENERGY, PROC_REF(consume_energy))
	RegisterSignal(parent, COMSIG_ROBOT_SET_EMAGGED, PROC_REF(set_emagged))
	RegisterSignal(parent, COMSIG_ROBOT_UPDATE_ICONS, PROC_REF(update_icons))

	RegisterSignal(parent, COMSIG_ROBOT_LIST_SELF_MONITOR, PROC_REF(append_monitor))

	//Build our required assembly
	start_finished = isnull(_start_finished) ? start_finished : _start_finished
	build_required_assembly()

/datum/component/endopart/proc/build_required_assembly()
	var/list/compiled_assembly = list()
	for(var/datum/endo_assembly/recipe as anything in required_assembly)
		var/datum/endo_assembly/new_recipe = ispath(recipe) ? new recipe(src) : recipe
		compiled_assembly += new_recipe
		if(start_finished && !new_recipe.start_finished)
			new_recipe.start_finished = TRUE
			new_recipe.build_ideal_part()
	required_assembly = compiled_assembly


///Can something be attached to us
/datum/component/endopart/proc/can_attach(obj/item/I)
	return SEND_SIGNAL(src, COMSIG_ENDO_ASSEMBLY_LIST_PART, I)

///Can something interact with us
/datum/component/endopart/proc/can_interact(obj/item/I)
	return SEND_SIGNAL(src, COMSIG_ENDO_ASSEMBLY_POLL_INTERACTION, I)

///Attach a part to THIS part
/datum/component/endopart/proc/attach_part(datum/source, obj/item/I, mob/living/L, params)
	SIGNAL_HANDLER

	. = FALSE
	//handle attaching parts
	if(can_attach(I))
		I.forceMove(parent)
		to_chat(L, "<span class='notice'>You attach [I] to [parent].</span>")
		current_assembly += I
		//Let the part we're adding know it's been connected to use
		SEND_SIGNAL(I, COMSIG_ENDO_ATTACHED, parent, src)
		//Let our assembly datums know we're adding a part to ourselves
		SEND_SIGNAL(src, COMSIG_ENDO_ASSEMBLY_ADD, I, L)
		//Register a signal so this part can be easily removed
		RegisterSignal(I, COMSIG_ENDO_REMOVE_PART, PROC_REF(remove_part))

		if(!start_finished) //This scared the shit out of me all through testing, this stops that
			playsound(parent, 'sound/machines/click.ogg', 60)
		. = TRUE
	//Handle item interactions
	if(can_interact(I))
		SEND_SIGNAL(src, COMSIG_ENDO_ASSEMBLY_INTERACT, I, L)

		if(!start_finished)
			playsound(parent, 'sound/machines/click.ogg', 60)
		. = TRUE
	if(assembled_mob)
		refresh_assembly(src, assembled_mob)

///Remove a part from THIS part
/datum/component/endopart/proc/remove_part(obj/item/I, mob/living/L, params)
	if(!(I in current_assembly))
		return
	if(L)
		to_chat(L, "<span class='notice'>You remove [I] from [parent].</span>")
	current_assembly -= I
	I.forceMove((get_turf(L) || get_turf(parent)))
	L?.put_in_hands(I)
	//Let the part we're removing know it's no-longer connected to us
	SEND_SIGNAL(I, COMSIG_ENDO_REMOVED, parent, src)
	//Let our assembly datums know we removed a part
	SEND_SIGNAL(src, COMSIG_ENDO_ASSEMBLY_REMOVE, I)
	//Remove removal signal
	UnregisterSignal(I, COMSIG_ENDO_REMOVE_PART)
	//Redo the assembly changes, now without the removed part
	if(assembled_mob)
		refresh_assembly(src, assembled_mob)

///Attach THIS part to
/datum/component/endopart/proc/attach_to(datum/source, obj/item/I, datum/component/endopart/part)
	SIGNAL_HANDLER

	build_assembly_overlay(I)
	RegisterSignal(I, COMSIG_ENDO_UNASSEMBLE, PROC_REF(remove_assembly))
	//Co-op stuff
	if(part.assembled_mob)
		apply_assembly(src, part.assembled_mob)
	RegisterSignal(part, COMSIG_ENDO_ASSEMBLE, PROC_REF(apply_assembly))
	RegisterSignal(part, COMSIG_ENDO_REFRESH_ASSEMBLY, PROC_REF(refresh_assembly))
	RegisterSignal(part, COMSIG_ENDO_LIST_PART, PROC_REF(list_part))
	RegisterSignal(part, COMSIG_ENDO_APPLY_LIFE, PROC_REF(life))
	RegisterSignal(part, COMSIG_ENDO_APPLY_HUD, PROC_REF(apply_hud))
	RegisterSignal(part, COMSIG_ROBOT_SET_EMAGGED, PROC_REF(set_emagged))
	RegisterSignal(part, COMSIG_ROBOT_LIST_SELF_MONITOR, PROC_REF(append_monitor))
	RegisterSignal(part, COMSIG_ROBOT_CONSUME_ENERGY, PROC_REF(consume_energy))
	RegisterSignal(part, COMSIG_ROBOT_UPDATE_ICONS, PROC_REF(update_icons))

	if(!start_finished)
		playsound(parent, 'sound/machines/click.ogg', 60)

	SEND_SIGNAL(src, COMSIG_ENDO_ATTACHED, I, part)

/datum/component/endopart/proc/remove_from(datum/source, obj/item/I, datum/component/endopart/part)
	SIGNAL_HANDLER

	//If we assembled, we need to undo our assembly
	if(assembled_mob)
		remove_assembly(src, assembled_mob)
	///Relationship with part is OVER
	cut_assembly_overlay(I)
	UnregisterSignal(I, COMSIG_ENDO_UNASSEMBLE)
	UnregisterSignal(part, COMSIG_ENDO_ASSEMBLE)
	UnregisterSignal(part, COMSIG_ENDO_REFRESH_ASSEMBLY)
	UnregisterSignal(part, COMSIG_ENDO_LIST_PART)
	UnregisterSignal(part, COMSIG_ENDO_APPLY_LIFE)
	UnregisterSignal(part, COMSIG_ENDO_APPLY_HUD)
	UnregisterSignal(part, COMSIG_ROBOT_SET_EMAGGED)
	UnregisterSignal(part, COMSIG_ROBOT_LIST_SELF_MONITOR)
	UnregisterSignal(part,  COMSIG_ROBOT_CONSUME_ENERGY)
	UnregisterSignal(part, COMSIG_ROBOT_UPDATE_ICONS)

	SEND_SIGNAL(src, COMSIG_ENDO_REMOVED, I, part)

///Apply our special and cool effects when Mr. Roboto is assembled
/datum/component/endopart/proc/apply_assembly(datum/source, mob/target)
	SIGNAL_HANDLER

	assembled_mob = target
	build_assembly_overlay(target)
	refresh_assembly(source, target)
	SEND_SIGNAL(src, COMSIG_ENDO_ASSEMBLE, target)
	RegisterSignal(target, COMSIG_MOB_APPLY_DAMGE, PROC_REF(apply_damage), TRUE)
	return

///Some of your apply_assembly() code should live in here, especially if it changes its behaviour when parts or added or removed
/datum/component/endopart/proc/refresh_assembly(datum/source, mob/target)
	SIGNAL_HANDLER

	apply_hud(source, assembled_mob?.hud_used)
	SEND_SIGNAL(src, COMSIG_ENDO_REFRESH_ASSEMBLY, target)

///Undo whatever awful shit we did
/datum/component/endopart/proc/remove_assembly(datum/source, mob/target)
	SIGNAL_HANDLER

	remove_hud(source, assembled_mob?.hud_used)
	assembled_mob = null
	cut_assembly_overlay(target)
	SEND_SIGNAL(parent, COMSIG_ENDO_UNASSEMBLE, target)
	UnregisterSignal(target, COMSIG_MOB_APPLY_DAMGE)
	return

///Handles screwdriver interaction, for removing parts
/datum/component/endopart/proc/catch_screwdriver(datum/source, mob/living/user, obj/item/I, list/recipes)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(screwdriver_async), user, I, recipes)
	return TRUE

/datum/component/endopart/proc/screwdriver_async(mob/living/L, obj/item/I, list/recipes)
	if(!length(current_assembly))
		return
	//TODO: Go over this code, it weirds me out - Racc
	var/list/choices = list()
	var/list/assoc = list()
	for(var/atom/part in current_assembly)
		var/image/image = new()
		image.appearance = part.appearance
		choices += list("[ref(part)]" = image)
		assoc += list("[ref(part)]" = part)
	var/atom/A = parent
	var/choice = show_radial_menu(L, isturf(A.loc) ? parent : A.loc, choices, require_near = TRUE, tooltips = TRUE)
	var/atom/choosen_part = assoc[choice]
	remove_part(choosen_part, L)

///Handle goobers looking at us
/datum/component/endopart/proc/catch_examine(datum/source, mob/M, list/examine_text)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(examine_async), M, examine_text)

/datum/component/endopart/proc/examine_async(mob/M, list/examine_text)
	if(!M.can_see_reagents())
		return
	var/list/choices = list()
	for(var/datum/endo_assembly/assembly as() in required_assembly)
		if(assembly.check_completion() & ENDO_ASSEMBLY_COMPLETE)
			continue
		var/list/hint_data = assembly.get_recipe_hint()
		choices += list(hint_data["name"] = hint_data["image"])
	if(!length(choices))
		return
	show_recipe_display_controller(M, parent, choices, require_near = FALSE, tooltips = TRUE)

/datum/component/endopart/proc/build_assembly_overlay(atom/A)
	if(iscarbon(A))
		return
	//For endoparts that aren't limbs, wtf, you will need to overwrite this with your own code for getting the icon
	var/obj/item/bodypart/parent_atom = parent
	if(!istype(parent_atom))
		return
	if(!assembly_overlay)
		assembly_overlay = new()
		assembly_overlay.add_overlay(parent_atom.get_limb_icon())
		assembly_overlay.pixel_x = 0
		assembly_overlay.pixel_y = 0
		assembly_overlay.plane = A.plane
	SEND_SIGNAL(A, COMSIG_ENDO_APPLY_OFFSET, offset_key, assembly_overlay)
	A?.cut_overlay(assembly_overlay)
	A?.add_overlay(assembly_overlay)

/datum/component/endopart/proc/cut_assembly_overlay(atom/A)
	if(!assembly_overlay)
		return
	A?.cut_overlay(assembly_overlay)

///Used to offset assembly overlays to look good on this part.
/datum/component/endopart/proc/apply_offset(datum/source, offset_key, mutable_appearance/MA)
	var/list/offsets = assembly_offsets[offset_key]
	if(!length(offsets))
		return
	MA.pixel_x = offsets[1]
	MA.pixel_y = offsets[2]

///Consume evergy? Most endoparts will just pass this on. Parts like chests implement this
/datum/component/endopart/proc/consume_energy(datum/source, amount)
	SIGNAL_HANDLER

	return SEND_SIGNAL(src, COMSIG_ROBOT_CONSUME_ENERGY, amount)

///Part getter stuff
/datum/component/endopart/proc/list_part(datum/source, type, list/population_list)
	SIGNAL_HANDLER

	SEND_SIGNAL(src, COMSIG_ENDO_LIST_PART, type, population_list)

///Is this part complete
/datum/component/endopart/proc/check_completion()
	var/outcome = ENDO_ASSEMBLY_COMPLETE
	//Check our assemblies
	for(var/datum/endo_assembly/assembly as() in required_assembly)
		var/incomplete = assembly.check_completion()
		if((incomplete & ENDO_ASSEMBLY_INCOMPLETE)) //If a given assembly isn't complete
			outcome &= ENDO_ASSEMBLY_COMPLETE //Remove completion status
			if((incomplete & ENDO_ASSEMBLY_NON_INTEGRAL))
				outcome |= ENDO_ASSEMBLY_NON_INTEGRAL //Add non-integral, if it isn't integral
			outcome |= ENDO_ASSEMBLY_INCOMPLETE //Add unfinished, since it's unfinished
	//If our parent is a bodypart, check if it's fucked
	var/obj/item/bodypart/parent_part = parent
	if(istype(parent_part) && parent_part.bodypart_disabled)
		return (outcome &= ENDO_ASSEMBLY_COMPLETE)
	return outcome

///What we do in the life loop
/datum/component/endopart/proc/life(datum/source, mob/M)
	SIGNAL_HANDLER

	. = FALSE
	//Can't life() if we're lifen't
	if(M.stat == DEAD)
		return
//Energy consumption
	var/mob/living/silicon/new_robot/R = M
	if(!istype(R))
		return
	if(R.consume_energy(ambient_draw))
		. =  TRUE
//Discovery research generation
	var/datum/component/discoverable/robot/discoverable = R.discovery_component
	discoverable?.point_reward += discovery_tick
	discoverable?.general_reward += general_tick

	SEND_SIGNAL(src, COMSIG_ENDO_APPLY_LIFE, M)

///Add hud stuff associated with this part
/datum/component/endopart/proc/apply_hud(datum/source, datum/hud/hud)
	SIGNAL_HANDLER

	SEND_SIGNAL(src, COMSIG_ENDO_APPLY_HUD, hud)

/datum/component/endopart/proc/remove_hud(datum/source, datum/hud/hud)
	SIGNAL_HANDLER

	SEND_SIGNAL(src, COMSIG_ENDO_REMOVE_HUD, hud)

///You'll never guess what this does
/datum/component/endopart/proc/set_emagged(datum/source, new_state)
	SIGNAL_HANDLER

	SEND_SIGNAL(src, COMSIG_ROBOT_SET_EMAGGED, new_state)

///Used for appending data to the borg self monitor
/datum/component/endopart/proc/append_monitor(datum/source, list/data)
	SIGNAL_HANDLER

	SEND_SIGNAL(src, COMSIG_ROBOT_LIST_SELF_MONITOR, data)

/datum/component/endopart/proc/update_icons(datum/source, atom/target)
	SIGNAL_HANDLER

	SEND_SIGNAL(src, COMSIG_ROBOT_UPDATE_ICONS, target)

//generic damage handling for limbs
/datum/component/endopart/proc/apply_damage(datum/source, damage, damagetype, def_zone, blocked, forced, obj/item/I)
	SIGNAL_HANDLER

//Prechecks to see if we can leave early
	var/obj/item/bodypart/BP = parent
	if(!istype(BP))
		return
	if(!def_zone)
		def_zone = check_zone(def_zone)
	if(BP.body_zone != def_zone)
		return
//Otherwise, commit to getting our ass kicked
	var/hit_percent = (100-blocked)/100
//TODO: Damage overlays - Racc
	switch(damagetype)
		if(BRUTE)
			//TODO: - Racc
			//H.damageoverlaytemp = 20
			var/damage_amount = forced ? damage : damage * hit_percent * brutemod
			if(BP.receive_damage(damage_amount, 0))
				return
				//assembled_mob.update_damage_overlays()
		if(BURN)
			//H.damageoverlaytemp = 20
			var/damage_amount = forced ? damage : damage * hit_percent * burnmod
			if(BP.receive_damage(0, damage_amount))
				return
				//H.update_damage_overlays()
//Handle dismemberment, copies a bunch of code from how species handle dismemberment
	var/mob/living/silicon/new_robot/R = assembled_mob
	if(!I?.force || !istype(R))
		return 0
	var/dismemberthreshold = ((BP.max_damage * 2) - BP.get_damage())
	var/attackforce = (((I.w_class - 3) * 5) + ((I.attack_weight - 1) * 14) + ((I.is_sharp()-1) * 20))
	if(I.is_sharp())
		attackforce = max(attackforce, I.force)
	if(attackforce < dismemberthreshold || I.force < 10)
		return
	I.add_mob_blood(assembled_mob)
	INVOKE_ASYNC(R.chassis_component, PROC_REF(remove_part), BP) //If this system gets more advanced, you can figure out how to make this robust
	playsound(get_turf(assembled_mob), I.get_dismember_sound(), 80, 1)
	//This is for balance / common sense, not realism
	var/list/chests = list()
	SEND_SIGNAL(R.chassis, COMSIG_ENDO_LIST_PART, /datum/component/endopart/chest, chests)
	for(var/obj/item/bodypart/chest as anything in chests)
		chest.receive_damage(clamp(BP.brute_dam/2 * chest.body_damage_coeff, 15, 50), clamp(BP.burn_dam/2 * chest.body_damage_coeff, 0, 50))
		//Only apply it to one chest, leave this as a loop in-case we want to do otherwise
		return
