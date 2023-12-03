/obj/item/spectral_scanner
	name = "spectral scanner"
	desc = "A scanner for detecting spectral entities and substances."
	icon = 'icons/obj/curios.dmi'
	icon_state = "spectral_scanner"
	w_class = WEIGHT_CLASS_NORMAL
	max_integrity = 100
	var/enabled = FALSE
	///Color of the radius
	var/radius_color = "#00ff00"
	var/spooky_color = "#00ffff"
	///Reference to the effect overlay
	var/atom/movable/radius_overlay

/obj/item/spectral_scanner/chaplain
	desc = "A scanner for detecting spectral entities and substances.\nIt looks like an old prototype."
	icon_state = "spectral_scanner_chap"
	radius_color = "#ff2121"
	spooky_color = "#fffb1f"

/obj/item/spectral_scanner/Initialize(mapload)
	. = ..()
	radius_overlay = new(src)
	build_scanner_effect()

/obj/item/spectral_scanner/interact(mob/user)
	. = ..()
	enabled = !enabled
	var/atom/movable/target = isliving(loc) ? loc : src
	if(enabled)
		playsound(src, 'sound/machines/capacitor_charge.ogg', 65)
		target.vis_contents += radius_overlay
	else
		playsound(src, 'sound/machines/capacitor_discharge.ogg', 65)
		target.vis_contents -= radius_overlay

/obj/item/spectral_scanner/equipped(mob/user, slot, initial)
	. = ..()
	if(enabled)
		user.vis_contents += radius_overlay
	vis_contents -= radius_overlay
	
/obj/item/spectral_scanner/dropped(mob/user, silent)
	. = ..()
	enabled = FALSE
	user.vis_contents -= radius_overlay

///Return mutable appearance of scanner effect - Proc'd so we can adjust the settings and rebuild it, for VV
/obj/item/spectral_scanner/proc/build_scanner_effect()
	//Intial appearance
	radius_overlay.appearance = mutable_appearance('icons/effects/96x96.dmi', "maint_scanner_circle", 10, HUD_PLANE)
	radius_overlay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT //Set it here becuase it breaks otherwise
	radius_overlay.color = radius_color
	radius_overlay.blend_mode = BLEND_ADD
	radius_overlay.appearance_flags = RESET_TRANSFORM | RESET_ALPHA | RESET_COLOR
	//Offsets
	radius_overlay.pixel_x = -32
	radius_overlay.pixel_y = -32
	//Masking
	radius_overlay.filters += filter(type = "alpha", render_source = GAME_PLANE_RENDER_TARGET)
	radius_overlay.filters += filter(type = "alpha", render_source = SPECTRAL_TRESPASS_PLANE_RENDER_TARGET, flags = MASK_INVERSE)
	var/icon/I = icon('icons/effects/96x96.dmi', "maint_scanner_stripes")
	radius_overlay.filters += filter(type = "alpha", icon = I, flags = MASK_INVERSE)

	//Spooky detection plane
	var/mutable_appearance/MA = mutable_appearance('icons/effects/96x96.dmi', "maint_scanner_circle", 11, HUD_PLANE)
	MA.color = spooky_color
	MA.appearance_flags = RESET_ALPHA | RESET_COLOR
	MA.blend_mode = BLEND_ADD
	MA.appearance_flags = RESET_TRANSFORM | RESET_ALPHA | RESET_COLOR
	//Masking
	MA.filters += filter(type = "alpha", render_source = SPECTRAL_TRESPASS_PLANE_RENDER_TARGET)
	MA.filters += filter(type = "alpha", icon = I, flags = MASK_INVERSE)
	radius_overlay.add_overlay(MA)
