/datum/event_container
	var/severity = -1
	var/delayed = 0
	var/delay_modifier = 1
	var/next_event_time = 0
	var/list/available_events
	var/list/last_event_time = list()
	var/datum/event_meta/next_event = null

	var/last_world_time = 0

/datum/event_container/process()
	if(!GLOB.round_start_time)
		return //don't do events if the round hasn't even started yet

	if(!next_event_time)
		set_event_delay()

	if(delayed || !CONFIG_GET(flag/allow_random_events))
		next_event_time += (world.time - last_world_time)
	else if(world.time > next_event_time)
		start_event()

	last_world_time = world.time

/datum/event_container/proc/start_event()
	if(!next_event)	// If non-one has explicitly set an event, randomly pick one
		next_event = acquire_event()

	// Has an event been acquired?
	if(next_event)
		// Set when the event of this type was last fired, and prepare the next event start
		last_event_time[next_event] = world.time
		set_event_delay()
		next_event.enabled = !next_event.one_shot	// This event will no longer be available in the random rotation if one shot

		new next_event.event_type(next_event)	// Events are added and removed from the processing queue in their New/kill procs

		log_debug("Starting event '[next_event.name]' of severity [GLOB.severity_to_string[severity]].")
		next_event = null						// When set to null, a random event will be selected next time
	else
		// If not, wait for one minute, instead of one tick, before checking again.
		next_event_time += (60 * 10)


/datum/event_container/proc/acquire_event()
	if(available_events.len == 0)
		return
	var/active_with_role = number_active_with_role()

	var/list/possible_events = list()
	for(var/datum/event_meta/EM in available_events)
		var/event_weight = get_weight(EM, active_with_role)
		if(event_weight > 0)
			possible_events[EM] = event_weight

	if(possible_events.len == 0)
		return null

	// Select an event and remove it from the pool of available events
	var/picked_event = pickweight(possible_events)
	available_events -= picked_event
	return picked_event

/datum/event_container/proc/get_weight(var/datum/event_meta/EM, var/list/active_with_role)
	if(!EM.enabled)
		return 0

	if(!(EM.minimum_active(active_with_role)))
		return 0

	var/weight = EM.get_weight(active_with_role)
	var/last_time = last_event_time[EM]
	if(last_time)
		var/time_passed = world.time - last_time
		var/weight_modifier = max(0, round((CONFIG_GET(number/expected_round_length) - time_passed) / 300))
		weight = weight - weight_modifier

	return weight

/datum/event_container/proc/set_event_delay()
	var/list/event_delays

	switch(severity)
		if(EVENT_LEVEL_MUNDANE)
			event_delays = CONFIG_GET(keyed_list/event_first_run_mundane)
		if(EVENT_LEVEL_MODERATE)
			event_delays = CONFIG_GET(keyed_list/event_first_run_moderate)
		if(EVENT_LEVEL_MAJOR)
			event_delays = CONFIG_GET(keyed_list/event_first_run_major)

	// If the next event time has not yet been set and we have a custom first time start
	if(next_event_time == 0 && event_delays)
		var/lower = (event_delays["lower"] MINUTES)
		var/upper = (event_delays["upper"] MINUTES)
		var/event_delay = rand(lower, upper)
		next_event_time = world.time + event_delay
	// Otherwise, follow the standard setup process
	else
		var/playercount_modifier = 1
		switch(GLOB.player_list.len)
			if(0 to 10)
				playercount_modifier = 1.2
			if(11 to 15)
				playercount_modifier = 1.1
			if(16 to 25)
				playercount_modifier = 1
			if(26 to 35)
				playercount_modifier = 0.9
			if(36 to 100000)
				playercount_modifier = 0.8
		playercount_modifier = playercount_modifier * delay_modifier

		var/event_delay = rand(CONFIG_GET(number_list/event_delay_lower)[severity] MINUTES, CONFIG_GET(number_list/event_delay_upper)[severity] MINUTES) * playercount_modifier
		next_event_time = world.time + event_delay

	log_debug("Next event of severity [GLOB.severity_to_string[severity]] in [(next_event_time - world.time)/600] minutes.")

/datum/event_container/proc/SelectEvent()
	var/datum/event_meta/EM = tgui_input_list(usr, "Select an event to queue up.", "Event Selection", available_events)
	if(!EM)
		return
	if(next_event)
		available_events += next_event
	available_events -= EM
	next_event = EM
	return EM

