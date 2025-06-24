/obj/machinery/vending/hydroseeds
	name = "\improper MegaSeed Servitor"
	desc = "When you need seeds fast!"
	product_slogans = "THIS'S WHERE TH' SEEDS LIVE! GIT YOU SOME!;Hands down the best seed selection on the station!;Also certain mushroom varieties available, more for experts! Get certified today!"
	product_ads = "We like plants!;Grow some crops!;Grow, baby, growww!;Aw h'yeah son!"
	icon_state = "seeds"
	light_mask = "seeds-light-mask" //TODO: Fix this - Racc
	products = list(//obj/item/plant_seeds/preset/ambrosia = 3,
					/obj/item/plant_seeds/preset/apple = 3,
					/obj/item/plant_seeds/preset/banana = 3,
					/obj/item/plant_seeds/preset/berry = 3,
					/obj/item/plant_seeds/preset/cabbage = 3,
					/obj/item/plant_seeds/preset/carrot = 3,
					//obj/item/plant_seeds/preset/cherry = 3,
					//obj/item/plant_seeds/preset/chanter = 3,
					/obj/item/plant_seeds/preset/chili = 3,
					//obj/item/plant_seeds/preset/cocoapod = 3,
					/obj/item/plant_seeds/preset/coconut = 3,
					/obj/item/plant_seeds/preset/coffee = 3,
					/obj/item/plant_seeds/preset/corn = 3,
					/obj/item/plant_seeds/preset/cotton = 3,
					//obj/item/plant_seeds/preset/dionapod = 3,
					/obj/item/plant_seeds/preset/eggplant = 3,
					/obj/item/plant_seeds/preset/garlic = 3,
					/obj/item/plant_seeds/preset/grape = 3,
					/obj/item/plant_seeds/preset/grass = 3,
					/obj/item/plant_seeds/preset/lemon = 3,
					/obj/item/plant_seeds/preset/lime = 3,
					/obj/item/plant_seeds/preset/onion = 3,
					/obj/item/plant_seeds/preset/orange = 3,
					/obj/item/plant_seeds/preset/pineapple = 3,
					/obj/item/plant_seeds/preset/potato = 3,
					//obj/item/plant_seeds/preset/flower/poppy = 3,
					/obj/item/plant_seeds/preset/pumpkin = 3,
					//obj/item/plant_seeds/preset/wheat/rice = 3,
					//obj/item/plant_seeds/preset/soya = 3,
					//obj/item/plant_seeds/preset/sunflower = 3,
					//obj/item/plant_seeds/preset/sugarcane = 3,
					//obj/item/plant_seeds/preset/tea = 3,
					//obj/item/plant_seeds/preset/tobacco = 3,
					/obj/item/plant_seeds/preset/tomato = 3,
					//obj/item/plant_seeds/preset/tower = 3,
					/obj/item/plant_seeds/preset/watermelon = 3,
					/obj/item/plant_seeds/preset/wheat = 3,)
					//obj/item/plant_seeds/preset/whitebeet = 3)
	contraband = list(/obj/item/seeds/amanita = 2,
						/obj/item/seeds/glowshroom = 2,
						/obj/item/seeds/liberty = 2,
						/obj/item/seeds/nettle = 2,
						/obj/item/seeds/plump = 2,
						/obj/item/seeds/reishi = 2,
						/obj/item/seeds/cannabis = 3,
						/obj/item/seeds/starthistle = 2,
						/obj/item/seeds/random = 2)
	premium = list(/obj/item/reagent_containers/spray/waterflower = 1)
	refill_canister = /obj/item/vending_refill/hydroseeds
	default_price = 10
	extra_price = 50
	dept_req_for_free = ACCOUNT_SRV_BITFLAG

/obj/item/vending_refill/hydroseeds
	machine_name = "MegaSeed Servitor"
	icon_state = "refill_plant"
