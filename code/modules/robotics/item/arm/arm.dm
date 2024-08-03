/obj/item/bodypart/l_arm/robot/endopart

/obj/item/bodypart/l_arm/robot/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/endopart/arm, ENDO_OFFSET_KEY_ARM(1))

/obj/item/bodypart/r_arm/robot/endopart

/obj/item/bodypart/r_arm/robot/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/endopart/arm, ENDO_OFFSET_KEY_ARM(2))
