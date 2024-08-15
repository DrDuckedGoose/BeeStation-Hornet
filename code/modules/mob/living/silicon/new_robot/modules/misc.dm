//TODO: This is a temp file. Rename it or consider moving these elsewhere - Racc
//LOOK AT robot_modules.dm TO SEE WHATS LEFT TO PORT AND WHAT VARIABLES YOU LEFT OUT

/obj/item/new_robot_module/standard
	name = "Standard"
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

/obj/item/new_robot_module/medical
	name = "Medical"
	basic_items = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/healthanalyzer,
		/obj/item/borg/charger,
		/obj/item/weldingtool/cyborg/mini,
		/obj/item/reagent_containers/borghypo,
		/obj/item/borg/apparatus/beaker,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/surgical_drapes,
		/obj/item/retractor,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/surgicaldrill,
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/blood_filter,
		/obj/item/extinguisher/mini,
		/obj/item/rollerbed/robo,
		/obj/item/borg/cyborghug/medical,
		/obj/item/stack/medical/gauze,
		/obj/item/organ_storage,
		/obj/item/borg/lollipop)
	emag_items = list(/obj/item/reagent_containers/borghypo/hacked)
	clockcult_items = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/sentinels_compromise,
		/obj/item/clock_module/prosperity_prism,
		/obj/item/clock_module/vanguard)

/obj/item/new_robot_module/engineering
	name = "Engineering"
	basic_items = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/sight/meson,
		/obj/item/borg/charger,
		/obj/item/construction/rcd/borg,
		/obj/item/pipe_dispenser,
		/obj/item/extinguisher,
		/obj/item/weldingtool/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/geiger_counter/cyborg,
		/obj/item/assembly/signaler/cyborg,
		/obj/item/areaeditor/blueprints/cyborg,
		/obj/item/electroadaptive_pseudocircuit,
		/obj/item/stack/sheet/iron,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/sheet/rglass/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/iron/base/cyborg,
		/obj/item/stack/cable_coil,
		/obj/item/holosign_creator/atmos)
	emag_items = list(/obj/item/borg/stun)
	clockcult_items = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/ocular_warden,
		/obj/item/clock_module/tinkerers_cache,
		/obj/item/clock_module/stargazer,
		/obj/item/clock_module/abstraction_crystal,
		/obj/item/clockwork/replica_fabricator,
		/obj/item/stack/sheet/brass/cyborg)

/obj/item/new_robot_module/deathsquad
	name = "CentCom"
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

/obj/item/new_robot_module/security
	name = "Security"
	basic_items = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/melee/baton/loaded,
		/obj/item/borg/charger,
		/obj/item/weldingtool/cyborg/mini,
		/obj/item/gun/energy/disabler/cyborg,
		/obj/item/clothing/mask/gas/sechailer/cyborg,
		/obj/item/extinguisher/mini)
	emag_items = list(/obj/item/gun/energy/laser/cyborg)
	clockcult_items = list(
		/obj/item/clock_module/abscond,
		/obj/item/clockwork/weapon/brass_spear,
		/obj/item/clock_module/ocular_warden,
		/obj/item/clock_module/vanguard)

/obj/item/new_robot_module/security/respawn_consumable(mob/living/silicon/new_robot/R, coeff = 1)
	..()
	var/obj/item/gun/energy/e_gun/advtaser/cyborg/T = locate(/obj/item/gun/energy/e_gun/advtaser/cyborg) in basic_items
	if(T)
		if(T.cell.charge < T.cell.maxcharge)
			var/obj/item/ammo_casing/energy/S = T.ammo_type[T.select]
			T.cell.give(S.e_cost * coeff)
			T.update_icon()
		else
			T.charge_timer = 0

/obj/item/new_robot_module/peacekeeper
	name = "Peacekeeper"
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

/obj/item/new_robot_module/janitor
	name = JOB_NAME_JANITOR
	basic_items = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/stack/tile/iron/base/cyborg,
		/obj/item/soap/nanotrasen,
		/obj/item/borg/charger,
		/obj/item/weldingtool/cyborg/mini,
		/obj/item/storage/bag/trash/cyborg,
		/obj/item/melee/flyswatter,
		/obj/item/extinguisher/mini,
		/obj/item/mop/cyborg,
		/obj/item/reagent_containers/glass/bucket,
		/obj/item/paint/paint_remover,
		/obj/item/lightreplacer/cyborg,
		/obj/item/holosign_creator/janibarrier,
		/obj/item/reagent_containers/spray/cyborg/drying_agent,
		/obj/item/reagent_containers/spray/cyborg/plantbgone,
		/obj/item/wirebrush)
	emag_items = list(
		/obj/item/reagent_containers/spray/cyborg/lube,
		/obj/item/reagent_containers/spray/cyborg/acid)
	clockcult_items  = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/sigil_submission,
		/obj/item/clock_module/kindle,
		/obj/item/clock_module/vanguard)

