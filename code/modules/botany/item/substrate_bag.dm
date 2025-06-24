/*
	Use this to set the substrate of a tray
	Don't worry about putting a limit on how many times we can use this, that's silly.
	Just use it to swap the substrate of a tray that isn't currently growing a plant
*/

/obj/item/substrate_bag
	name = "substrate bag"
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "seeds"
	///What substrate does this bag contain
	var/substrate = /datum/plant_subtrate

/obj/item/substrate_bag/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/obj/machinery/plumbing/tank/plant_tray/tray = target
	if(!istype(tray))
		return
	if(!do_after(user, 2.3 SECONDS, target))
		return
	//TODO: SFX - Racc
	to_chat(user, "<span class='notice'>You fill [target] from [src]</span>")
	tray.set_substrate(substrate)

/*
	Generic presets for botany
*/

/obj/item/substrate_bag/dirt
	name = "dirt substrate bag"
	substrate = /datum/plant_subtrate/dirt

/obj/item/substrate_bag/clay
	name = "clay substrate bag"
	substrate = /datum/plant_subtrate/clay

/obj/item/substrate_bag/sand
	name = "sand substrate bag"
	substrate = /datum/plant_subtrate/sand

/obj/item/substrate_bag/debris
	name = "debris substrate bag"
	substrate = /datum/plant_subtrate/debris
