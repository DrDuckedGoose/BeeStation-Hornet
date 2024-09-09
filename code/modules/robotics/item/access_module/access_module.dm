/obj/item/access_module
	name = "access module"
	desc = "A component used in endo assembly to grant area access to robots."
	icon = 'icons/obj/robotics/endo.dmi'
	icon_state = "access_module"
	///What access we rocking with?
	var/list/access = list()

/obj/item/access_module/proc/get_access()
	return access

//All access
/obj/item/access_module/all
	name = "command access module"

/obj/item/access_module/all/get_access()
	return get_all_accesses()

/*
	Generic department access
*/

/obj/item/access_module/service
	name = "service access module"
	icon_state = "access_module_service"
	access = list(ACCESS_COURT, ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_AUX_BASE,
	ACCESS_CONSTRUCTION, ACCESS_MORGUE, ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS,
	ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)

/obj/item/access_module/science
	name = "science access module"
	icon_state = "access_module_science"
	access = list(ACCESS_TOX, ACCESS_MORGUE, ACCESS_EXPLORATION, ACCESS_TOX_STORAGE, ACCESS_MECH_SCIENCE, ACCESS_MECH_MINING, ACCESS_MECH_MEDICAL,
	ACCESS_MECH_ENGINE, ACCESS_RESEARCH, ACCESS_ROBOTICS, ACCESS_XENOBIOLOGY, ACCESS_MINISAT, ACCESS_MAINT_TUNNELS, ACCESS_NETWORK, ACCESS_AUX_BASE,
	ACCESS_RD_SERVER)

/obj/item/access_module/security
	name = "security access module"
	icon_state = "access_module_security"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_SEC_RECORDS, ACCESS_BRIG, ACCESS_BRIGPHYS, ACCESS_ARMORY, ACCESS_COURT, ACCESS_WEAPONS,
	ACCESS_MECH_SECURITY, ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS)

/obj/item/access_module/engineering
	name = "engineering access module"
	icon_state = "access_module_engineering"
	access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_ATMOSPHERICS,
	ACCESS_AUX_BASE, ACCESS_CONSTRUCTION, ACCESS_MINISAT, ACCESS_MECH_ENGINE, ACCESS_TCOMSAT, ACCESS_MINERAL_STOREROOM)

/obj/item/access_module/medical
	name = "medical access module"
	icon_state = "access_module_medical"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS, ACCESS_CLONING,
	ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_SURGERY, ACCESS_MECH_MEDICAL, ACCESS_MAINT_TUNNELS, ACCESS_BRIGPHYS)

/*
	Box for roundstart stuff
*/
//TODO: Throw these in robotics on maps - Racc
/obj/item/storage/box/access_module
	name = "box of robotic access modules"
	desc = "A box containing access modules used in robotic assembly."

/obj/item/storage/box/access_module/PopulateContents()
	//Add 3 random access
	var/list/modules = subtypesof(/obj/item/access_module) - /obj/item/access_module/all
	for(var/i in 1 to 3)
		var/module = pick(modules)
		modules -= module
		new module(src)
	//Add 1 all access
	new /obj/item/access_module/all(src)
