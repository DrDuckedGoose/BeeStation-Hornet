/datum/component/planter
	///How many available slots do we have for plants
	var/plant_slots = PLANT_BODY_SLOT_SIZE_LARGEST
	///What kind of substrate do we have?
	var/datum/plant_subtrate/substrate
	///How much do we visually offset the plant when planting it
	var/visual_upset = 12
	///Do we allow our substrate to be changed?
	var/allow_substrate_change = TRUE
	///List of plant's old layer
	var/list/recover_layers = list()

/datum/component/planter/Initialize(_upset)
	. = ..()
	visual_upset = _upset || visual_upset
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(catch_attack))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(catch_examine))
	RegisterSignal(parent, COMSIG_ATOM_ENTERED, PROC_REF(catch_entered))
	RegisterSignal(parent, COMSIG_ATOM_EXITED, PROC_REF(catch_exited))

/datum/component/planter/proc/catch_attack(datum/source, obj/item/I, mob/living/attacker, params)
	SIGNAL_HANDLER

//Let people fill trays with reagents by hand
	if(!IS_EDIBLE(I) && !istype(I, /obj/item/reagent_containers))
		return
	var/obj/item/reagent_containers/reagent_source = I
	if(!reagent_source.reagents.total_volume) //It aint got no gas in it
		to_chat(attacker, span_warning("[reagent_source] is empty!"))
		return
	//Transfer reagents
	reagent_source.reagents.trans_to(parent, reagent_source.amount_per_transfer_from_this, transfered_by = attacker)
	to_chat(attacker, span_notice("You add [reagent_source.amount_per_transfer_from_this]u from [reagent_source] to [parent]!"))

/datum/component/planter/proc/catch_examine(datum/source, mob/looker, list/examine_text)
	SIGNAL_HANDLER

	if(substrate)
		examine_text += ("<span class='notice'>[parent] is filled with [substrate.name].\n[substrate.tooltip]</span>")
	else
		examine_text += ("<span class='warning'>[parent] does not contain any substrate!</span>")

/datum/component/planter/proc/catch_entered(datum/source, atom/movable/entering)
	SIGNAL_HANDLER

	recover_layers += list("[REF(entering)]" = entering.layer)
	var/atom/parent_atom = parent
	entering.layer = parent_atom.layer
	//Some extra visual logic to fix little plants
	var/datum/component/plant/plant_component = entering.GetComponent(/datum/component/plant)
	if(!plant_component?.draw_below_water)
		entering.layer += 0.1
	//Add visuals, move the plant upwards to make it look like it's inside us
	entering.pixel_y += visual_upset

/datum/component/planter/proc/catch_exited(datum/source, atom/movable/exiting)
	SIGNAL_HANDLER

	exiting.layer = recover_layers["[REF(exiting)]"] || exiting.layer
	recover_layers -= recover_layers["[REF(exiting)]"]
	exiting.pixel_y -= visual_upset

/datum/component/planter/proc/set_substrate(_substrate)
	if(!allow_substrate_change)
		return
	SEND_SIGNAL(src, COMSIG_PLANTER_UPDATE_SUBSTRATE_SETUP, substrate)
	if(substrate)
		QDEL_NULL(substrate)
	substrate = new _substrate()
	SEND_SIGNAL(src, COMSIG_PLANTER_UPDATE_SUBSTRATE, substrate)
	return substrate
