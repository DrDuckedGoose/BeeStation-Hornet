/*
	- Features - visual settings
		* texture - what texture/image the sprite uses/animates.
			* texture_path - texture name, essentially   
		* mask - what alphamask the texture is clipped by, shaped.
			* mask-path, same as texture_path
		* sub_mask - additional masks for misc features, path to it
		* color - the color applied to the texture
			* color_path - same as texture_path   
			* sub_color / exotic_color - complementory colors
		* speed - texture animation speed
		* direction - texture animation direction
		* rotation - initial texture rotation
	- Attributes - additional stats.
		* health, extra health
		* speed, extra speed
		* strength, extra damage
*/
/datum/slime_dna
	///List of visual features for main texture
	var/list/features = list("texture" = null, "texture_path" = "", "mask" = null, "mask_path" = null, "sub_mask" = null, "color" = null, "color_path" = null, "sub_color" = null, "exotic_color" = null, "speed" = null, "direction" = null, "rotation" = null)
	///list of physical attributes
	var/list/attributes = list("health" = 0, "speed" = 0, "strength" = 0)
	///List of technical features 
	var/list/traits = list()
	///chance to mutate as a percentage. The higher the percentage the greater the changes
	var/instability = 6
	///Mastah Wayne
	var/mob/living/simple_animal/slime_uni/owner

/datum/slime_dna/New(var/mob/living/simple_animal/slime_uni/argument_owner, inst, texture, mask, sub_mask, color, rotation, pan)
	. = ..()
	owner = argument_owner
	instability = inst
	
	//no/partial inheritance, initialize missing features
	setup(texture, mask, sub_mask, color, rotation, pan)
	features["speed"] = 1 + ((instability / 100) * 3)

	//set owner'sub_mask attributes to dna
	owner.chat_color = features["color"]
	owner.speed += attributes["speed"]
	owner.maxHealth += attributes["health"]
	owner.health = owner.maxHealth
	owner.damage_coeff[CLONE] += attributes["strength"]

