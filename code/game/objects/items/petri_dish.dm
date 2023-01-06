#define GROWMODE_ORGAN "growmode_organ"
#define GROWMODE_MOB "growmode_mob"

/obj/item/reagent_containers/glass/petri_dish
	name = "petri dish"
	desc = "Grows possibly delicious meat."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "petri_dish"
	item_state = "petri_dish"
	alpha = 200
	w_class = WEIGHT_CLASS_TINY
	volume = 15
	materials = list(/datum/material/glass = 5)
	///How complete is the organ growing process
	var/organ_completion = 0
	///The rate at which we develop organs
	var/completion_rate = 15
	///List of mutations that have been inserted into this dish
	var/list/mutations = list()
	///The current quality of the new organ, overall
	var/organ_quality = 0
	///What we're growing
	var/grow_mode

/obj/item/reagent_containers/glass/petri_dish/process(delta_time)
	if(world.time % 3 != 0 || !(locate(/datum/reagent/organ_sample) in reagents.reagent_list) || !(locate(/datum/reagent/medicine/synthflesh) in reagents.reagent_list))
		return
	//Itterate completion
	organ_completion = min(100, organ_completion + completion_rate)
	if(organ_completion >= 100)
		SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER)

/obj/item/reagent_containers/glass/petri_dish/attackby(obj/item/I, mob/user, params)
	. = ..()	
	var/datum/reagent/organ_sample/OS = locate(/datum/reagent/organ_sample) in reagents.reagent_list
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in reagents.reagent_list
	//Update organ quality
	if(OS)
		grow_mode = GROWMODE_ORGAN
		organ_quality = 0
		for(var/i in OS.data["quality"])
			if(OS.data["quality"]["[i]"])
				organ_quality += 1
		//Check quality for scanners
		if(istype(I, /obj/item/sequence_scanner))
			//Build text for organ quality
			var/text = "<span class='notice'>Cell sample quality: </span>"
			var/list/colors = list("#f00", "#ff9500", "#ddff00", "#00ff1e", "#00ff84", "#00ddff")
			var/color_itt = 1
			for(var/i in OS.data["quality"])
				text = "[text]<span style='color:[colors[color_itt]];font-size:20px'>[OS.data["quality"]["[i]"]?"■":"□"]</span>"
				color_itt += 1
			to_chat(user, text)
	else if(B)
		grow_mode = GROWMODE_MOB

/obj/item/reagent_containers/glass/petri_dish/proc/finish_organ()
	var/datum/reagent/organ_sample/S = (locate(/datum/reagent/organ_sample) in reagents.reagent_list)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in reagents.reagent_list
	if(S) //Making organs
		var/obj/item/organ/O = S.data["type"]
		O = new O(loc, FALSE)
		//Setup quality
		var/list/quality = S.data["quality"]
		O.quality = quality.Copy()
		//Reset values
		reagents.remove_all(volume)
		organ_completion = 0
		organ_quality = 0
		return O
	//Making mobs
	else if(B)
		return null
