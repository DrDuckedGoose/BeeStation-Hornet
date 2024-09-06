/*
	Sub-component for heads
	Is responsible for some important HUD stuff
	//TODO: I want the head or MMI to be resposible for all the law stuf - Racc
*/
/datum/component/endopart/head
	name = "head"
	required_assembly = list(/datum/endo_assembly/item/eyes, /datum/endo_assembly/item/mmi,
	/datum/endo_assembly/item/access_module, /datum/endo_assembly/item/radio, /datum/endo_assembly/item/lamp,
	/datum/endo_assembly/item/ai_controller)
	offset_key = ENDO_OFFSET_KEY_HEAD(1)
	ambient_draw = 1
//Hud Stuff
	///Reference to zone selection hud element
	var/atom/movable/screen/zone_select
	///Intent
	var/atom/movable/screen/act_intent/robot/intent
	///Language menu
	var/atom/movable/screen/language_menu/langauge
	///Health
	var/atom/movable/screen/healths/robot/health
	//Everyone has a modular tablet asshole, it came free with your fucking Xbox
	var/atom/movable/screen/new_robot/modpc/tablet

/datum/component/endopart/head/apply_assembly(datum/source, mob/target)
	. = ..()
	var/mob/living/silicon/new_robot/R = target
	//Put whatever brain that's in us into control of mob/target
	if(!iscarbon(target)) //Remove this check to allow heads with MMIs to control humans when attached
		INVOKE_ASYNC(src, PROC_REF(async_apply_assembly), target)
	//If we don't have eyes, we'll go blind
	var/list/eyes = list()
	SEND_SIGNAL(src, COMSIG_ENDO_LIST_PART, /obj/item/organ/eyes, eyes)
	if(!length(eyes))
		R.become_blind(src)
	else
		R.cure_blind(src)

/datum/component/endopart/head/remove_assembly(datum/source, mob/target)
	. = ..()
	//TODO: Remove ckey control & hud stuff - Racc

/datum/component/endopart/head/apply_hud(datum/source, datum/hud/hud)
	. = ..()
	if(!hud)
		return
	//Zone selection
	if(!zone_select)
		zone_select = new /atom/movable/screen/zone_sel/robot()
	zone_select.hud = hud
	zone_select.update_icon()
	hud.static_inventory += zone_select
	//Intent
	if(!intent)
		intent = new /atom/movable/screen/act_intent/robot()
	intent.icon_state = hud.mymob.a_intent
	intent.hud = hud
	hud.action_intent = intent
	hud.static_inventory += intent
	//Language menu
	if(!langauge)
		langauge = new/atom/movable/screen/language_menu
	langauge.screen_loc = ui_borg_language_menu
	hud.static_inventory += langauge
	//Health
	//TODO: This is kinda weird, the screenloc is predefined, see doing that for the others - Racc
	if(!health)
		health = new /atom/movable/screen/healths/robot()
	health.hud = hud
	hud.healths = health
	hud.infodisplay += health
	//Tablet
	if(!tablet)
		tablet = new /atom/movable/screen/new_robot/modpc()
	tablet.screen_loc = ui_borg_tablet
	tablet.hud = hud
	hud.static_inventory += tablet
	var/mob/living/silicon/new_robot/robot = hud.mymob
	if(robot.modularInterface)
		tablet.vis_contents += robot.modularInterface
	tablet.robot = robot
	//Update hud
	hud.show_hud(HUD_STYLE_STANDARD)

/datum/component/endopart/head/remove_hud(datum/source, datum/hud/hud)
	. = ..()
	if(!hud)
		return
	//Zone
	zone_select?.hud = null
	hud.static_inventory -= zone_select
	//intent
	intent?.hud = null
	hud.action_intent = null
	hud.static_inventory -= intent
	//langauge
	hud.static_inventory -= langauge
	//Tablet
	tablet?.hud = null
	hud.static_inventory -= tablet
	//healths
	health?.hud = null
	hud.healths = null
	hud.infodisplay -= health

	hud.show_hud(HUD_STYLE_STANDARD)

/datum/component/endopart/head/life(datum/source, mob/living/M)
	. = ..()
	//Update our health hud
	if(!health || !istype(M))
		return
	if(M.stat == DEAD)
		health.icon_state = "health7"
		return
	//Get health as a percentage, then get it on a scale of 0-6, then use that as the index for our icon
	var/stage = 6-clamp(round((M.health/M.maxHealth)*6), 0, 6) //0 is healthy, 6 is dying
	health.icon_state = "health[stage]"

/datum/component/endopart/head/proc/async_apply_assembly(mob/target)
	var/datum/endo_assembly/item/mmi/assembly = locate(/datum/endo_assembly/item/mmi) in required_assembly
	var/obj/item/mmi/mmi = locate(/obj/item/mmi) in assembly?.parts
	if(!mmi?.brainmob?.ckey || is_banned_from(mmi.brainmob.ckey, JOB_NAME_CYBORG) || mmi.brainmob.client.get_exp_living(TRUE) <= MINUTES_REQUIRED_BASIC)
		return
	mmi?.transfer_identity(target)
