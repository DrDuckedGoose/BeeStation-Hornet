/obj/effect/witch_crafting
	anchored = TRUE
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/witch_crafting/Initialize(mapload, atom/target)
	. = ..()
	//basic visual stuffs
	appearance = target.appearance
	color = "#0f0"
	filters += filter(type = "bloom", size = 1, offset = 1, threshold = "#888")
	pixel_x = rand(-5, 5)
	pixel_y = rand(-3, 3)
	//Animate effects
	animate(src, color = "#000", time = 0.5 SECONDS)
	var/matrix/n_transform = transform
	n_transform.Scale(0.1, 0.1)
	animate(src, transform = n_transform, time = 1 SECONDS)
	animate(src, pixel_y = (pixel_y + rand(8, 12)), time = 1 SECONDS, easing = CIRCULAR_EASING | EASE_IN)
	addtimer(CALLBACK(src, PROC_REF(shakespear)), 1 SECONDS)

/obj/effect/witch_crafting/proc/shakespear()
	qdel(src)
