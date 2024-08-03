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
