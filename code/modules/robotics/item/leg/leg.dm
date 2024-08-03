/obj/item/bodypart/l_leg/robot/endopart

/obj/item/bodypart/l_leg/robot/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/endopart/leg, ENDO_OFFSET_KEY_LEG(1))

/obj/item/bodypart/r_leg/robot/endopart

/obj/item/bodypart/r_leg/robot/endopart/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/endopart/leg, ENDO_OFFSET_KEY_LEG(2))
