// === Console ===
/obj/machinery/computer/slime_cloner_console
	name = "slime cloner console"
	desc = "More slimes per slime is the future."
	///Cloning hardware
	var/obj/machinery/slime_cloner/synced_cloner
	///Inserted slime gun
	var/obj/item/slime_gun/inserted_gun
	///Sample selected for cloning
	var/mob/living/simple_animal/slime_uni/slime_sample

/obj/machinery/computer/slime_cloner_console/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	sync_devices()

/obj/machinery/computer/slime_cloner_console/Destroy()
	. = ..()
	if(inserted_gun)
		inserted_gun.forceMove(get_turf(src))

/obj/machinery/computer/slime_cloner_console/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/slime_gun))
		if(inserted_gun)
			inserted_gun.forceMove(get_turf(src)) //remove old gun if it exists
		I.forceMove(src)
		inserted_gun = I
		to_chat(user, "<span class='notice'> You insert [I] into [src].</span>")
		return FALSE

/obj/machinery/computer/slime_cloner_console/AltClick(mob/user)
	if(synced_cloner)
		synced_cloner.do_clone(slime_sample)
	else
		sync_devices()

///Look for nearby relevant devices & sync them to this console
/obj/machinery/computer/slime_cloner_console/proc/sync_devices()
	for(var/obj/machinery/slime_cloner/S in oview(3,src))
		synced_cloner = S
	if(synced_cloner)
		RegisterSignal(synced_cloner, COMSIG_PARENT_QDELETING, .proc/handle_del)

/obj/machinery/computer/slime_cloner_console/proc/handle_del(atom/A)
	if(synced_cloner)
		synced_cloner = null

// === Cloner ===
/obj/machinery/slime_cloner
	name = "slime cloner"
	desc = "A vat filled with friends."
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_0"
	///Beaker w/ hopefully plasma
	var/obj/item/reagent_containers/container_volume

/obj/machinery/slime_cloner/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/reagent_containers) && !user.a_intent == INTENT_HELP)
		if(container_volume)
			container_volume.forceMove(get_turf(src)) //remove old beaker
		container_volume = I
		I.forceMove(src)
		to_chat(user, "<span class='notice'> You insert [I] into [src].</span>")
		return FALSE

/obj/machinery/slime_cloner/proc/do_clone(var/mob/living/simple_animal/slime_uni/slime_sample)
	var/datum/reagent/stable_plasma/P = locate(/datum/reagent/stable_plasma) in container_volume?.reagents.reagent_list
	if(P?.volume > 50)
		var/mob/living/simple_animal/slime_uni/new_slime = new slime_sample
		new_slime.forceMove(get_turf(src))
