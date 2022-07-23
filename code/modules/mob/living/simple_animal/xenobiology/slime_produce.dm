///slime_uni brand slime core
/obj/item/reagent_containers/slime_produce
	name = "slime core"
	desc = "Excess slime produced by slimes turns into loose slime, slimy!"
	reagent_flags = INJECTABLE | DRAWABLE
	volume = 5
	///Inhertied species content
	var/species_name
	var/list/traits = list()
	///Activation method
	var/activation
	///Required activation elements, including reagent & target
	var/datum/reagent/activation_reagent
	var/atom/activation_target

/obj/item/reagent_containers/slime_produce/Initialize(mapload, var/mob/living/simple_animal/slime_uni/P)
	//stop admins runtiming
	if(!P)
		return

	//inherit parent stuff
	species_name = P.species_name
	for(var/datum/xenobiology_trait/T in P.dna.traits)
		T = new T.type(list(src))
		traits += T

	//create custom icon from parent texture.
	var/icon/temp = new(P.animated_texture)
	var/icon/mask = new('icons/mob/xenobiology/slime.dmi', "produce")
	temp.AddAlphaMask(mask)
	//filters
	add_filter("outline", 2, list("type" = "outline", "color" = gradient(P.dna.features["color"], "#000", 0.65), "size" = 1))
	icon = temp

	//Setup activation todo: making path_choosen a new type might be icky
	var/datum/xenobiology_trait/trait_choosen = pick(traits)
	var/atom/path_choosen = pick(trait_choosen?.possible_targets)
	path_choosen = new path_choosen
	activation = (istype(path_choosen, /datum/reagent) ? "reagent" : istype(path_choosen, /obj) ? "target" : "touch")
	switch(activation)
		if("touch")
			RegisterSignal(src, COMSIG_ITEM_ATTACK_SELF, .proc/check_source)
		if("reagent")
			activation_reagent = path_choosen
			RegisterSignal(src, COMSIG_PARENT_ATTACKBY, .proc/check_source)
		if("target")
			activation_target = path_choosen
			RegisterSignal(src, COMSIG_ITEM_AFTERATTACK, .proc/check_source)
	..()

/obj/item/reagent_containers/slime_produce/examine(mob/user)
	. = ..()
	if(user.can_see_reagents())
		. += "[species_name] excess"

///Used to check activation source
/obj/item/reagent_containers/slime_produce/proc/check_source(datum/source, atom/target, atom/user, params)
	switch(activation)
		if("touch")
			if(!isliving(target))
				return
		if("reagent")
			if(istype(target, /obj/item/reagent_containers/syringe))
				var/obj/item/reagent_containers/syringe/S = target
				var/datum/reagent/R = S.reagents.get_reagent(activation_reagent)
				if(R?.volume < 5)
					return
			else
				return
		if("target")
			if(!istype(target, activation_target))
				return
	activate()

/obj/item/reagent_containers/slime_produce/AltClick(mob/user)
	. = ..()
	activate()

///Activate from DNA reference
/obj/item/reagent_containers/slime_produce/proc/activate()
	//todo: Consider using signals for this, could mess with the order
	say("activated")
	for(var/datum/xenobiology_trait/X as() in traits)
		X.activate()

/obj/item/reagent_containers/slime_produce/Destroy()
    . = ..()
    UnregisterSignal(src, COMSIG_ITEM_ATTACK_SELF)
    UnregisterSignal(src, COMSIG_PARENT_ATTACKBY)
    UnregisterSignal(src, COMSIG_ITEM_AFTERATTACK)
    for(var/datum/xenobiology_trait/T in traits)
        qdel(T)
    traits = null
