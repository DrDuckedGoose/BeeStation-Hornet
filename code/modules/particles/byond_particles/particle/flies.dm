/particles/flies
	color = generator("color", "#000000", "#1d1d1d", UNIFORM_RAND)
	position = generator("box", list(-15, -15, -15), list(10, 10, 10), UNIFORM_RAND)
	icon = 'icons/effects/particles/misc.dmi'
	icon_state = list("fly")
	count = 8
	spawning = 4
	spin = generator("num", 35, 50, UNIFORM_RAND)
	lifespan = 8 SECONDS
	fade = 3 SECONDS
	fadein = 3 SECONDS
