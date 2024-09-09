/obj/item/bodypart/l_leg/robot/endopart

/obj/item/bodypart/l_leg/robot/endopart/build_endo_component()
	AddComponent(/datum/component/endopart/leg, FALSE, ENDO_OFFSET_KEY_LEG(1))

/obj/item/bodypart/r_leg/robot/endopart

/obj/item/bodypart/r_leg/robot/endopart/build_endo_component()
	AddComponent(/datum/component/endopart/leg, FALSE, ENDO_OFFSET_KEY_LEG(2))

/*
	Tracks
*/

/obj/item/bodypart/l_leg/robot/endopart/track
	icon_state = "robotic_track_l_leg"
	limb_id = "robotic_track"

/obj/item/bodypart/l_leg/robot/endopart/track/build_endo_component()
	AddComponent(/datum/component/endopart/leg/track, FALSE, ENDO_OFFSET_KEY_LEG(1))

/obj/item/bodypart/r_leg/robot/endopart/track
	icon_state = "robotic_track_r_leg"
	limb_id = "robotic_track"

/obj/item/bodypart/r_leg/robot/endopart/track/build_endo_component()
	AddComponent(/datum/component/endopart/leg/track, FALSE, ENDO_OFFSET_KEY_LEG(2))
