//Bot chassis
/datum/design/bot_chassis
	materials = list(/datum/material/iron=5000)
	construction_time = 500
	build_type = MECHFAB
	//category = list("Bot") //We don't actually want this abstract to show up

/datum/design/bot_chassis/cleanbot
	name = "Cleanbot Chassis"
	id = "cleanbot_chassis"
	build_path = /obj/item/endopart/chassis/cleanbot
	category = list("Bot")

/datum/design/bot_chassis/medibot
	name = "Medibot Chassis"
	id = "medibot_chassis"
	build_path = /obj/item/endopart/chassis/medibot
	category = list("Bot")
