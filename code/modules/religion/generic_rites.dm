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
		Takes the global ref to old iron, and reloads it. If the gun already has a bullet, or doesn't exist, the ritua is aborted.
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
