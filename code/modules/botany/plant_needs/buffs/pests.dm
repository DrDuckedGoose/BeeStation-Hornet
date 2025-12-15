/*
	Actually a debuff
	Attracts pests to the tray
*/
/datum/plant_need/reagent/buff/pests
	need_description = "Wards off pests usually attracted to this plant's sweet aroma."
	reagent_needs = list(/datum/reagent/toxin/pestkiller = 5, /datum/reagent/toxin = 1, /datum/reagent/consumable/ethanol = 3, /datum/reagent/fluorine = 1, /datum/reagent/chlorine = 1, /datum/reagent/diethylamine = 1)
	auto_threshold = TRUE
	debuff = TRUE
	nectar_buff_duration = 15 SECONDS
	///How fast pests build up per tick
	var/pest_build_up = 0.05
	///Level of pests for damage calculation
	var/pest_level = 0
	///Maximum damage from pests per second
	var/pest_damage = 3
	///Quick reference the plant's body
	var/datum/plant_feature/body/body_parent

	///
	var/archive_description
	///
	var/atom/movable/artifact_particle_holder/calibrated_holder

/datum/plant_need/reagent/buff/pests/New(datum/plant_feature/_parent)
	. = ..()
	archive_description = need_description

/datum/plant_need/reagent/buff/pests/setup_component_parent(datum/source)
	. = ..()
	if(!parent || !parent.parent)
		return
	body_parent = locate(/datum/plant_feature/body) in parent.parent.plant_features
	if(!body_parent)
		return
	START_PROCESSING(SSobj, src)

/datum/plant_need/reagent/buff/pests/process(delta_time)
	need_description = "[archive_description]\nPest Level: [pest_level]%"
	if(pest_level <= 0)
		QDEL_NULL(calibrated_holder)
		return
	if(pest_level >= 30 && !calibrated_holder)
		var/atom/movable/atom_parent = parent.parent.plant_item
		calibrated_holder = new(atom_parent)
		calibrated_holder.add_emitter(/obj/emitter/flies, "calibration", 10)
		atom_parent.vis_contents += calibrated_holder
	var/mod = pest_level/100
	body_parent.adjust_health(mod*pest_damage*-1)

/datum/plant_need/reagent/buff/pests/apply_buff(__delta_time)
	. = ..()
	pest_level -= (pest_build_up*__delta_time)*2 //pests are removed twice as fast as they build up
	pest_level = max(pest_level, 0)

/datum/plant_need/reagent/buff/pests/remove_buff(__delta_time)
	. = ..()
	pest_level += pest_build_up*__delta_time
	pest_level = min(pest_level, 100)

/datum/plant_need/reagent/buff/pests/catch_nectar(datum/source)
	. = ..()
	pest_level = 0
