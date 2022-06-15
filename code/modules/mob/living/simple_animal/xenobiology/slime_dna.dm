/*
    - Features - visual settings
        * texture - what texture/image the sprite uses/animates.
        * mask - what alphamask the texture is clipped by, shaped.
        * color - the color applied to the texture
    - Attributes - additional stats.
        * health, extra health
        * speed, extra speed
        * strength, extra damage
*/
/datum/slime_dna
    ///List of visual features for main texture
    var/features = list("texture" = null, "texture_path" = "", "mask" = null, "mask_path" = /datum/xenobiology_feature/mask, "sub_mask" = null, "color" = null, "color_path" = null, "sub_color" = null, "exotic_color" = null, "speed" = null, "direction" = null, "rotation" = null)
    ///list of physical attributes
    var/attributes = list("health" = 0, "speed" = 0, "strength" = 0)
    ///List of technical features 
    var/traits = list()
    ///chance to mutate as a percentage. The higher the percentage the greater the changes
    var/instability = 0
    ///Mastah Wayne
    var/mob/living/simple_animal/slime_uni/owner

/datum/slime_dna/New(var/mob/living/simple_animal/slime_uni/argument_owner, var/datum/slime_dna/inherited, force = FALSE, texture, mask, sub_mask, color, rotation, pan)
    . = ..()
    owner = argument_owner
    if(!owner) //Needs an owner to work
        return
    if(inherited && !force)
        features = inherited.features
        traits = inherited.traits
        instability = inherited.instability
    else //If no inheritance, initialize missing features
        setup()
    features["speed"] = 1 + ((instability / 100) * 3)

    //set owner's attributes to dna
    owner.chat_color = features["color"]
    owner.speed += attributes["speed"]
    owner.maxHealth += attributes["health"]
    owner.health = owner.maxHealth
    owner.damage_coeff[CLONE] += attributes["strength"]

///setup stats and features if not directly inherited
/datum/slime_dna/proc/setup(texture, mask, sub_mask, color, rotation, pan)
    //masking
    var/icon/hold_mask = features["mask"]
    var/datum/xenobiology_feature/M = (mask ? mask : pickweight(XENOB_MASKS))
    M = new M()
    owner.species_name = "[owner.species_name ? "[owner.species_name] " : ""][M.epithet ? "[M.epithet]" : ""]"
    features["mask_path"] = M
    hold_mask = new('icons/mob/xenobiology/slime.dmi', "default") //main mask

    features["sub_mask"] = (sub_mask ? sub_mask : pickweight(XENOB_SUB_MASKS)) //bonus sub mask
    if(features["sub_mask"]) //Add any extra icons to the alpha_mask icon
        var/icon/sub = new('icons/mob/xenobiology/slime.dmi', features["sub_mask"])
        hold_mask.Blend(sub, ICON_OVERLAY)

    features["mask"] = hold_mask

    //texture
    var/icon/hold_text = features["texture"]
    var/datum/xenobiology_feature/texture/T = (texture ? texture : pickweight(XENOB_TEXTURES))
    T = new T()
    owner.species_name = "[owner.species_name][T.epithet ? " [T.epithet]" : ""]"
    features["texture_path"] = T
    hold_text = new('icons/mob/xenobiology/slime_texture.dmi', T.address)

    //texture color
    var/datum/xenobiology_feature/color/color_feature = (color ? color : pickweight(XENOB_COLORS))
    color_feature = new color_feature()
    owner.species_name = "[owner.species_name][color_feature.epithet ? " [color_feature.epithet]" : ""]"
    features["color_path"] = color_feature

    features["color"] = rgb(color_feature.r, color_feature.g, color_feature.b)
    features["sub_color"] = rgb(color_feature.b, color_feature.r, color_feature.g)
    features["exotic_color"] = rgb(color_feature.g, color_feature.b, color_feature.r)
    hold_text.SwapColor("#DDDDDD", features["color"])
    hold_text.SwapColor("#A7A7A7", features["sub_color"])
    hold_text.SwapColor("#6E6E6E", features["exotic_color"])

    //texture rotation
    features["rotation"] = (rotation ? rotation : 90 * pick(0, 1, 2, 3))
    hold_text.Turn(features["rotation"])

    features["texture"] = hold_text //load holder into actual dna, post transformations

    //pan direction
    features["direction"] = (pan ? pan : pick(NORTH, SOUTH, EAST, WEST))

///Visual feature datums
/datum/xenobiology_feature
    ///icon/resource address
    var/address
    ///genus epithet
    var/epithet = "un-set-ium"
    ///list weight
    var/weight = XENOB_COMMON

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

/datum/xenobiology_feature/texture/smile
    address = "r_smile"
    epithet = "faciem"
    weight = XENOB_UNCOMMON

/datum/xenobiology_feature/texture/bubble
    address = "e_bouncy"
    epithet = "bulla"
    weight = XENOB_RARE

/datum/xenobiology_feature/texture/pac
    address = "e_pac"
    epithet = "stipant"
    weight = XENOB_RARE

// -- masks -- 
/datum/xenobiology_feature/mask

/datum/xenobiology_feature/mask/default
    address = "default"
    epithet = "gelatina"

// -- colors --
/datum/xenobiology_feature/color
    ///Color components, red, green and blue. These have to individual for calculations
    var/r
    var/g
    var/b

/datum/xenobiology_feature/color/red
    // rgb(255, 45, 45)
    r = 255
    g = 45 
    b = 45
    epithet = "rubrum"

/datum/xenobiology_feature/color/blue
    // rgb(69, 69, 255)
    r = 69
    g = 69 
    b = 255
    epithet = "caeruleum"

/datum/xenobiology_feature/color/green
    // rgb(26, 242, 58)
    r = 26
    g = 242
    b = 58
    epithet = "viridis"

/datum/xenobiology_feature/color/pink
    // rgb(255, 40, 216)
    r = 255
    g = 40
    b = 216
    epithet = "pallide-ruber"

/datum/xenobiology_feature/color/pink
    // rgb(191, 255, 43)
    r = 191
    g = 255
    b = 43
    epithet = "calcis" 

/datum/xenobiology_feature/color/pink
    // rgb(0, 255, 247)
    r = 0
    g = 255
    b = 247
    epithet = "levis-hyacintho" 

///This only works with xenobiology_features, takes a datum path and compiles it into a weighted list
/proc/compileWeightedList(path)
    if(!ispath(path))
        return
    var/list/temp = subtypesof(path)
    var/list/weighted = list()
    for(var/datum/xenobiology_feature/F as() in temp)
        weighted += list((F) = initial(F.weight))
    return weighted
