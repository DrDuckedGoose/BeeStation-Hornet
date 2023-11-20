#define LIFE_TIME 2.5 SECONDS

/obj/effect/spectral_trespass
	name = "holy blessing" //TODO: Change this name/desc - Racc
	desc = "Holy energies interfere with ethereal travel at this location."
	icon = 'icons/obj/religion.dmi'
	icon_state = null
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/spectral_trespass/Initialize(mapload, result = 0)
	. = ..()
	//TODO: What the fuck is this code, fix it - Racc
	for(var/obj/effect/spectral_trespass/S in loc)
		if(S != src)
			return INITIALIZE_HINT_QDEL
		var/image/I = image(icon = 'icons/obj/religion.dmi', icon_state = result ? "cross_good" : "cross_bad", layer = ABOVE_MOB_LAYER, loc = src)

		//Filter
		I.filters += filter(type = "wave", x = 1, y = 0, size = 1, offset = 1)
		I.filters += filter(type = "bloom", size = 1, offset = 1, threshold = "#666")
		//Animation
		animate(src, alpha = 0, time = LIFE_TIME)
		animate(src, pixel_y = (result ? 32 : -32), time = LIFE_TIME)
		animate(I.filters[1], offset = 3, time = LIFE_TIME)
		//Only the chosen can see it
		add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/holyAware, "spectral trespass", I)

		addtimer(CALLBACK(src, PROC_REF(finish)), LIFE_TIME)

/obj/effect/spectral_trespass/proc/finish()
	SIGNAL_HANDLER

	Destroy()

#undef LIFE_TIME
