/datum/litany_component
	///Who litany item does this belong to?
	var/obj/item/litany/owner
	///name of this component
	var/name = ""
	///brief description for this component - '[Any] : [Any]'
	var/desc = ""
	///icon path for this component's symbol
	var/icon = 'icons/obj/religion.dmi'
	///state for this component's symbol
	var/icon_state = ""
	///What did we effect - Helper for the components that use it
	var/atom/target
	///How much does this component cost - in holy favour, so typically in the 100s
	var/cost = 0
	///How much time does this component add to the cooldown
	var/cooldown = 0 SECONDS

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
	desc = "\[Any] : \[None]"

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
	desc = "\[None] : \[Any]"

/datum/litany_component/beta/activate()
	var/atom/A = owner.info_stack[length(owner.info_stack)]
	if(isatom(A) && !A.get_filter("litany_outline"))
		//Don't let cultists get blessed, wizards can be though
		var/mob/living/M = A
		if(isliving(A) && !(iscultist(M) || is_servant_of_ratvar(M)) || !isliving(A))
			A.add_filter("litany_outline", 10, outline_filter(1, rgb(255, 255, 255)))
			register_target(A)
	owner.info_stack -= A

/datum/litany_component/beta/handle_target_removal()
	target?.remove_filter("litany_outline")
	return ..()

/*
	OMEGA
	0:1

	Reduces rot and buffs rot holy favor and adds the holy trait, etc. Also sets cultists on fire & stuns them
*/
/datum/litany_component/omega
	name = "omega"
	icon_state = "omega"
	cooldown = 3 SECONDS
	desc = "\[None] : \[Any]"
	///Was the target blessed before? - rot
	var/blessed_before = FALSE

/datum/litany_component/omega/activate()
	var/atom/A = owner.info_stack[length(owner.info_stack)]
	if(isatom(A))
		//Generic holy buff
		ADD_TRAIT(A, TRAIT_HOLY, "litany")
		//Generic bless
		A.bless(null, owner)
		//Rot
		var/datum/component/rot/R = A.GetComponent(/datum/component/rot)
		blessed_before = R?.blessed
		R?.blessed = TRUE
		R?.favor_modifier += 1
		//Cult stuff
		var/mob/living/M = A
		if(isliving(A) && (iscultist(M) || is_servant_of_ratvar(M)))
			M.adjust_fire_stacks(5)
			M.IgniteMob()
			M.Stun(3 SECONDS)
			M.jitteriness = min(M.jitteriness+4,10)
		register_target(A)
	owner.info_stack -= A

/datum/litany_component/omega/handle_target_removal()
	//Generic holy buff
	if(target)
		REMOVE_TRAIT(target, TRAIT_HOLY, "litany")
	//Rot
	var/datum/component/rot/R = target?.GetComponent(/datum/component/rot)
	R?.blessed = blessed_before
	R?.favor_modifier -= 1
	return ..()

/*
	GAMMA
	0:1
	
	Reveals a mob's real name
*/
/datum/litany_component/gamma
	name = "gamma"
	icon_state = "gamma"
	desc = "\[Mob] : \[String]"

/datum/litany_component/gamma/activate()
	var/atom/A = owner.info_stack[length(owner.info_stack)]
	if(ismob(A))
		var/mob/M = A
		owner.info_stack += M.mind.name
	owner.info_stack -= A

/*
	SIGMA balls
	1:0

	Stops rot
*/
/datum/litany_component/sigma
	name = "sigma"
	icon_state = "alpha"
	cooldown = 3 SECONDS
	desc = "\[Mob] : \[None]"
	cost = 100
	///The original state of the rot variable
	var/old_trespass_state

/datum/litany_component/sigma/activate()
	var/atom/A = owner.info_stack[length(owner.info_stack)]
	if(isatom(A))
		var/datum/component/rot/R = A.GetComponent(/datum/component/rot)
		old_trespass_state = R?.make_trespass
		R?.make_trespass = FALSE
	owner.info_stack -= A

/datum/litany_component/sigma/handle_target_removal()
	//Rot
	var/datum/component/rot/R = target?.GetComponent(/datum/component/rot)
	R?.make_trespass = old_trespass_state
	return ..()
