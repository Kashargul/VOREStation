/datum/power/changeling/DeathSting
	name = "Death Sting"
	desc = "We silently sting a human, filling him with potent chemicals. His rapid death is all but assured."
	ability_icon_state = "ling_sting_death"
	genomecost = 10
	verbpath = /mob/proc/changeling_DEATHsting

/mob/proc/changeling_DEATHsting()
	set category = "Changeling"
	set name = "Death Sting (40)"
	set desc = "Causes spasms onto death."

	var/mob/living/carbon/T = changeling_sting(40,/mob/proc/changeling_DEATHsting)
	if(!T)
		return 0
	add_attack_logs(src,T,"Death sting (changeling)")
	to_chat(T, span_danger("You feel a small prick and your chest becomes tight."))
	T.silent = 10
	T.Paralyse(10)
	T.make_jittery(100)
	if(T.reagents)	T.reagents.add_reagent(REAGENT_ID_LEXORIN, 40)
	feedback_add_details("changeling_powers","DTHS")
	return 1
