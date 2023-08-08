/*
    Not really like a traditional crafting recipe, but similar enough.a
    Essentially, when the player combines food, if the combination is a set recipe, we set it to that recipe
*/
/datum/food_recipe
    ///What we will rename this food item to
    var/name = ""
    ///
    //var/icon = ''
    ///
    var/icon_state = ""
    ///What we will transform this food item into - Don't set this unless you must
    var/obj/item/food/food_item
    ///What the combination requires to become this recipe
    var/list/reqs = list()
    var/text_reqs = ""

/datum/food_recipe/New()
    . = ..()
    for(var/i in reqs)
        var/atom/A = i
        text_reqs = "[text_reqs], [A]"

/datum/food_recipe/meatball_burger
    name = "meatyball"
    reqs = list(/obj/item/food/meat/rawbacon, /obj/item/food/bun)

