/*

*/
/datum/plant_dictionary
	var/name = ""
/*

*/
/datum/plant_dictionary/entry
	var/desc = ""
	var/test

/datum/plant_dictionary/entry/new(/datum/source)
	test = source

/*

*/
/datum/plant_dictionary/chapter
	var/list/entries = list()
