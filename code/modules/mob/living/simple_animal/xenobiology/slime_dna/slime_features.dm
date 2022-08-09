///Visual feature datums
/datum/xenobiology_feature
	///icon/resource address
	var/address
	///genus epithet
	var/epithet = "un-set-um"
	///list weight
	var/weight = XENOB_COMMON
	///Extra discovery points provided by feature
	var/extra_discovery = XENOB_DISC_COMMON

// -- textures --
/datum/xenobiology_feature/texture

/datum/xenobiology_feature/texture/plain
	address = "c_plain"
	epithet = ""
	weight = XENOB_VERY_COMMON

/datum/xenobiology_feature/texture/dots
	address = "c_dots"
	epithet = "maculosus"

/datum/xenobiology_feature/texture/waves
	address = "c_waves"
	epithet = "fluctus"

/datum/xenobiology_feature/texture/arrow
	address = "r_arrow"
	epithet = "sagitta"
	weight = XENOB_UNCOMMON
	extra_discovery = XENOB_DISC_RARE

/datum/xenobiology_feature/texture/rattle
	address = "r_rattle"
	epithet = "sagitta"
	weight = XENOB_UNCOMMON
	extra_discovery = XENOB_DISC_RARE

/datum/xenobiology_feature/texture/bubble
	address = "e_bouncy"
	epithet = "bulla"
	weight = XENOB_RARE
	extra_discovery = XENOB_DISC_EXOTIC

/datum/xenobiology_feature/texture/hat
	address = "e_hat"
	epithet = "petasum"
	weight = XENOB_RARE
	extra_discovery = XENOB_DISC_EXOTIC

/datum/xenobiology_feature/texture/smile
	address = "e_smile"
	epithet = "faciem"
	weight = XENOB_RARE
	extra_discovery = XENOB_DISC_EXOTIC

// -- masks -- 
/datum/xenobiology_feature/mask

/datum/xenobiology_feature/mask/default
	address = "m_default"
	epithet = "gelatina"
	weight = XENOB_VERY_COMMON

/datum/xenobiology_feature/mask/square
	address = "m_square"
	epithet = "gelatina-cubena" //cubena is technically a genus of moths :)
	weight = XENOB_EXOTIC
	extra_discovery = XENOB_DISC_EXOTIC

/datum/xenobiology_feature/mask/dough
	address = "m_dough"
	epithet = "gelatina-torusa"
	weight = XENOB_EXOTIC
	extra_discovery = XENOB_DISC_EXOTIC

// -- sub-masks --
//please don'texture parent these to masks
/datum/xenobiology_feature/sub_mask
	weight = XENOB_RARE
	extra_discovery = XENOB_DISC_RARE

/datum/xenobiology_feature/sub_mask/blank
	address = "m_blank"
	epithet = ""
	weight = XENOB_COMMON
	extra_discovery = XENOB_DISC_COMMON

/datum/xenobiology_feature/sub_mask/tumor
	address = "m_tumor"
	epithet = "bulbus"

/datum/xenobiology_feature/sub_mask/shogun
	address = "m_shogun"
	epithet = "cornibus"

/datum/xenobiology_feature/sub_mask/hat
	address = "m_hat"
	epithet = "parvum-petasum"

/datum/xenobiology_feature/sub_mask/love
	address = "m_love"
	epithet = "amare"

/datum/xenobiology_feature/sub_mask/halo
	address = "m_halo"
	epithet = "angelus" //this was orignally the latin word for halo...

// -- colors --
/datum/xenobiology_feature/color
	///Color components, primary, secondary, and tertiary
	var/list/primary = list(null, null, null)
	var/list/secondary = list(null, null, null)
	var/list/tertiary = list(null, null, null)

/datum/xenobiology_feature/color/red
	// rgb(255, 0, 0)
	primary = list(255, 0, 0)
	epithet = "rubrum"

/datum/xenobiology_feature/color/blue
	// rgb(0, 0, 255)
	primary = list(0, 0, 255)	
	epithet = "caeruleum"

/datum/xenobiology_feature/color/green
	// rgb(0, 255, 0)
	primary = list(0, 255, 0)
	epithet = "viridis"

/datum/xenobiology_feature/color/medical
	weight = XENOB_UNCOMMON
	// rgb(255, 255, 255)
	primary = list(255, 255, 255)
	// rgb(255, 0, 0)
	secondary = list(255, 0, 0)
	// rgb(255, 0, 0)
	tertiary = list(255, 0, 0)
	epithet = "medica"
