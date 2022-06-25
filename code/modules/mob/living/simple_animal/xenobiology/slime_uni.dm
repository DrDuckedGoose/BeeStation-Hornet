///Universal slimes, not University slimes
/mob/living/simple_animal/slime_uni
	name = "slime"
	desc = "A squishy disco party!"
	icon = 'icons/mob/xenobiology/slime.dmi'
	icon_state = "random"
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	gender = NEUTER
	faction = list("slime")
	///Slime DNA, contains traits and visual features
	var/datum/slime_dna/dna
	///Icon the actual mob uses, contains animated frames
	var/icon/icon_flourish
	///Icon the actual mob uses on death!
	var/icon/icon_perish
	///Static icon used for displays
	var/icon/still_icon
	///texture for overlay reference
	var/icon/animated_texture
	///technical name seen by science goggles
	var/species_name = ""
	///Whether this species is undicovered or not
	var/discovered = FALSE
	///This slimes team
	var/datum/component/slime_team/slime_team

/mob/living/simple_animal/slime_uni/Initialize(mapload, instability, texture, mask, sub_mask, color, rotation, pan)
	..()
	//Setup dna
	dna = new(src, instability, texture, mask, sub_mask, color, rotation, pan)

	//apply textures, colors, and outlines
	setup_texture()
	add_filter("outline", 2, list("type" = "outline", "color" = gradient(dna.features["color"], "#000", 0.59), "size" = 1))

	//Do component configuration
	var/datum/component/discoverable/D = GetComponent(/datum/component/discoverable)
	D?.unique = TRUE

	//Preform subsystem tasks
	discovered = (SSslime_species.append_species(src, TRUE) ? FALSE : TRUE) //If statement returns true it's undiscovered, this is wonky

	//setup traits
	var/datum/slime_species/S
	S = SSslime_species.slime_species[species_name]
	dna.setup_traits(S?.traits)

//Additionally handles species name & discover status
/mob/living/simple_animal/slime_uni/examine(mob/user)
	. = ..()
	if(user.can_see_reagents())
		. += species_name + (check_discovery() ? {"<span style="color:["#13a311"];">\nDiscovered</span>"} : {"<span style="color:["#c12222"];">\nUndiscovered</span>"})
	
/mob/living/simple_animal/slime_uni/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/reagent_containers/syringe))
		if(slime_team)
			to_chat(user, "<span class ='warning'>[slime_team.owner == user ? "This slime is already on your team!" : "This slime already has a team!"]</span>")
			return
		var/obj/item/reagent_containers/syringe/S = I
		var/datum/reagent/blood/B = S.reagents.has_reagent(/datum/reagent/blood)
		if(B)
			//notify
			user.visible_message("<span class ='warning'>[user] injects [src] with blood, binding the DNA!</span>","<span class ='warning'>You inject [src] with blood, binding the DNA!</span>")
			
			//remove our reagents
			S.reagents.remove_reagent(/datum/reagent/blood, 5)
			//add factions to slime
			faction |= "slime_faction_[B.data["blood_DNA"]]"
			faction |= B.data["factions"]
			//add factions to mob
			var/datum/mind/M = B.data["mind"]
			var/mob/living/owner = M.current
			owner.faction |= "slime_faction_[B.data["blood_DNA"]]"	
			
			//handle team component
			if(!owner.GetComponent(/datum/component/slime_team))
				owner.AddComponent(/datum/component/slime_team)
			var/datum/component/slime_team/ST = owner.GetComponent(/datum/component/slime_team)
			ST?.append_player(src)
			slime_team = ST

/mob/living/simple_animal/slime_uni/Destroy()
	qdel(dna)
	dna = null
	..()

/mob/living/simple_animal/slime_uni/death(gibbed)
	. = ..()
	if(gibbed)
		return
	icon = icon_dead //Doesn't otherwise?

//todo: consider moving this to dna
///Animates texture for final use from dna
/mob/living/simple_animal/slime_uni/proc/setup_texture()
	//typecast to access procs & features
	var/icon/hold = dna.features["texture"]

	//dead icon
	icon_perish = new(hold)
	///Alpha mask for cutting out excess but dead!
	var/icon/alpha_mask_dead = new('icons/mob/xenobiology/slime.dmi', "m_dead")
	icon_perish.AddAlphaMask(alpha_mask_dead)
	icon_dead = icon_perish

	//living icon
	icon_flourish = new(hold)
	icon_flourish.Insert(hold)
	for(var/i in 2 to 32) //Make adjustments, animaton
		hold.Shift(dna.features["direction"], dna.features["speed"], TRUE) //update texture
		icon_flourish.Insert(hold, frame=i) //insert frames into icon
	animated_texture = new(icon_flourish)
	///Alpha mask for cutting out excess
	var/icon/alpha_mask = dna.features["mask"]
	icon_flourish.AddAlphaMask(alpha_mask)
	still_icon = new()
	still_icon.Insert(icon_flourish, frame=1)
	icon = icon_flourish

///Check subsystem for species, updates discovery respectively
/mob/living/simple_animal/slime_uni/proc/check_discovery()
	discovered = (SSslime_species.append_species(src, TRUE) ? FALSE : TRUE)
	if(discovered)
		return TRUE
	return FALSE

///makes produce / slime core
/mob/living/simple_animal/slime_uni/proc/do_produce()
	new /obj/item/slime_produce(get_turf(src), src)

///slime_uni brand slime core
/obj/item/slime_produce
	name = "slime bile"
	desc = "Excess slime produced by slimes turns into loose slime, slimy!"
	var/species_name

/obj/item/slime_produce/Initialize(mapload, var/mob/living/simple_animal/slime_uni/P)
	if(!P)
		return
	//inherit parent name, if we can
	species_name = P.species_name
	//create custom icon if parent exists
	var/icon/temp = P.animated_texture
	var/icon/mask = new('icons/mob/xenobiology/slime.dmi', "produce")
	temp.AddAlphaMask(mask)
	//filtering
	add_filter("outline", 2, list("type" = "outline", "color" = gradient(P.dna.features["color"], "#000", 0.59), "size" = 1))
	icon = temp
	..()

/obj/item/slime_produce/examine(mob/user)
	. = ..()
	if(user.can_see_reagents())
		. += "[species_name] excess"

///mapping variant. Please use this when adding slimes to maps.
/mob/living/simple_animal/slime_uni/map_variant/Initialize(mapload, instability, var/datum/xenobiology_feature/texture, var/datum/xenobiology_feature/mask, var/datum/xenobiology_feature/sub_mask, color, rotation, pan)
	texture = new /datum/xenobiology_feature/texture/plain()
	mask = new /datum/xenobiology_feature/mask/default()
	sub_mask = new /datum/xenobiology_feature/sub_mask/blank()
	..()
