/datum/emote/brain
	mob_type_allowed_typecache = list(/mob/living/brain)
	mob_type_blacklist_typecache = list()
	emote_type = EMOTE_AUDIBLE

/datum/emote/brain/can_run_emote(mob/user, status_check = TRUE, intentional, params)
	. = ..()
	var/mob/living/brain/B = user
	if(!istype(B) || (!(B.container && istype(B.container, /obj/item/mmi))))
		return FALSE

/datum/emote/brain/alert
	key = "alert"
	message = "lets out a distressed noise."

/datum/emote/brain/flash
	key = "flash"
	message = "blinks their lights."
	emote_type = EMOTE_VISIBLE

/datum/emote/brain/notice
	key = "notice"
	message = "plays a loud tone."
