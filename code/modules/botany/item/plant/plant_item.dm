/obj/item/plant_item
	name = "plant"
	desc = "plant :)"
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = ""
	flags_1 = IS_ONTOP_1
	///Does this plant item skip it's growth cycle
	var/skip_growth = FALSE

/obj/item/plant_item/Initialize(mapload, _plant_features, _species_id)
	. = ..()
	AddComponent(/datum/component/plant, src, _plant_features, _species_id, skip_growth)

//TODO: Move this to the component / plant feature - Racc
/obj/item/plant_item/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(!istype(I, /obj/item/shovel/spade))
		return
	playsound(src, 'sound/effects/shovel_dig.ogg', 60)
	if(do_after(user, 2.5 SECONDS, src))
		forceMove(I)
		I.vis_contents += src
		RegisterSignal(I, COMSIG_ITEM_AFTERATTACK, PROC_REF(catch_attack))

/obj/item/plant_item/proc/catch_attack(datum/source, atom/target, mob/user, params)
	SIGNAL_HANDLER

	if(target == src)
		return
	var/obj/item/I = source
	var/obj/obj_target = target
	UnregisterSignal(source, COMSIG_ITEM_AFTERATTACK)
	forceMove(target)
	obj_target.vis_contents += src
	I.vis_contents -= src
