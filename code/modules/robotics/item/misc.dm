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

/obj/item/mmi/ai_brain
	var/deployed = FALSE
	var/mob/living/silicon/ai/mainframe = null
	var/datum/action/innate/undeployment/undeployment_action

/obj/item/mmi/ai_brain/Initialize(mapload)
	. = ..()
	undeployment_action = new(null, src)

/obj/item/mmi/ai_brain/proc/undeploy()
	if(!deployed || !robot.mind || !mainframe)
		return
	mainframe.redeploy_action.Grant(mainframe)
	mainframe.redeploy_action.last_used_shell = src
	robot.mind.transfer_to(mainframe)
	deployed = FALSE
	mainframe.deployed_shell = null
	undeployment_action.Remove(robot)
	if(robot.radio) //Return radio to normal
		robot.radio.recalculateChannels()
	if(!QDELETED(robot.builtInCamera))
		robot.builtInCamera.c_tag = robot.real_name	//update the camera name too
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

/obj/item/mmi/ai_brain/proc/deploy_init(var/mob/living/silicon/ai/AI)
	robot.real_name = "[robot.real_name] shell [rand(100, 999)] - [robot.designation]"	//Randomizing the name so it shows up separately in the shells list
	robot.name = robot.real_name
	if(!QDELETED(robot.builtInCamera))
		robot.builtInCamera.c_tag = robot.real_name	//update the camera name too
	mainframe = AI
	deployed = TRUE
	robot.connected_ai = mainframe
	mainframe.connected_robots |= src
	robot.toggle_law_sync(TRUE)
	robot.lawsync()
	if(robot.radio && AI.radio) //AI keeps all channels, including Syndie if it is a Traitor
		if(AI.radio.syndie)
			robot.radio.make_syndie()
		robot.radio.subspace_transmission = TRUE
		robot.radio.channels = AI.radio.channels
		for(var/chan in robot.radio.channels)
			robot.radio.secure_radio_connections[chan] = add_radio(robot.radio, GLOB.radiochannels[chan])

/datum/action/innate/undeployment
	name = "Disconnect from shell"
	desc = "Stop controlling your shell and resume normal core operations."
	icon_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "ai_core"
	///Ref to the AI controller
	var/obj/item/mmi/ai_brain/ai_controller

/datum/action/innate/undeployment/New(Target, _ai_controller)
	. = ..()
	ai_controller = _ai_controller

/datum/action/innate/undeployment/Trigger()
	if(!..())
		return FALSE
	ai_controller.undeploy()
	return TRUE
