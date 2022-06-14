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
    var/features = list("texture" = null, "mask" = null, "sub_masks" = list(), "color" = null, "sub_color" = null, "exotic_color" = null, "speed" = null, "direction" = null, "rotation" = null)
    ///list of physical attributes
    var/attributes = list("health" = 0, "speed" = 0, "strength" = 0)
    ///List of technical features 
    var/traits = list()
    ///chance to mutate as a percentage. The higher the percentage the greater the changes
    var/instability = 0

/datum/slime_dna/New(var/mob/living/simple_animal/slime_uni/owner, var/datum/slime_dna/inherited, texture, color, mask)
    . = ..()
    if(!owner)
        return
    if(inherited)
        features = inherited.features
        traits = inherited.traits
        instability = inherited.instability
        mutate()
    else //If no inheritance, initialize missing features
        mutate(TRUE)
    features["speed"] = 1 + ((instability / 100) * 3)

    //set owner's attributes to dna
    owner.chat_color = features["color"]
    owner.speed += attributes["speed"]
    owner.maxHealth += attributes["health"]
    owner.health = owner.maxHealth
    owner.damage_coeff[CLONE] += attributes["strength"]

///mutate existing stats, or generate completely new ones
/datum/slime_dna/proc/mutate(always_mutate = FALSE, modifier = 0, texture, mask, sub_masks, color)
    if(!prob(instability+modifier) && !always_mutate)
        return

    var/icon/hold_mask = features["mask"]
    if(always_mutate || prob(instability+modifier) || mask) //masking
        hold_mask = new('icons/mob/xenobiology/slime.dmi', (mask ? mask : pickweight(XENOB_MASKS))) //main mask
        //instability -= XENOB_MUTATE_MEDIUM
    if(always_mutate || prob(instability+modifier) || sub_masks)
        features["sub_masks"] += (sub_masks ? sub_masks : pickweight(XENOB_SUB_MASKS)) //bonus sub mask
        //Add any extra icons to the alpha_mask icon
        if(features["sub_masks"])
            for(var/i in features["sub_masks"])
                var/icon/M = new('icons/mob/xenobiology/slime.dmi', i)
                hold_mask.Blend(M, ICON_OVERLAY)
        instability -= (instability-XENOB_MUTATE_MEDIUM < 0 ? XENOB_MUTATE_MEDIUM-abs(instability-XENOB_MUTATE_MEDIUM) : XENOB_MUTATE_MEDIUM)
    features["mask"] = hold_mask

    var/icon/hold_text = features["texture"]
    if(always_mutate || prob(instability+modifier)) //texture
        hold_text = new('icons/mob/xenobiology/slime_texture.dmi', (texture ? texture : pickweight(XENOB_TEXTURES)))
        instability -= (instability-XENOB_MUTATE_MAJOR < 0 ? XENOB_MUTATE_MAJOR-abs(instability-XENOB_MUTATE_MAJOR) : XENOB_MUTATE_MAJOR)

    if(always_mutate || prob(instability+modifier)) //texture color
        var/clr = pick(XENOB_COLORS)
        var/r = pick(clr)
        clr -= r
        var/g = pick(clr)
        clr -= g
        var/b = pick(clr)
        features["color"] = (color ? color : rgb(r, g, b))
        features["sub_color"] = (color ? color : rgb(b, r, g))
        features["exotic_color"] = (color ? color : rgb(g, b, r))
        instability -= (instability-XENOB_MUTATE_MINOR < 0 ? XENOB_MUTATE_MINOR-abs(instability-XENOB_MUTATE_MINOR) : XENOB_MUTATE_MINOR)
    hold_text.SwapColor("#DDDDDD", features["color"])
    hold_text.SwapColor("#A7A7A7", features["sub_color"])
    hold_text.SwapColor("#6E6E6E", features["exotic_color"])
        
    if(always_mutate || prob(instability+modifier)) //texture rotation
        features["rotation"] = 90 * pick(0, 1, 2, 3)
        instability -= (instability-XENOB_MUTATE_MINOR < 0 ? XENOB_MUTATE_MINOR-abs(instability-XENOB_MUTATE_MINOR) : XENOB_MUTATE_MINOR)
    hold_text.Turn(features["rotation"])
    features["texture"] = hold_text //load holder into actual dna, post transformations

    if(always_mutate || prob(instability+modifier)) //pan direction
        features["direction"] = pick(NORTH, SOUTH, EAST, WEST)
        instability -= (instability-XENOB_MUTATE_MINOR < 0 ? XENOB_MUTATE_MINOR-abs(instability-XENOB_MUTATE_MINOR) : XENOB_MUTATE_MINOR)
