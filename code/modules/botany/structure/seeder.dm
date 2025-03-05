/obj/machinery/seeder
	name = "industrial seeder"
	desc = "A large set of jaws set in a compact frame.\n<span class='notice'>Turns 'fruit' into seed</span>"
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "seeder"
	///Upper amount of seeds we can make
	var/seed_amount = 3

/obj/machinery/seeder/attackby(obj/item/C, mob/user)
	. = ..()
	var/list/genes = list()
	SEND_SIGNAL(C, COMSIG_PLANT_GET_GENES, genes)
	if(!length(genes))
		return
	for(var/index in 1 to seed_amount)
		var/obj/item/plant_seeds/seed = new(get_turf(src), genes)
		to_chat(user, "<span>[seed] created!</span>")
	qdel(C)
