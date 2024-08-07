#define SHORT 5/7
#define TALL 7/5

/datum/element/squish
	element_flags = ELEMENT_DETACH

/datum/element/squish/Attach(datum/target, duration)
	. = ..()
	if(!iscarbon(target))
		return ELEMENT_INCOMPATIBLE

	var/mob/living/carbon/C = target
	var/was_lying = C.body_position == LYING_DOWN
	addtimer(CALLBACK(src, PROC_REF(Detach), C, was_lying), duration)

	C.transform = C.transform.Scale(TALL, SHORT)

/datum/element/squish/Detach(mob/living/carbon/C, was_lying)
	. = ..()
	if(istype(C))
		var/is_lying = C.body_position == LYING_DOWN

		if(was_lying == is_lying)
			C.transform = C.transform.Scale(SHORT, TALL)
		else
			C.transform = C.transform.Scale(TALL, SHORT)

#undef SHORT
#undef TALL
