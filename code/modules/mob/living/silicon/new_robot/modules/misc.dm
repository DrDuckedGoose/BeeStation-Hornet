/obj/item/new_robot_module/standard
	name = "Standard"
	module_icon = "nomod"
	basic_items = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/reagent_containers/borghypo/epi,
		/obj/item/healthanalyzer,
		/obj/item/borg/charger,
		/obj/item/weldingtool/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/stack/sheet/iron,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/iron/base/cyborg,
		/obj/item/extinguisher,
		/obj/item/pickaxe,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/soap/nanotrasen,
		/obj/item/borg/cyborghug,
		/obj/item/instrument/piano_synth)
	emag_items = list(/obj/item/melee/transforming/energy/sword/cyborg)
	clockcult_items = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/kindle,
		/obj/item/clock_module/abstraction_crystal,
		/obj/item/clockwork/replica_fabricator,
		/obj/item/stack/sheet/brass/cyborg,
		/obj/item/clockwork/weapon/brass_spear)

/obj/item/new_robot_module/deathsquad
	name = "CentCom"
	module_icon = "malf"
	basic_items = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/melee/baton/loaded,
		/obj/item/borg/charger,
		/obj/item/weldingtool/cyborg/mini,
		/obj/item/shield/riot/tele,
		/obj/item/gun/energy/disabler/cyborg,
		/obj/item/melee/transforming/energy/sword/cyborg,
		/obj/item/gun/energy/pulse/carbine/cyborg,
		/obj/item/clothing/mask/gas/sechailer/cyborg)
	emag_items = list(/obj/item/gun/energy/laser/cyborg)
	clockcult_items = list(/obj/item/clock_module/abscond)

/obj/item/new_robot_module/peacekeeper
	name = "Peacekeeper"
	module_icon = "nomod"
	basic_items = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/cookiesynth,
		/obj/item/borg/charger,
		/obj/item/weldingtool/cyborg/mini,
		/obj/item/harmalarm,
		/obj/item/reagent_containers/borghypo/peace,
		/obj/item/holosign_creator/cyborg,
		/obj/item/borg/cyborghug/peacekeeper,
		/obj/item/extinguisher,
		/obj/item/reagent_containers/peppercloud_deployer,
		/obj/item/borg/projectile_dampen)
	emag_items = list(/obj/item/reagent_containers/borghypo/peace/hacked)
	clockcult_items = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/vanguard,
		/obj/item/clock_module/kindle,
		/obj/item/clock_module/sigil_submission)

/obj/item/new_robot_module/borgi
	name = "Borgi"
	module_icon = "brobot"
	basic_items = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/charger,
		/obj/item/borg/cyborghug/peacekeeper)

/obj/item/new_robot_module/butler
	name = "Service"
	module_icon = "service"
	basic_items = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/reagent_containers/food/drinks/drinkingglass,
		/obj/item/pen,
		/obj/item/toy/crayon/spraycan/borg,
		/obj/item/extinguisher/mini,
		/obj/item/hand_labeler/borg,
		/obj/item/razor,
		/obj/item/borg/charger,
		/obj/item/weldingtool/cyborg/mini,
		/obj/item/rsf,
		/obj/item/cookiesynth,
		/obj/item/instrument/piano_synth,
		/obj/item/reagent_containers/dropper,
		/obj/item/lighter,
		/obj/item/borg/apparatus/beaker/service,
		/obj/item/reagent_containers/borghypo/borgshaker)
	emag_items = list(/obj/item/reagent_containers/borghypo/borgshaker/hacked)
	clockcult_items = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/vanguard,
		/obj/item/clock_module/sigil_submission,
		/obj/item/clock_module/kindle,
		/obj/item/clock_module/sentinels_compromise,
		/obj/item/clockwork/replica_fabricator)

/obj/item/new_robot_module/butler/respawn_consumable(mob/living/silicon/new_robot/R, coeff = 1)
	..()
	var/obj/item/reagent_containers/O = locate(/obj/item/reagent_containers/food/condiment/enzyme) in basic_items
	if(O)
		O.reagents.add_reagent(/datum/reagent/consumable/enzyme, 2 * coeff)
