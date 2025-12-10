//TODO: Add interaction for floral projectiles, from the botany gun thing - Racc
/datum/plant_feature
	///The 'scientific' name for our plant feature
	var/species_name = "testus testium"
	///The regular name
	var/name = "test"

	///Can this feature appear in random plants
	var/random_plant = FALSE

	///What category of feature/s are we? Mostly used for gene editing.
	var/feature_catagories

	///Reference to component daddy
	var/datum/component/plant/parent

	///List of features we don't wanna be with
	var/list/blacklist_features = list()
	///List of features we can only be with
	var/list/whitelist_features = list()

	///What traits are we rockin'?
	var/list/plant_traits = list()
	///What is the power coefficient for our traits that use it? Generally scale this as stuff like 1.3 1.8 2.1
	var/trait_power = 1

	///What are our desires, what we need to grow
	var/list/plant_needs = list()

	/*
		Although this is a list, it might be better, in terms of design, to only
		mutate into one thing, and have that one thing mutate into the
		next. Then the final mutation should mutate back into this.
	*/
	///What can this feature mutate into? typically list(mutation, mutation, mutation) but it can also be list(mutation = 10) if you want certain mutations to cost more
	var/list/mutations = list()

	///What is our genetic budget for how many traits we can afford?
	var/genetic_budget = 3
	var/remaining_genetic_budget
	///List of needs we've gained from overdrawing our budget
	var/list/overdraw_needs = list()
	///List of needs we've previously had from overdrawing, stops rerolling
	var/list/previous_needs = list()

	///Trait type shortcut
	var/trait_type_shortcut = /datum/plant_feature

//Appearance
	var/icon = 'icons/obj/hydroponics/features/generic.dmi'
	var/icon_state = ""
	var/mutable_appearance/feature_appearance

//Trait editing properties
	///Can this trait be copied
	var/can_copy = TRUE
	///Can this trait be removed
	var/can_remove = TRUE

/datum/plant_feature/New(datum/component/plant/_parent)
	. = ..()
	remaining_genetic_budget = genetic_budget
	//Build our initial appearance
	feature_appearance = mutable_appearance(icon, icon_state)
	//Setup parent stuff
	setup_parent(_parent)
	//Build initial traits
	for(var/trait as anything in plant_traits)
		plant_traits -= trait
		plant_traits += new trait(src)
	//Build initial needs
	for(var/need as anything in plant_needs)
		plant_needs -= need
		plant_needs += new need(src)
	//Build white & black list
	blacklist_features = typecacheof(blacklist_features)
	whitelist_features = typecacheof(whitelist_features)

//Used to get dialogue / text for hand-held plant scanner - This is like get_ui_data() but it has more information about specific things you'd want to know on the fly
/datum/plant_feature/proc/get_scan_dialogue()
	var/dialogue = "[capitalize(name)]([species_name])\n"
	//Traits
	for(var/datum/plant_trait/trait as anything in plant_traits)
		dialogue += "<i>[trait.name]</i>\n"
	if(!length(plant_traits))
		dialogue += "\n"
	//generic shared info - This can be a little duplicate when compared with get_ui_data() but it'll be good to keep this seperate for future additions
	dialogue += "Genetic Stability: [genetic_budget]\n"
	dialogue += "Genetic Availability: [remaining_genetic_budget]\n"
	dialogue += "Trait Modifier: [trait_power]\n"
	return dialogue

//Used to get dialogue / text for needs, when a tray is scanned
/datum/plant_feature/proc/get_need_dialogue()
	var/dialogue = "[name]([species_name])\n\n"
	for(var/datum/plant_need/need as anything in plant_needs)
		dialogue += "[need.need_description]\n"
	return dialogue

///This is a keyed list for UIs to get specific values, usually for logic or display
/datum/plant_feature/proc/get_ui_stats()
	return list("name" = capitalize(name), "species_name" = capitalize(species_name), "key" = REF(src), "feature_appearance" = icon2base64(feature_appearance), "type_shortcut" = "[trait_type_shortcut]",
	"can_copy" = can_copy, "can_remove" = can_remove)

///This is for display+, a pre-formatted list of nice looking text
/datum/plant_feature/proc/get_ui_data()
	return list(PLANT_DATA("Name", capitalize(name)), PLANT_DATA("Species Name", capitalize(species_name)), PLANT_DATA(null, null))

