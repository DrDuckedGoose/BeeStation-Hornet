/*
	Sub-component for legs
	blah blah blah
*/
/datum/component/endopart/leg
	name = "leg"
	required_assembly = list(/datum/endo_assembly/item/wire)

/datum/component/endopart/leg/Initialize(_offset_key = ENDO_OFFSET_KEY_LEG(1))
	. = ..()
	offset_key = _offset_key

/datum/component/endopart/leg/apply_assembly(datum/source, mob/target)
	. = ..()
	//Unfinished legs shenanigans
	if(!(check_completion() & ENDO_ASSEMBLY_INCOMPLETE))
		return
	var/obj/item/bodypart/B = parent
	if(istype(B))
		ADD_TRAIT(B, TRAIT_PARALYSIS, src)
		B.update_disabled()
	if(!iscarbon(target) && !iscyborg(target))
		target.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/limbless, multiplicative_slowdown = 6)

