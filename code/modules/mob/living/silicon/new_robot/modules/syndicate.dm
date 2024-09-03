/obj/item/new_robot_module/syndicate
	name = "Syndicate Assault"
	module_icon = "malf"
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
	var/mob/living/silicon/new_robot/Syndi = robot_parent
	Syndi?.faction += "silicon" //ai is your bff now!
	return ..()

/obj/item/new_robot_module/syndicate_medical
	name = "Syndicate Medical"
	module_icon = "malf"
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
	module_icon = "malf"
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
