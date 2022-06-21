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

///slime instability itterator
#define XENOB_INSTABILITY_MOD 0
///Slime max instability allowed
#define XENOB_INSTABILITY_MAX 18

///slime mutation costs
#define XENOB_MUTATE_MINOR 3
#define XENOB_MUTATE_MEDIUM 6
#define XENOB_MUTATE_MAJOR 12

///slime litter sizes, how many children can slimes make in sim
#define XENOB_MAX_LITTER 9
#define XENOB_MIN_LITTER 1

///Normal time to combine slimes
#define XENOB_COMBINE_TIME 3 SECONDS
