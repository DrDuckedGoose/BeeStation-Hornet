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
	default_raw_text = "Hello, _____.\n\
	I have sent this letter ahead of time, hoping you shall find it when you arrive at your new post.\n\
	\n\
	I'd like to impart you with some things I wish I knew when I first started. I believe this will help you along your path, and help you to become a better shepherd than I ever was.\n\
	You might be familiar already, but if you aren't-\n\
	\n\
	Remember you can make litanies by blessing paper. Interact with them to add litany components. You can probably figure the rest out yourself.\n\
	\n\
	The sisters here are always placing flowers and other 'memorabilia' in the coffins, I think it'd be good for you to aswell. Remember the rule of threes.\n\
	\n\
	Since it's technically yours anyway, I left the old spectral scanner somehwere in your office. You'll probably make better use of it than me anyway. Excuse the condition.\n\
	\n\
	Finally, I sent you a parcel with a surprise inside, I hope you like it.\n\
	\n\
	Best regards,\n\
	~ Grigori."

/obj/item/paper/chaplain_tips/warning
	name = "Father Grigori's warning"
	default_raw_text = "_____, I fear I have made a grave mistake.\n\
	\n\
	I have let rot creep into the monastery. It coats everything, like a foetid mucus.\n\
	I can hardly breath, the air is filled with disease.\n\
	\n\
	I have failed to take care when laying the dead to rest, and I have let evil nestle within them.\n\
	Their bodies rot and fester.\n\
	\n\
	Do not make my mistake.\n\
	It is our duty to lay the dead to rest, clean and preserved.\n\
	To deny evil a place to rest.\n\
	\n\
	Please forgive me.\n\
	\n\
	~ Grigori."

/obj/item/paper/chaplain_tips/closet
	name = "Vatican statement"
	default_raw_text = "Dear _____, we hope you have settled in well and begun the good work.\n\
	\n\
	As a hand of the vatican, we'd like to bestow you with some necesary tools to complete your tasks.\n\
	\n\
	Among them, you will find-\n\
	* Old Iron. Grigori told us you'd be reluctant to use it, but we urge you to understand the oppurtunity it provides, should you meet an unrelenting force.\n\
	* The Chapter of Occlusion. Please use it responsibly, Lord knows the others didn't.\n\
	* Mysterious Shard. One of twelve, we're not quite sure what they do. Please take the oppurtunity of your posting on a research station to study it.\n\
	* Heart. Just a heart, Grigori insisted. Please don't fret, it is of the non-human variety.\n\
	\n\
	That will be all for now. God be with you _____.\n\
	\n\
	~ Claude Frollo."

/obj/item/paper/chaplain_tips/bodies
	name =  "Statement of retrieval"
	default_raw_text = ""

/obj/item/paper/chaplain_tips/bodies/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/paper/chaplain_tips/bodies/LateInitialize()
	. = ..()
	if(!GLOB?.uncounted_bodies)
		qdel(src) //Hint doesn't work here
		return
	default_raw_text = "Dear _____, it seems that [GLOB.uncounted_bodies] unaccounted bodies remain on the station premises.\n\
	We have been informed this may be an issue for you, and are acting accordingly."
	add_raw_text(default_raw_text)

//TODO: Remove this when private testing is over - Racc
/obj/item/paper/racc_dev_tip
	icon_state = "paper_dev"
	show_written_words = FALSE
	name = "Message from Racc-Off, the Developer"
	default_raw_text = "Heya, champ.\n\
	\n\
	I've strewn these papers across the station to ensure you read them, but they all say the same thing.\n\
	Just some quick words of advice, so you can get the full experience while you're playing alone / testing for me.\n\
	\n\
	* If you get stuck, be sure to examine objects and read descriptions, this includes yourself in some scenarios.\n\
	* If you didn't get one from the parcel, please spawn a compass, you'll need it on singleplayer.\n\
	* Remember to do all the chaplain setup, like selecting a sect at the altar.\n\
	* I hope you're enticed to read the papers strewn acrossed the chapel, they will be you in-game intro to all this.\n\
	* Don't forget to check the back room, next to your office.\n\
	\n\
	That's all champ, have fun!\n\
	\n\
	~ Racc"
