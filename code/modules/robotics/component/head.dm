/*
	Sub-component for heads
	Is responsible for some important HUD stuff
	//TODO: I want the head or MMI to be resposible for all the law stuf - Racc
*/
/datum/component/endopart/head
	name = "head"
	required_assembly = list(/datum/endo_assembly/item/eyes, /datum/endo_assembly/item/mmi,
	/datum/endo_assembly/item/access_module, /datum/endo_assembly/item/radio, /datum/endo_assembly/item/lamp,)
	///datum/endo_assembly/item/ai_controller)
	offset_key = ENDO_OFFSET_KEY_HEAD(1)
	ambient_draw = 1
//Eye light
	//Light overlay
	var/mutable_appearance/eye_lights
	//Light overlay key
	var/light_overlay_key = "generic_lights"
//Hat Stuff
	///Hats we DO NOT fuck with
	var/list/blacklisted_hats = list( //Hats that don't really work on borgos
	/obj/item/clothing/head/helmet/space/santahat,
	/obj/item/clothing/head/utility/welding,
	/obj/item/clothing/head/helmet/space/eva,
	)
	///Our hat, if we have one
	var/obj/item/hat
	///Hat overlay
	var/mutable_appearance/hat_overlay
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

/datum/component/endopart/head/Initialize(_start_finished)
	eye_lights = mutable_appearance('icons/mob/augmentation/augments.dmi', "")
	return ..()

/datum/component/endopart/head/Destroy(force, silent)
	. = ..()
	QDEL_NULL(eye_lights)

/datum/component/endopart/head/refresh_assembly(datum/source, mob/target)
	. = ..()
	var/mob/living/silicon/new_robot/R = target
	//If we don't have eyes, we'll go blind
	var/list/eyes = list()
	SEND_SIGNAL(src, COMSIG_ENDO_LIST_PART, /obj/item/organ/eyes, eyes)
	if(!length(eyes))
		R.become_blind(src)
	else
		R.cure_blind(src)

/datum/component/endopart/head/remove_assembly(datum/source, mob/target)
//Hat stuff
	if(hat_overlay)
		target.cut_overlay(hat_overlay)
		QDEL_NULL(hat_overlay)
	if(hat)
		hat.forceMove(get_turf(parent))
		hat = null
//Control stuff
	//TODO: Remove ckey control & hud stuff - Racc
	return ..()

/datum/component/endopart/head/apply_hud(datum/source, datum/hud/hud)
	. = ..()
	if(!hud)
		return
	//Zone selection
	if(!zone_select)
		zone_select = new /atom/movable/screen/zone_sel/robot()
	zone_select.hud = hud
	zone_select.update_icon()
	hud.static_inventory |= zone_select
	//Intent
	if(!intent)
		intent = new /atom/movable/screen/act_intent/robot()
	intent.icon_state = hud.mymob.a_intent
	intent.hud = hud
	hud.action_intent = intent
	hud.static_inventory |= intent
	//Language menu
	if(!langauge)
		langauge = new/atom/movable/screen/language_menu
	hud.static_inventory |= langauge
	//Health
	if(!health)
		health = new /atom/movable/screen/healths/robot()
	health.hud = hud
	hud.healths = health
	hud.infodisplay += health
	//Tablet
	if(!tablet)
		tablet = new /atom/movable/screen/new_robot/modpc()
	tablet.hud = hud
	hud.static_inventory |= tablet
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

/datum/component/endopart/head/update_icons(datum/source, atom/target)
	. = ..()
	var/mob/living/silicon/new_robot/R = target
	if(!istype(R))
		return
	R.cut_overlay(eye_lights)
	if(R.stat == DEAD || R.IsUnconscious() || !R.powered)
		return
	var/list/lamps = list()
	SEND_SIGNAL(R.chassis, COMSIG_ENDO_LIST_PART, /datum/endo_assembly/item/lamp, lamps)
	var/datum/endo_assembly/item/lamp/lamp = length(lamps) ? lamps[1] : null
	//If the borg has been flashed recently, we'll bat our pretty eyes
	if(R.last_flashed && R.last_flashed + FLASHED_COOLDOWN >= world.time)
		eye_lights.icon_state = "[light_overlay_key]_fl"
	//We lampin'
	else if(lamp?.lamp_enabled)
		eye_lights.icon_state = "[light_overlay_key]_l"
		eye_lights.color = lamp.lamp_color
		eye_lights.plane = ABOVE_LIGHTING_PLANE
	//We aint lampin'
	else
		eye_lights.icon_state = "[light_overlay_key]_e[R.ratvar ? "_r" : ""]"
		eye_lights.color = COLOR_WHITE
		eye_lights.plane = ABOVE_LIGHTING_PLANE
	R.add_overlay(eye_lights)

/datum/component/endopart/head/proc/can_wear(var/obj/item/clothing/head/hat)
	return (istype(hat) && !is_type_in_typecache(hat, blacklisted_hats))

/datum/component/endopart/head/proc/place_on_head(obj/item/new_hat)
	if(hat) //if we already have a hat, remove it
		hat.forceMove(get_turf(parent))
	hat = new_hat
	new_hat.forceMove(parent)
	//Icon ops
	var/mob/living/silicon/new_robot/R = assembled_mob
	if(!istype(R))
		return
	hat_overlay = hat.build_worn_icon(default_icon_file = 'icons/mob/clothing/head/default.dmi')
	R.chassis_component.apply_offset(src, offset_key, hat_overlay)
	R.add_overlay(hat_overlay)
