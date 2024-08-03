/obj/item/access_module
	name = "access module"
	desc = "A component used in endo assembly to grant area access."
	icon_state = "nucleardisk"
	///What access we rocking with?
	var/list/access = list()

/obj/item/access_module/proc/get_access()
	return access

//All access
/obj/item/access_module/all
	name = "access module - ALL"

/obj/item/access_module/all/get_access()
	return get_all_accesses()
