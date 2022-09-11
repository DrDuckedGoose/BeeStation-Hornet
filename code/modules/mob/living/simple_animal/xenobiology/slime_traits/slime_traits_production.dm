/// ======= produces a material, amount based on happiness if coming directly from a slime =======
/datum/xenobiology_trait/production/material
	///produced material
	var/obj/item/stack/sheet/material

/datum/xenobiology_trait/production/material/activate()
	var/amount = 10
	if(istype(owner, /mob/living/simple_animal/slime_uni))
		var/mob/living/simple_animal/slime_uni/S = owner
		amount = 25*(S.happiness/100)
	new material(get_turf(owner), amount)

// === Bananium production ===
/datum/xenobiology_trait/production/material/bananium
	name = "Bananium Production"
	desc = "Deposits of particularly funny jokes build inside the subject, and calcify when activated."
	material = /obj/item/stack/sheet/mineral/bananium
	weight = 25

// === Plasma production ===
/datum/xenobiology_trait/production/material/plasma
	name = "Plasma Production"
	desc = "Deposits of plasma build inside the subject, and calcify when activated."
	possible_targets = list(/datum/reagent/blood)
	material = /obj/item/stack/sheet/mineral/plasma
