//This is pretty much just a game piece for the Curator's curios
/obj/structure/witch_table
	name = "witching table"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "witch_table"
	desc = "A station for wicked deeds."
	density = TRUE
	anchored = TRUE
	resistance_flags = ACID_PROOF
	armor = list(MELEE = 30,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 0, RAD = 0, FIRE = 70, ACID = 100, STAMINA = 0)
	max_integrity = 200
	integrity_failure = 25
