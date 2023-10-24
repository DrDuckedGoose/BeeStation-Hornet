/datum/spooky_event/ghost
	name = "ghost"

/datum/spooky_event/ghost/setup(datum/controller/subsystem/spooky/SS)
	var/area/A = pick_weight(SS?.areas)
	//logging
	log_game("[name]([src]) was created at [world.time], located in [A].")
	//Our unique logic
	var/mob/living/simple_animal/hostile/retaliate/ghost/G = new(A)
	//Pick a random corpse for this ghost to impersonate
	var/mob/living/corpse = pick_weight(SS?.corpses)
	if(corpse)
		G.appearance = corpse.appearance
		G.alpha = 128
		//TODO: make the alpha fade near the bottom with a mask filter - racc

	return TRUE
