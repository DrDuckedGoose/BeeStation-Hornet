/*
	Sub-component for legs
	Responsible for move speed
*/
/datum/component/endopart/leg
	name = "leg"
	required_assembly = list(/datum/endo_assembly/item/interaction/stack/wire)
	///What move speed bonus does this leg have. < 0 is fast, > 0 is slow
	var/speed_bonus = 0
	var/datum/movespeed_modifier/robot_varspeed/speed_datum
	///Should we paralyze this arm if it's incomplete
	var/paralyze = TRUE

/datum/component/endopart/leg/Initialize(_start_finished, _offset_key = ENDO_OFFSET_KEY_LEG(1))
	. = ..()
	offset_key = _offset_key
	speed_datum = new()
	speed_datum.id = "[ref(src)]"

/datum/component/endopart/leg/refresh_assembly(datum/source, mob/target)
	. = ..()
	if(!(check_completion() & ENDO_ASSEMBLY_INCOMPLETE))
		//If we're not incomplete, we'll add our speed benehfit
		target.add_or_update_variable_movespeed_modifier(speed_datum, multiplicative_slowdown = speed_bonus)
		return
	//If we're unfinished, add paralysis trait for human stuff
	var/obj/item/bodypart/B = parent
	if(istype(B) && paralyze)
		ADD_TRAIT(B, TRAIT_PARALYSIS, src)
		B.update_disabled()
	//If it's a bot, just slow them down
	if(!iscarbon(target) && !iscyborg(target))
		target.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/limbless, multiplicative_slowdown = 6)

/datum/component/endopart/leg/remove_assembly(datum/source, mob/target)
	. = ..()
	target.remove_movespeed_modifier(speed_datum)
	if(!iscarbon(target) && !iscyborg(target))
		target.remove_movespeed_modifier(/datum/movespeed_modifier/limbless)

/datum/movespeed_modifier/robot_varspeed
	variable = TRUE