//our traits
/datum/plant_feature/proc/get_ui_traits()
	if(!length(plant_traits))
		return
	var/list/trait_ui = list()
	for(var/datum/plant_trait/trait as anything in plant_traits)
		trait_ui += trait?.get_ui_stats()
	return trait_ui

///Copies the plant's unique data - This is mostly, if not entirely, for randomized stuff & custom player made plants
/datum/plant_feature/proc/copy(datum/component/plant/_parent, datum/plant_feature/_feature)
	var/datum/plant_feature/new_feature = _feature || new type(_parent)
//Copy traits & needs - The reason we do this is to handle randomized traits & needs, make them the same as this one
	//traits
	for(var/trait as anything in new_feature.plant_traits)
		new_feature.plant_traits -= trait
		qdel(trait)
	for(var/datum/plant_trait/trait as anything in plant_traits)
		new_feature.plant_traits += trait.copy(new_feature)
	//needs
	for(var/need as anything in new_feature.plant_needs) //Remove new feature's generic needs
		new_feature.plant_needs -= need
		qdel(need)
	for(var/datum/plant_need/need as anything in plant_needs) //Replace them with ours
		new_feature.plant_needs += need.copy(new_feature)
	return new_feature

/datum/plant_feature/proc/setup_parent(_parent, reset_features = TRUE)
	//Remove our initial parent
	if(parent)
		UnregisterSignal(parent.plant_item, COMSIG_ATOM_EXAMINE)
		UnregisterSignal(parent, COMSIG_PLANT_PLANTED)
		UnregisterSignal(parent, COMSIG_PLANT_UPROOTED)
	//Shack up with the new rockstar
	parent = _parent
	if(parent?.plant_item)
		RegisterSignal(parent.plant_item, COMSIG_ATOM_EXAMINE, PROC_REF(catch_examine))
	RegisterSignal(parent, COMSIG_PLANT_PLANTED, PROC_REF(catch_planted))
	RegisterSignal(parent, COMSIG_PLANT_UPROOTED, PROC_REF(catch_uprooted))
	SEND_SIGNAL(src, COMSIG_PF_ATTACHED_PARENT)

/datum/plant_feature/proc/remove_parent()
	setup_parent(null)

/datum/plant_feature/proc/check_needs(_delta_time)
	if(SEND_SIGNAL(parent.plant_item.loc, COMSIG_PLANT_NEEDS_PAUSE, parent) && length(plant_needs))
		return
	for(var/datum/plant_need/need as anything in plant_needs)
		if(ispath(need))
			continue
		if(!need?.check_need(_delta_time))
			SEND_SIGNAL(parent, COMSIG_PLANT_NEEDS_FAILS, src)
			return FALSE
	SEND_SIGNAL(parent, COMSIG_PLANT_NEEDS_PASS, src)
	return TRUE

/datum/plant_feature/proc/catch_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	//Info
	return

///Use this to associate this feature datum with a seed packet, before it's planted
/datum/plant_feature/proc/associate_seeds(obj/item/plant_seeds/seeds)
	return

/datum/plant_feature/proc/catch_planted(datum/source, atom/destination)
	SIGNAL_HANDLER

/datum/plant_feature/proc/catch_uprooted(datum/source, mob/user, obj/item/tool, atom/old_loc)
	SIGNAL_HANDLER

///Used to adjust our genetic budget, contains logic for overdrawing our budget
/datum/plant_feature/proc/adjust_genetic_budget(amount, datum/source)
	remaining_genetic_budget += amount
//Need management
	//If we're overdrawing, add needs
	if(amount < 0 && remaining_genetic_budget <= 0)
		var/datum/plant_need = previous_needs["[source.type]"] || SSbotany.get_random_need()
		plant_need = new plant_need(src)
		overdraw_needs += list(REF(source) = plant_need)
		plant_needs += plant_need
		return
	//If we're paying it back, remove needs
	if(amount > 0 && plant_needs[REF(source)])
		//Archive the need so people don't try to reroll it
		var/datum/plant_need = overdraw_needs[REF(source)]
		previous_needs += list("[source.type]" = plant_need.type)
		//Remove it from ourselves
		plant_needs -= plant_need
		overdraw_needs -= REF(source)
		qdel(plant_need)

