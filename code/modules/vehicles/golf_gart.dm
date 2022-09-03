/obj/vehicle/ridden/golf_cart
	name = "golf cart"
	desc = "A golf cart modified to work in lavaland's extreme conditions."
	icon_state = "pussywagon"
	max_buckled_mobs = 2
	key_type = /obj/item/key/golf_cart

/obj/vehicle/ridden/golf_cart/Initialize(mapload)
	. = ..()
	update_icon()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 7), TEXT_EAST = list(-12, 7), TEXT_WEST = list( 12, 7)))

/obj/item/key/golf_cart
	name = "golf cart key"
	desc = "A license to pick up chicks and retired men."
