/obj/item/plant_disk
	name = "plant disk"
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "disk"
	///Our saved plant data
	var/saved

/obj/item/plant_disk/test
	saved = new /datum/plant_trait/seperated_contents()
