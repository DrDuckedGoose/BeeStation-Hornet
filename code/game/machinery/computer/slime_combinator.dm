///Maximum amount of parents in a simulation
#define XENOB_MAX_PARENTS 2

///Slime data datum type
/datum/slime_data
	///reference to slime
	var/mob/living/simple_animal/slime_uni/reference
	///base 64 icon
	var/base_icon

/datum/slime_data/New(var/mob/living/simple_animal/slime_uni/ref)
	. = ..()
	if(!ref)
		return
	reference = ref
	///convert reference icon to base 64
	if(!SSslime_species.cached_icons[ref.species_name])
		SSslime_species.cached_icons[ref.species_name] = icon2base64(reference.still_icon)
	base_icon = SSslime_species.cached_icons[ref.species_name]

/datum/slime_data/Destroy(force, ...)
	reference = null
	..()

///Slime mixing sim computer, the shut-the-fuck-up-i-can-name-it-whatever-inator!
/obj/machinery/computer/slime_combinator
	name = "slime combinator"
	desc = "I love the 'puter, it's where all my slimes are."
	///combination of slimes from original parents after simulation
	var/list/slime_combinations = list()
	///list of original parent slimes inserted into simulation
	var/list/slime_parents = list()
	///list of previous parents
	var/list/slime_parents_previous = list()
	///list of all available slimes to mix
	var/list/available_slimes = list()
	///Inserted slime gun
	var/obj/item/slime_gun/inserted_gun
	///Selected child
	var/datum/slime_data/selected_child
	///Current UI tab
	var/tab = "Select-Initial"
	///simulation instability
	var/instability = 0
	///Availability flag, toggled after use
	var/available = TRUE

/obj/machinery/computer/slime_combinator/attackby(obj/item/I, mob/living/user, params) //Accept slime gun / swap out current
	if(istype(I, /obj/item/slime_gun))
		if(tab != "Select-Initial")
			say("Error: cannot swap volume. Please finish task.")
			return
		if(inserted_gun)
			inserted_gun.forceMove(get_turf(src)) //remove old gun if it exists
		I.forceMove(src)
		inserted_gun = I
		update_contents()
	..()

/obj/machinery/computer/slime_combinator/AltClick(mob/user) //drop gun & update UI
	if(inserted_gun && tab == "Select-Initial")
		inserted_gun.forceMove(get_turf(src))
		inserted_gun = null
		update_contents()
	else if(tab != "Select-Initial")
		say("Error: cannot unisert volume. Please finish task.")
	..()

/obj/machinery/computer/slime_combinator/proc/update_contents()
	for(var/datum/slime_data/i as() in available_slimes)
		qdel(i) //delete old list of all slimes
	for(var/datum/slime_data/i as() in slime_parents)
		qdel(i) //delete old list of parents
	slime_parents = list()
	available_slimes = list()
	//Get slimes from gun
	if(inserted_gun)
		for(var/mob/living/simple_animal/slime_uni/S in inserted_gun.contents)
			available_slimes += new /datum/slime_data(S)

	ui_update()

/obj/machinery/computer/slime_combinator/ui_data(mob/user)
	. = list()
	//tab type
	.["tab"] = tab
	//List of all available slimes
	.["all_slimes"] = list()
	if(available_slimes.len)
		for(var/datum/slime_data/D as() in available_slimes)
			var/list/data = list(
				self_ref = REF(D),
				ref = REF(D.reference),
				img = D.base_icon,
				name = D.reference.species_name,
			)
			.["all_slimes"] += list(data)
	//List of litter
	.["litter_slimes"] = list()
	if(slime_combinations.len)
		for(var/datum/slime_data/D as() in slime_combinations)
			var/list/data = list(
				self_ref = REF(D),
				ref = REF(D.reference),
				img = D.base_icon,
				name = D.reference.species_name,
			)
			.["litter_slimes"] += list(data)
	//List of parents
	.["parent_slimes"] = list()
	if(slime_parents.len)
		for(var/datum/slime_data/D as() in slime_parents)
			var/list/data = list(
				self_ref = REF(D),
				ref = REF(D.reference),
				img = D.base_icon,
				name = D.reference.species_name,
			)
			.["parent_slimes"] += list(data)
	//selected child
	.["choosen_slime"] = selected_child
	///availability
	.["availability"] = available

