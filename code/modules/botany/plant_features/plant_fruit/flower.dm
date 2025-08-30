/*
	Flower
	Generic flower
*/
/datum/plant_feature/fruit/flower
	species_name = "oblivisci flos"
	name = "forget me not"
	icon_state = "flower_1"
	//colour_overlay = "flower_1_colour"
	random_plant = TRUE
	fruit_product = /obj/item/food/grown/flower/forgetmenot
	plant_traits = list(/datum/plant_trait/nectar)
	//colour_override = "#ffffff"
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_VERY_FAST
	fast_reagents = list(/datum/reagent/medicine/kelotane = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/flower/poppy)

/*
	Poppy
*/
/datum/plant_feature/fruit/flower/poppy
	species_name = "flos ruber"
	name = "poppy"
	icon_state = "flower_3"
	colour_overlay = "flower_3_colour"
	fruit_product = /obj/item/food/grown/flower/poppy
	colour_override = "#ee1e1e"
	fast_reagents = list(/datum/reagent/medicine/bicaridine = PLANT_REAGENT_MEDIUM, /datum/reagent/medicine/morphine = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/flower/geranium, /datum/plant_feature/fruit/flower/lily)


/*
	Geranium
*/
/datum/plant_feature/fruit/flower/geranium
	species_name = "hyacinthum papaver"
	name = "geranium"
	icon_state = "flower_2"
	colour_overlay = "flower_2_colour"
	fruit_product = /obj/item/food/grown/flower/geranium
	colour_override = "#33a4d8"
	fast_reagents = list(/datum/reagent/medicine/bicaridine = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/flower)

/*
	Harebell
*/
/datum/plant_feature/fruit/flower/harebell
	species_name = "viriditas flos"
	name = "harebell"
	icon_state = "flower_3" //TODO: make custom sprite - Racc
	colour_overlay = "flower_3_colour"
	fruit_product = /obj/item/food/grown/flower/harebell
	colour_override = "#a561e6"

/*
	Lily
	See her everywhere in everything, dude
*/
/datum/plant_feature/fruit/flower/lily
	species_name = "sol lilium"
	name = "lily"
	icon_state = "flower_2"
	colour_overlay = "flower_2_colour"
	fruit_product = /obj/item/food/grown/flower/lily
	colour_override = "#ee601e"
	fast_reagents = list(/datum/reagent/medicine/bicaridine = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/flower/trumpet)

/*
	Spaceman's Trumpet
*/
/datum/plant_feature/fruit/flower/trumpet
	species_name = "tubae flos"
	name = "spaceman's trumpet"
	icon_state = "flower_2" //TODO: make custom sprite - Racc
	colour_overlay = "flower_2_colour"
	fruit_product = /obj/item/food/grown/flower/trumpet
	colour_override = "#f700ff"
	fast_reagents = list(/datum/reagent/medicine/polypyr = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/flower/poppy)

/*
	Sun Flower
*/
/datum/plant_feature/fruit/flower/sun
	species_name = "sol flos"
	name = "sun flower"
	icon_state = "flower_2" //TODO: make custom sprite - Racc
	colour_overlay = "flower_2_colour"
	fruit_product = /obj/item/grown/sunflower
	fast_reagents = list(/datum/reagent/consumable/nutriment/fat/oil = PLANT_REAGENT_MEDIUM)
	mutations = list()

/*
	Nova Flower
*/
/datum/plant_feature/fruit/flower/nova
	species_name = "flos nova"
	name = "nova flower"
	icon_state = "flower_2" //TODO: make custom sprite - Racc
	colour_overlay = "flower_2_colour"
	fruit_product = /obj/item/grown/novaflower
	fast_reagents = list(/datum/reagent/consumable/condensedcapsaicin = PLANT_REAGENT_MEDIUM, /datum/reagent/consumable/capsaicin = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/flower/moon)

/*
	Moon Flower
*/
/datum/plant_feature/fruit/flower/moon
	species_name = "flos lunae"
	name = "moon flower"
	icon_state = "flower_2" //TODO: make custom sprite - Racc
	colour_overlay = "flower_2_colour"
	fruit_product = /obj/item/food/grown/flower/moonflower
	fast_reagents = list(/datum/reagent/consumable/ethanol/moonshine = PLANT_REAGENT_MEDIUM, /datum/reagent/acetone = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/flower/sun)

/*
	Rainbow Flower
*/
/datum/plant_feature/fruit/flower/rainbow
	species_name = "iris flos"
	name = "rainbow flower"
	icon_state = "flower_1"
	colour_overlay = "flower_1_colour"
	fruit_product = /obj/item/food/grown/flower/rainbow

/datum/plant_feature/fruit/flower/rainbow/New(datum/component/plant/_parent)
	var/flower_color = rand(1,8)
	switch(flower_color)
		if(1)
			colour_override = "#DA0000"
			fast_reagents = list(/datum/reagent/colorful_reagent/powder/red = PLANT_REAGENT_MEDIUM)
		if(2)
			colour_override = "#FF9300"
			fast_reagents = list(/datum/reagent/colorful_reagent/powder/orange = PLANT_REAGENT_MEDIUM)
		if(3)
			colour_override = "#FFF200"
			fast_reagents = list(/datum/reagent/colorful_reagent/powder/yellow = PLANT_REAGENT_MEDIUM)
		if(4)
			colour_override = "#A8E61D"
			fast_reagents = list(/datum/reagent/colorful_reagent/powder/green = PLANT_REAGENT_MEDIUM)
		if(5)
			colour_override = "#00B7EF"
			fast_reagents = list(/datum/reagent/colorful_reagent/powder/blue = PLANT_REAGENT_MEDIUM)
		if(6)
			colour_override = "#DA00FF"
			fast_reagents = list(/datum/reagent/colorful_reagent/powder/purple = PLANT_REAGENT_MEDIUM)
		if(7)
			colour_override = "#1C1C1C"
			fast_reagents = list(/datum/reagent/colorful_reagent/powder/black = PLANT_REAGENT_MEDIUM)
		if(8)
			colour_override = "#FFFFFF"
			fast_reagents = list(/datum/reagent/colorful_reagent/powder/white = PLANT_REAGENT_MEDIUM)
	return ..()
