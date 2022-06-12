/*
    - features
        * texture - what texture/image the sprite uses/animates.
        * mask - what alphamask the texture is clipped by, shaped.
        * color - the color applied to the texture
    - 
*/
/datum/slime_dna
    ///List of visual features for main texture
    var/features = list("texture" = null, "mask" = null, "color" = null, "sub_color" = null, "exotic_color" = null, "speed" = null, "direction" = null, "rotation" = null)
    ///List of technical features 
    var/traits = list()
    ///chance to mutate as a percentage. The higher the percentage the greater the changes
    var/instability = 0

/datum/slime_dna/New(var/datum/slime_dna/inherited, texture, color, mask)
    . = ..()
    if(inherited)
        features = inherited.features
        traits = inherited.traits
        instability = inherited.instability
        features["direction"] = inherited.features["direction"]
    else
        //If no inheritance, initialize missing features
        var/icon/hold_mask = new('icons/mob/xenobiology/slime.dmi', (mask ? mask : "test"))
        features["mask"] = hold_mask

        var/icon/hold_text = new('icons/mob/xenobiology/slime_texture.dmi', (texture ? texture : pick(XENOB_TEXTURES)))

        //color process
        var/r = pick(255, rand(0, 255))
        var/g = r != 255 ? pick(255, rand(0, 180)) : rand(0, 180)
        var/b = r != 255 && g != 255 ? 255 : rand(0, 180)
        features["color"] = (color ? color : rgb(r, g, b))
        features["sub_color"] = (color ? color : rgb(255-r, 255-g, 255-b))
        features["exotic_color"] = (color ? color : rgb(120-r, 120-g, 120-b))
        hold_text.SwapColor("#DDDDDD", features["color"])
        hold_text.SwapColor("#A7A7A7", features["sub_color"])
        hold_text.SwapColor("#6E6E6E", features["exotic_color"])

        features["rotation"] = 90 * pick(0, 1, 2, 3)
        hold_text.Turn(features["rotation"])
        
        features["texture"] = hold_text

        features["direction"] = pick(NORTH, SOUTH, EAST, WEST)
    features["speed"] = 1 + ((instability / 100) * 4)
