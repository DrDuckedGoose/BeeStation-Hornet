/datum/spooky_event/ghost
	name = "ghost"

/datum/spooky_event/ghost/setup(datum/controller/subsystem/spooky/SS)
	var/area/A = pick_weight(SS?.areas)
	//logging
	log_game("[name]([src]) was created at [world.time], located in [A].")
	//Our unique logic
	//Pick a random corpse for this ghost to impersonate
	var/mob/living/corpse = pick_weight(SS?.corpses)
	if(corpse)
		var/mob/living/simple_animal/hostile/retaliate/ghost/G = new(pick(A.contained_turfs))
		G.appearance = corpse.appearance
		G.alpha = 128
		G.name = "ghost of [corpse.name]" //TODO: Consider letting only the chap and curator read the names - Racc
		//Corpses are typically on their sides, so we need to make them upright
		var/matrix/n_transform = G.transform
		n_transform.Turn(-90)
		G.transform = n_transform
		//Build the fade effect / filter
		var/icon/I = icon('icons/mob/mob.dmi', "ghost_fade")
		G.add_filter("fade", 1, alpha_mask_filter(icon = I))
		//Inform ghosts
		notify_ghosts("The [G.name] has appeared in [A]!", source = G)
		return TRUE
	return FALSE
