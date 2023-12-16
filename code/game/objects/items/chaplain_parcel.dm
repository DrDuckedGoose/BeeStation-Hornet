/obj/item/chaplain_parcel
	name = "mysterious mail"
	desc = "A strange parcel, the address is scracthed out."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "mail_large"
	///What options do we have to give
	var/list/give_options = list(/obj/item/curio/compass, /obj/item/curio/tally)

/obj/item/chaplain_parcel/interact(mob/user)
	. = ..()
	var/list/options = list()
	var/list/associated = list()
	for(var/obj/item/I as() in give_options)
		var/datum/radial_menu_choice/RC = new()
		RC.image = image(initial(I.icon), icon_state = initial(I.icon_state))
		RC.info = initial(I.desc)
		options += list(initial(I.name) = RC)
		associated += list(initial(I.name) = I)
	var/obj/item/I = associated[show_radial_menu(user, src, options, tooltips = TRUE)]
	if(I)
		var/turf/T = get_turf(src)
		I = new I(T)
		playsound(T, 'sound/items/poster_ripped.ogg', 60)
		user.dropItemToGround(src, TRUE, TRUE)
		user.put_in_hands(I)
		qdel(src)
