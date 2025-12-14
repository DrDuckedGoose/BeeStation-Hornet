//Galaxy Thistle
/obj/item/food/grown/galaxythistle
	seed = /obj/item/plant_seeds/preset/galaxythistle
	name = "galaxythistle flower head"
	desc = "This spiny cluster of florets reminds you of the highlands."
	icon_state = "galaxythistle"
	filling_color = "#1E7549"
	bite_consumption_mod = 2
	foodtypes = VEGETABLES
	wine_power = 35
	tastes = list("thistle" = 2, "artichoke" = 1)

// Cabbage
/obj/item/food/grown/cabbage
	seed = /obj/item/plant_seeds/preset/cabbage
	name = "cabbage"
	desc = "Ewwwwwwwwww. Cabbage."
	icon_state = "cabbage"
	filling_color = "#90EE90"
	foodtypes = VEGETABLES
	wine_power = 20

// Sugarcane
/obj/item/food/grown/sugarcane
	seed = /obj/item/plant_seeds/preset/sugarcane
	name = "sugarcane"
	desc = "Sickly sweet."
	icon_state = "sugarcane"
	filling_color = "#FFD700"
	bite_consumption_mod = 2
	foodtypes = VEGETABLES | SUGAR
	distill_reagent = /datum/reagent/consumable/ethanol/rum

// Gatfruit
/obj/item/food/grown/shell/gatfruit
	seed = /obj/item/plant_seeds/preset/gat
	name = "gatfruit"
	desc = "It smells like burning."
	icon_state = "gatfruit"
	trash_type = /obj/item/gun/ballistic/revolver/detective/random
	bite_consumption_mod = 2
	foodtypes = FRUIT
	tastes = list("gunpowder" = 1)
	wine_power = 90 //It burns going down, too.

//Cherry Bombs
/obj/item/food/grown/cherry_bomb
	name = "cherry bombs"
	desc = "You think you can hear the hissing of a tiny fuse."
	icon_state = "cherry_bomb"
	filling_color = rgb(20, 20, 20)
	seed = /obj/item/plant_seeds/preset/cherry_bomb
	bite_consumption_mod = 3
	max_volume = 125 //Gives enough room for the black powder at max potency
	max_integrity = 40
	wine_power = 80
	discovery_points = 300

/*
//TODO: rip this apart and implement into traits, same with lemon IED - Racc
/obj/item/food/grown/cherry_bomb/attack_self(mob/living/user)
	user.visible_message(span_warning("[user] plucks the stem from [src]!"), span_userdanger("You pluck the stem from [src], which begins to hiss loudly!"))
	log_bomber(user, "primed a", src, "for detonation")
	prime()

/obj/item/food/grown/cherry_bomb/deconstruct(disassembled = TRUE)
	if(!disassembled)
		prime()
	if(!QDELETED(src))
		qdel(src)

/obj/item/food/grown/cherry_bomb/ex_act(severity)
	qdel(src) //Ensuring that it's deleted by its own explosion. Also prevents mass chain reaction with piles of cherry bombs

/obj/item/food/grown/cherry_bomb/proc/prime(mob/living/lanced_by)
	icon_state = "cherry_bomb_lit"
	playsound(src, 'sound/effects/fuse.ogg', 30, 0)
	reagents.chem_temp = 1000 //Sets off the black powder
	reagents.handle_reactions()
*/
