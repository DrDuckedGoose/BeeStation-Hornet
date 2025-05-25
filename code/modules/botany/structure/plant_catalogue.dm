/obj/machinery/computer/plant_catalogue
	name = "electronic plant catalogue"
	desc = "A catalogue console for plant seed listings.\n\
	<span class='notice'>Scan plants, with the discovery scanner, to unlock more seeds!</span>"
	icon_screen = "xenoartifact_console" //TODO: - Racc
	icon_keyboard = "rd_key" //TODO: - Racc
	//circuit = /obj/item/circuitboard/computer/xenoarchaeology_console //TODO: - Racc

//TODO: make a UI for this - Racc
//TODO: UI should show every tier of seeds, available or not - Racc
/obj/machinery/computer/plant_catalogue/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	say("[length(SSbotany.discovered_species)] plants scanned!")
	//TODO: show available seeds - Racc
