#define NAME_COLORS list("Scarlet", "Primrose", "Violet", "Azure", "Jade")
#define NAME_DELIVERY list("Secret", "Promise", "Shame")
#define MIN_STEPS 8
#define MAX_STEPS 13

/datum/secret_timeline
    ///What's the name of this secret
    var/name = ""
    ///List of steps
    var/list/steps = list()
    ///What is the resolution to this secret
    var/datum/secret_timeline_resolution/resolution

/datum/secret_timeline/New()
    . = ..()
    //Generate a name
    name = "A [pick(NAME_COLORS)] [pick(NAME_DELIVERY)]"
    //Generate steps
    var/step_count = rand(MIN_STEPS, MAX_STEPS)
    var/list/available_steps = subtypesof(/datum/secret_timeline_step)
    for(var/i in 1 to step_count)
        var/datum/secret_timeline_step/TS = pick(available_steps)
        TS = new TS()
        steps += TS

#undef NAME_COLORS
#undef NAME_DELIVERY
#undef MIN_STEPS
#undef MAX_STEPS

/datum/secret_timeline_step
    ///Descriptor for what this step requires
    var/desc = ""

/datum/secret_timeline_resolution
    ///Name for this resoltion
    var/name = ""
    ///Description for this resolution
    var/desc = ""
