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
	var/list/assembly_offsets = list(ENDO_OFFSET_KEY_ARM(1) = list(7, -1), ENDO_OFFSET_KEY_ARM(2) = list(-7, -1),
	ENDO_OFFSET_KEY_LEG(1) = list(2, -14), ENDO_OFFSET_KEY_LEG(2) = list(-2, -14), ENDO_OFFSET_KEY_HEAD(1) = list(0, 7),
	ENDO_OFFSET_KEY_CHEST(1) = list(0, 0))

/datum/component/endopart/New(list/raw_args)
	. = ..()
	if(!parent)
		return
	//Build our required assembly
	var/list/compiled_assembly = list()
	for(var/datum/endo_assembly/recipe as() in required_assembly)
		compiled_assembly += new recipe(src)
	required_assembly = compiled_assembly
	//Setup our signals
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(attach_part))
	RegisterSignal(parent, COMSIG_ENDO_ATTACHED, PROC_REF(attach_to))
	RegisterSignal(parent, COMSIG_ENDO_REMOVED, PROC_REF(remove_from))

	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER), PROC_REF(catch_screwdriver))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(catch_examine))

	RegisterSignal(parent, COMSIG_ENDO_APPLY_OFFSET, PROC_REF(apply_offset))
	RegisterSignal(parent, COMSIG_ENDO_LIST_PART, PROC_REF(poll_part))
	RegisterSignal(parent, COMSIG_ENDO_APPLY_LIFE, PROC_REF(poll_life))
	RegisterSignal(parent, COMSIG_ENDO_APPLY_HUD, PROC_REF(poll_hud))

	RegisterSignal(parent, COMSIG_BODYPART_ATTACHED, PROC_REF(apply_assembly))

	RegisterSignal(parent, COMSIG_ENDO_CONSUME_ENERGY, PROC_REF(consume_energy))

///Can something be attached to us
/datum/component/endopart/proc/can_attach(obj/item/I)
	//Check if one of our assembly datums can use this item
	var/can_attach
	can_attach = can_attach || SEND_SIGNAL(src, COMSIG_ENDO_ASSEMBLY_POLL_PART, I)
	return can_attach

///Can something interact with us
/datum/component/endopart/proc/can_interact(obj/item/I)
	var/can_interact
	can_interact = can_interact || SEND_SIGNAL(src, COMSIG_ENDO_ASSEMBLY_POLL_INTERACTION, I)
	return can_interact

///Attach a part to THIS part
/datum/component/endopart/proc/attach_part(datum/source, obj/item/I, mob/living/L, params)
	SIGNAL_HANDLER

	//handle attaching parts
	if(can_attach(I))
		I.forceMove(parent)
		to_chat(L, "<span class='notice'>You attach [I] to [parent].</span>")
		current_assembly += I
		//Let the part we're adding know it's been connected to use
		SEND_SIGNAL(I, COMSIG_ENDO_ATTACHED, parent)
		//Let our assembly datums know we're adding a part to ourselves
		SEND_SIGNAL(src, COMSIG_ENDO_ASSEMBLY_ADD, I, L)
		//TODO: Sounds and effects - Racc
	//Handle item interactions
	if(can_interact(I))
		SEND_SIGNAL(src, COMSIG_ENDO_ASSEMBLY_INTERACT, I, L)
		//TODO: Sounds and effects - Racc
	//If we're already assembled we'll need to reassemble to apply the new changes
	if(assembled_mob) //TODO: This gets called even if the part dont fit, make sure that isn't a problem - Racc
		SEND_SIGNAL(parent, COMSIG_ENDO_UNASSEMBLE, assembled_mob)
		SEND_SIGNAL(parent, COMSIG_ENDO_ASSEMBLE, assembled_mob)

///Remove a part from THIS part
/datum/component/endopart/proc/remove_part(obj/item/I, mob/living/L, params)
	if(!(I in current_assembly))
		return
	//Undo any assembly changes, hopefully with the part we're removing
	if(assembled_mob)
		SEND_SIGNAL(parent, COMSIG_ENDO_UNASSEMBLE, assembled_mob)
	to_chat(L, "<span class='notice'>You remove [I] from [parent].</span>")
	current_assembly -= I
	I.forceMove(get_turf(L))
	L.put_in_hands(I)
	//Let the part we're removing know it's no-longer connected to us
	SEND_SIGNAL(I, COMSIG_ENDO_REMOVED, parent)
	//Let our assembly datums know we removed a part
	SEND_SIGNAL(src, COMSIG_ENDO_ASSEMBLY_REMOVE, I)
	//Redo the assembly changes, now without the removed part
	if(assembled_mob)
		SEND_SIGNAL(parent, COMSIG_ENDO_ASSEMBLE, assembled_mob)

