/obj/machinery/plant_tray
	name = "plant tray"
	desc = "A fifth generation space compatible botanical growing tray."
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "tray"

/obj/machinery/plant_tray/Initialize(mapload)
	. = ..()
	create_reagents(500)
