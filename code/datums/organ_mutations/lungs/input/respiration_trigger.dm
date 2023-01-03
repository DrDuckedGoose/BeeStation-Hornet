//Respiration trigger - Breathing a specified gas will cause a trigger
//Oxygen trigger
/datum/organ_mutation/lungs/respiration
	name = "Reactive Respiration"
	desc = "When exposed to O2, this organ will produce large amount of adrenaline."
	text_gain_indication = "<span class='notice'>Your body feels warm!</span>"
	quality = 1
	///What gas triggers us
	var/trigger_gas = GAS_O2
	///How many ticks between breath checks - higher = slower - multiples of 3 work best
	var/tick_intensity = 3

//Plasma trigger
/datum/organ_mutation/lungs/respiration/plasma
	desc = "When exposed to Plasma, this organ will produce large amount of adrenaline."
	trigger_gas = GAS_PLASMA

/datum/organ_mutation/lungs/respiration/New()
	..()
	START_PROCESSING(SSobj, src)

/datum/organ_mutation/lungs/respiration/process(delta_time)
	//Only perform this every X ticks
	if(world.time % tick_intensity != 0)
		return
	//Activate our mutations if we found our gas
	var/turf/T = get_turf(carbon_owner) //Needs to have these steps unfortunately, auxmos moment
	var/datum/gas_mixture/G = T?.return_air()//Turf air
	var/datum/gas_mixture/GI = carbon_owner?.get_breath_from_internal(BREATH_VOLUME) //Internals air
	G = GI ? null : G //Can't have turf air if we're using internals
	var/air = G?.get_moles(trigger_gas) + GI?.get_moles(trigger_gas) //This is a weird way of doing it but auxmos causes many strange runtimes
	if(air)
		SEND_SIGNAL(organ_owner, ORGAN_MUT_TRIGGER)
