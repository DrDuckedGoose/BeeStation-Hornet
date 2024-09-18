/obj/item/endopart/chassis/borg
	name = "bipedal chassis"
	desc = "A proprietary chassis for a bipedal robot, made by Faraday LTD."
	endo_component = /datum/component/endopart/chassis/borg

//Tutorial
//TODO: - Racc
/*
	When xenoarch 2.0 gets merged, add a sticky note to this chassis-

	These are pretty expensive, and we can't make our own, not this good.
	If you break it, it's my ass on the line...

	These ones are a little different to the ones they use in training,
	so I'll quickly run through the details for you.
	Pretty basic shit, examine the parts and your HUD should let you
	know what it needs. Try not to forget anything, there's no such
	thing as spare parts...

	Otherwise you should see what else you can make work, you are a
	scientist afterall. I saw someone stick a human arm on one of these
	once, yielded some pretty valuable research too, actually.

	All the best.

	- Markus
*/
/obj/item/endopart/chassis/borg/tutorial

//Transform machine / prebuilt
/obj/item/endopart/chassis/borg/transform_machine
	endo_component = /datum/component/endopart/chassis/borg/transform_machine

//Syndicate
/obj/item/endopart/chassis/borg/syndicate
	endo_component = /datum/component/endopart/chassis/borg/transform_machine

/obj/item/endopart/chassis/borg/syndicate/medical

/obj/item/endopart/chassis/borg/syndicate/saboteur
