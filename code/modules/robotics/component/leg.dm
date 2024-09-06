/*
	Sub-component for legs
	Responsible for move speed
*/
/datum/component/endopart/leg
	name = "leg"
	required_assembly = list(/datum/endo_assembly/item/interaction/stack/wire)

/datum/component/endopart/leg/Initialize(_start_finished, _offset_key = ENDO_OFFSET_KEY_LEG(1))
	. = ..()
	offset_key = _offset_key

/datum/component/endopart/leg/apply_assembly(datum/source, mob/target)
	. = ..()
	if(!(check_completion() & ENDO_ASSEMBLY_INCOMPLETE))
		//If we're not incomplete, we'll add our speed benehfit
		var/datum/movespeed_modifier/robot_varspeed/speed = new()
		target.add_or_update_variable_movespeed_modifier(speed, multiplicative_slowdown = 2)
		return
	//If we're unfinished, add paralysis trait for human stuff
	var/obj/item/bodypart/B = parent
	if(istype(B))
		ADD_TRAIT(B, TRAIT_PARALYSIS, src)
		B.update_disabled()
	//If it's a bot, just slow them down
	if(!iscarbon(target) && !iscyborg(target))
		target.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/limbless, multiplicative_slowdown = 6)

/datum/movespeed_modifier/robot_varspeed
	variable = TRUE
