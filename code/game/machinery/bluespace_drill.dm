/obj/machinery/bluespace_drill
	name = "bluespace drill"
	icon = 'icons/obj/machines/telescience.dmi'
	icon_state = "base"
	///How often we harvest resources, higher is slower
	var/process_rate = 10
	///Coordinates for drill sample
	var/azimuth = 0
	var/elevation = 0
	///
	var/datum/component/remote_materials/materials

/obj/machinery/bluespace_drill/Initialize(mapload)
	. = ..()
	materials = AddComponent(/datum/component/remote_materials, "orm", mapload)
	START_PROCESSING(SSobj, src)

/obj/machinery/bluespace_drill/process(delta_time)
	var/datum/component/material_container/mat_container = materials.mat_container
	if (!mat_container)
		return
	var/obj/item/stack/ore/gold/G = new()
	mat_container.insert_item(G, 1) //insert it
	
