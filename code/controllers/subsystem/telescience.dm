SUBSYSTEM_DEF(telescience)
	name = "Telescience"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_TELESCIENCE
	///formula for telescience this round
	var/list/formula = list()
	///weight of built up uses
	var/weight = 0
	///Used for multiple portals, helps avoid references
	var/last_effect = 0
