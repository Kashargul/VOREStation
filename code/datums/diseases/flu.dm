/datum/disease/flu
	name = "The Flu"
	medical_name = "Influenza"
	max_stages = 3
	spread_text = "Airborne"
	cure_text = REAGENT_SPACEACILLIN
	cures = list(REAGENT_ID_SPACEACILLIN, REAGENT_ID_CHICKENSOUP, REAGENT_ID_CHICKENNOODLESOUP)
	virus_modifiers = NONE //Does NOT have needs_all_cures
	cure_chance = 10
	agent = "H13N1 flu virion"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/human/monkey)
	permeability_mod = 0.75
	desc = "If left untreated the subject will feel quite unwell."
	danger = DISEASE_MINOR

/datum/disease/flu/stage_act()
	..()
	switch(stage)
		if(2)
			if(affected_mob.lying && prob(20))
				to_chat(affected_mob, span_notice("You feel better."))
				stage--
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, span_danger("Your muscles ache."))
				if(prob(20))
					affected_mob.apply_damage(1)
			if(prob(1))
				to_chat(affected_mob, span_danger("Your stomach hurts."))
				affected_mob.adjustToxLoss(1)
		if(3)
			if(affected_mob.lying && prob(15))
				to_chat(affected_mob, span_notice("You feel better."))
				stage--
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, span_danger("Your muscles ache."))
				if(prob(20))
					affected_mob.apply_damage(1)
			if(prob(1))
				to_chat(affected_mob, span_danger("Your stomach hurts."))
				affected_mob.adjustToxLoss(1)
	return
