/*
	Stuff like chassis will inherit from this, since they can't inherit from bodyparts and other stuff
*/
/obj/item/endopart
	icon = 'icons/obj/robotics/endo.dmi'
	icon_state = ""
	///What endopart component we rocking with?
	var/endo_component

/obj/item/endopart/ComponentInitialize()
	. = ..()
	if(endo_component)
		AddComponent(endo_component)
