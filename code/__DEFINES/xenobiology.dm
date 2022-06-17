///rareness weight defines
#define XENOB_VERY_COMMON 150
#define XENOB_COMMON 100
#define XENOB_UNCOMMON 15
#define XENOB_RARE 5

///List of available textures for slimes
#define XENOB_TEXTURES compileWeightedList(/datum/xenobiology_feature/texture)
///List of masks used for extra & main details, like dapper hats & bodies
#define XENOB_MASKS compileWeightedList(/datum/xenobiology_feature/mask)
#define XENOB_SUB_MASKS list("nothing, you big fucking nerd" = XENOB_COMMON, "m_tumor" = XENOB_UNCOMMON, "m_shogun" = XENOB_RARE, "m_hat" = XENOB_RARE, "m_halo" = XENOB_RARE, "m_love" = XENOB_RARE)

///List of approved color sets
#define XENOB_COLORS compileWeightedList(/datum/xenobiology_feature/color)

///slime instability itterator
#define XENOB_INSTABILITY_MOD 25

///slime mutation costs
#define XENOB_MUTATE_MINOR 25
#define XENOB_MUTATE_MEDIUM 50
#define XENOB_MUTATE_MAJOR 75

///slime litter sizes, how many children can slimes make in sim
#define XENOB_MAX_LITTER 3
#define XENOB_MIN_LITTER 1
