/obj/item/bodypart/head/simian
	icon = 'icons/mob/species/simian/bodyparts.dmi'
	f_color_icon = 'icons/mob/species/simian/bodyparts.dmi'
	limb_id = SPECIES_SIMIAN
	is_dimorphic = FALSE
	should_draw_greyscale = TRUE
	uses_mutcolor = TRUE

/obj/item/bodypart/chest/simian
	icon = 'icons/mob/species/simian/bodyparts.dmi'
	f_color_icon = 'icons/mob/species/simian/bodyparts.dmi'
	limb_id = SPECIES_SIMIAN
	should_draw_greyscale = TRUE
	uses_mutcolor = TRUE

/obj/item/bodypart/l_arm/simian
	icon = 'icons/mob/species/simian/bodyparts.dmi'
	f_color_icon = 'icons/mob/species/simian/bodyparts.dmi'
	limb_id = SPECIES_SIMIAN
	should_draw_greyscale = TRUE
	uses_mutcolor = TRUE

/obj/item/bodypart/r_arm/simian
	icon = 'icons/mob/species/simian/bodyparts.dmi'
	f_color_icon = 'icons/mob/species/simian/bodyparts.dmi'
	limb_id = SPECIES_SIMIAN
	should_draw_greyscale = TRUE
	uses_mutcolor = TRUE

//Our weird hand legs
/obj/item/bodypart/l_leg/simian
	icon = 'icons/mob/species/simian/bodyparts.dmi'
	f_color_icon = 'icons/mob/species/simian/bodyparts.dmi'
	limb_id = SPECIES_SIMIAN
	should_draw_greyscale = TRUE
	uses_mutcolor = TRUE
	held_index = 3
	held_offset = list("x" = 0, "y" = -4)

/obj/item/bodypart/l_leg/simian/attach_limb(mob/living/carbon/C, special, is_creating)
	. = ..()
	C.hand_bodyparts.len += 1
	C.held_items.len += 1

/obj/item/bodypart/l_leg/simian/drop_limb(special)
	owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	owner.hand_bodyparts.len -= 1
	owner.held_items.len -= 1
	return ..()

/obj/item/bodypart/l_leg/simian/set_disabled(new_disabled)
	. = ..()
	if(!.)
		return
	if(disabled == BODYPART_DISABLED_DAMAGE)
		if(owner.stat < UNCONSCIOUS)
			owner.emote("scream")
		if(owner.stat < DEAD)
			to_chat(owner, "<span class='userdanger'>Your [name] is too damaged to function!</span>")
		if(held_index)
			owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	else if(disabled == BODYPART_DISABLED_PARALYSIS)
		if(owner.stat < DEAD)
			to_chat(owner, "<span class='userdanger'>You can't feel your [name]!</span>")
			if(held_index)
				owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	if(owner.hud_used)
		var/atom/movable/screen/inventory/hand/L = owner.hud_used.hand_slots["[held_index]"]
		if(L)
			L.update_icon()

/obj/item/bodypart/r_leg/simian
	icon = 'icons/mob/species/simian/bodyparts.dmi'
	f_color_icon = 'icons/mob/species/simian/bodyparts.dmi'
	limb_id = SPECIES_SIMIAN
	should_draw_greyscale = TRUE
	uses_mutcolor = TRUE
	held_index = 4
	held_offset = list("x" = 0, "y" = -4)

/obj/item/bodypart/r_leg/simian/attach_limb(mob/living/carbon/C, special, is_creating)
	. = ..()
	C.hand_bodyparts.len += 1
	C.held_items.len += 1

/obj/item/bodypart/r_leg/simian/drop_limb(special)
	owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	owner.hand_bodyparts.len -= 1
	owner.held_items.len -= 1
	return ..()

/obj/item/bodypart/r_leg/simian/set_disabled(new_disabled)
	. = ..()
	if(!.)
		return
	if(disabled == BODYPART_DISABLED_DAMAGE)
		if(owner.stat < UNCONSCIOUS)
			owner.emote("scream")
		if(owner.stat < DEAD)
			to_chat(owner, "<span class='userdanger'>Your [name] is too damaged to function!</span>")
		if(held_index)
			owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	else if(disabled == BODYPART_DISABLED_PARALYSIS)
		if(owner.stat < DEAD)
			to_chat(owner, "<span class='userdanger'>You can't feel your [name]!</span>")
			if(held_index)
				owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	if(owner.hud_used)
		var/atom/movable/screen/inventory/hand/L = owner.hud_used.hand_slots["[held_index]"]
		if(L)
			L.update_icon()
