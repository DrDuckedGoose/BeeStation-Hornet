//TODO: Fully implement this, especially sprites - Racc
//Can be used to summon spooky events
/obj/item/curio/water_candle
	name = "water candle"
	desc = "A strange half melted candle."
	icon_state = "water_candle"
	///Ref to the event we spawn
	var/datum/spooky_event/event_target
	///How long the candle can burn before it stops the event
	var/event_time = 10 MINUTES

/obj/item/curio/water_candle/Destroy()
	. = ..()
	if(event_target)
		QDEL_NULL(event_target)

//Each curio has to code how this is called
/obj/item/curio/water_candle/activate(datum/user, force)
	. = ..()
	if(!. || !SSspooky.current_behaviour || !istype(get_area(src), /area/chapel) || length(SSspooky.current_behaviour.active_products) > 1)
		to_chat(user, "<span class='warning'>[src] makes a smouldering noise, and refuses to light.</span>")
		return
	to_chat(user, "<span class='notice'>[src] begins to burn!</span>")
	var/datum/spooky_event/random_event = SSspooky.current_behaviour.generate_goal()
	event_target = SSspooky.current_behaviour.do_event(random_event)
	addtimer(CALLBACK(src, PROC_REF(self_destruct)), event_time)
	RegisterSignal(event_target, COMSIG_PARENT_QDELETING, PROC_REF(self_destruct))

/obj/item/curio/water_candle/interact(mob/user)
	. = ..()
	if(event_target)
		qdel(src)

/obj/item/curio/water_candle/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(I.is_hot() && !event_target && do_after(user, 5 SECONDS, src))
		activate(user)

/obj/item/curio/water_candle/proc/self_destruct()
	qdel(src)
