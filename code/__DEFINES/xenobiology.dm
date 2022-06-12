//rareness weight defines
#define XENOB_COMMON 13
#define XENOB_UNCOMMON 4
#define XENOB_RARE 1

///List of available textures for slimes
#define XENOB_TEXTURES list("c_plain" = XENOB_COMMON, "c_dots" = XENOB_COMMON, "c_waves" = XENOB_COMMON, "r_smile" = XENOB_UNCOMMON, "e_bouncy" = XENOB_RARE)
///List of sub textures used for extra details, like dapper hats
#define XENOB_SUB_MASKS list("nothing, you big fucking nerd" = XENOB_COMMON, "m_tumor" = XENOB_UNCOMMON, "m_hat" = XENOB_RARE, "m_halo" = XENOB_RARE)

///List of approved color sets
#define XENOB_COLORS list(list(255, 150, 50), list(255, 100, 90), list(255, 180, 30), list(255, 90, 13), list(255, 180, 15), list(225, 90, 10), list(255, 200, 15), list(255, 13, 0), list(255, 0, 195), list(208, 255, 0))

///slime instability itterator
#define XENOB_INSTABILITY 5
