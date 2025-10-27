/*
	Nettle leaf
*/
//TODO: - Sprites
/datum/plant_feature/fruit/nettle
	species_name = "folium aculeatum"
	name = "nettle"
	icon_state = "missing"
	fruit_product = /obj/item/food/grown/nettle
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	fast_reagents = list(/datum/reagent/toxin/acid)
