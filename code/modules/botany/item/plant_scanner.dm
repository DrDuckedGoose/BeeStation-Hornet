/*
	The plant scanner shows some plant information and tray information
*/
/obj/item/plant_scanner
	name = "plant scanner"
	desc = "A portble device used to scan and analyse plants."
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "plant_scanner"

/obj/item/plant_scanner/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/scan_dialogue = ""
	//This code is kinda samey but it's easier to read
//Tray
	var/obj/item/plant_tray/tray = target
	if(istype(tray))
		//Report needs
		for(var/datum/plant_feature/feature as anything in tray.needy_features)
			scan_dialogue += "<span class='plant_sub'>[feature.get_need_dialogue()]</span>"
		//Report problems
		for(var/datum/plant_feature/feature as anything in tray.problem_features)
			scan_dialogue += "<span class='plant_sub'>[feature.get_scan_dialogue()]</span>"
		//Report harvest
		for(var/datum/component/plant/plant as anything in tray.harvestable_components)
			scan_dialogue += "<span class='plant_sub'>[plant.plant_item]([get_species_name(plant.plant_features)])\n\nReady For Harvest</span>"
		//Report Weeds
		var/datum/component/planter/tray_component = tray.GetComponent(/datum/component/planter)
		scan_dialogue +="<span class='plant_sub'>Weed Composition: [tray_component.weed_level]%</span>"
		to_chat(user, "<span class='plant_scan'><b>[capitalize(target.name)]</b></span><span class='plant_scan'>[scan_dialogue]</span>")
		playsound(src, 'sound/effects/fastbeep.ogg', 20)
		return FALSE
//Seed packet
	var/obj/item/plant_seeds/seeds = target
	if(istype(seeds))
		for(var/datum/plant_feature/feature as anything in seeds.plant_features)
			scan_dialogue += "<span class='plant_sub'>[feature.get_scan_dialogue()]</span>"
		to_chat(user, "<span class='plant_scan'><b>[capitalize(target.name)]</b></span><span class='plant_scan'>[scan_dialogue]</span>")
		playsound(src, 'sound/effects/fastbeep.ogg', 20)
		return FALSE
//Plant
	var/datum/component/plant/plant_component = target.GetComponent(/datum/component/plant)
	if(!plant_component || !length(plant_component.plant_features)) //Find me a plant with no features, unless a player makes one, for some somehow
		return FALSE
	//Cycle through features to collect dialogue
	for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
		scan_dialogue += "<span class='plant_sub'>[feature.get_scan_dialogue()]</span>"
	to_chat(user, "<span class='plant_scan'><b>[capitalize(target.name)]</b></span><span class='plant_scan'>[scan_dialogue]</span>")
	playsound(src, 'sound/effects/fastbeep.ogg', 20)
	return FALSE
//Fruit
	//TODO: - Racc
