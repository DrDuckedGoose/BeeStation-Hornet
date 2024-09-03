
/mob/living/silicon/new_robot/gib_animation()
	new /obj/effect/temp_visual/gib_animation(loc, "gibbed-r")

/mob/living/silicon/new_robot/spawn_dust()
	new /obj/effect/decal/remains/robot(loc)

/mob/living/silicon/new_robot/dust_animation()
	new /obj/effect/temp_visual/dust_animation(loc, "dust-r")

/mob/living/silicon/new_robot/death(gibbed)
	if(stat == DEAD)
		return
	if(!gibbed)
		logevent("FATAL -- SYSTEM HALT")
		modularInterface.shutdown_computer()
	. = ..()
	cover_open = TRUE //unlock cover
	if(!QDELETED(builtInCamera) && builtInCamera.status)
		builtInCamera.toggle_cam(src,0)
	toggle_headlamp(TRUE) //So borg lights are disabled when killed.
	unbuckle_all_mobs(TRUE)
	SSblackbox.ReportDeath(src)
