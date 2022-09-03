/mob/living/simple_animal/hostile/cow
	name = "cow"
	desc = "Something about it is suspicious."
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_dead"
	icon_gib = "cow_gib"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak = list("RAWR!","Rawr!","GRR!","Growl!")
	speak = list("moo?","moo","MOOOOOO")
	speak_emote = list("moos","moos hauntingly")
	emote_hear = list("brays.")
	emote_see = list("shakes its head.")
	emote_taunt = list("stares hauntingly", "grazes")
	speak_chance = 1
	taunt_chance = 25
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 6)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 60
	health = 60

	obj_damage = 60
	melee_damage = 25
	attacktext = "bites"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	friendly = "cow pets"
	chat_color = "#ff0000"

	faction = list("telescience_faction")
	gold_core_spawnable = HOSTILE_SPAWN

	do_footstep = TRUE
