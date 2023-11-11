//TODO: Add antiharddel stuff relating to owner - Racc
/datum/litany_component
	///Who litany item does this belong to?
	var/obj/item/litany/owner
	///name of this component
	var/name = ""
	///icon path for this component's symbol
	var/icon = 'icons/obj/religion.dmi'
	///state for this component's symbol
	var/icon_state = ""
	///What did we effect - Helper for the components that use it
	var/atom/target

/datum/litany_component/New(obj/item/litany/_owner)
	. = ..()
	owner = _owner
	RegisterSignal(_owner, COMSIG_LITANY_ACTIVATE, PROC_REF(activate))
	RegisterSignal(_owner, COMSIG_LITANY_REMOVE, PROC_REF(remove))

/datum/litany_component/proc/activate()
	return

/datum/litany_component/proc/remove()
	handle_target_removal()
	return

/datum/litany_component/proc/register_target(atom/_target)
	target = _target
	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(handle_target_removal))

///For removal
/datum/litany_component/proc/handle_target_removal()
	if(target)
		UnregisterSignal(target, COMSIG_PARENT_QDELETING)
		target = null

/*
	ALPHA
	1:0

	pushes the current location to the stack
*/
/datum/litany_component/alpha
	name = "alpha"
	icon_state = "alpha"

/datum/litany_component/alpha/activate()
	owner.info_stack += owner.loc

/*
	BETA
	0:1
	
	Adds an outline to the atom on the top of the stack, and pops it
*/
/datum/litany_component/beta
	name = "beta"
	icon_state = "beta"

/datum/litany_component/beta/activate()
	var/atom/A = owner.info_stack[length(owner.info_stack)]
	if(isatom(A) && !A.get_filter("litany_outline"))
		A.add_filter("litany_outline", 10, outline_filter(1, rgb(255, 255, 255)))
		register_target(A)
	owner.info_stack -= A

/datum/litany_component/beta/handle_target_removal()
	target?.remove_filter("litany_outline")
	return ..()

/*
	OMEGA
	0:0

	:D
*/
/datum/litany_component/omega
	name = "omega"
	icon_state = "omega"
