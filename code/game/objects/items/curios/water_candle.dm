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

/obj/item/curio/water_candle/examine(mob/user)
	. = ..()
	if(event_target)
		user.balloon_alert(user, event_target.event_message)
		to_chat(user, "<span class='warning'>[event_target.event_message]\n[get_area(event_target.get_location())]...</span>")

/obj/item/curio/water_candle/activate(datum/user, force)
	. = ..()
	if(!. || !SSspooky.current_behaviour || !istype(get_area(src), /area/chapel) || length(SSspooky.current_behaviour.active_products) > 1)
		to_chat(user, "<span class='warning'>[src] makes a smouldering noise, and refuses to light.</span>")
		return
	to_chat(user, "<span class='notice'>[src] begins to burn!</span>")
	var/datum/spooky_event/random_event = SSspooky.current_behaviour.generate_goal()
	event_target = SSspooky.current_behaviour.do_event(random_event)
	//Do some fancy visual stuff, if the event supports that
	//TODO: Oh my fucking god, off-screen atoms aren't rendered and break this
	var/atom/A = event_target.get_location()
	if(A)
		if(!A.render_target || A.render_target == "")
			A.render_target = "[A]"
		add_filter("show-off", 1, layering_filter(render_source= A.render_target, color = "#99999999", y = 16))
	addtimer(CALLBACK(src, PROC_REF(self_destruct)), event_time)
	RegisterSignal(event_target, COMSIG_PARENT_QDELETING, PROC_REF(self_destruct))

/obj/item/curio/water_candle/interact(mob/user)
	. = ..()
	if(event_target)
		qdel(src)

/obj/item/curio/water_candle/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(I.is_hot() && !event_target)
		to_chat(user, "<span class='warning'>You begin to light [src].</span>")
		if(do_after(user, 5 SECONDS, src))
			activate(user)
		else
			to_chat(user, "<span class='warning'>You hesitate to light [src].</span>")

/obj/item/curio/water_candle/proc/self_destruct()
	qdel(src)