///setup stats and features
/datum/slime_dna/proc/setup(var/datum/xenobiology_feature/texture/texture, var/datum/xenobiology_feature/mask/mask, var/datum/xenobiology_feature/sub_mask/sub_mask, var/datum/xenobiology_feature/color/color, rotation, pan)
	//masking
	var/icon/hold_mask = features["mask"]
	mask = (mask?.type ? mask?.type : pickweight(XENOB_MASKS)) //main mask
	if(instability >= XENOB_MUTATE_MAJOR && prob(instability)) //apperently having 0 instability can still cause mutations? probablity moment.
		var/datum/xenobiology_feature/M = pickweight(XENOB_MASKS)
		if(M != mask) //Weird chance setup, this just helps with masks rolling the same output, removing the old output isn't intended behaviour. 
			mask = M
			instability -= (instability-XENOB_MUTATE_MAJOR < 0 ? XENOB_MUTATE_MAJOR-abs(instability-XENOB_MUTATE_MAJOR) : XENOB_MUTATE_MAJOR)
	mask = new mask()
	features["mask_path"] = mask
	hold_mask = new('icons/mob/xenobiology/slime.dmi', mask.address)
	owner.discovery_points += mask.extra_discovery

	//sub-masking
	sub_mask = (sub_mask?.type ? sub_mask?.type : pickweight(XENOB_SUB_MASKS)) //bonus mask
	if(instability >= XENOB_MUTATE_MAJOR && prob(instability))
		sub_mask = pickweight(XENOB_SUB_MASKS)
	sub_mask = new sub_mask()
	instability -= (instability-XENOB_MUTATE_MAJOR < 0 ? XENOB_MUTATE_MAJOR-abs(instability-XENOB_MUTATE_MAJOR) : XENOB_MUTATE_MAJOR)
	var/icon/sub = new('icons/mob/xenobiology/slime.dmi', sub_mask.address)
	hold_mask.Blend(sub, ICON_OVERLAY)
	features["sub_mask"] = sub_mask
	features["mask"] = hold_mask
	owner.discovery_points += sub_mask.extra_discovery

	//texture
	///texture holder for transformations
	var/icon/hold_text = features["texture"]
	texture = (texture?.type ? texture?.type : pickweight(XENOB_TEXTURES))
	if(instability >= XENOB_MUTATE_MAJOR && prob(instability))
		texture = pickweight(XENOB_TEXTURES-texture)
		instability -= (instability-XENOB_MUTATE_MAJOR < 0 ? XENOB_MUTATE_MAJOR-abs(instability-XENOB_MUTATE_MAJOR) : XENOB_MUTATE_MAJOR)
	texture = new texture()
	features["texture_path"] = texture
	hold_text = new('icons/mob/xenobiology/slime_texture.dmi', texture.address)
	features["texture"] = hold_text
	owner.discovery_points += texture.extra_discovery

	//texture color
	color = (color?.type ? color?.type : pickweight(XENOB_COLORS))
	if(instability >= XENOB_MUTATE_MEDIUM && prob(instability))
		color = pickweight(XENOB_COLORS-color)
		instability -= (instability-XENOB_MUTATE_MEDIUM < 0 ? XENOB_MUTATE_MEDIUM-abs(instability-XENOB_MUTATE_MEDIUM) : XENOB_MUTATE_MEDIUM)
	color = new color()
	features["color_path"] = color
	owner.discovery_points += color.extra_discovery

	features["color"] = rgb(color.primary[1], color.primary[2], color.primary[3])
	//if the color doesn't have secondary & tertiary colors, they are generated
	//If the texture doesn't contain a third color, the used color will be a complementory instead of triadict
	features["sub_color"] = (texture.weight <= 5 ? rgb(color.secondary[1] || color.primary[3], color.secondary[2] || color.primary[1], color.secondary[3] || color.primary[2]) : rgb(color.secondary[1] || 255-color.primary[1], color.secondary[2] || 255-color.primary[2], color.secondary[3] || 255-color.primary[3]))
	features["exotic_color"] = rgb(color.primary[2], color.primary[3], color.primary[1])
	hold_text.SwapColor("#DDDDDD", features["color"])
	hold_text.SwapColor("#A7A7A7", features["sub_color"])
	hold_text.SwapColor("#6E6E6E", features["exotic_color"])

	//texture rotation, not animation
	if(instability >= XENOB_MUTATE_MINOR && prob(instability))
		features["rotation"] = 90 * pick(list(0, 1, 2, 3)-features["rotation"])
		instability -= (instability-XENOB_MUTATE_MINOR < 0 ? XENOB_MUTATE_MINOR-abs(instability-XENOB_MUTATE_MINOR) : XENOB_MUTATE_MINOR)
	else
		features["rotation"] = (rotation ? rotation : 90 * pick(0, 1, 2, 3))
	hold_text.Turn(features["rotation"])

	//texture pan direction, animation
	if(instability >= XENOB_MUTATE_MINOR && prob(instability))
		features["direction"] = pick(list(NORTH, SOUTH, EAST, WEST)-features["direction"])
		instability -= (instability-XENOB_MUTATE_MINOR < 0 ? XENOB_MUTATE_MINOR-abs(instability-XENOB_MUTATE_MINOR) : XENOB_MUTATE_MINOR)
	else
		features["direction"] = (pan ? pan : pick(NORTH, SOUTH, EAST, WEST))

	//final epithet stuff / species name
	owner.species_name = "[owner.species_name ? "[owner.species_name]" : ""][mask.epithet ? {"<span style="color:[features["exotic_color"]];">[mask.epithet]</span>"} : ""]" //mask epithet
	owner.species_name = "[owner.species_name][color.epithet ? {"<span style="color:[features["color"]];"> [color.epithet]</span>"} : ""]" //color epithet
	owner.species_name = "[owner.species_name][texture.epithet ? {"<span style="color:[features["sub_color"]];"> [texture.epithet]</span>"} : ""]" //texture epithet
	owner.species_name = "[owner.species_name][sub_mask.epithet ? {"<span style="color:[features["exotic_color"]];"> [sub_mask.epithet]</span>"} : ""]" //sub-mask epithet

///Setup traits, builds from a list if provided
/datum/slime_dna/proc/setup_traits(var/list/traits = list())
	if(traits.len)
		world.log << "test"

///Visual feature datums
/datum/xenobiology_feature
	///icon/resource address
	var/address
	///genus epithet
	var/epithet = "un-set-um"
	///list weight
	var/weight = XENOB_COMMON
	///Extra discovery points provided by feature
	var/extra_discovery = XENOB_DISC_COMMON

// -- textures --
/datum/xenobiology_feature/texture

