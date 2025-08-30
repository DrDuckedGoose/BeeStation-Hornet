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
	//TODO: optimize this code - Racc
	var/scan_dialogue = ""
//Tray Code
	var/obj/machinery/plumbing/tank/plant_tray/tray = target
	if(istype(tray))
		//Report needs //TODO: maybe make this a proc. like the below for() - Racc
		//TODO: make this work for all plants, not just need ones. Make scanning the tray for PROBLEMS. Or Just make scanning the tray informative - Racc
		for(var/datum/plant_feature/feature as anything in tray.needy_features)
			scan_dialogue += feature.get_need_dialogue()
		to_chat(user, "<span class='plant_scan'><span class='big bold'>[target.name]</span><br/>[scan_dialogue]</span>") //TODO: the text formatting everywhere in this file - Racc
		return
//Plant Code
	var/datum/component/plant/plant_component = target.GetComponent(/datum/component/plant)
	if(!plant_component || !length(plant_component.plant_features)) //Find me a plant with no features, unless a player makes one, for some reason
		return
	//Cycle through features to collect dialogue
	for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
		scan_dialogue += "<span class='plant_sub'>[feature.get_scan_dialogue()]</span>"
	to_chat(user, "<span class='plant_scan'><span class='big bold'>[target.name]</span><br/>[scan_dialogue]</span>")
	playsound(src, 'sound/effects/fastbeep.ogg', 20)
	return FALSE
