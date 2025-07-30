/obj/item/plant_item
	name = "plant"
	desc = "plant :)"
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = ""
	flags_1 = IS_ONTOP_1
	appearance_flags = TILE_BOUND | LONG_GLIDE | KEEP_APART | KEEP_TOGETHER
	///Does this plant item skip it's growth cycle
	var/skip_growth = FALSE

/obj/item/plant_item/Initialize(mapload, _plant_features, _species_id)
	. = ..()
	AddComponent(/datum/component/plant, src, _plant_features, _species_id, skip_growth)

/obj/item/plant_item/attack_hand(mob/user, modifiers)
	. = ..()
	return FALSE //This item can't be picked up, only with a spade
