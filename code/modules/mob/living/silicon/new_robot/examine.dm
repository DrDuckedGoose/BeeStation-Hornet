/mob/living/silicon/new_robot/examine(mob/user)
//WHO THE FUCK IS THIS?!
	. = list("<span class='info'>This is [icon2html(src, user)] \a <EM>[src]</EM>!")
	if(desc)
		. += "[desc]"
//What are they holding
	var/obj/act_module = get_active_held_item()
	if(act_module)
		. += "It is holding [icon2html(act_module, user)] \a [act_module]."
	. += status_effect_examines()
//How fucked up are they?
	//Brute
	if (getBruteLoss())
		if (getBruteLoss() < maxHealth*0.5)
			. += "<span class='warning'>It looks slightly dented.</span>"
		else
			. += "<span class='warning'><B>It looks severely dented!</B></span>"
	//Fire
	if (getFireLoss() || getToxLoss())
		var/overall_fireloss = getFireLoss() + getToxLoss()
		if (overall_fireloss < maxHealth * 0.5)
			. += "<span class='warning'>It looks slightly charred.</span>"
		else
			. += "<span class='warning'><B>It looks severely burnt and heat-warped!</B></span>"
	//General health indication
	if (health < -maxHealth*0.5)
		. += "<span class='warning'>It looks barely operational.</span>"
	//Fire stacks
	if (fire_stacks < 0)
		. += "<span class='warning'>It's covered in water.</span>"
	else if (fire_stacks > 0)
		. += "<span class='warning'>It's coated in something flammable.</span>"
//Our cover's status
	. += "Its cover is [cover_open ? "open" : "closed"]."
//Our cell, our charge, status
	var/obj/item/stock_parts/cell/cell = get_cell()
	if(cell && cell.charge <= 0)
		. += "<span class='warning'>Its battery indicator is blinking red!</span>"
//Our status
	switch(stat)
		if(CONSCIOUS && !client)
			. += "It appears to be in stand-by mode." //afk
		if(SOFT_CRIT, UNCONSCIOUS, HARD_CRIT)
			. += "<span class='warning'>It doesn't seem to be responding.</span>"
		if(DEAD)
			. += "<span class='deadsay'>It looks like its system is corrupted and requires a reset.</span>"
	//This looks weird, but I know it works and I didn't write it
	. += "</span>"
	return . + ..()

/mob/living/silicon/new_robot/get_examine_string(mob/user, thats = FALSE)
	return null
