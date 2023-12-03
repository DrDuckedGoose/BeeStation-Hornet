//Shows the current spectral trespass
/obj/item/curio/tally
	name = "damaged tally"
	desc = "A damged tally. The counter seems broken."
	icon_state = "tally"
	force = 0
	item_cooldown = 10 SECONDS

/obj/item/curio/tally/interact(mob/user)
	. = ..()
	activate(user)
	
/obj/item/curio/tally/activate(datum/user, force)
	. = ..()
	if(!.)
		return
	to_chat(user, "<span class='warning'>You begin to shake [src]...</span>")
	if(do_after(user, 1 SECONDS, src))
		var/message = "[src] reads, [SSspooky.spectral_trespass]!"
		balloon_alert(user, message)
		to_chat(user, "<span class='warning'>[message]!</span>")
		Shake()
		//No punishment
	else
		to_chat(user, "<span class='notice'>Better not...</span>")
