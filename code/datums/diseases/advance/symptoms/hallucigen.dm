/*
//////////////////////////////////////

Hallucigen

	Very noticable.
	Lowers resistance considerably.
	Decreases stage speed.
	Reduced transmittable.
	Critical Level.

Bonus
	Makes the affected mob be hallucinated for short periods of time.

//////////////////////////////////////
*/

/datum/symptom/hallucigen
	name = "Hallucigen"
	desc = "The virus stimulates the brain, causing occasional hallucinations."
	stealth = 1
	resistance = -1
	stage_speed = 1
	transmission = 1
	level = 3
	severity = 1
	base_message_chance = 25
	symptom_delay_min = 10 SECONDS
	symptom_delay_max = 70 SECONDS

	var/fake_healthy = FALSE

	prefixes = list("Narcotic ", "Narco", "Psycho-")
	suffixes = list(" Psychosis")

	threshold_descs = list(
		"Stage Speed 7" = "Increases the amount of hallucinations.",
		"Stealth 2" = "The virus mimics positive symptoms"
	)

/datum/symptom/hallucigen/severityset(datum/disease/advance/A)
	. = ..()
	if(A.stage_rate >= 7)
		severity += 1

/datum/symptom/hallucigen/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= 2)
		fake_healthy = TRUE
		base_message_chance = 50
	if(A.stage_rate >= 7)
		power = 2

/datum/symptom/hallucigen/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	if(M.stat == DEAD)
		return
	var/list/healthy_messages = list(
		"Your lungs feel great.",
		"You realize you haven't been breathing",
		"You don't feel the need to breathe.",
		"Your eyes feel great.",
		"You are now blinking manually.",
		"You don't feel the need to blnk."
	)

	switch(A.stage)
		if(1, 2)
			if(prob(base_message_chance))
				if(!fake_healthy)
					to_chat(M, span_notice(pick("Something appears in your peripheral vision, then winks out.", "You hear a faint whisper with no source.", "Your head aches.")))
				else
					to_chat(M, span_notice(pick(healthy_messages)))
		if(3, 4)
			if(prob(base_message_chance))
				if(!fake_healthy)
					to_chat(M, span_danger(pick("Something is following you.", "You are being watched.", "You hear a whisper in your ear.", "Thumping footsteps slam toward you from nowhere.")))
				else
					to_chat(M, span_notice(pick(healthy_messages)))
		else
			if(prob(base_message_chance))
				to_chat(M, span_userdanger(pick("Oh, your head...", "Your head pounds.", "They're everywhere! Run!", "Something is in the shadows...")))
			M.hallucination += (45 * power)
