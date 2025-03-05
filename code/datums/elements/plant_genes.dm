#define COMSIG_PLANT_GET_GENES "COMSIG_PLANT_GET_GENES"

/// Plant gene element. Allows most things grown from plants to be turned into seeds
/datum/element/plant_genes
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	///List of our plant genes
	var/list/plant_features = list()

/datum/element/plant_genes/Attach(obj/target, list/_plant_features)
	. = ..()
	//TODO: Consider if I want this - Racc
	//if(!isitem(target))
	//	return ELEMENT_INCOMPATIBLE
	plant_features = _plant_features
	RegisterSignal(target, COMSIG_PLANT_GET_GENES, PROC_REF(append_genes))

/datum/element/plant_genes/proc/append_genes(datum/source, list/gene_list)
	SIGNAL_HANDLER

	gene_list += plant_features