///Attach THIS part to
/datum/component/endopart/proc/attach_to(datum/source, obj/item/I)
	SIGNAL_HANDLER

	build_assembly_overlay(I)
	RegisterSignal(I, COMSIG_ENDO_ASSEMBLE, PROC_REF(apply_assembly))
	RegisterSignal(I, COMSIG_ENDO_UNASSEMBLE, PROC_REF(remove_assembly))
	//Co-op stuff
	var/datum/component/endopart/E = I.GetComponent(/datum/component/endopart)
	RegisterSignal(E, COMSIG_ENDO_LIST_PART, PROC_REF(poll_part))
	RegisterSignal(E, COMSIG_ENDO_APPLY_LIFE, PROC_REF(poll_life))
	RegisterSignal(E, COMSIG_ENDO_APPLY_HUD, PROC_REF(poll_hud))
	//TODO: Sounds and effects - Racc

/datum/component/endopart/proc/remove_from(datum/source, obj/item/I)
	SIGNAL_HANDLER

	cut_assembly_overlay(I)
	UnregisterSignal(I, COMSIG_ENDO_ASSEMBLE)
	UnregisterSignal(I, COMSIG_ENDO_UNASSEMBLE)
	var/datum/component/endopart/E = I.GetComponent(/datum/component/endopart)
	UnregisterSignal(E, COMSIG_ENDO_LIST_PART)
	UnregisterSignal(E, COMSIG_ENDO_APPLY_LIFE)
	UnregisterSignal(E, COMSIG_ENDO_APPLY_HUD)

///Apply our special and cool effects when Mr. Roboto is assembled
/datum/component/endopart/proc/apply_assembly(datum/source, mob/target)
	SIGNAL_HANDLER

	assembled_mob = target
	build_assembly_overlay(target)
	SEND_SIGNAL(parent, COMSIG_ENDO_ASSEMBLE, target)
	return

///Undo whatever awful shit we did
/datum/component/endopart/proc/remove_assembly(datum/source, mob/target)
	SIGNAL_HANDLER

	assembled_mob = null
	cut_assembly_overlay(target)
	SEND_SIGNAL(parent, COMSIG_ENDO_UNASSEMBLE, target)
	return

///Handles screwdriver interaction, for removing parts
/datum/component/endopart/proc/catch_screwdriver(datum/source, mob/living/user, obj/item/I, list/recipes)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(screwdriver_async), user, I, recipes)
	return TRUE

/datum/component/endopart/proc/screwdriver_async(mob/living/L, obj/item/I, list/recipes)
	if(!length(current_assembly))
		return
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
	//TODO: Only people with diagostic huds should see this - Racc
	//TODO: Make a special visual for this, I don't really like the radial menu - Racc
	var/list/choices = list()
	for(var/datum/endo_assembly/assembly as() in required_assembly)
		if(assembly.check_completion() & ENDO_ASSEMBLY_COMPLETE)
			continue
		var/list/hint_data = assembly.get_recipe_hint()
		choices += list(hint_data["name"] = hint_data["image"])
	if(!length(choices))
		return
	show_radial_menu(M, parent, choices, require_near = FALSE, tooltips = TRUE)

/datum/component/endopart/proc/build_assembly_overlay(atom/A)
	var/atom/parent_atom = parent
	if(!parent_atom)
		return
	if(!assembly_overlay)
		assembly_overlay = new()
		assembly_overlay.appearance = parent_atom.appearance
		assembly_overlay.pixel_x = 0
		assembly_overlay.pixel_y = 0
		assembly_overlay.layer = A.layer
	//TODO: These are broken, they don't change direction - Racc
	SEND_SIGNAL(A, COMSIG_ENDO_APPLY_OFFSET, offset_key, assembly_overlay)
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

	return SEND_SIGNAL(src, COMSIG_ENDO_CONSUME_ENERGY, amount)

///TODO: Descript this - Racc
/datum/component/endopart/proc/poll_part(datum/source, type, list/population_list)
	SIGNAL_HANDLER

	SEND_SIGNAL(src, COMSIG_ENDO_LIST_PART, type, population_list)

///TODO: Descript this - Racc
/datum/component/endopart/proc/check_completion()
	var/outcome = ENDO_ASSEMBLY_COMPLETE
	for(var/datum/endo_assembly/assembly as() in required_assembly)
		var/incomplete = assembly.check_completion()
		if((incomplete & ENDO_ASSEMBLY_NON_INTEGRAL))
			outcome |= ENDO_ASSEMBLY_NON_INTEGRAL
		if((incomplete & ENDO_ASSEMBLY_INCOMPLETE))
			if(!(incomplete & ENDO_ASSEMBLY_NON_INTEGRAL))
				var/atom/movable/A = parent
				A.say("ME! [A]")
				outcome &= ENDO_ASSEMBLY_COMPLETE
			outcome |= ENDO_ASSEMBLY_INCOMPLETE
	return outcome

///TODO: Descript this - Racc
/datum/component/endopart/proc/poll_life(datum/source, mob/M)
	SIGNAL_HANDLER

	SEND_SIGNAL(src, COMSIG_ENDO_APPLY_LIFE, M)

///TODO: Descript this - Racc
/datum/component/endopart/proc/poll_hud(datum/source, datum/hud/hud)
	SIGNAL_HANDLER

	SEND_SIGNAL(src, COMSIG_ENDO_APPLY_HUD, hud)
