///rareness weight defines
#define XENOB_VERY_COMMON 150
#define XENOB_COMMON 100
#define XENOB_UNCOMMON 15
#define XENOB_RARE 5

///List of available textures for slimes
#define XENOB_TEXTURES list("c_plain" = XENOB_VERY_COMMON, "c_dots" = XENOB_COMMON, "c_waves" = XENOB_COMMON, "r_smile" = XENOB_UNCOMMON, "e_bouncy" = XENOB_RARE, "e_pac" = XENOB_RARE)
///List of masks used for extra & main details, like dapper hats & bodies
#define XENOB_MASKS list("default" = XENOB_COMMON)
#define XENOB_SUB_MASKS list("nothing, you big fucking nerd" = XENOB_COMMON, "m_tumor" = XENOB_UNCOMMON, "m_shogun" = XENOB_RARE, "m_hat" = XENOB_RARE, "m_halo" = XENOB_RARE, "m_love" = XENOB_RARE)

///List of approved color sets
#define XENOB_COLORS list(list(255, 150, 50), list(255, 100, 90), list(255, 180, 30), list(255, 90, 13), list(255, 180, 15), list(225, 90, 10), list(255, 200, 15), list(255, 13, 0), list(255, 0, 195), list(208, 255, 0))

///slime instability itterator
#define XENOB_INSTABILITY_MOD 25

///slime mutation costs
#define XENOB_MUTATE_MINOR 25
#define XENOB_MUTATE_MEDIUM 50
#define XENOB_MUTATE_MAJOR 75
