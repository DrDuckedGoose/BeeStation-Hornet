/obj/structure/deep_water
	name = "deep water"
	desc = "A deep volume of"

	icon = 'icons/obj/pool.dmi'
	icon_state = "water"

	density = FALSE
	anchored = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	///How much we hold
	var/volume = 800

/obj/structure/deep_water/Initialize(mapload)
	. = ..()
	//generate reagents
	reagents = new(volume)
	reagents.add_reagent(SSdeep_water.ocean_reagent, volume)
	color = initial(SSdeep_water.ocean_reagent?.color)
	desc = "[desc] [initial(SSdeep_water.ocean_reagent?.name)]"
	//Setup distribution for people who step on us
	RegisterSignal(get_turf(src), COMSIG_ATOM_ENTERED, .proc/on_entered)
	//Setup liquid checks for nearby turfs & structures
	var/list/directions = list(NORTH, SOUTH, EAST, WEST)
	for(var/i in directions)
		var/turf/T = get_step(src, i)
		//Prioritize windows
		var/obj/structure/S = locate(/obj/structure/window) in T
		S = S || locate(/obj/structure) in T
		if(S || T)
			RegisterSignal(S || T, COMSIG_PARENT_QDELETING, .proc/flow)
	//Setup admin reagent change signal
	RegisterSignal(SSdeep_water, COMSIG_ACTION_TRIGGER, .proc/update_reagents)

/obj/structure/deep_water/attackby(obj/item/reagent_containers/I, mob/living/user, params)
	. = ..()
	//People can fill beakers from us
	if(istype(I) && I.reagent_flags & OPENCONTAINER)
		reagents.trans_to(I, I.amount_per_transfer_from_this)
		//If we empty, we die
		if(reagents.total_volume <= 0)
			qdel(src)

//When the stuff next to us is destroyed, like windows & walls
/obj/structure/deep_water/proc/flow(turf/source)
	if(locate(/obj/structure/deep_water) in get_turf(source) || !istype(source))
		return
	addtimer(CALLBACK(src, .proc/finish_flow, source.x, source.y, source.z), 0.1 SECONDS) //Delay might be fucked

//becuase I'm skeptical about checking this in one step
/obj/structure/deep_water/proc/finish_flow(x, y, z)
	if(istype(locate(x, y, z), /turf/closed) || locate(/obj/structure/deep_water) in locate(x, y, z))
		return
	new /obj/structure/deep_water(locate(x, y, z))

//When someone steps on us, slime 'em
/obj/structure/deep_water/proc/on_entered(datum/source, atom/movable/entering)
	//Play funky water sound for that sweet immersion
	playsound(src, 'sound/effects/splosh.ogg', 100, 1) //TODO: Change this to something more fitting
	//Distribute contents onto target - 5 should be an okay average
	reagents.reaction(entering, TOUCH, exact_amount = 5)
	//If we empty, we die
	if(reagents.total_volume <= 0)
		qdel(src)

//Used to change what reagent we hold, don't call this manually. Used by SS
/obj/structure/deep_water/proc/update_reagents(datum/source, datum/reagent/new_reagent)
	reagents.clear_reagents()
	reagents.add_reagent(new_reagent, volume)
	color = initial(new_reagent?.color)
	desc = "[desc] [initial(new_reagent?.name)]"
