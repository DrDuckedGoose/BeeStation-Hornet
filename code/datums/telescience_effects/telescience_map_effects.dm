//some Locations that have uniue access effects

/// ===== Sends portal to a seperate Z =====
/datum/telescience_crash_effect/map/z_jump
	name = "Dimensional matrix fold"
	desc = "An naturally folded section of space has been accessed."
	var/level = 2

/datum/telescience_crash_effect/map/z_jump/action(turf/T)
	return get_turf(locate(T?.x, T?.y, level))
