//TODO: Add progress indicator to organ growing
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

/obj/item/reagent_containers/glass/petri_dish/Initialize(mapload, vol)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/glass/petri_dish/process(delta_time)
	if(world.time % 3 != 0 || !(locate(/datum/reagent/organ_sample) in reagents.reagent_list) || !(locate(/datum/reagent/medicine/synthflesh) in reagents.reagent_list))
		return
	//Itterate completion
	organ_completion = min(100, organ_completion + completion_rate)
	//Build organ when we've finished
	if(organ_completion >= 100)
		var/datum/reagent/organ_sample/S = (locate(/datum/reagent/organ_sample) in reagents.reagent_list)
		var/obj/item/organ/O = S.data["type"]
		O = new O(loc, FALSE)
		//Setup quality
		var/list/quality = S.data["quality"]
		O.quality = quality.Copy()
		//Reset values
		reagents.remove_all(volume)
		organ_completion = 0
