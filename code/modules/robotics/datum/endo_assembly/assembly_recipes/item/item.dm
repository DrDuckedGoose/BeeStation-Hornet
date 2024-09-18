/datum/endo_assembly/item/signaler
	item_requirment = /obj/item/assembly/signaler
	assembly_integral = TRUE

/datum/endo_assembly/item/proximity_sensor
	item_requirment = /obj/item/assembly/prox_sensor
	assembly_integral = TRUE

/datum/endo_assembly/item/vest
	item_requirment = /obj/item/clothing/suit/armor/vest
	assembly_integral = TRUE

/datum/endo_assembly/item/helmet
	item_requirment = /obj/item/clothing/head/helmet
	assembly_integral = TRUE

/datum/endo_assembly/item/analyzer
	item_requirment = /obj/item/analyzer

/datum/endo_assembly/item/clown_horn
	item_requirment = /obj/item/bikehorn

/datum/endo_assembly/item/hardhat
	item_requirment = /obj/item/clothing/head/utility/hardhat
	assembly_integral = TRUE

/datum/endo_assembly/item/oxygen
	item_requirment = /obj/item/tank/internals/oxygen

/datum/endo_assembly/item/toolbox
	item_requirment = /obj/item/storage/toolbox

/datum/endo_assembly/item/welder
	item_requirment = /obj/item/weldingtool

/datum/endo_assembly/item/stun_baton
	item_requirment = /obj/item/melee/baton
	assembly_integral = TRUE

/datum/endo_assembly/item/disabler
	item_requirment = /obj/item/gun/energy/disabler
	assembly_integral = TRUE

/datum/endo_assembly/item/healthanalyzer
	item_requirment = /obj/item/healthanalyzer

/datum/endo_assembly/item/access_module
	item_requirment = /obj/item/access_module
	poll_path = /obj/item/access_module
	allow_poll = TRUE
	amount_required = 3

/datum/endo_assembly/item/access_module/New(datum/parent)
	. = ..()
	hint_data["name"] = "access module"

/datum/endo_assembly/item/cell
	item_requirment = /obj/item/stock_parts/cell
	poll_path = /obj/item/stock_parts/cell
	allow_poll = TRUE

/datum/endo_assembly/item/cell/transform_machine
	item_requirment = /obj/item/stock_parts/cell/upgraded/plus

/datum/endo_assembly/item/tiles
	item_requirment = /obj/item/stack/tile

/datum/endo_assembly/item/tiles/add_part(datum/source, obj/item/I, mob/living/L)
	var/obj/item/stack/tile/stack = I
	if(istype(stack) && stack.amount < 10)
		return
	return ..()
