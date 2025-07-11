//Fluff structures serve no purpose and exist only for enriching the environment. They can be destroyed with a wrench.

/obj/structure/fluff
	name = "fluff structure"
	desc = "Fluffier than a sheep. This shouldn't exist."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "minibar"
	anchored = TRUE
	density = FALSE
	opacity = FALSE
	var/deconstructible = TRUE

/obj/structure/fluff/attackby(obj/item/I, mob/living/user, params)
	if(I.tool_behaviour == TOOL_WRENCH && deconstructible)
		user.visible_message(span_notice("[user] starts disassembling [src]..."), span_notice("You start disassembling [src]..."))
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 50))
			user.visible_message(span_notice("[user] disassembles [src]!"), span_notice("You break down [src] into scrap metal."))
			playsound(user, 'sound/items/deconstruct.ogg', 50, 1)
			new/obj/item/stack/sheet/iron(drop_location())
			qdel(src)
		return
	..()

/obj/structure/fluff/empty_terrarium //Empty terrariums are created when a preserved terrarium in a lavaland seed vault is activated.
	name = "empty terrarium"
	desc = "An ancient machine that seems to be used for storing plant matter. Its hatch is ajar."
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "terrarium_open"
	density = TRUE

/obj/structure/fluff/empty_sleeper //Empty sleepers are created by a good few ghost roles in lavaland.
	name = "empty sleeper"
	desc = "An open sleeper. It looks as though it would be awaiting another patient, were it not broken."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper-open"

/obj/structure/fluff/empty_sleeper/nanotrasen
	name = "broken hypersleep chamber"
	desc = "A Nanotrasen hypersleep chamber - this one appears broken. \
		There are exposed bolts for easy disassembly using a wrench."
	icon_state = "sleeper-o"

/obj/structure/fluff/empty_sleeper/syndicate
	icon_state = "sleeper_s-open"

/obj/structure/fluff/empty_cryostasis_sleeper //Empty cryostasis sleepers are created when a malfunctioning cryostasis sleeper in a lavaland shelter is activated
	name = "empty cryostasis sleeper"
	desc = "Although comfortable, this sleeper won't function as anything but a bed ever again."
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper_open"

/obj/structure/fluff/broken_flooring
	name = "broken tiling"
	desc = "A segment of broken flooring."
	icon = 'icons/obj/brokentiling.dmi'
	icon_state = "corner"

/obj/structure/fluff/drake_statue //Ash drake status spawn on either side of the necropolis gate in lavaland.
	name = "drake statue"
	desc = "A towering basalt sculpture of a proud and regal drake. Its eyes are six glowing gemstones."
	icon = 'icons/effects/64x64.dmi'
	icon_state = "drake_statue"
	pixel_x = -16
	density = TRUE
	deconstructible = FALSE
	layer = EDGED_TURF_LAYER

/obj/structure/fluff/drake_statue/falling //A variety of statue in disrepair; parts are broken off and a gemstone is missing
	desc = "A towering basalt sculpture of a drake. Cracks run down its surface and parts of it have fallen off."
	icon_state = "drake_statue_falling"


/obj/structure/fluff/bus
	name = "bus"
	desc = "GO TO SCHOOL. READ A BOOK."
	icon = 'icons/obj/bus.dmi'
	icon_state = null
	density = TRUE
	deconstructible = FALSE

/obj/structure/fluff/bus/dense
	name = "bus"
	icon_state = "backwall"

/obj/structure/fluff/bus/passable
	name = "bus"
	icon_state = "frontwalltop"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER //except for the stairs tile, which should be set to OBJ_LAYER aka 3.


/obj/structure/fluff/bus/passable/seat
	name = "seat"
	desc = "Buckle up! ...What do you mean, there's no seatbelts?!"
	icon_state = "backseat"
	pixel_y = 17
	layer = OBJ_LAYER


/obj/structure/fluff/bus/passable/seat/driver
	name = "driver's seat"
	desc = "Space Jesus is my copilot."
	icon_state = "driverseat"

/obj/structure/fluff/bus/passable/seat/driver/attack_hand(mob/user, list/modifiers)
	playsound(src, 'sound/items/carhorn.ogg', 50, TRUE)
	. = ..()

/obj/structure/fluff/paper
	name = "dense lining of papers"
	desc = "A lining of paper scattered across the bottom of a wall."
	icon = 'icons/obj/fluff.dmi'
	icon_state = "paper"
	deconstructible = FALSE

/obj/structure/fluff/paper/corner
	icon_state = "papercorner"

/obj/structure/fluff/paper/stack
	name = "dense stack of papers"
	desc = "A stack of various papers, childish scribbles scattered across each page."
	icon_state = "paperstack"


/obj/structure/fluff/divine
	name = "Miracle"
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "error"
	density = TRUE

/obj/structure/fluff/divine/nexus
	name = "nexus"
	desc = "It anchors a deity to this world. It radiates an unusual aura. It looks well protected from explosive shock."
	icon_state = "nexus"

/obj/structure/fluff/divine/conduit
	name = "conduit"
	desc = "It allows a deity to extend their reach.  Their powers are just as potent near a conduit as a nexus."
	icon_state = "conduit"

/obj/structure/fluff/divine/convertaltar
	name = "conversion altar"
	desc = "An altar dedicated to a deity."
	icon_state = "convertaltar"
	density = FALSE
	can_buckle = 1

/obj/structure/fluff/divine/powerpylon
	name = "power pylon"
	desc = "A pylon which increases the deity's rate it can influence the world."
	icon_state = "powerpylon"
	can_buckle = 1

/obj/structure/fluff/divine/defensepylon
	name = "defense pylon"
	desc = "A pylon which is blessed to withstand many blows, and fire strong bolts at nonbelievers. A god can toggle it."
	icon_state = "defensepylon"

/obj/structure/fluff/divine/shrine
	name = "shrine"
	desc = "A shrine dedicated to a deity."
	icon_state = "shrine"

/obj/structure/fluff/fokoff_sign
	name = "crude sign"
	desc = "A crudely-made sign with the words 'fok of' written in some sort of red paint."
	icon = 'icons/obj/fluff.dmi'
	icon_state = "fokof"

/obj/structure/fluff/hedge
	name = "hedge"
	desc = "A large bushy hedge."
	icon = 'icons/obj/smooth_structures/hedge.dmi'
	icon_state = "hedge-0"
	base_icon_state = "hedge"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_HEDGE_FLUFF)
	canSmoothWith = list(SMOOTH_GROUP_HEDGE_FLUFF)
	density = TRUE
	deconstructible = FALSE

/obj/structure/fluff/hedge/opaque //useful for mazes and such
	opacity = TRUE

/obj/structure/fluff/fans
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "fan_tiny"
	name = "environmental regulation system"
	desc = "A vent nested into the wall, managing the airflow between the rooms"

/obj/structure/fluff/rug
	icon = 'icons/obj/rug.dmi'
	icon_state = "tiger_rug"
	name = "tiger rug"
	desc = "A huge rug made out of tiger skin. Was this a real tiger?"
	pixel_x = -32
	pixel_y = -16
	plane = FLOOR_PLANE
	anchored = FALSE
	deconstructible = FALSE
