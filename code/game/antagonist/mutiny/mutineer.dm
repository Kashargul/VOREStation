var/datum/antagonist/mutineer/mutineers

/datum/antagonist/mutineer
	role_type = BE_MUTINEER
	role_text = "Mutineer"
	role_text_plural = "Mutineers"
	id = MODE_MUTINEER
	antag_indicator = "mutineer"
	restricted_jobs = list(JOB_SITE_MANAGER)

/datum/antagonist/mutineer/New(var/no_reference)
	..()
	if(!no_reference)
		mutineers = src

/datum/antagonist/mutineer/proc/recruit()

/datum/antagonist/mutineer/can_become_antag(var/datum/mind/player)
	if(!..())
		return 0
	if(!ishuman(player.current))
		return 0
	if(M.special_role)
		return 0
	return 1

/*
	var/list/directive_candidates = get_directive_candidates()
	if(!directive_candidates || directive_candidates.len == 0)
		to_world(span_warning("Mutiny mode aborted: no valid candidates for Directive X."))
		return 0

	head_loyalist = pick(loyalist_candidates)
	head_mutineer = pick(mutineer_candidates)
	current_directive = pick(directive_candidates)


	// Returns an array in case we want to expand on this later.
	proc/get_head_loyalist_candidates()
		var/list/candidates[0]
		for(var/mob/loyalist in GLOB.player_list)
			if(loyalist.mind && loyalist.mind.assigned_role == JOB_SITE_MANAGER)
				candidates.Add(loyalist.mind)
		return candidates

	proc/get_head_mutineer_candidates()
		var/list/candidates[0]
		for(var/mob/mutineer in GLOB.player_list)
			if(mutineer.client.prefs.be_special & BE_MUTINEER)
				for(var/job in command_positions - JOB_SITE_MANAGER)
					if(mutineer.mind && mutineer.mind.assigned_role == job)
						candidates.Add(mutineer.mind)
		return candidates

	proc/get_directive_candidates()
		var/list/candidates[0]
		for(var/T in subtypesof(/datum/directive))
			var/datum/directive/D = new T(src)
			if (D.meets_prerequisites())
				candidates.Add(D)
		return candidates


	return 1

*/