//TODO: Port these interactions somehow - Racc
/*

if(S.has_reagent(/datum/reagent/plantnutriment/eznutriment, 1))
		yieldmod = 1
		mutmod = 1
		cycledelay = 200
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/plantnutriment/eznutriment) * 1))

	if(S.has_reagent(/datum/reagent/plantnutriment/left4zednutriment, 1))
		yieldmod = 0
		mutmod = 2
		cycledelay = 200
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/plantnutriment/left4zednutriment) * 1))

	if(S.has_reagent(/datum/reagent/plantnutriment/robustharvestnutriment, 1))
		yieldmod = 1.3
		mutmod = 0
		cycledelay = 200
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/plantnutriment/robustharvestnutriment) *1 ))

	if(S.has_reagent(/datum/reagent/plantnutriment/slimenutriment, 1))
		yieldmod = 0.8
		mutmod = 1
		cycledelay = 150
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/plantnutriment/slimenutriment) *1))

			// Ambrosia Gaia produces earthsblood.
	if(S.has_reagent(/datum/reagent/medicine/earthsblood))
		self_sufficiency_progress += S.get_reagent_amount(/datum/reagent/medicine/earthsblood)
		if(self_sufficiency_progress >= self_sufficiency_req)
			become_self_sufficient()
		else if(!self_sustaining)
			to_chat(user, span_notice("[src] warms as it might on a spring day under a genuine Sun."))

	// Antitoxin binds shit pretty well. So the tox goes significantly down
	if(S.has_reagent(/datum/reagent/medicine/charcoal, 1))
		adjustToxic(-round(S.get_reagent_amount(/datum/reagent/medicine/charcoal) * 2))

	if(S.has_reagent(/datum/reagent/toxin, 1))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/toxin) * 2))

	// Milk is good for humans, but bad for plants. The sugars canot be used by plants, and the milk fat fucks up growth. Not shrooms though. I can't deal with this now...
	if(S.has_reagent(/datum/reagent/consumable/milk, 1))
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/consumable/milk) * 0.1))
		adjustWater(round(S.get_reagent_amount(/datum/reagent/consumable/milk) * 0.9))

	// Beer is a chemical composition of alcohol and various other things. It's a shitty nutrient but hey, it's still one. Also alcohol is bad, mmmkay?
	if(S.has_reagent(/datum/reagent/consumable/ethanol/beer, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/consumable/ethanol/beer) * 0.05))
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/consumable/ethanol/beer) * 0.25))
		adjustWater(round(S.get_reagent_amount(/datum/reagent/consumable/ethanol/beer) * 0.7))

	// You're an idiot for thinking that one of the most corrosive and deadly gasses would be beneficial
	if(S.has_reagent(/datum/reagent/fluorine, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/fluorine) * 2))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/fluorine) * 2.5))
		adjustWater(-round(S.get_reagent_amount(/datum/reagent/fluorine) * 0.5))
		adjustWeeds(-rand(1,4))

	// You're an idiot for thinking that one of the most corrosive and deadly gasses would be beneficial
	if(S.has_reagent(/datum/reagent/chlorine, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/chlorine) * 1))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/chlorine) * 1.5))
		adjustWater(-round(S.get_reagent_amount(/datum/reagent/chlorine) * 0.5))
		adjustWeeds(-rand(1,3))

	// White Phosphorous + water -> phosphoric acid. That's not a good thing really.
	// Phosphoric salts are beneficial though. And even if the plant suffers, in the long run the tray gets some nutrients. The benefit isn't worth that much.
	if(S.has_reagent(/datum/reagent/phosphorus, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/phosphorus) * 0.75))
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/phosphorus) * 0.1))
		adjustWater(-round(S.get_reagent_amount(/datum/reagent/phosphorus) * 0.5))
		adjustWeeds(-rand(1,2))

	// Plants should not have sugar, they can't use it and it prevents them getting water/ nutients, it is good for mold though...
	if(S.has_reagent(/datum/reagent/consumable/sugar, 1))
		adjustWeeds(rand(1,2))
		adjustPests(rand(1,2))
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/consumable/sugar) * 0.1))

	// It is water!
	if(S.has_reagent(/datum/reagent/water, 1))
		adjustWater(round(S.get_reagent_amount(/datum/reagent/water) * 1))

	// Holy water. Mostly the same as water, it also heals the plant a little with the power of the spirits~
	if(S.has_reagent(/datum/reagent/water/holywater, 1))
		adjustWater(round(S.get_reagent_amount(/datum/reagent/water/holywater) * 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/water/holywater) * 0.1))

	// A variety of nutrients are dissolved in club soda, without sugar.
	// These nutrients include carbon, oxygen, hydrogen, phosphorous, potassium, sulfur and sodium, all of which are needed for healthy plant growth.
	if(S.has_reagent(/datum/reagent/consumable/sodawater, 1))
		adjustWater(round(S.get_reagent_amount(/datum/reagent/consumable/sodawater) * 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/consumable/sodawater) * 0.1))
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/consumable/sodawater) * 0.1))

	// Man, you guys are stupid
	if(S.has_reagent(/datum/reagent/toxin/acid, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/toxin/acid) * 1))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/toxin/acid) * 1.5))
		adjustWeeds(-rand(1,2))

	// SERIOUSLY
	if(S.has_reagent(/datum/reagent/toxin/acid/fluacid, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/toxin/acid/fluacid) * 2))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/toxin/acid/fluacid) * 3))
		adjustWeeds(-rand(1,4))

	// Plant-B-Gone is just as bad
	if(S.has_reagent(/datum/reagent/toxin/plantbgone, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/toxin/plantbgone) * 5))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/toxin/plantbgone) * 6))
		adjustWeeds(-rand(4,8))

	// why, just why
	if(S.has_reagent(/datum/reagent/napalm, 1))
		if(!(myseed.resistance_flags & FIRE_PROOF))
			adjustHealth(-round(S.get_reagent_amount(/datum/reagent/napalm) * 6))
			adjustToxic(round(S.get_reagent_amount(/datum/reagent/napalm) * 7))
		adjustWeeds(-rand(5,9)) //At least give them a small reward if they bother.

	//Weed Spray
	if(S.has_reagent(/datum/reagent/toxin/plantbgone/weedkiller, 1))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/toxin/plantbgone/weedkiller) * 0.5))
		//old toxicity was 4, each spray is default 10 (minimal of 5) so 5 and 2.5 are the new ammounts
		adjustWeeds(-rand(1,2))

	//Pest Spray
	if(S.has_reagent(/datum/reagent/toxin/pestkiller, 1))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/toxin/pestkiller) * 0.5))
		adjustPests(-rand(1,2))

	// Healing
	if(S.has_reagent(/datum/reagent/medicine/cryoxadone, 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/medicine/cryoxadone) * 3))
		adjustToxic(-round(S.get_reagent_amount(/datum/reagent/medicine/cryoxadone) * 3))

	// Ammonia is bad ass.
	if(S.has_reagent(/datum/reagent/ammonia, 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/ammonia) * 0.5))
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/ammonia) * 1))
		if(myseed)
			myseed.adjust_yield(round(S.get_reagent_amount(/datum/reagent/ammonia) * 0.01))

	// Saltpetre is used for gardening IRL, to simplify highly, it speeds up growth and strengthens plants
	if(S.has_reagent(/datum/reagent/saltpetre, 1))
		var/salt = S.get_reagent_amount(/datum/reagent/saltpetre)
		adjustHealth(round(salt * 0.25))
		if (myseed)
			myseed.adjust_production(-round(salt/100)-prob(salt%100))
			myseed.adjust_potency(round(salt*0.5))
	// Ash is also used IRL in gardening, as a fertilizer enhancer and weed killer
	if(S.has_reagent(/datum/reagent/ash, 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/ash) * 0.25))
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/ash) * 0.5))
		adjustWeeds(-1)

	// This is more bad ass, and pests get hurt by the corrosive nature of it, not the plant.
	if(S.has_reagent(/datum/reagent/diethylamine, 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/diethylamine) * 1))
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/diethylamine) * 2))
		if(myseed)
			myseed.adjust_yield(round(S.get_reagent_amount(/datum/reagent/diethylamine) * 0.02))
		adjustPests(-rand(1,2))

	// Compost, effectively
	if(S.has_reagent(/datum/reagent/consumable/nutriment, 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/consumable/nutriment) * 0.5))
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/consumable/nutriment) * 1))

	// FEED ME
	if(S.has_reagent(/datum/reagent/blood, 1))
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/blood) * 1))
		adjustPests(rand(2,4))

	// FEED ME SEYMOUR
	if(S.has_reagent(/datum/reagent/medicine/strange_reagent, 1))
		spawnplant()

	// The best stuff there is. For testing/debugging.
	if(S.has_reagent(/datum/reagent/medicine/adminordrazine, 1))
		adjustWater(round(S.get_reagent_amount(/datum/reagent/medicine/adminordrazine) * 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/medicine/adminordrazine) * 1))
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/medicine/adminordrazine) * 1))
		adjustPests(-rand(1,5))
		adjustWeeds(-rand(1,5))
*/
