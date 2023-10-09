/obj/effect/spectral_trespass
	name = "holy blessing"
	desc = "Holy energies interfere with ethereal travel at this location."
	icon = 'icons/obj/religion.dmi'
	icon_state = null
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	///How long we goof around for
	var/lifetime = 2.5 SECONDS

/obj/effect/spectral_trespass/Initialize(mapload)
	. = ..()
	for(var/obj/effect/spectral_trespass/S in loc)
		if(S != src)
			return INITIALIZE_HINT_QDEL
		var/image/I = image(icon = 'icons/obj/religion.dmi', icon_state = "skull", layer = ABOVE_MOB_LAYER, loc = src)

		//Filter
		I.filters += filter(type = "wave", x = 1, y = 0, size = 1, offset = 1)
		I.filters += filter(type = "bloom", size = 1, offset = 1, threshold = "#666")
		//Animation
		animate(src, alpha = 0, time = lifetime)
		animate(src, pixel_y = 32, time = lifetime)
		animate(I.filters[1], offset = 3, time = lifetime)

		add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/holyAware, "spectral trespass", I)
		addtimer(CALLBACK(src, PROC_REF(finish)), lifetime)

/obj/effect/spectral_trespass/proc/finish()
	SIGNAL_HANDLER

	Destroy()
