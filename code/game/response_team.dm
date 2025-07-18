//STRIKE TEAMS
//Thanks to Kilakk for the admin-button portion of this code.

GLOBAL_VAR_INIT(send_emergency_team, 0) // Used for automagic response teams; 'admin_emergency_team' for admin-spawned response teams

GLOBAL_VAR_INIT(ert_base_chance, 10) // Default base chance. Will be incremented by increment ERT chance.
GLOBAL_VAR(can_call_ert)
GLOBAL_VAR_INIT(silent_ert, 0)

/client/proc/response_team()
	set name = "Dispatch Emergency Response Team"
	set category = "Fun.Event Kit"
	set desc = "Send an emergency response team to the station"

	if(!check_rights_for(src, R_HOLDER))
		to_chat(usr, span_danger("Only administrators may use this command."))
		return
	if(!ticker)
		to_chat(usr, span_danger("The game hasn't started yet!"))
		return
	if(ticker.current_state == 1)
		to_chat(usr, span_danger("The round hasn't started yet!"))
		return
	if(GLOB.send_emergency_team)
		to_chat(usr, span_danger("[using_map.boss_name] has already dispatched an emergency response team!"))
		return
	if(tgui_alert(usr, "Do you want to dispatch an Emergency Response Team?","ERT",list("Yes","No")) != "Yes")
		return
	if(tgui_alert(usr, "Do you want this Response Team to be announced?","ERT",list("Yes","No")) != "Yes")
		GLOB.silent_ert = 1
	if(get_security_level() != "red") // Allow admins to reconsider if the alert level isn't Red
		if(tgui_alert(usr, "The station is not in red alert. Do you still want to dispatch a response team?","ERT",list("Yes","No")) != "Yes")
			return
	if(GLOB.send_emergency_team)
		to_chat(usr, span_danger("Looks like somebody beat you to it!"))
		return

	message_admins("[key_name_admin(usr)] is dispatching an Emergency Response Team.", 1)
	admin_chat_message(message = "[key_name(usr)] is dispatching an Emergency Response Team", color = "#CC2222") //VOREStation Add
	log_admin("[key_name(usr)] used Dispatch Response Team.")
	trigger_armed_response_team(1)

/client/verb/JoinResponseTeam()

	set name = "Join Response Team"
	set category = "IC.Event"

	if(!MayRespawn(1))
		to_chat(usr, span_warning("You cannot join the response team at this time."))
		return

	if(isobserver(usr) || isnewplayer(usr))
		if(!GLOB.send_emergency_team)
			to_chat(usr, "No emergency response team is currently being sent.")
			return
		if(jobban_isbanned(usr, JOB_SYNDICATE) || jobban_isbanned(usr, JOB_EMERGENCY_RESPONSE_TEAM) || jobban_isbanned(usr, JOB_SECURITY_OFFICER))
			to_chat(usr, span_danger("You are jobbanned from the emergency reponse team!"))
			return
		if(ert.current_antagonists.len >= ert.hard_cap)
			to_chat(usr, "The emergency response team is already full!")
			return
		ert.create_default(usr)
	else
		to_chat(usr, "You need to be an observer or new player to use this.")

// returns a number of dead players in %
/proc/percentage_dead()
	var/total = 0
	var/deadcount = 0
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(H.client) // Monkeys and mice don't have a client, amirite?
			if(H.stat == 2) deadcount++
			total++

	if(total == 0) return 0
	else return round(100 * deadcount / total)

// counts the number of antagonists in %
/proc/percentage_antagonists()
	var/total = 0
	var/antagonists = 0
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(is_special_character(H) >= 1)
			antagonists++
		total++

	if(total == 0) return 0
	else return round(100 * antagonists / total)

// Increments the ERT chance automatically, so that the later it is in the round,
// the more likely an ERT is to be able to be called.
/proc/increment_ert_chance()
	while(GLOB.send_emergency_team == 0) // There is no ERT at the time.
		if(get_security_level() == "green")
			GLOB.ert_base_chance += 1
		if(get_security_level() == "yellow")
			GLOB.ert_base_chance += 1
		if(get_security_level() == "violet")
			GLOB.ert_base_chance += 2
		if(get_security_level() == "orange")
			GLOB.ert_base_chance += 2
		if(get_security_level() == "blue")
			GLOB.ert_base_chance += 2
		if(get_security_level() == "red")
			GLOB.ert_base_chance += 3
		if(get_security_level() == "delta")
			GLOB.ert_base_chance += 10           // Need those big guns
		sleep(600 * 3) // Minute * Number of Minutes


/proc/trigger_armed_response_team(var/force = 0)
	if(!GLOB.can_call_ert && !force)
		return
	if(GLOB.send_emergency_team)
		return

	var/send_team_chance = GLOB.ert_base_chance // Is incremented by increment_ert_chance.
	send_team_chance += 2*percentage_dead() // the more people are dead, the higher the chance
	send_team_chance += percentage_antagonists() // the more antagonists, the higher the chance
	send_team_chance = min(send_team_chance, 100)

	if(force) send_team_chance = 100

	// there's only a certain chance a team will be sent
	if(!prob(send_team_chance))
		command_announcement.Announce("It would appear that an emergency response team was requested for [station_name()]. Unfortunately, we were unable to send one at this time.", "[using_map.boss_name]")
		GLOB.can_call_ert = 0 // Only one call per round, ladies.
		return
	if(GLOB.silent_ert == 0)
		command_announcement.Announce("It would appear that an emergency response team was requested for [station_name()]. We will prepare and send one as soon as possible.", "[using_map.boss_name]")

	GLOB.can_call_ert = 0 // Only one call per round, gentleman.
	GLOB.send_emergency_team = 1
	consider_ert_load() //VOREStation Add

	sleep(600 * 5)
	GLOB.send_emergency_team = 0 // Can no longer join the ERT.
