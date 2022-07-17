/datum/xenobiology_trait
	var/name
	var/desc
	var/mob/living/simple_animal/slime_uni/owner

/datum/xenobiology_trait/New(list/raw_args)
	. = ..()
	owner = raw_args[1]
	if(!istype(owner))
		qdel(src)
		return
	initialize() //forgive me
  
//This doesn't have a traditional initialize() otherwise
/datum/xenobiology_trait/proc/initialize()
	return

//Used for trait use
/datum/xenobiology_trait/proc/activate()
	return

/// === produces a material, amount based on happiness ===
/datum/xenobiology_trait/material
	///produced material
	var/obj/item/stack/material

/datum/xenobiology_trait/material/activate()
	material = new(get_turf(owner), 25*(owner.happiness/100))

/datum/xenobiology_trait/material/bananium
	name = "Bananium Production"
	material = /obj/item/stack/sheet/mineral/bananium

