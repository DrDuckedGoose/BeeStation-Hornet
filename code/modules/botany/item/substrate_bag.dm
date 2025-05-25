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
	var/substrate = = PLANT_SUBSTRATE_DIRT | PLANT_SUBSTRATE_SAND |  PLANT_SUBSTRATE_CLAY | PLANT_SUBSTRATE_DEBRIS
