//Deadchat moveable item
/obj/item/curio/doll
	name = "tattered doll"
	desc = "An old tattered doll. Something seems 'off' about it."
	force = 0
	item_cooldown = 2 MINUTES
	icon_state = "doll"
	///How long can the doll move for per activation
	var/move_time = 1 MINUTES
	var/can_move
	///Ref to ghost movement component
	var/datum/component/deadchat_control/controller

/obj/item/curio/doll/Initialize(mapload, atom/plush)
	. = ..()
	controller = _AddComponent(list(/datum/component/deadchat_control, "democracy", list(
			 "up" = CALLBACK(src, PROC_REF(haunted_step), NORTH),
			 "down" = CALLBACK(src, PROC_REF(haunted_step), SOUTH),
			 "left" = CALLBACK(src, PROC_REF(haunted_step), WEST),
			 "right" = CALLBACK(src, PROC_REF(haunted_step), EAST)), 10 SECONDS))
	//Appearance  / pretty sutff
	if(plush) //Just a check for debug spawns
		//Mask our flesh appearance to the dolls
		add_filter("mask", 1, alpha_mask_filter(icon = icon(plush.icon, plush.icon_state, plush.dir)))
		//Naming
		name = "tattered [plush]"
	//Underlay / dynamic outline
	var/mutable_appearance/MA = new()
	MA.appearance = appearance
	MA.color = "#4d4d4d"
	var/matrix/M = MA.transform
	M.Scale(1.1, 1.1)
	MA.transform = M
	underlays += MA

/obj/item/curio/doll/Destroy()
	. = ..()
	QDEL_NULL(controller)

/obj/item/curio/doll/attack_ghost(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>You can write directions, in chat, to move the doll.\nUP, DOWN, LEFT, RIGHT</span>")

/obj/item/curio/doll/interact(mob/user)
	. = ..()
	activate(user)

/obj/item/curio/doll/activate(datum/user, force)
	. = ..()
	if(!.)
		return
	to_chat(user, "<span class='warning'>You begin to shake [src]...</span>")
	if(do_after(user, 5 SECONDS, src))
		to_chat(user, "<span class='danger'>[src] springs to life!</span>")
		if(isliving(user)) //Can we be so sure?
			var/mob/living/M = user
			M.dropItemToGround(src)
		if(can_move)
			deltimer(can_move)
		can_move = addtimer(CALLBACK(src, PROC_REF(handle_can_move)), move_time, TIMER_STOPPABLE)
		do_punishment()
	else
		to_chat(user, "<span class='notice'>Better not...</span>")
		handle_timer()
	
/obj/item/curio/doll/proc/haunted_step(outcome)
	//We'll do a fancy animation :D
	var/matrix/n_transform = transform
	var/matrix/o_transform = transform
	if(can_move)
		n_transform.Scale(0.7, 1.3)
	else
		Shake()
	animate(src, transform = n_transform, time = 0.25 SECONDS, easing = BACK_EASING | EASE_OUT)
	animate(transform = o_transform, time = 0.15 SECONDS, easing = LINEAR_EASING)
	//We can only move when active
	if(!can_move)
		return
	//Make any mobs drop this before it moves
	if(isliving(loc))
		var/mob/living/M = loc
		M.dropItemToGround(src)
	playsound(get_turf(src), 'sound/effects/magic.ogg', 50, TRUE)
	step(src, outcome)

/obj/item/curio/doll/proc/handle_can_move()
	can_move = null
