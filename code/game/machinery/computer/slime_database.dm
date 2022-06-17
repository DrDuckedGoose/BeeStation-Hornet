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
	if(ref)
		return
	reference = ref
	///convert reference icon to base 64
	base_icon = icon2base64(reference.icon)

/datum/slime_data/Destroy(force, ...)
	reference = null
	..()

///Slime mixing sim computer
/obj/machinery/computer/slime_database
	name = "slime generative simulator"
	desc = "I love the 'puter, it's where all my slimes are."
	///combination of slimes from original parents from simulation
	var/list/slime_combinations = list()
	///list of original parent slimes inserted into simulation
	var/list/slime_parents = list()
	///list of all available slimes to mix
	var/list/available_slimes = list()
	///Inserted slime gun
	var/obj/item/slime_gun/inserted_gun

/obj/machinery/computer/slime_database/attackby(obj/item/I, mob/living/user, params) //Accept slime gun / swap out current
	if(istype(I, /obj/item/slime_gun))
		if(inserted_gun)
			inserted_gun.forceMove(get_turf(src)) //remove old gun if it exists
			for(var/datum/slime_data/i as() in available_slimes)
				qdel(i) //delete old list of all slimes
			for(var/datum/slime_data/i as() in slime_parents)
				qdel(i) //delete old list of parents
		I.forceMove(src)
		inserted_gun = I
		//Get slimes from gun
		for(var/mob/living/simple_animal/slime_uni/S in I.contents)
			available_slimes += new /datum/slime_data(S)
			if(!slime_parents.len >= XENOB_MAX_PARENTS)
				slime_parents += available_slimes[available_slimes.len] //add to parents if we have none, we can change them later
	..()

/obj/machinery/computer/slime_database/AltClick(mob/user) //drop gun & update UI
	if(inserted_gun)
		inserted_gun.forceMove(get_turf(src))
	..()

/obj/machinery/computer/slime_database/ui_data(mob/user)
	. = list()
	.["all_slimes"] = list()
	if(available_slimes.len)
		for(var/datum/slime_data/D as() in available_slimes)
			var/list/data = list(
				ref = D.reference,
				img = D.base_icon
			)
			.["all_slimes"] += list(data)

///combine parents and make new slimes
/obj/machinery/computer/slime_database/proc/combine_parents()
	if(slime_parents.len < 2)
		return
	for(var/i in pick(XENOB_MIN_LITTER, XENOB_MAX_LITTER))
		var/mob/living/simple_animal/slime_uni/O = slime_parents[1]
		var/mob/living/simple_animal/slime_uni/T = slime_parents[2]
		var/mob/living/simple_animal/slime_uni/S = new(get_turf(src), pick(O, T), pick(O?.dna.features["texture_path"], T?.dna.features["texture_path"]),
		pick(O?.dna.features["mask_path"], T?.dna.features["mask_path"]),
		pick(O?.dna.features["sub_mask"], T?.dna.features["sub_mask"]),
		pick(O?.dna.features["color_path"], T?.dna.features["color_path"]),
		pick(O?.dna.features["rotation"], T?.dna.features["rotation"]),
		pick(O?.dna.features["direction"], T?.dna.features["direction"]))
		slime_combinations += S
