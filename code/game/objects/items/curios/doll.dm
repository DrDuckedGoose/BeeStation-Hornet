/obj/item/curio/doll
	name = "tattered doll"
	desc = "An old tattered doll. It seems to have something inserted in its mouth."
	icon_state = "towel"
	///How long can the doll move for per activation
	var/move_time = 1 MINUTES
	var/can_move
	///Ref to ghost movement component
	var/datum/component/deadchat_control/controller

/obj/item/curio/doll/Initialize(mapload)
	. = ..()
	controller = AddComponent(list(/datum/component/deadchat_control, "democracy", list(
			 "up" = CALLBACK(src, PROC_REF(haunted_step), NORTH),
			 "down" = CALLBACK(src, PROC_REF(haunted_step), SOUTH),
			 "left" = CALLBACK(src, PROC_REF(haunted_step), WEST),
			 "right" = CALLBACK(src, PROC_REF(haunted_step), EAST)), 10 SECONDS))

/obj/item/curio/doll/Destroy()
	. = ..()
	QDEL_NULL(controller)

/obj/item/curio/doll/activate(datum/user, force)
	. = ..()
	if(!.)
		return
	if(can_move)
		deltimer(can_move)
	can_move = addtimer(CALLBACK(src, PROC_REF(handle_can_move)), move_time, TIMER_STOPPABLE)
	
/obj/item/curio/doll/proc/haunted_step(outcome)
	//We'll do a fancy animation :D
	var/matrix/n_transform = transform
	var/matrix/o_transform = transform
	n_transform.Scale(1, 1.5)
	animate(src, transform = n_transform, time = 0.25 SECONDS, easing = BACK_EASING | EASE_OUT)
	animate(transform = o_transform, time = 0.25 SECONDS, easing = LINEAR_EASING)
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
