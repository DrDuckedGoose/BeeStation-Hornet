/datum/plant_feature/fruit/coffee
	icon_state = "apple"
	fruit_product = /obj/item/food/grown/coffee
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/coffee_powder)
	total_volume = PLANT_REAGENT_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/datum/plant_feature/fruit/coffee/robusta
	fruit_product = /obj/item/food/grown/coffee/robusta
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/coffee_powder, /datum/plant_trait/reagent/fruit/ephedrine)
	total_volume = PLANT_REAGENT_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
