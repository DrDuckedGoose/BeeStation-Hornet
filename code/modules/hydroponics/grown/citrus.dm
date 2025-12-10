// Citrus - base type
/obj/item/food/grown/citrus
	seed = /obj/item/plant_seeds/preset/lime
	name = "citrus"
	desc = "It's so sour, your face will twist."
	icon_state = "lime"
	foodtypes = FRUIT
	wine_power = 30

// Lime
/obj/item/food/grown/citrus/lime
	seed = /obj/item/plant_seeds/preset/lime
	name = "lime"
	desc = "It's so sour, your face will twist."
	icon_state = "lime"
	juice_typepath = /datum/reagent/consumable/limejuice

// Orange
/obj/item/food/grown/citrus/orange
	seed = /obj/item/plant_seeds/preset/orange
	name = "orange"
	desc = "It's a tangy fruit."
	icon_state = "orange"
	juice_typepath = /datum/reagent/consumable/orangejuice
	distill_reagent = /datum/reagent/consumable/ethanol/triple_sec

// Lemon
/obj/item/food/grown/citrus/lemon
	seed = /obj/item/plant_seeds/preset/lemon
	name = "lemon"
	desc = "When life gives you lemons, make lemonade."
	icon_state = "lemon"
	juice_typepath = /datum/reagent/consumable/lemonjuice

// Combustible lemon
/obj/item/food/grown/firelemon
	name = "Combustible Lemon"
	desc = "Made for burning houses down."
	icon_state = "firelemon"
	foodtypes = FRUIT
	wine_power = 70
	discovery_points = 300

//TODO: Convert to traits - Racc
/obj/item/food/grown/firelemon/attack_self(mob/living/user)
	user.visible_message(span_warning("[user] primes [src]!"), span_userdanger("You prime [src]!"))
	log_bomber(user, "primed a", src, "for detonation")
	icon_state = "firelemon_active"
	playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
	addtimer(CALLBACK(src, PROC_REF(prime)), rand(10, 60))

/obj/item/food/grown/firelemon/burn()
	prime()
	..()

/obj/item/food/grown/firelemon/proc/update_mob()
	if(ismob(loc))
		var/mob/M = loc
		M.dropItemToGround(src)

/obj/item/food/grown/firelemon/ex_act(severity)
	qdel(src) //Ensuring that it's deleted by its own explosion

/obj/item/food/grown/firelemon/proc/prime(mob/living/lanced_by)
	var/potency = get_fruit_trait_power(src) * 25
	switch(potency) //Combustible lemons are alot like IEDs, lots of flame, very little bang.
		if(0 to 25)
			update_mob()
			explosion(src.loc,-1,-1,2, flame_range = 1)
			qdel(src)
		if(26 to 50)
			update_mob()
			explosion(src.loc,-1,-1,2, flame_range = 3)
			qdel(src)
		else
			update_mob()
			explosion(src.loc,-1,-1,2, flame_range = 5)
			qdel(src)

//3D Orange
/obj/item/food/grown/citrus/orange_3d
	name = "extradimensional orange"
	desc = "You can hardly wrap your head around this thing."
	icon_state = "orang"
	bite_consumption_mod = 2
	juice_typepath = /datum/reagent/consumable/orangejuice
	distill_reagent = /datum/reagent/consumable/ethanol/triple_sec
	tastes = list("polygons" = 1, "oranges" = 1)
	discovery_points = 300

/obj/item/food/grown/citrus/orange_3d/pickup(mob/user)
	..()
	icon_state = "orange"

/obj/item/food/grown/citrus/orange_3d/dropped(mob/user)
	..()
	icon_state = "orang"
