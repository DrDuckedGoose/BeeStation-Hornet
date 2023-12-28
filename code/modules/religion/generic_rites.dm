/datum/religion_rites/generic

/datum/religion_rites/generic/New()
	. = ..()
	if(!GLOB?.religious_sect)
		return
	LAZYREMOVE(GLOB.religious_sect.active_rites, src)
	LAZYADD(GLOB.religious_sect.generic_active_rites, src)

/datum/religion_rites/generic/Destroy()
	if(!GLOB?.religious_sect)
		return
	LAZYREMOVE(GLOB.religious_sect.generic_active_rites, src)
	return ..()

/*
	Reload Old Iron
		Takes the global ref to old iron, and reloads it. If the gun already has a bullet, or doesn't exist, the ritual is aborted.
*/

/datum/religion_rites/generic/reload_old_iron
	name = "Reload Old Iron"
	desc = "Reloads Old Iron, with one bullet."
	ritual_length = 10 SECONDS
	favor_cost = 800

/datum/religion_rites/generic/reload_old_iron/can_afford(mob/living/user)
	. = ..()
	if(GLOB.old_iron)
		var/obj/item/gun/ballistic/revolver/old_iron/G = GLOB.old_iron
		if(!G.get_ammo(TRUE, FALSE))
			return TRUE
	return FALSE

/datum/religion_rites/generic/reload_old_iron/invoke_effect(mob/living/user, atom/religious_tool)
	. = ..()
	var/obj/item/gun/ballistic/revolver/old_iron/G = GLOB.old_iron
	for(var/i in G.magazine.stored_ammo)
		qdel(i)
	G.magazine.stored_ammo += new G.magazine.ammo_type(G.magazine)
	G.chamber_round(FALSE)
	to_chat(user, "<span class='notice'>[G] clicks, a new bullet has entered the chamber.</span>")

/*
	Learn new rune
		Adds a alitany component to the ones the chaplain knows
*/

/datum/religion_rites/generic/lean_rune
	name = "Learn New Rune"
	desc = "Learn a new, random, rune."
	ritual_length = 10 SECONDS
	favor_cost = 500

/datum/religion_rites/generic/lean_rune/can_afford(mob/living/user)
	. = ..()
	if(!length(GLOB.chaplain_all_runes - GLOB.chaplain_known_runes))
		to_chat(user, "<span class='warning'>There is nothing new to learn.</span>")
		return FALSE
	return TRUE

/datum/religion_rites/generic/lean_rune/invoke_effect(mob/living/user, atom/religious_tool)
	. = ..()
	var/list/available = GLOB.chaplain_all_runes-GLOB.chaplain_known_runes
	var/datum/litany_component/LC = pick(available)
	GLOB.chaplain_known_runes += LC
	to_chat(user, "<span class='notice'>You feel new knowledge enter your mind, [initial(LC.name)].</span>")
