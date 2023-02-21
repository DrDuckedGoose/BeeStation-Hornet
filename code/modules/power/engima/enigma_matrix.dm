#define RADIATION_UPPER_POWER 8
#define TESLA_UPPER_RANGE 5
#define TESLA_UPPER_POWER 50

/obj/machinery/power/enigma_matrix
	name = "enigma matrix"
	desc = "A complex bluespace compression matrix."
	icon = 'icons/obj/enigma_matrix.dmi'
	icon_state = "plate"
	base_icon_state = "plate"
	layer = ABOVE_MOB_LAYER
	density = TRUE
	anchored = TRUE
	light_range = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	critical_machine = TRUE
	///Ratios of gasses near us - more like parts instead of ratios, measured from the smallest
	var/list/gas_ratios = list()
	///Ratios for effect potentials
	var/list/potential_ratios = list("radiation_potential" = list(), "lighting_potential" = list(), "heat_potential" = list(), "cool_potential" = list())
	///The minimum percentage to activate an effect
	var/list/potential_percentages = list("radiation_potential" = 0, "lighting_potential" = 0, "heat_potential" = 0, "cool_potential" = 0)

/obj/machinery/power/enigma_matrix/Initialize(mapload)
	. = ..()
	build_potential_ratios()
	SSair.atmos_air_machinery += src
	new /obj/effect/enigma_matrix_distortion(loc)

/obj/machinery/power/enigma_matrix/process_atmos()
	get_gas_ratios()
	process_gas_ratios()

///Build the gas ration list from nearby gasses
/obj/machinery/power/enigma_matrix/proc/get_gas_ratios()
	//Pick a nearby turf to scan gasses
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/G = T?.return_air()
	if(!G)
		return
	gas_ratios = list()
	//Setup ratios from mixture
	var/floor = 0
	var/compile = FALSE
	for(var/i in 1 to 2)
		for(var/id in G.get_gases())
			if(!(id in GLOB.hardcoded_gases))
				continue
			//Get the largest volume
			if(!compile)
				floor = floor ? min(floor, G.get_moles(id)) : G.get_moles(id)
			//Build ratios from smallest
			else if(floor && G.get_moles(id) > 1)
				var/moles = G.get_moles(id)
				gas_ratios += list("[id]" = round(moles / floor))
		//Setup to build ratios once we have the largest value
		compile = TRUE

///Build a list of recipes for effects
/obj/machinery/power/enigma_matrix/proc/build_potential_ratios()
	for(var/i in potential_ratios)
		//How many gasses are required to produce this effect
		var/component_count = rand(2, 3)
		//Recipe ratios
		var/list/reciped_gas_ratios = list()
		//Available gasses for recipe
		var/list/available_gasses = GLOB.hardcoded_gases.Copy()
		for(var/e in 1 to component_count)
			var/chosen_gas = pick(available_gasses)
			available_gasses -= chosen_gas
			reciped_gas_ratios += list("[chosen_gas]" = (e > 1 ? rand(2, 8) : 1))
		potential_ratios[i] = reciped_gas_ratios
		potential_ratios[i]["temperature"] = list("setting" = pick("hot", "cold", "none"), "value" = T20C) //todo: explain this
		potential_ratios[i]["temperature"]["value"] = rand(T20C, (potential_ratios[i]["temperature"]["setting"] == "hot" ? 500 : 70))
		potential_percentages[i] = rand(3, 6) * 0.1 //gas ratios have to be around 30-60% identical to produce effects

/obj/machinery/power/enigma_matrix/proc/process_gas_ratios()
	//List of achieved percentages
	var/list/effect_percentages = list()
	//Cycle through the gas ratios
	for(var/i in potential_ratios)
		var/total_parts = 0
		for(var/e in potential_ratios[i])
			if(e == "temperature")
				continue
			total_parts += potential_ratios[i][e]
			effect_percentages[i] += (gas_ratios[e] ? min(1, gas_ratios[e] / potential_ratios[i][e]) : 0)
		effect_percentages[i] = min(1, effect_percentages[i]/total_parts)
		//Handle temperature argument
		var/turf/T = get_turf(src)
		var/datum/gas_mixture/G = T?.return_air()
		if(potential_ratios[i]["temperature"]["setting"] == "hot")
			effect_percentages[i] *= (G.return_temperature() >= potential_ratios[i]["temperature"]["value"] ? 1 : 0)
		else if(potential_ratios[i]["temperature"]["setting"] == "cold")
			effect_percentages[i] *= (G.return_temperature() <= potential_ratios[i]["temperature"]["value"] ? 1 : 0)
	//Award percentages
	for(var/i in effect_percentages)
		if(effect_percentages[i] < potential_percentages[i])
			continue
		switch(i)
			if("radiation_potential")
				say("Radiation [100 * effect_percentages[i]]%")
				radiation_pulse(src, RADIATION_UPPER_POWER * effect_percentages[i])
			if("lighting_potential")
				say("Lightning [100 * effect_percentages[i]]%")
				tesla_zap(src, max(1, TESLA_UPPER_RANGE * effect_percentages[i]), TESLA_UPPER_POWER * effect_percentages[i], TESLA_MOB_DAMAGE | TESLA_OBJ_DAMAGE | TESLA_MOB_STUN | TESLA_ALLOW_DUPLICATES)
			if("heat_potential")
				say("Heat [100 * effect_percentages[i]]%")
			if("cold_potential")
				say("Cold [100 * effect_percentages[i]]%")
			else
				continue

#undef RADIATION_UPPER_POWER
#undef TESLA_UPPER_RANGE
#undef TESLA_UPPER_POWER

//Effect
/obj/effect/enigma_matrix_distortion
	appearance_flags = PIXEL_SCALE | TILE_BOUND | KEEP_TOGETHER
	mouse_opacity = FALSE
	pixel_x = 38
	pixel_y = 38
	layer = 5

/obj/effect/enigma_matrix_distortion/Initialize(mapload)
	. = ..()
	//Gather vis contents in a 3x3 area
	for(var/i in x-1 to x+1)
		for(var/n in y-1 to y+1)
			var/turf/T = locate(i, n, z)
			vis_contents += T
	//Apply a mask filter
	var/icon/I = icon('icons/effects/96x96.dmi', "explosion")
	add_filter("mask", 1, alpha_mask_filter(32, 32, I))
	//apply and animate wave filter
	add_filter("special_wave", 2, wave_filter(1, 0.05, size = 1, offset = 2, flags = list(WAVE_SIDEWAYS)))
	animate(get_filter("special_wave"), offset = 10, time = 10 SECONDS, loop = -1)
	animate(offset = 1, time = 10 SECONDS, loop = -1)
	//flip ourselves
	var/matrix/M = new()
	M.Turn(180)
	M.Scale(1.2)
	transform = M
