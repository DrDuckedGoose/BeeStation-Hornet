/mob/living/simple_animal/hostile/chupacabra
	name = "chupacabra"
	desc = "Be not afriad, be terrified."
	icon = 'icons/mob/animal.dmi'
	icon_state = "chupacabra"
	icon_living = "chupacabra"
	icon_dead = "chupacabra_dead"
	speed = -1
	maxHealth = 500
	health = 500
	obj_damage = 60
	melee_damage = 25
	attacktext = "bashes"
	speak_emote = list("screeches")
	a_intent = INTENT_HARM
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list(FACTION_HERETIC)
	status_flags = CANPUSH
	minbodytemp = 0
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	gold_core_spawnable = NO_SPAWN
	deathsound = 'sound/voice/hiss6.ogg'
	deathmessage = "lets out a waning guttural screech..."
	chat_color = "#ff0000"

	do_footstep = TRUE
	discovery_points = 2000

/mob/living/simple_animal/hostile/chupacabra/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/waddling)
