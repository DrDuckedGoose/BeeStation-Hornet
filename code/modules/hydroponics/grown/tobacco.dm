// Tobacco
/obj/item/food/grown/tobacco
	seed = /obj/item/plant_seeds/preset/tobacco
	name = "tobacco leaves"
	desc = "Dry them out to make some smokes."
	icon_state = "tobacco_leaves"
	filling_color = "#008000"
	distill_reagent = /datum/reagent/consumable/ethanol/creme_de_menthe //Menthol, I guess.

// Space Tobacco
/obj/item/food/grown/tobacco/space
	name = "space tobacco leaves"
	desc = "Dry them out to make some space-smokes."
	icon_state = "stobacco_leaves"
	bite_consumption_mod = 2
	distill_reagent = null
	wine_power = 50
	discovery_points = 300

//Lavaland Tobacco
/obj/item/food/grown/tobacco/lavaland
	seed = /obj/item/seeds/tobacco/lavaland
	name = "lavaland tobacco leaves"
	desc = "Despite being called lavaland tobacco this plant has little in common with regular tobacco."
	icon_state = "ltobacco_leaves"
	distill_reagent = null
	wine_power = 10
	discovery_points = 300
