/datum/keybinding/shell
	category = CATEGORY_ROBOT
	weight = WEIGHT_ROBOT

/datum/keybinding/shell/can_use(client/user)
	if(iscyborg(user.mob))
		var/mob/living/silicon/new_robot/our_shell = user.mob
		if(our_shell.get_shell())
			return TRUE
		else
			return FALSE
	else
		return FALSE

/datum/keybinding/shell/undeploy
	category = CATEGORY_AI
	keys = list("=")
	name = "undeploy"
	full_name = "Disconnect from shell"
	description = "Returns you to your AI core"
	keybind_signal = COMSIG_KB_SILION_UNDEPLOY_DOWN

/datum/keybinding/shell/undeploy/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/silicon/new_robot/our_shell = user.mob
	var/obj/item/mmi/ai_brain/shell = our_shell.get_shell()
	shell?.undeploy()
	return TRUE
