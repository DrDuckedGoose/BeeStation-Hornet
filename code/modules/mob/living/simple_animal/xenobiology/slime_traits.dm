/datum/xenobiology_trait
	var/name
	var/desc
	var/atom/owner

//This is practically the same as other components, how can you blame me?
/datum/xenobiology_trait/New(list/raw_args)
	. = ..()
	owner = raw_args?.len ? raw_args[1] : null
	initialize()
  
//This doesn't have a traditional initialize() otherwise
/datum/xenobiology_trait/proc/initialize()
	return

//Used for trait use / function
/datum/xenobiology_trait/proc/activate()
	return

/// === produces a material, amount based on happiness ===
/datum/xenobiology_trait/material
	///produced material
	var/obj/item/stack/material

/datum/xenobiology_trait/material/activate()
	var/amount = 10
	if(istype(owner, /mob/living/simple_animal/slime_uni))
		var/mob/living/simple_animal/slime_uni/S = owner
		amount = 25*(S.happiness/100)
	material = new(get_turf(owner), amount)

/datum/xenobiology_trait/material/bananium
	name = "Bananium Production"
	material = /obj/item/stack/sheet/mineral/bananium