/datum/event_container/mundane
	severity = EVENT_LEVEL_MUNDANE
	available_events = list(
		// Severity level, event name, even type, base weight, role weights, one shot, min weight, max weight. Last two only used if set and non-zero
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Nothing",			/datum/event/nothing,			100),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "APC Damage",		/datum/event/apc_damage,		20, 	list(DEPARTMENT_ENGINEERING = 20)),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Brand Intelligence",/datum/event/brand_intelligence,20, 	list(JOB_JANITOR = 25),	1),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Camera Damage",		/datum/event/camera_damage,		20, 	list(DEPARTMENT_ENGINEERING = 20)),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Economic News",		/datum/event/economic_event,	300),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Lost Carp",			/datum/event/carp_migration, 	20, 	list(DEPARTMENT_SECURITY = 10), 1),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Money Hacker",		/datum/event/money_hacker, 		0, 		list(DEPARTMENT_ANY = 4), 1, 10, 25),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Money Lotto",		/datum/event/money_lotto, 		0, 		list(DEPARTMENT_ANY = 1), 1, 5, 15),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Shipping Error",	/datum/event/shipping_error	, 	30, 	list(DEPARTMENT_ANY = 2), 0),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Space Dust",		/datum/event/dust	, 			60, 	list(DEPARTMENT_ENGINEERING = 20), 0, 0, 50),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Trivial News",		/datum/event/trivial_news, 		400),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Lore News",			/datum/event/lore_news, 		400),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Vermin Infestation",/datum/event/infestation, 		100,	list(JOB_JANITOR = 100)),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Wallrot",			/datum/event/wallrot, 			0,		list(DEPARTMENT_ENGINEERING = 30, JOB_BOTANIST = 50)),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Aurora Caelus",		/datum/event/aurora_caelus,		2,		list(), 1),
	)

/datum/event_container/moderate
	severity = EVENT_LEVEL_MODERATE
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Nothing",					/datum/event/nothing,					800),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Appendicitis", 			/datum/event/spontaneous_appendicitis, 	0,		list(DEPARTMENT_MEDICAL = 30), 1),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Carp School",				/datum/event/carp_migration,			100, 	list(DEPARTMENT_ENGINEERING = 20, DEPARTMENT_SECURITY = 30), 1),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Communication Blackout",	/datum/event/communications_blackout,	500,	list(JOB_AI = 150, DEPARTMENT_SECURITY = 120)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Electrical Storm",			/datum/event/electrical_storm, 			250,	list(DEPARTMENT_ENGINEERING = 20, JOB_JANITOR = 150)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Gravity Failure",			/datum/event/gravity,	 				75,		list(DEPARTMENT_ENGINEERING = 60)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Grid Check",				/datum/event/grid_check, 				200,	list(DEPARTMENT_RESEARCH = 10)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Ion Storm",				/datum/event/ionstorm, 					0,		list(JOB_AI = 80, JOB_CYBORG = 50, DEPARTMENT_ENGINEERING = 15, DEPARTMENT_RESEARCH = 5)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Meteor Shower",			/datum/event/meteor_wave,				30,		list(DEPARTMENT_ENGINEERING = 20)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Prison Break",				/datum/event/prison_break,				10,		list(DEPARTMENT_SECURITY = 100)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Radiation Storm",			/datum/event/radiation_storm, 			50,		list(DEPARTMENT_MEDICAL = 50), 1),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Random Antagonist",		/datum/event/random_antag,		 		2.5,	list(DEPARTMENT_SECURITY = 1), 1, 0, 5),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Rogue Drones",				/datum/event/rogue_drone, 				20,		list(DEPARTMENT_SECURITY = 60)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Solar Storm",				/datum/event/solar_storm, 				30,		list(DEPARTMENT_ENGINEERING = 40, DEPARTMENT_SECURITY = 30), 1),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Space Dust",				/datum/event/dust,	 					80, 	list(DEPARTMENT_ENGINEERING = 30)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Spider Infestation",		/datum/event/spider_infestation, 		100,	list(DEPARTMENT_SECURITY = 40), 1),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Virology Breach",			/datum/event/prison_break/virology,		0,		list(DEPARTMENT_MEDICAL = 100)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Xenobiology Breach",		/datum/event/prison_break/xenobiology,	0,		list(DEPARTMENT_RESEARCH = 100)),
	)

/datum/event_container/major
	severity = EVENT_LEVEL_MAJOR
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Nothing",				/datum/event/nothing,			900),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Blob",				/datum/event/blob, 				10,	list(DEPARTMENT_ENGINEERING = 60), 1),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Carp Migration",		/datum/event/carp_migration,	10,	list(DEPARTMENT_SECURITY = 10), 1),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Containment Breach",	/datum/event/prison_break/station,0,list(DEPARTMENT_ANY = 5)),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Meteor Wave",			/datum/event/meteor_wave,		30,	list(DEPARTMENT_ENGINEERING = 30),	1),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Space Vines",			/datum/event/spacevine, 		20,	list(DEPARTMENT_ENGINEERING = 15), 1),
	)
