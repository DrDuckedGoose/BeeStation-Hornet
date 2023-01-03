//Respiration trigger
/datum/organ_mutation/lungs/respiration
	name = "Reactive Respiration"
	text_gain_indication = "<span class='notice'>Your body feels warm!</span>"
	quality = 1
	///What gas triggers us
	var/trigger_gas = GAS_O2

/datum/organ_mutation/lungs/respiration/New()
	..()
	START_PROCESSING(SSobj, src)
	desc = "When exposed to [trigger_gas], this organ will produce large amount of adrenaline."

/datum/organ_mutation/lungs/respiration/process(delta_time)
	carbon_owner?.say("Tick!")
	var/datum/gas_mixture/G
	var/obj/loc_as_obj = carbon_owner?.loc
	G = loc_as_obj?.handle_internal_lifeform(src, BREATH_VOLUME)
	if(G?.get_moles(trigger_gas))
		SEND_SIGNAL(carbon_owner, ORGAN_MUT_TRIGGER)
		carbon_owner?.say("I breathe!")
