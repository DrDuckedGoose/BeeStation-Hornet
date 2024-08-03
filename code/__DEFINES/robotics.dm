/*
	Endo component
*/
#define COMSIG_ENDO_ATTACHED "endo_attached"
#define COMSIG_ENDO_REMOVED "endo_removed"
#define COMSIG_ENDO_ASSEMBLE "endo_assemble"
#define COMSIG_ENDO_UNASSEMBLE "endo_unassemble"

#define COMSIG_ENDO_POLL_EQUIP "endo_poll_equip"

#define COMSIG_ENDO_APPLY_LIFE "endo_apply_life"
#define COMSIG_ENDO_APPLY_OFFSET "endo_apply_offset"
#define COMSIG_ENDO_APPLY_HUD "endo_apply_hud"

#define COMSIG_ENDO_LIST_PART "endo_list_part_type"

#define COMSIG_ENDO_CONSUME_ENERGY "endo_consume_energy"

//TODO: Consider just using the robot attack signal, instead of this - Racc
#define COMSIG_ENDO_ATTACK_UNARMED "endo_attack_unarmed"

/*
	Assembly datum
*/
#define COMSIG_ENDO_ASSEMBLY_POLL_PART "endo_assembly_poll_part"
#define COMSIG_ENDO_ASSEMBLY_POLL_INTERACTION "endo_assembly_poll_interaction"

#define COMSIG_ENDO_ASSEMBLY_ADD "endo_assembly_add"
#define COMSIG_ENDO_ASSEMBLY_REMOVE "endo_assembly_remove"
#define COMSIG_ENDO_ASSEMBLY_INTERACT "endo_assembly_interact"

#define ENDO_ASSEMBLY_IN_USE "endo_assembly_in_use"

#define ENDO_ASSEMBLY_COMPLETE (1<<0) //1
#define ENDO_ASSEMBLY_INCOMPLETE (1<<1) //2
#define ENDO_ASSEMBLY_NON_INTEGRAL (1<<2) //4

/*
	MISC
*/

/*
	Offset key
*/
#define ENDO_OFFSET_KEY_ARM(x) ("offset_key_arm_"+#x)
#define ENDO_OFFSET_KEY_LEG(x) ("offset_key_leg_"+#x)
#define ENDO_OFFSET_KEY_HEAD(x) ("offset_key_head_"+#x)
#define ENDO_OFFSET_KEY_CHEST(x) ("offset_key_chest_"+#x)