/obj/machinery/computer/slime_combinator/ui_act(action, params)
	. = ..()
	if(. || !available)
		say("Error: simulation still resetting.") //Probably doesn't matter that the other thing could trigger this
		return
	switch(action)
		if("select-slime")
			var/datum/slime_data/S = (locate(params["ref"]) in available_slimes)
			if(!S)
				S = (locate(params["ref"]) in slime_combinations)
			if(S in slime_parents)
				slime_parents -= S
			else
				if(slime_parents.len >= 2)
					slime_parents.Cut(1,1)
				slime_parents += S
			selected_child = slime_parents.len ? slime_parents[1] : null

		if("combine-selected")
			if(slime_parents.len > 1)
				say("Process: combining samples...")
				combine_parents()
				tab = "Promote-Outcomes"
				slime_parents_previous = slime_parents
				slime_parents = list()
				selected_child = null
			else
				say("Error: not enough sample diversity.")

		if("choose-selected")
			if(!inserted_gun)
				say("Error: no inserted buffer.")
				return
			var/mob/living/simple_animal/slime_uni/S = selected_child.reference
			S?.forceMove(inserted_gun)
			qdel(selected_child)
			selected_child = null
			//Kill old children
			for(var/datum/slime_data/SD as() in slime_combinations)
				slime_combinations -= SD
				qdel(SD)
			tab = "Select-Initial"
			slime_parents = list()
			update_contents()
			inserted_gun.change_overlay(S)
			available = FALSE
			addtimer(CALLBACK(src, .proc/reenable), (XENOB_REFRESH_TIME*(instability/XENOB_INSTABILITY_MAX)), TIMER_STOPPABLE)
			instability = 0
	ui_update()

/obj/machinery/computer/slime_combinator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SlimeCombinator")
		ui.open()

///combine parents and make new slimes
/obj/machinery/computer/slime_combinator/proc/combine_parents()
	if(slime_parents.len < 2)
		return FALSE
	//type casting
	var/datum/slime_data/o = slime_parents[1]
	var/datum/slime_data/t = slime_parents[2]
	//parents
	var/mob/living/simple_animal/slime_uni/O = o?.reference
	var/mob/living/simple_animal/slime_uni/T = t?.reference
	//create new slimes
	var/list/new_slimes = list()
	var/litter_size = max(1, (XENOB_MAX_LITTER-(XENOB_MAX_LITTER*(instability/XENOB_INSTABILITY_MAX))))
	for(var/i in 1 to litter_size)
		var/mob/living/simple_animal/slime_uni/S = new(get_turf(src), 
			instability,
			pick(O?.dna.features["texture_path"], T?.dna.features["texture_path"]),
			pick(O?.dna.features["mask_path"], T?.dna.features["mask_path"]),
			pick(O?.dna.features["sub_mask"], T?.dna.features["sub_mask"]),
			pick(O?.dna.features["color_path"], T?.dna.features["color_path"]),
			pick(O?.dna.features["rotation"], T?.dna.features["rotation"]),
			pick(O?.dna.features["direction"], T?.dna.features["direction"]))
		new_slimes += new /datum/slime_data/(S)
		S.forceMove(src)
	//Kill old children
	for(var/datum/slime_data/SD as() in slime_combinations)
		slime_combinations -= SD
		qdel(SD)
	//Load results into children
	slime_combinations = new_slimes
	//iterate instability
	instability += XENOB_INSTABILITY_MOD
	instability = min(XENOB_INSTABILITY_MAX, instability) //Better ways of doing this but, this is easier to read

	ui_update()
	return TRUE

///Simple proc for callbacks, reenable usage
/obj/machinery/computer/slime_combinator/proc/reenable()
	available = TRUE
	ui_update()
