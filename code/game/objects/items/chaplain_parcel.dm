/obj/item/chaplain_parcel
	name = "mysterious mail"
	desc = "A strange parcel, the address is scracthed out."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "mail_large_old"
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

/obj/item/paper/chaplain_tips
	icon_state = "paper_holy"
	show_written_words = FALSE
	name = "Father Grigori's welcome"
	default_raw_text = "Hello, old friend.\n\
	I have sent this letter ahead of time, hoping you shall find it when you arrive at your new post.\n\
	\n\
	I'd like to bestow you with some knowledge I wish I knew when I first started. I believe this will save you much difficulty and help you to become a better shepherd than I ever was.\n\
	You might be familiar already, but if you aren't-\n\
	\n\
	Remember you can make litanies by blessing paper. Interact with them to add litany components. You can probably figure the rest out yourself.\n\
	\n\
	It's important to contain corpses, try to avoid leaving them in the open. You can also embalm them to reduce that awful smell, something that the good Lord will appreciate too.\n\
	\n\
	Placing flowers and other 'memorabilia' in coffins, with a corpse, will also please the Lord, something I recommend you do as often as possible.\n\
	\n\
	I know you don't like using it, but don't forget Old Iron. Punish those undying devils.\
	\n\
	'Haunted' items are more common than you think, be sure to give those ghosts a good wack with your nullrod, rattle them out. I've been told they don't like blessed items either.\
	\n\
	Since it's technically yours anyway, I left the old spectral scanner somehwere in your office. You'll probably make better use of it than me anyway.\
	\n\
	Otherwise, I can't offer much other advice, you'll have to figure out the rest yourself.\n\
	Note I have also sent you a parcel with a surprise inside, I hope you like it.\n\
	\n\
	- Best regards, Grigori."

/obj/item/paper/chaplain_tips/warning
	name = "Father Grigori's warning"
	default_raw_text = "Brother, I fear I have made a grave mistake.\
	\n\
	I have let rot creep into the monastery, it coats everything like a foetid mucus.\
	I can hardly breath, the air demands labour and harbours disease.\
	\n\
	I have failed to make care when laying the dead to rest, and I have let evil nestle within them.\
	Their bodies rot and fester, pleasing the evil I fear that has moved in.\
	\n\
	Do not make my mistake, do not let sloth take you from your tasks.\
	It is our duty to lay the dead to rest, clean and preserved.\
	To deny evil a place to rest.\
	\n\
	Please forgive me.\
	\n\
	- Grigori."
