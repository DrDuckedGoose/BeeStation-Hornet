/*
    - features
        * texture - what texture/image the sprite uses/animates.
        * mask - what alphamask the texture is clipped by, shaped.
        * color - the color applied to the texture
    - 
*/
/datum/slime_dna
    ///List of visual features for main texture
    var/features = list("texture" = null, "mask" = null, "color" = null, "speed" = null, "direction" = null)
    ///List of technical features 
    var/traits = list()
    ///chance to mutate as a percentage. The higher the percentage the greater the changes
    var/instability = 0

/datum/slime_dna/New(var/datum/slime_dna/inherited, texture, mask)
    . = ..()
    if(inherited)
        features = inherited.features
        traits = inherited.traits
        instability = inherited.instability
        features["direction"] = inherited.features["direction"]
        mutate()
    else
        //If no inheritance, initialize missing features
        features["color"] = pick(XENOB_COLORS)

        var/icon/hold_mask = new('icons/mob/xenobiology/slime.dmi', (mask ? mask : "default"))
        features["mask"] = hold_mask

        var/icon/hold_text = new('icons/mob/xenobiology/slime_texture.dmi', (texture ? texture : pick(XENOB_TEXTURES)))
        hold_text.ColorTone(features["color"])
        features["texture"] = hold_text

        features["direction"] = pick(NORTH, SOUTH, EAST, WEST)
    features["speed"] = 1 + ((instability / 100) * 4)

///Handle mutation and changes. 
/datum/slime_dna/proc/mutate()   
