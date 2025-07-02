/obj/machinery/plumbing/tank/plant_tray/pot
	name = "plant pot"

/*
	Variant that contains a random plant
	Used for hallway plants
*/
/obj/machinery/plumbing/tank/plant_tray/pot/random

/obj/machinery/plumbing/tank/plant_tray/pot/random/Initialize(mapload)
	. = ..()
	var/obj/item/plant_item/random/random_plant = new(get_turf(src))
	random_plant.forceMove(src) //forceMove instead of creating it inside to proc Entered()
	vis_contents += random_plant