/datum/xenobiology_feature/texture/plain
	address = "c_plain"
	epithet = ""
	weight = XENOB_VERY_COMMON

/datum/xenobiology_feature/texture/dots
	address = "c_dots"
	epithet = "maculosus"

/datum/xenobiology_feature/texture/waves
	address = "c_waves"
	epithet = "fluctus"

/datum/xenobiology_feature/texture/arrow
	address = "r_arrow"
	epithet = "sagitta"
	weight = XENOB_UNCOMMON
	extra_discovery = XENOB_DISC_RARE

/datum/xenobiology_feature/texture/rattle
	address = "r_rattle"
	epithet = "sagitta"
	weight = XENOB_UNCOMMON
	extra_discovery = XENOB_DISC_RARE

/datum/xenobiology_feature/texture/bubble
	address = "e_bouncy"
	epithet = "bulla"
	weight = XENOB_RARE
	extra_discovery = XENOB_DISC_EXOTIC

/datum/xenobiology_feature/texture/hat
	address = "e_hat"
	epithet = "petasum"
	weight = XENOB_RARE
	extra_discovery = XENOB_DISC_EXOTIC

/datum/xenobiology_feature/texture/smile
	address = "e_smile"
	epithet = "faciem"
	weight = XENOB_RARE
	extra_discovery = XENOB_DISC_EXOTIC

// -- masks -- 
/datum/xenobiology_feature/mask

/datum/xenobiology_feature/mask/default
	address = "m_default"
	epithet = "gelatina"
	weight = XENOB_VERY_COMMON

/datum/xenobiology_feature/mask/square
	address = "m_square"
	epithet = "gelatina-cubena" //cubena is technically a genus of moths :)
	weight = XENOB_EXOTIC
	extra_discovery = XENOB_DISC_EXOTIC

/datum/xenobiology_feature/mask/dough
	address = "m_dough"
	epithet = "gelatina-torusa"
	weight = XENOB_EXOTIC
	extra_discovery = XENOB_DISC_EXOTIC

// -- sub-masks --
//please don'texture parent these to masks
/datum/xenobiology_feature/sub_mask
	weight = XENOB_RARE
	extra_discovery = XENOB_DISC_RARE

/datum/xenobiology_feature/sub_mask/blank
	address = "m_blank"
	epithet = ""
	weight = XENOB_COMMON
	extra_discovery = XENOB_DISC_COMMON

/datum/xenobiology_feature/sub_mask/tumor
	address = "m_tumor"
	epithet = "bulbus"

/datum/xenobiology_feature/sub_mask/shogun
	address = "m_shogun"
	epithet = "cornibus"

/datum/xenobiology_feature/sub_mask/hat
	address = "m_hat"
	epithet = "parvum-petasum"

/datum/xenobiology_feature/sub_mask/love
	address = "m_love"
	epithet = "amare"

/datum/xenobiology_feature/sub_mask/halo
	address = "m_halo"
	epithet = "angelus" //this was orignally the latin word for halo...

// -- colors --
/datum/xenobiology_feature/color
	///Color components, primary, secondary, and tertiary
	var/list/primary = list(null, null, null)
	var/list/secondary = list(null, null, null)
	var/list/tertiary = list(null, null, null)

/datum/xenobiology_feature/color/red
	// rgb(255, 0, 0)
	primary = list(255, 0, 0)
	epithet = "rubrum"

/datum/xenobiology_feature/color/blue
	// rgb(0, 0, 255)
	primary = list(0, 0, 255)	
	epithet = "caeruleum"

/datum/xenobiology_feature/color/green
	// rgb(0, 255, 0)
	primary = list(0, 255, 0)
	epithet = "viridis"

/datum/xenobiology_feature/color/medical
	weight = XENOB_UNCOMMON
	// rgb(255, 255, 255)
	primary = list(255, 255, 255)
	// rgb(255, 0, 0)
	secondary = list(255, 0, 0)
	// rgb(255, 0, 0)
	tertiary = list(255, 0, 0)
	epithet = "medica"

///Takes a datum path and compiles it into a weighted list, this only works with xenobiology_features currently
/proc/compileWeightedList(path)
	if(!ispath(path))
		return
	var/list/temp = subtypesof(path)
	var/list/weighted = list()
	for(var/datum/xenobiology_feature/F as() in temp)
		weighted += list((F) = initial(F.weight))
	return weighted