/obj/item/new_robot_module/janitor/respawn_consumable(mob/living/silicon/new_robot/R, coeff = 1)
	..()
	var/obj/item/lightreplacer/LR = locate(/obj/item/lightreplacer) in basic_items
	if(LR)
		for(var/i in 1 to coeff)
			LR.Charge(R)

/obj/item/new_robot_module/clown
	name = JOB_NAME_CLOWN
	basic_items = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/toy/crayon/rainbow,
		/obj/item/instrument/bikehorn,
		/obj/item/stamp/clown,
		/obj/item/bikehorn,
		/obj/item/bikehorn/airhorn,
		/obj/item/paint/anycolor,
		/obj/item/borg/charger,
		/obj/item/weldingtool/cyborg/mini,
		/obj/item/soap/nanotrasen,
		/obj/item/pneumatic_cannon/pie/selfcharge/cyborg,
		/obj/item/razor,					//killbait material - Kevinz000
		/obj/item/lipstick/purple,
		/obj/item/reagent_containers/spray/waterflower/cyborg,
		/obj/item/borg/cyborghug/peacekeeper,
		/obj/item/borg/lollipop/clown,
		/obj/item/picket_sign/cyborg,
		/obj/item/reagent_containers/borghypo/clown,
		/obj/item/extinguisher/mini)
	emag_items = list(
		/obj/item/reagent_containers/borghypo/clown/hacked,
		/obj/item/reagent_containers/spray/waterflower/cyborg/hacked)
	clockcult_items = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/vanguard,
		/obj/item/clockwork/weapon/brass_battlehammer)	//honk

/obj/item/new_robot_module/borgi
	name = "Borgi"
	basic_items = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/charger,
		/obj/item/borg/cyborghug/peacekeeper)

/obj/item/new_robot_module/butler
	name = "Service"
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

/obj/item/new_robot_module/miner
	name = "Miner"
	basic_items = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/sight/meson,
		/obj/item/storage/bag/ore/cyborg,
		/obj/item/pickaxe/drill/cyborg,
		/obj/item/shovel,
		/obj/item/borg/charger,
		/obj/item/crowbar/cyborg,
		/obj/item/weldingtool/cyborg/mini,
		/obj/item/extinguisher/mini,
		/obj/item/storage/bag/sheetsnatcher/borg,
		/obj/item/gun/energy/kinetic_accelerator/cyborg,
		/obj/item/gps/cyborg,
		/obj/item/stack/marker_beacon,
		/obj/item/t_scanner/adv_mining_scanner/cyborg)
	emag_items = list(/obj/item/borg/stun)
	clockcult_items = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/vanguard,
		/obj/item/clock_module/ocular_warden,
		/obj/item/clock_module/sentinels_compromise)

/obj/item/new_robot_module/syndicate
	name = "Syndicate Assault"
	basic_items = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/melee/transforming/energy/sword/cyborg,
		/obj/item/gun/energy/printer,
		/obj/item/gun/ballistic/revolver/grenadelauncher/cyborg,
		/obj/item/card/emag,
		/obj/item/borg/charger,
		/obj/item/weldingtool/cyborg/mini,
		/obj/item/crowbar/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/pinpointer/syndicate_cyborg)

/obj/item/new_robot_module/syndicate/add_parent(mob/M)
	. = ..()
	var/mob/living/silicon/new_robot/Syndi = robot_parent
	Syndi?.faction  -= "silicon" //ai turrets

/obj/item/new_robot_module/syndicate/remove_parent(obj/item/I, delete_after)
	var/mob/living/silicon/robot_old/Syndi = robot_parent
	Syndi?.faction += "silicon" //ai is your bff now!
	return ..()

/obj/item/new_robot_module/syndicate_medical
	name = "Syndicate Medical"
	basic_items = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/reagent_containers/borghypo/syndicate,
		/obj/item/shockpaddles/syndicate/cyborg,
		/obj/item/healthanalyzer,
		/obj/item/surgical_drapes,
		/obj/item/borg/charger,
		/obj/item/weldingtool/cyborg/mini,
		/obj/item/retractor,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/surgicaldrill,
		/obj/item/scalpel,
		/obj/item/melee/transforming/energy/sword/cyborg/saw,
		/obj/item/rollerbed/robo,
		/obj/item/card/emag,
		/obj/item/crowbar/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/pinpointer/syndicate_cyborg,
		/obj/item/stack/medical/gauze,
		/obj/item/gun/medbeam,
		/obj/item/organ_storage)

/obj/item/new_robot_module/saboteur
	name = "Syndicate Saboteur"
	basic_items = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/sight/thermal,
		/obj/item/construction/rcd/borg/syndicate,
		/obj/item/pipe_dispenser,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/borg/charger,
		/obj/item/extinguisher,
		/obj/item/weldingtool/cyborg,
		/obj/item/screwdriver/nuke,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/stack/sheet/iron,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/sheet/rglass/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/iron/base/cyborg,
		/obj/item/dest_tagger/borg,
		/obj/item/stack/cable_coil,
		/obj/item/card/emag,
		/obj/item/pinpointer/syndicate_cyborg,
		/obj/item/borg_chameleon,
		)
