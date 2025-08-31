/datum/job/noncrew
	title = JOB_OUTSIDER
	disallow_jobhop = TRUE
	total_positions = 6
	spawn_positions = 6
	supervisors = "nobody, but you fall under NanoTrasen's Unauthorized Personnel SOP while on NT property. Please read <a href='https://wiki.chompstation13.net/index.php/Rules#Outsiders_Guidelines'>the Outsider Guidelines</a> clearly before playing"

	flag = NONCREW
	departments = list(DEPARTMENT_NONCREW)
	department_flag = OTHER
	faction = FACTION_STATION
	assignable = FALSE
	account_allowed = 0
	offmap_spawn = TRUE

	outfit_type = /decl/hierarchy/outfit/noncrew
	job_description = {"Players taking a role of an outsider not employed by NT with no special mechanics. One superpose pod is provided.
		-----Server rules still apply to the fullest
		-----Outsiders are considered unauthorized personnel on the station.
		-----Outsiders are not allowed to take part in events and mini-event areas unless the EM says otherwise.
		-----Outsiders are not allowed to take station jobs.
		-----Outsiders are not allowed to know more than two department jobs.
		-----Outsiders are expected to behave in accordance with Unauthorized Personnel SOP regardless of their IC knowledge.
		-----Outsiders are not allowed to log-off with station key items (e.g. Captain's spare, station blueprints, nuclear authentication disk, bluespace harpoon, large quantities of station goods, etc). Please leave these items on station or with relevant crew.
		-----We encourage outsiders to take on exploration content as a group, staff will not help you for any hardships of solo play.
		-----Notice: The outsider role is relatively new; if you encounter bugs, please notify a staff member and avoid using exploits."}
	alt_titles = list("Spacefarer" = /datum/alt_title/spacefarer)

/datum/alt_title/spacefarer
	title = "Spacefarer"
	title_outfit = /decl/hierarchy/outfit/noncrew/spacefarer

/datum/job/noncrewrobot
	title = JOB_OUTSIDER_ROBOT
	disallow_jobhop = TRUE
	total_positions = 3
	spawn_positions = 2
	supervisors = "nobody, but you fall under NanoTrasen's Unauthorized Personnel SOP while on NT property. Please read <a href='https://wiki.chompstation13.net/index.php/Rules#Outsiders_Guidelines'>the Outsider Guidelines</a> clearly before playing"

	flag = NONCREW
	departments = list(DEPARTMENT_NONCREW)
	department_flag = OTHER
	faction = FACTION_STATION
	assignable = FALSE
	minimal_player_age = 1
	account_allowed = 0
	economic_modifier = 0
	offmap_spawn = TRUE
	has_headset = FALSE
	assignable = FALSE
	mob_type = JOB_SILICON_ROBOT
	outfit_type = /decl/hierarchy/outfit/job/silicon/cyborg

	job_description = {"Players taking a role of an outsider not owned by NT with no special mechanics.
		-----Server rules still apply to the fullest
		-----Outsiders are considered unauthorized personnel on the station.
		-----Outsiders are not allowed to take part in events and mini-event areas unless the EM says otherwise.
		-----Outsiders are not allowed to take station jobs.
		-----Outsiders are not allowed to know more than two department jobs.
		-----Outsiders are expected to behave in accordance with Unauthorized Personnel SOP regardless of their IC knowledge.
		-----Outsiders are not allowed to log-off with station key items (e.g. Captain's spare, station blueprints, nuclear authentication disk, bluespace harpoon, large quantities of station goods, etc). Please leave these items on station or with relevant crew.
		-----We encourage outsiders to take on exploration content as a group, staff will not help you for any hardships of solo play.
		-----Notice: The outsider role is relatively new; if you encounter bugs, please notify a staff member and avoid using exploits."}

/datum/job/noncrewrobot/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	return 1

/datum/job/noncrewrobot/equip_preview(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/cardborg(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/cardborg(H), slot_head)
	return 1
