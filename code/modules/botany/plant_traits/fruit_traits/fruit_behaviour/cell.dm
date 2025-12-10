/*
	The fruit can be turned into a battery
*/
/*
/datum/plant_gene/trait/battery/on_attackby(obj/item/food/grown/G, obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = I
		if(C.use(5))
			to_chat(user, span_notice("You add some cable to [G] and slide it inside the battery encasing."))
			var/obj/item/stock_parts/cell/potato/pocell = new /obj/item/stock_parts/cell/potato(user.loc)
			pocell.icon_state = G.icon_state
			pocell.maxcharge = G.seed.potency * 20

			// The secret of potato supercells!
			var/datum/plant_gene/trait/cell_charge/CG = G.seed.get_gene(/datum/plant_gene/trait/cell_charge)
			if(CG) // Cell charge max is now 40MJ or otherwise known as 400KJ (Same as bluespace power cells)
				pocell.maxcharge *= CG.rate*100
			pocell.charge = pocell.maxcharge
			pocell.name = "[G.name] battery"
			pocell.desc = "A rechargeable plant-based power cell. This one can store up to [display_power(pocell.maxcharge)], and you should not swallow it."

			if(G.reagents.has_reagent(/datum/reagent/toxin/plasma, 2))
				pocell.rigged = TRUE

			qdel(G)
		else
			to_chat(user, span_warning("You need five lengths of cable to make a [G] battery!"))
*/
