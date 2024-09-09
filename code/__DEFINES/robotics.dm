/*
	Endo component
*/
#define COMSIG_ENDO_ATTACHED "endo_attached"
#define COMSIG_ENDO_REMOVED "endo_removed"
#define COMSIG_ENDO_ASSEMBLE "endo_assemble"
#define COMSIG_ENDO_REFRESH_ASSEMBLY "endo_refresh_assembly"
#define COMSIG_ENDO_UNASSEMBLE "endo_unassemble"

#define COMSIG_ENDO_POLL_EQUIP "endo_poll_equip"

#define COMSIG_ENDO_APPLY_LIFE "endo_apply_life"
#define COMSIG_ENDO_APPLY_OFFSET "endo_apply_offset"
#define COMSIG_ENDO_APPLY_HUD "endo_apply_hud"
#define COMSIG_ENDO_REMOVE_HUD "endo_remove_hud"

#define COMSIG_ENDO_LIST_PART "endo_list_part_type"

#define COMSIG_ENDO_REMOVE_PART "endo_remove_part"

/*
	Assembly, crafting step stuff
*/
#define COMSIG_ENDO_ASSEMBLY_LIST_PART "endo_assembly_list_part"
#define COMSIG_ENDO_ASSEMBLY_POLL_INTERACTION "endo_assembly_poll_interaction"

#define COMSIG_ENDO_ASSEMBLY_ADD "endo_assembly_add"
#define COMSIG_ENDO_ASSEMBLY_REMOVE "endo_assembly_remove"
#define COMSIG_ENDO_ASSEMBLY_INTERACT "endo_assembly_interact"

#define ENDO_ASSEMBLY_IN_USE "endo_assembly_in_use"

#define ENDO_ASSEMBLY_COMPLETE (1<<0) //1
#define ENDO_ASSEMBLY_INCOMPLETE (1<<1) //2
#define ENDO_ASSEMBLY_NON_INTEGRAL (1<<2) //4

/*
	Robot
*/

#define COMSIG_ROBOT_CONSUME_ENERGY "robot_consume_energy"
#define COMSIG_ROBOT_PICKUP_ITEM "robot_pickup_item"
#define COMSIG_ROBOT_SET_EMAGGED "robot_set_emagged"
#define COMSIG_ROBOT_LIST_SELF_MONITOR "robot_list_self_monitor"
#define COMSIG_ROBOT_UPDATE_ICONS "robot_update_icons"

#define COMSIG_ROBOT_HAS_MAGPULSE "robot_has_magpulse"
#define COMSIG_ROBOT_HAS_IONPULSE "robot_has_ionpulse"

#define ROBOT_COVER_OPEN_TIME 3 SECONDS
#define ROBOT_MODIFY_TIME 1.3 SECONDS

/*
	Offset key
*/
#define ENDO_OFFSET_KEY_ARM(x) ("offset_key_arm_"+#x)
#define ENDO_OFFSET_KEY_LEG(x) ("offset_key_leg_"+#x)
#define ENDO_OFFSET_KEY_HEAD(x) ("offset_key_head_"+#x)
#define ENDO_OFFSET_KEY_CHEST(x) ("offset_key_chest_"+#x)

/*
	Module
*/
#define MODULE_ITEM_CATEGORY_BASIC (1<<0)
#define MODULE_ITEM_CATEGORY_EMAGGED (1<<1)
#define MODULE_ITEM_CATEGORY_CLOCKCULT (1<<2)
#define MODULE_ITEM_CATEGORY_EXTERNAL (1<<3)

/*
	Compat flags
*/
#define ENDO_COMPATIBILITY_GENERIC (1<<0)
#define ENDO_COMPATIBILITY_FORD (1<<1)
#define ENDO_COMPATIBILITY_HONDA (1<<2)
