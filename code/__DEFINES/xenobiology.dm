///rareness weight defines
#define XENOB_VERY_COMMON 150
#define XENOB_COMMON 100
#define XENOB_UNCOMMON 15
#define XENOB_RARE 5
#define XENOB_EXOTIC 0.5

///List of available textures for slimes
#define XENOB_TEXTURES compileWeightedList(/datum/xenobiology_feature/texture)
///List of masks used for extra & main details, like dapper hats & bodies
#define XENOB_MASKS compileWeightedList(/datum/xenobiology_feature/mask)
#define XENOB_SUB_MASKS compileWeightedList(/datum/xenobiology_feature/sub_mask)
///List of approved color sets
#define XENOB_COLORS compileWeightedList(/datum/xenobiology_feature/color)

///List of all traits
#define XENOB_TRAITS compileWeightedList(/datum/xenobiology_trait)
///List of behaviour traits
#define XENOB_BEHAVIOUR_TRAITS compileWeightedList(/datum/xenobiology_trait/behaviour)
///List of material traits
#define XENOB_PRODUCTION_TRAITS compileWeightedList(/datum/xenobiology_trait/production)

///slime instability itterator
#define XENOB_INSTABILITY_MOD 20
///Slime max instability allowed
#define XENOB_INSTABILITY_MAX 100
///slime mutation costs
#define XENOB_MUTATE_MINOR 20
#define XENOB_MUTATE_MEDIUM 40
#define XENOB_MUTATE_MAJOR 60

///slime litter sizes, how many children can slimes make in sim
#define XENOB_MAX_LITTER 9
#define XENOB_MIN_LITTER 1

///Normal time to combine slimes
#define XENOB_REFRESH_TIME 120 SECONDS

///Max reagents slimes can hold
#define XENOB_SLIME_VOLUME 15

///Max slime saturation for hunger
#define SLIME_SATURATION_MAX 200

///Discovey point values
#define XENOB_DISC_COMMON 0
#define XENOB_DISC_RARE 100
#define XENOB_DISC_EXOTIC 200
