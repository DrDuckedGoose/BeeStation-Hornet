
/mob/living/silicon/new_robot/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	show_laws(0)
