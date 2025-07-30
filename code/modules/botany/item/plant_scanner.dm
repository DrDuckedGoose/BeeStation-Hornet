/obj/item/plant_scanner
	name = "plant scanner"
	desc = "A portble device used to scan and analyse plants."
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "plant_scanner"

/obj/item/plant_scanner/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/datum/component/plant/plant_component = target.GetComponent(/datum/component/plant)
	if(!plant_component || !length(plant_component.plant_features)) //Find me a plant with no features, unless a player makes one, for some reason
		return
	var/scan_dialogue = ""
	//Cycle through features to collect dialogue
	for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
		scan_dialogue += feature.get_scan_dialogue()
	to_chat(user, "<span class='notice'>[scan_dialogue]</span>")
	//.playsound() //TODO: - Racc

//TODO: add features to this - Racc
/*
	Probably the best move is making this give some brief information to maintain plants, the desktop analyzer is for
	more insightful information.
	- Remaining yields
	- Current age, although this doesn't really matter
	- Needs
*/
