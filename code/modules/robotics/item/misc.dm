/*
	Debug tool to add endo components to anything
*/
/obj/item/endopart_enator
	name = "endopartenator"
	icon_state = "madeyoulook"
	///What component type are we making the target?
	var/component_type

/obj/item/endopart_enator/interact(mob/user)
	. = ..()
	component_type = tgui_input_list(user, "Pick Component", "Pick Component", subtypesof(/datum/component/endopart))

/obj/item/endopart_enator/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!target.GetComponent(component_type))
		target.AddComponent(component_type)
		to_chat(user, "<span class='notice'>Added [component_type] to [target].</span>")

/*
	Debug tool to remove limbs
*/
/obj/item/delimber
	name = "delimber"
	icon_state = "madeyoulook"
	///Are we deleting the limb after we remove it
	var/delete_limb = TRUE

/obj/item/delimber/interact(mob/user)
	. = ..()
	delete_limb = !delete_limb
	to_chat(user, "<span class='notice'>You toggle 'delete limbs' to [delete_limb ? "on" : "off"].</span>")

/obj/item/delimber/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/mob/living/carbon/c_user = user
	var/mob/living/carbon/c_target = target
	if(!istype(c_user) || !istype(c_target))
		return
	var/limb = c_user.get_combat_bodyzone(c_target)
	var/obj/item/bodypart/B = c_target.get_bodypart(limb)
	B?.dismember()
	if(delete_limb)
		qdel(B)

/*
	Debug tool to add limbs
*/
/obj/item/relimber
	name = "relimber"
	icon_state = "madeyoulook"
	///What kind of limb are we trying to add
	var/obj/item/bodypart/bodypart
	///Baked list of bodyparts so we don't kill the server
	var/list/bodypart_list

/obj/item/relimber/Initialize(mapload)
	. = ..()
	bodypart_list = typesof(/obj/item/bodypart)

/obj/item/relimber/interact(mob/user)
	. = ..()
	bodypart = tgui_input_list(user, "Pick Limb", "Change Limb", bodypart_list)

/obj/item/relimber/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/mob/living/carbon/c_target = target
	if(!istype(c_target))
		return
	var/obj/item/bodypart/temp_bodypart = new bodypart(get_turf(target))
	temp_bodypart.attach_limb(c_target)

/*
	Temp AI brain
*/

/obj/item/food/bbqribs/ai_brain
//TODO: Do we consider moving these to the actual AI brain item? - Racc
	var/deployed = FALSE
	var/mob/living/silicon/ai/mainframe = null
	//TODO: - Racc
	//var/datum/action/innate/undeployment/undeployment_action = new

/obj/item/food/bbqribs/ai_brain/proc/undeploy()
	return
	//TODO: - Racc
	/*
	if(!deployed || !mind || !mainframe)
		return
	mainframe.redeploy_action.Grant(mainframe)
	mainframe.redeploy_action.last_used_shell = src
	mind.transfer_to(mainframe)
	deployed = FALSE
	mainframe.deployed_shell = null
	undeployment_action.Remove(src)
	if(radio) //Return radio to normal
		radio.recalculateChannels()
	if(!QDELETED(builtInCamera))
		builtInCamera.c_tag = real_name	//update the camera name too
	//diag_hud_set_aishell()
	mainframe.diag_hud_set_deployed()
	if(mainframe.laws)
		mainframe.laws.show_laws(mainframe) //Always remind the AI when switching
	if(!mainframe.eyeobj)
		mainframe.create_eye()
	mainframe.eyeobj.setLoc(get_turf(src))
	transfer_observers_to(mainframe.eyeobj) // borg shell to eyemob
	mainframe.transfer_observers_to(mainframe.eyeobj) // ai core to eyemob
	mainframe = null
	*/
