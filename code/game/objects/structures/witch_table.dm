/obj/structure/table/witch_table
	name = "witching table"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "witch_table"
	base_icon_state = "witch_table"
	smoothing_flags = null
	smoothing_groups = list()
	canSmoothWith = list()
	desc = "A station for wicked deeds."
	density = TRUE
	anchored = TRUE
	resistance_flags = ACID_PROOF
	armor = list(MELEE = 30,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 0, RAD = 0, FIRE = 70, ACID = 100, STAMINA = 0)
	max_integrity = 200
	integrity_failure = 25

/obj/structure/table/witch_table/Initialize(mapload, _buildstack)
	. = ..()

/obj/structure/table/witch_table/attack_hand(mob/living/user)
	. = ..()
	//TODO: Lord knows this is probably bad - Racc
	//Get the recipes that work
	var/list/available = list()
	var/list/recipes = list()
	for(var/datum/witch_recipe/R as() in GLOB.witch_recipes)
		if(R.check_recipe(get_turf(src)))
			if(available["[R.name]"])
				continue
			//TODO: Swap over the the dedicated option datum, so I can use descriptions - Racc
			available += list("[R.name]" = image(R.icon, R.icon_state))
			recipes += list("[R.name]" = R)
	if(!length(available))
		return
	//Show the user a fancy radial menu for crafting options
	var/choice = show_radial_menu(user, src, available, tooltips = TRUE)
	if(!choice)
		return
	var/datum/witch_recipe/R = recipes[choice]
	R.produce(user, get_turf(src))
	SSspooky.adjust_trespass(user, TRESPASS_LARGE)
	//TODO: Temporary animation - Racc
	var/matrix/n_transform = transform
	var/matrix/o_transform = transform
	n_transform.Scale(0.85, 1.15)
	animate(src, transform = n_transform, time = 0.25 SECONDS, easing = BACK_EASING | EASE_OUT)
	animate(transform = o_transform, time = 0.15 SECONDS, easing = LINEAR_EASING)
