/obj/item/law_module
	name = "law module"
	desc = "A law module used to store a singular law on a law server."
	icon = 'icons/obj/robotics/endo.dmi'
	icon_state = "law_circuit"
	///Our current law
	var/law_text = ""

/obj/item/law_module/Initialize(mapload)
	. = ..()
	color = "#[random_color()]"

/obj/item/law_module/interact(mob/user)
	. = ..()
	law_text = tgui_input_text(user, "Change Law", "Change Law", law_text)
