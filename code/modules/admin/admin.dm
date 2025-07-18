GLOBAL_VAR_INIT(floorIsLava, 0)


////////////////////////////////
/proc/message_admins(var/msg)
	msg = span_filter_adminlog(span_log_message(span_prefix("ADMIN LOG:") + span_message("[msg]")))
	//log_adminwarn(msg) //log_and_message_admins is for this

	for(var/client/C in GLOB.admins)
		if(check_rights_for(C, (R_ADMIN|R_MOD|R_SERVER)))
			to_chat(C,
					type = MESSAGE_TYPE_ADMINLOG,
					html = msg,
					confidential = TRUE)

/proc/msg_admin_attack(var/text) //Toggleable Attack Messages
	var/rendered = span_filter_attacklog(span_log_message(span_prefix("ATTACK:") + span_message("[text]")))
	for(var/client/C in GLOB.admins)
		if(check_rights_for(C, (R_ADMIN|R_MOD)))
			if(C.prefs?.read_preference(/datum/preference/toggle/show_attack_logs))
				var/msg = rendered
				to_chat(C,
						type = MESSAGE_TYPE_ATTACKLOG,
						html = msg,
						confidential = TRUE)

/proc/admin_notice(var/message, var/rights)
	for(var/mob/M in GLOB.mob_list)
		var/C = M.client

		if(!C)
			return

		if(!(istype(C, /client)))
			return

		if(check_rights_for(C, rights))
			to_chat(C, message)

///////////////////////////////////////////////////////////////////////////////////////////////Panels

ADMIN_VERB_ONLY_CONTEXT_MENU(show_player_panel, R_HOLDER, "Show Player Panel", mob/player in world)
	log_admin("[key_name(user)] checked the individual player panel for [key_name(player)][isobserver(user.mob)?"":" while in game"].")

	if(!player)
		to_chat(user, "You seem to be selecting a mob that doesn't exist anymore.")
		return

	var/body = "Options panel for " + span_bold("[player]")
	if(player.client)
		body += " played by " + span_bold("[player.client]")
		body += "\[<A href='byond://?_src_=holder;[HrefToken()];editrights=[(GLOB.admin_datums[player.client.ckey] || GLOB.deadmins[player.client.ckey]) ? "rank" : "add"];key=[player.key]'>[player.client.holder ? player.client.holder.rank_names() : "Player"]</A>\]"

	if(isnewplayer(player))
		body += span_bold("Hasn't Entered Game")
	else
		body += " \[<A href='byond://?_src_=holder;[HrefToken()];revive=[REF(player)]'>Heal</A>\] "

	if(player.client)
		body += "<br>" + span_bold("First connection:") + "[player.client.player_age] days ago"
		body += "<br>" + span_bold("BYOND account created:") + "[player.client.account_join_date]"
		body += "<br>" + span_bold("BYOND account age (days):") + "[player.client.account_age]"

	body += {"
		<br><br>\[
		<a href='byond://?_src_=vars;[HrefToken()];Vars=\ref[player]'>VV</a> -
		<a href='byond://?_src_=holder;[HrefToken()];traitor=\ref[player]'>TP</a> -
		<a href='byond://??_src_=holder;[HrefToken()];priv_msg=\ref[player]'>PM</a> -
		<a href='byond://?_src_=holder;[HrefToken()];subtlemessage=\ref[player]'>SM</a> -
		[admin_jump_link(player, src)]\] <br>
		"} + span_bold("Mob type:") + {"[player.type]<br>
		"} + span_bold("Inactivity time:") + {" [player.client ? "[player.client.inactivity/600] minutes" : "Logged out"]<br/><br/>
		<A href='byond://?_src_=holder;[HrefToken()];boot2=\ref[player]'>Kick</A> |
		<A href='byond://?_src_=holder;[HrefToken()];warn=[player.ckey]'>Warn</A> |
		<A href='byond://?_src_=holder;[HrefToken()];newban=\ref[player]'>Ban</A> |
		<A href='byond://?_src_=holder;[HrefToken()];jobban2=\ref[player]'>Jobban</A> |
		<A href='byond://?_src_=holder;[HrefToken()];notes=show;mob=\ref[player]'>Notes</A>
	"}

	if(player.client)
		body += "| <A href='byond://?_src_=holder;[HrefToken()];sendtoprison=\ref[player]'>Prison</A> | "
		body += "\ <A href='byond://?_src_=holder;[HrefToken()];sendbacktolobby=\ref[player]'>Send back to Lobby</A> | "
		var/muted = player.client.prefs.muted
		body += {"<br>"} + span_bold("Mute: ") + {"
			\[<A href='byond://?_src_=holder;[HrefToken()];mute=\ref[player];mute_type=[MUTE_IC]'>[(muted & MUTE_IC) ? span_red("IC") : span_blue("IC")]</a> |
			<A href='byond://?_src_=holder;[HrefToken()];mute=\ref[player];mute_type=[MUTE_OOC]'>[(muted & MUTE_OOC) ? span_red("OOC") : span_blue("OOC")]</a> |
			<A href='byond://?_src_=holder;[HrefToken()];mute=\ref[player];mute_type=[MUTE_LOOC]'>[(muted & MUTE_LOOC) ? span_red("LOOC") : span_blue("LOOC")]</a> |
			<A href='byond://?_src_=holder;[HrefToken()];mute=\ref[player];mute_type=[MUTE_PRAY]'>[(muted & MUTE_PRAY) ? span_red("PRAY") : span_blue("PRAY")]</a> |
			<A href='byond://?_src_=holder;[HrefToken()];mute=\ref[player];mute_type=[MUTE_ADMINHELP]'>[(muted & MUTE_ADMINHELP) ? span_red("ADMINHELP") : span_blue("ADMINHELP")]</a> |
			<A href='byond://?_src_=holder;[HrefToken()];mute=\ref[player];mute_type=[MUTE_DEADCHAT]'>[(muted & MUTE_DEADCHAT) ? span_red("DEADCHAT") : span_blue("DEADCHAT")]</a>\]
			(<A href='byond://?_src_=holder;[HrefToken()];mute=\ref[player];mute_type=[MUTE_ALL]'>[(muted & MUTE_ALL) ? span_red("toggle all") : span_blue("toggle all")]</a>)
		"}

	body += {"<br><br>
		<A href='byond://?_src_=holder;[HrefToken()];jumpto=\ref[player]'>"} + span_bold("Jump to") + {"</A> |
		<A href='byond://?_src_=holder;[HrefToken()];getmob=\ref[player]'>Get</A> |
		<A href='byond://?_src_=holder;[HrefToken()];sendmob=\ref[player]'>Send To</A>
		<br><br>
		[check_rights(R_ADMIN|R_MOD|R_EVENT,0) ? "<A href='byond://?_src_=holder;[HrefToken()];traitor=\ref[player]'>Traitor panel</A> | " : "" ]
		<A href='byond://?_src_=holder;[HrefToken()];narrateto=\ref[player]'>Narrate to</A> |
		<A href='byond://?_src_=holder;[HrefToken()];subtlemessage=\ref[player]'>Subtle message</A>
	"}

	if (player.client)
		if(!isnewplayer(player))
			body += "<br><br>"
			body += span_bold("Transformation:")
			body += "<br>"

			//Monkey
			if(issmall(player))
				body += span_bold("Monkeyized") + " | "
			else
				body += "<A href='byond://?_src_=holder;[HrefToken()];turn_monkey=\ref[player]'>Monkeyize</A> | "

			//Corgi
			if(iscorgi(player))
				body += span_bold("Corgized") + " | "
			else
				body += "<A href='byond://?_src_=holder;[HrefToken()];corgione=\ref[player]'>Corgize</A> | "

			//AI / Cyborg
			if(isAI(player))
				body += span_bold("Is an AI ")
			else if(ishuman(player))
				body += {"<A href='byond://?_src_=holder;[HrefToken()];turn_ai=\ref[player]'>Make AI</A> |
					<A href='byond://?_src_=holder;[HrefToken()];turn_robot=\ref[player]'>Make Robot</A> |
					<A href='byond://?_src_=holder;[HrefToken()];turn_alien=\ref[player]'>Make Alien</A>
				"}

			//Simple Animals
			if(isanimal(player))
				body += "<A href='byond://?_src_=holder;[HrefToken()];makeanimal=\ref[player]'>Re-Animalize</A> | "
			else
				body += "<A href='byond://?_src_=holder;[HrefToken()];makeanimal=\ref[player]'>Animalize</A> | "

			body += "<A href='byond://?_src_=holder;[HrefToken()];respawn=\ref[player.client]'>Respawn</A> | "

			// DNA2 - Admin Hax
			if(player.dna && iscarbon(player))
				body += "<br><br>"
				body += span_bold("DNA Blocks:") + "<br><table border='0'><tr><th>&nbsp;</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th>"
				var/bname
				var/list/output_list = list()
				// Traitgenes more reliable way to check gene states
				for(var/setup_block=1;setup_block<=DNA_SE_LENGTH;setup_block++)
					output_list["[setup_block]"] = null
				for(var/datum/gene/gene in GLOB.dna_genes) // Traitgenes Genes accessible by global VV. Removed /dna/ from path
					output_list["[gene.block]"] = gene
				for(var/block=1;block<=DNA_SE_LENGTH;block++) // Traitgenes more reliable way to check gene states
					var/datum/gene/gene = output_list["[block]"] // Traitgenes Removed /dna/ from path
					if(((block-1)%5)==0)
						body += "</tr><tr><th>[block-1]</th>"
					// Traitgenes more reliable way to check gene states
					if(gene)
						bname = gene.name
					else
						bname = ""
					body += "<td>"
					if(bname)
						var/bstate=(bname in player.active_genes) // Traitgenes more reliable way to check gene states
						// Traitgenes show trait linked names on mouseover
						var/tname = bname
						if(istype(gene,/datum/gene/trait))
							var/datum/gene/trait/T = gene
							tname = T.get_name()
						if(bstate)
							bname = span_green(bname)
						else if(!bstate && player.dna.GetSEState(block)) // Gene isn't active, but the dna says it is... Was blocked by another gene!
							bname = span_orange(bname)
						else
							bname = span_red(bname)
						body += "<A href='byond://?_src_=holder;[HrefToken()];togmutate=\ref[player];block=[block]' title='[tname]'>[bname]</A><sub>[block]</sub>" // Traitgenes edit - show trait linked names on mouseover
					else
						body += "[block]"
					body+="</td>"
				body += "</tr></table>"

			body += {"<br><br>
				"} + span_bold("Rudimentary transformation:") + span_normal("<br>These transformations only create a new mob type and copy stuff over. They do not take into account MMIs and similar mob-specific things. The buttons in 'Transformations' are preferred, when possible.") + {"<br>
				<A href='byond://?_src_=holder;[HrefToken()];simplemake=observer;mob=\ref[player]'>Observer</A> |
				\[ Xenos: <A href='byond://?_src_=holder;[HrefToken()];simplemake=larva;mob=\ref[player]'>Larva</A>
				<A href='byond://?_src_=holder;[HrefToken()];simplemake=human;species=Xenomorph Drone;mob=\ref[player]'>Drone</A>
				<A href='byond://?_src_=holder;[HrefToken()];simplemake=human;species=Xenomorph Hunter;mob=\ref[player]'>Hunter</A>
				<A href='byond://?_src_=holder;[HrefToken()];simplemake=human;species=Xenomorph Sentinel;mob=\ref[player]'>Sentinel</A>
				<A href='byond://?_src_=holder;[HrefToken()];simplemake=human;species=Xenomorph Queen;mob=\ref[player]'>Queen</A> \] |
				\[ Crew: <A href='byond://?_src_=holder;[HrefToken()];simplemake=human;mob=\ref[player]'>Human</A>
				<A href='byond://?_src_=holder;[HrefToken()];simplemake=human;species=Unathi;mob=\ref[player]'>Unathi</A>
				<A href='byond://?_src_=holder;[HrefToken()];simplemake=human;species=Tajaran;mob=\ref[player]'>Tajaran</A>
				<A href='byond://?_src_=holder;[HrefToken()];simplemake=human;species=Skrell;mob=\ref[player]'>Skrell</A> \] | \[
				<A href='byond://?_src_=holder;[HrefToken()];simplemake=nymph;mob=\ref[player]'>Nymph</A>
				<A href='byond://?_src_=holder;[HrefToken()];simplemake=human;species='Diona';mob=\ref[player]'>Diona</A> \] |
				\[ slime: <A href='byond://?_src_=holder;[HrefToken()];simplemake=slime;mob=\ref[player]'>Baby</A>,
				<A href='byond://?_src_=holder;[HrefToken()];simplemake=adultslime;mob=\ref[player]'>Adult</A> \]
				<A href='byond://?_src_=holder;[HrefToken()];simplemake=monkey;mob=\ref[player]'>Monkey</A> |
				<A href='byond://?_src_=holder;[HrefToken()];simplemake=robot;mob=\ref[player]'>Cyborg</A> |
				<A href='byond://?_src_=holder;[HrefToken()];simplemake=cat;mob=\ref[player]'>Cat</A> |
				<A href='byond://?_src_=holder;[HrefToken()];simplemake=runtime;mob=\ref[player]'>Runtime</A> |
				<A href='byond://?_src_=holder;[HrefToken()];simplemake=corgi;mob=\ref[player]'>Corgi</A> |
				<A href='byond://?_src_=holder;[HrefToken()];simplemake=ian;mob=\ref[player]'>Ian</A> |
				<A href='byond://?_src_=holder;[HrefToken()];simplemake=crab;mob=\ref[player]'>Crab</A> |
				<A href='byond://?_src_=holder;[HrefToken()];simplemake=coffee;mob=\ref[player]'>Coffee</A> |
				\[ Construct: <A href='byond://?_src_=holder;[HrefToken()];simplemake=constructarmoured;mob=\ref[player]'>Armoured</A> ,
				<A href='byond://?_src_=holder;[HrefToken()];simplemake=constructbuilder;mob=\ref[player]'>Builder</A> ,
				<A href='byond://?_src_=holder;[HrefToken()];simplemake=constructwraith;mob=\ref[player]'>Wraith</A> \]
				<A href='byond://?_src_=holder;[HrefToken()];simplemake=shade;mob=\ref[player]'>Shade</A>
				<br>
			"}
	body += {"<br><br>
			"} + span_bold("Other actions:") + {"
			<br>
			<A href='byond://?_src_=holder;[HrefToken()];forcespeech=\ref[player]'>Forcesay</A>
			"}
	if (player.client)
		body += {" |
			<A href='byond://?_src_=holder;[HrefToken()];tdome1=\ref[player]'>Thunderdome 1</A> |
			<A href='byond://?_src_=holder;[HrefToken()];tdome2=\ref[player]'>Thunderdome 2</A> |
			<A href='byond://?_src_=holder;[HrefToken()];tdomeadmin=\ref[player]'>Thunderdome Admin</A> |
			<A href='byond://?_src_=holder;[HrefToken()];tdomeobserve=\ref[player]'>Thunderdome Observer</A> |
		"}
	// language toggles
	body += "<br><br>" + span_bold("Languages:") + "<br>"
	var/f = 1
	for(var/k in GLOB.all_languages)
		var/datum/language/L = GLOB.all_languages[k]
		if(!(L.flags & INNATE))
			if(!f) body += " | "
			else f = 0
			if(L in player.languages)
				k = span_green(k)
				body += "<a href='byond://?_src_=holder;[HrefToken()];toglang=\ref[player];lang=[html_encode(k)]'>[k]</a>"
			else
				k = span_red(k)
				body += "<a href='byond://?_src_=holder;[HrefToken()];toglang=\ref[player];lang=[html_encode(k)]'>[k]</a>"

	body += {"<br>"}

	var/datum/browser/popup = new(user, "adminplayeropts", "Edit Player", 550, 515)
	popup.add_head_content("<title>Options for [player.key]</title>")
	popup.set_content(body)
	popup.open()

	feedback_add_details("admin_verb","SPP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/player_info/var/author // admin who authored the information
/datum/player_info/var/rank //rank of admin who made the notes
/datum/player_info/var/content // text content of the information
/datum/player_info/var/timestamp // Because this is bloody annoying

/datum/admins/proc/PlayerNotes()
	set category = "Admin.Logs"
	set name = "Player Notes"
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return
	PlayerNotesPage(1)

/datum/admins/proc/PlayerNotesFilter()
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return
	var/filter = tgui_input_text(usr, "Filter string (case-insensitive regex)", "Player notes filter")
	PlayerNotesPage(1, filter)

/datum/admins/proc/PlayerNotesPage(page, filter)
	var/savefile/S=new("data/player_notes.sav")
	var/list/note_keys
	S >> note_keys

	if(note_keys)
		note_keys = sortList(note_keys)

	var/datum/tgui_module/player_notes/A = new(src)
	A.ckeys = note_keys
	A.tgui_interact(usr)


/datum/admins/proc/player_has_info(var/key as text)
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos || !infos.len) return 0
	else return 1


/datum/admins/proc/show_player_info(var/key as text)
	set category = "Admin.Investigate"
	set name = "Show Player Info"
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	var/datum/tgui_module/player_notes_info/A = new(src)
	A.key = key
	A.tgui_interact(usr)


/datum/admins/proc/access_news_network() //MARKER
	set category = "Fun.Event Kit"
	set name = "Access Newscaster Network"
	set desc = "Allows you to view, add and edit news feeds."

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return
	var/dat
	dat = text("<H3>Admin Newscaster Unit</H3>")

	switch(admincaster_screen)
		if(0)
			dat += {"Welcome to the admin newscaster.<BR> Here you can add, edit and censor every newspiece on the network.
				<BR>Feed channels and stories entered through here will be uneditable and handled as official news by the rest of the units.
				<BR>Note that this panel allows full freedom over the news network, there are no constrictions except the few basic ones. Don't break things!
			"}
			if(news_network.wanted_issue)
				dat+= "<HR><A href='byond://?src=\ref[src];[HrefToken()];ac_view_wanted=1'>Read Wanted Issue</A>"

			dat+= {"<HR><BR><A href='byond://?src=\ref[src];[HrefToken()];ac_create_channel=1'>Create Feed Channel</A>
				<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_view=1'>View Feed Channels</A>
				<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_create_feed_story=1'>Submit new Feed story</A>
				<BR><BR><A href='byond://?src=\ref[usr];[HrefToken()];mach_close=newscaster_main'>Exit</A>
			"}

			var/wanted_already = 0
			if(news_network.wanted_issue)
				wanted_already = 1

			dat+={"<HR>"} + span_bold("Feed Security functions:") + {"<BR>
				<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_menu_wanted=1'>[(wanted_already) ? ("Manage") : ("Publish")] \"Wanted\" Issue</A>
				<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_menu_censor_story=1'>Censor Feed Stories</A>
				<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_menu_censor_channel=1'>Mark Feed Channel with [using_map.company_name] D-Notice (disables and locks the channel.</A>
				<BR><HR><A href='byond://?src=\ref[src];[HrefToken()];ac_set_signature=1'>The newscaster recognises you as:<BR>"} + span_green("[src.admincaster_signature]") + {"</A>
			"}
		if(1)
			dat+= "Station Feed Channels<HR>"
			if( isemptylist(news_network.network_channels) )
				dat+=span_italics("No active channels found...")
			else
				for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
					if(CHANNEL.is_admin_channel)
						dat+=span_bold("<FONT style='BACKGROUND-COLOR: LightGreen'><A href='byond://?src=\ref[src];[HrefToken()];ac_show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A></FONT>") + "<BR>"
					else
						dat+=span_bold("<A href='byond://?src=\ref[src];[HrefToken()];ac_show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? (span_red("***")) : null]<BR>")
			dat+={"<BR><HR><A href='byond://?src=\ref[src];[HrefToken()];ac_refresh=1'>Refresh</A>
				<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_setScreen=[0]'>Back</A>
			"}

		if(2)
			dat+={"
				Creating new Feed Channel...
				<HR>"} + span_bold("<A href='byond://?src=\ref[src];[HrefToken()];ac_set_channel_name=1'>Channel Name</A>:") + {" [src.admincaster_feed_channel.channel_name]<BR>
				"} + span_bold("<A href='byond://?src=\ref[src];[HrefToken()];ac_set_signature=1'>Channel Author</A>:") + {" "} + span_green("[src.admincaster_signature]") + {"<BR>
				"} + span_bold("<A href='byond://?src=\ref[src];[HrefToken()];ac_set_channel_lock=1'>Will Accept Public Feeds</A>:") + {" [(src.admincaster_feed_channel.locked) ? ("NO") : ("YES")]<BR><BR>
				<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_submit_new_channel=1'>Submit</A><BR><BR><A href='byond://?src=\ref[src];[HrefToken()];ac_setScreen=[0]'>Cancel</A><BR>
			"}
		if(3)
			dat+={"
				Creating new Feed Message...
				<HR>"} + span_bold("<A href='byond://?src=\ref[src];[HrefToken()];ac_set_channel_receiving=1'>Receiving Channel</A>:") + {" [src.admincaster_feed_channel.channel_name]<BR>
				"} + span_bold("Message Author:") + {" "} + span_green("[src.admincaster_signature]") + {"<BR>
				"} + span_bold("<A href='byond://?src=\ref[src];[HrefToken()];ac_set_new_message=1'>Message Body</A>:") + {" [src.admincaster_feed_message.body] <BR>
				<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_submit_new_message=1'>Submit</A><BR><BR><A href='byond://?src=\ref[src];[HrefToken()];ac_setScreen=[0]'>Cancel</A><BR>
			"}
		if(4)
			dat+={"
					Feed story successfully submitted to [src.admincaster_feed_channel.channel_name].<BR><BR>
					<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_setScreen=[0]'>Return</A><BR>
				"}
		if(5)
			dat+={"
				Feed Channel [src.admincaster_feed_channel.channel_name] created successfully.<BR><BR>
				<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_setScreen=[0]'>Return</A><BR>
			"}
		if(6)
			dat+=span_bold(span_maroon("ERROR: Could not submit Feed story to Network.")) + "<HR><BR>"
			if(src.admincaster_feed_channel.channel_name=="")
				dat+=span_maroon("Invalid receiving channel name.") + "<BR>"
			if(src.admincaster_feed_message.body == "" || src.admincaster_feed_message.body == "\[REDACTED\]" || admincaster_feed_message.title == "")
				dat+=span_maroon("Invalid message body.") + "<BR>"
			dat+="<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_setScreen=[3]'>Return</A><BR>"
		if(7)
			dat+=span_bold(span_maroon("ERROR: Could not submit Feed Channel to Network.")) + "<HR><BR>"
			if(src.admincaster_feed_channel.channel_name =="" || src.admincaster_feed_channel.channel_name == "\[REDACTED\]")
				dat+=span_maroon("Invalid channel name.") + "<BR>"
			var/check = 0
			for(var/datum/feed_channel/FC in news_network.network_channels)
				if(FC.channel_name == src.admincaster_feed_channel.channel_name)
					check = 1
					break
			if(check)
				dat+=span_maroon("Channel name already in use.") + "<BR>"
			dat+="<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_setScreen=[2]'>Return</A><BR>"
		if(9)
			dat+=span_bold("[src.admincaster_feed_channel.channel_name]: ") + span_small("\[created by: [span_maroon("[src.admincaster_feed_channel.author]")]\]") + "<HR>"
			if(src.admincaster_feed_channel.censored)
				dat+={"
					"} + span_red(span_bold("ATTENTION: ")) + {"This channel has been deemed as threatening to the welfare of the station, and marked with a [using_map.company_name] D-Notice.<BR>
					No further feed story additions are allowed while the D-Notice is in effect.<BR><BR>
				"}
			else
				if( isemptylist(src.admincaster_feed_channel.messages) )
					dat+=span_italics("No feed messages found in channel...") + "<BR>"
				else
					var/i = 0
					for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
						i++
						//dat+="-[MESSAGE.body] <BR>"
						var/pic_data
						if(MESSAGE.img)
							usr << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
							pic_data+="<img src='tmp_photo[i].png' width = '180'><BR>"
						dat+= get_newspaper_content(MESSAGE.title, MESSAGE.body, MESSAGE.author,"#d4cec1", pic_data)
						dat+="<BR>"
						dat+=span_small("\[Story by [span_maroon("[MESSAGE.author] - [MESSAGE.time_stamp]")]\]") + "<BR>"
			dat+={"
				<BR><HR><A href='byond://?src=\ref[src];[HrefToken()];ac_refresh=1'>Refresh</A>
				<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_setScreen=[1]'>Back</A>
			"}
		if(10)
			dat+={"
				"} + span_bold("[using_map.company_name] Feed Censorship Tool") + {"<BR>
				"} + span_small("NOTE: Due to the nature of news Feeds, total deletion of a Feed Story is not possible.<BR>") + {"
				"} + span_small("Keep in mind that users attempting to view a censored feed will instead see the \[REDACTED\] tag above it.") + {"
				<HR>Select Feed channel to get Stories from:<BR>
			"}
			if(isemptylist(news_network.network_channels))
				dat+=span_italics("No feed channels found active...") + "<BR>"
			else
				for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
					dat+="<A href='byond://?src=\ref[src];[HrefToken()];ac_pick_censor_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? (span_red("***")) : null]<BR>"
			dat+="<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_setScreen=[0]'>Cancel</A>"
		if(11)
			dat+={"
				"} + span_bold("[using_map.company_name] D-Notice Handler") + {"<HR>
				"} + span_small("A D-Notice is to be bestowed upon the channel if the handling Authority deems it as harmful for the station's") + {"
				"} + span_small("morale, integrity or disciplinary behaviour. A D-Notice will render a channel unable to be updated by anyone, without deleting any feed") + {"
				"} + span_small("stories it might contain at the time. You can lift a D-Notice if you have the required access at any time.") + {"<HR>
			"}
			if(isemptylist(news_network.network_channels))
				dat+=span_italics("No feed channels found active...") + "<BR>"
			else
				for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
					dat+="<A href='byond://?src=\ref[src];[HrefToken()];ac_pick_d_notice=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? (span_red("***")) : null]<BR>"

			dat+="<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_setScreen=[0]'>Back</A>"
		if(12)
			dat+={"
				"} + span_bold("[src.admincaster_feed_channel.channel_name]: ") + span_small("\[ created by: [span_maroon("[src.admincaster_feed_channel.author]")] \]") + {"<BR>
				"} + span_normal("<A href='byond://?src=\ref[src];[HrefToken()];ac_censor_channel_author=\ref[src.admincaster_feed_channel]'>[(src.admincaster_feed_channel.author=="\[REDACTED\]") ? ("Undo Author censorship") : ("Censor channel Author")]</A>") + {"<HR>
			"}
			if( isemptylist(src.admincaster_feed_channel.messages) )
				dat+=span_italics("No feed messages found in channel...") + "<BR>"
			else
				for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
					dat+={"
						-[MESSAGE.body] <BR>"} + span_small("\[Story by [span_maroon("[MESSAGE.author]")]\]") + {"<BR>
						"} + span_normal("<A href='byond://?src=\ref[src];[HrefToken()];ac_censor_channel_story_body=\ref[MESSAGE]'>[(MESSAGE.body == "\[REDACTED\]") ? ("Undo story censorship") : ("Censor story")]</A>  -  <A href='byond://?src=\ref[src];[HrefToken()];ac_censor_channel_story_author=\ref[MESSAGE]'>[(MESSAGE.author == "\[REDACTED\]") ? ("Undo Author Censorship") : ("Censor message Author")]</A>") + {"<BR>
					"}
			dat+="<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_setScreen=[10]'>Back</A>"
		if(13)
			dat+={"
				"} + span_bold("[src.admincaster_feed_channel.channel_name]: ") + span_small("\[ created by: [span_maroon("[src.admincaster_feed_channel.author]")] \]") + {"<BR>
				Channel messages listed below. If you deem them dangerous to the station, you can <A href='byond://?src=\ref[src];[HrefToken()];ac_toggle_d_notice=\ref[src.admincaster_feed_channel]'>Bestow a D-Notice upon the channel</A>.<HR>
			"}
			if(src.admincaster_feed_channel.censored)
				dat+={"
					"} + span_red(span_bold("ATTENTION: ")) + {"This channel has been deemed as threatening to the welfare of the station, and marked with a [using_map.company_name] D-Notice.<BR>
					No further feed story additions are allowed while the D-Notice is in effect.<BR><BR>
				"}
			else
				if( isemptylist(src.admincaster_feed_channel.messages) )
					dat+=span_italics("No feed messages found in channel...") + "<BR>"
				else
					for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
						dat+="-[MESSAGE.body] <BR>" + span_small("\[Story by [span_maroon("[MESSAGE.author]")]\]") + "<BR>"

			dat+="<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_setScreen=[11]'>Back</A>"
		if(14)
			dat+=span_bold("Wanted Issue Handler:")
			var/wanted_already = 0
			var/end_param = 1
			if(news_network.wanted_issue)
				wanted_already = 1
				end_param = 2
			if(wanted_already)
				dat+=span_normal(span_italics("<BR>A wanted issue is already in Feed Circulation. You can edit or cancel it below."))
			dat+={"
				<HR>
				<A href='byond://?src=\ref[src];[HrefToken()];ac_set_wanted_name=1'>Criminal Name</A>: [src.admincaster_feed_message.author] <BR>
				<A href='byond://?src=\ref[src];[HrefToken()];ac_set_wanted_desc=1'>Description</A>: [src.admincaster_feed_message.body] <BR>
			"}
			if(wanted_already)
				dat+=span_bold("Wanted Issue created by:") + span_green(" [news_network.wanted_issue.backup_author]") + "<BR>"
			else
				dat+=span_bold("Wanted Issue will be created under prosecutor:") + span_green(" [src.admincaster_signature]") + "<BR>"
			dat+="<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_submit_wanted=[end_param]'>[(wanted_already) ? ("Edit Issue") : ("Submit")]</A>"
			if(wanted_already)
				dat+="<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_cancel_wanted=1'>Take down Issue</A>"
			dat+="<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_setScreen=[0]'>Cancel</A>"
		if(15)
			dat+={"
				"} + span_green("Wanted issue for [src.admincaster_feed_message.author] is now in Network Circulation.") + {"<BR><BR>
				<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_setScreen=[0]'>Return</A><BR>
			"}
		if(16)
			dat+=span_bold(span_maroon("ERROR: Wanted Issue rejected by Network.")) + "<HR><BR>"
			if(src.admincaster_feed_message.author =="" || src.admincaster_feed_message.author == "\[REDACTED\]")
				dat+=span_maroon("Invalid name for person wanted.") + "<BR>"
			if(src.admincaster_feed_message.body == "" || src.admincaster_feed_message.body == "\[REDACTED\]")
				dat+=span_maroon("Invalid description.") + "<BR>"
			dat+="<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_setScreen=[0]'>Return</A><BR>"
		if(17)
			dat+={"
				"} + span_bold("Wanted Issue successfully deleted from Circulation") + {"<BR>
				<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_setScreen=[0]'>Return</A><BR>
			"}
		if(18)
			dat+={"
				"} + span_bold(span_maroon("-- STATIONWIDE WANTED ISSUE --")) + {"<BR>"} + span_normal("\[Submitted by: [span_green("[news_network.wanted_issue.backup_author]")]\]") + {"<HR>
				"} + span_bold("Criminal") + {": [news_network.wanted_issue.author]<BR>
				"} + span_bold("Description") + {": [news_network.wanted_issue.body]<BR>
				"} + span_bold("Photo:") + {":
			"}
			if(news_network.wanted_issue.img)
				usr << browse_rsc(news_network.wanted_issue.img, "tmp_photow.png")
				dat+="<BR><img src='tmp_photow.png' width = '180'>"
			else
				dat+="None"
			dat+="<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_setScreen=[0]'>Back</A><BR>"
		if(19)
			dat+={"
				"} + span_green("Wanted issue for [src.admincaster_feed_message.author] successfully edited.") + {"<BR><BR>
				<BR><A href='byond://?src=\ref[src];[HrefToken()];ac_setScreen=[0]'>Return</A><BR>
			"}
		else
			dat+="I'm sorry to break your immersion. This shit's bugged. Report this bug to Agouri, polyxenitopalidou@gmail.com"

	//to_world("Channelname: [src.admincaster_feed_channel.channel_name] [src.admincaster_feed_channel.author]")
	//to_world("Msg: [src.admincaster_feed_message.author] [src.admincaster_feed_message.body]")

	var/datum/browser/popup = new(owner, "admincaster_main", "Admin Newscaster", 400, 600)
	popup.add_head_content("<TITLE>Admin Newscaster</TITLE>")
	popup.set_content(dat)
	popup.open()

/datum/admins/proc/Jobbans()
	if(!check_rights(R_BAN))	return

	var/dat = span_bold("Job Bans!") + "<HR><table>"
	for(var/t in jobban_keylist)
		var/r = t
		if( findtext(r,"##") )
			r = copytext( r, 1, findtext(r,"##") )//removes the description
		dat += text("<tr><td>[t] (<A href='byond://?src=\ref[src];[HrefToken()];removejobban=[r]'>unban</A>)</td></tr>")
	dat += "</table>"

	var/datum/browser/popup = new(owner, "ban", "Job Bans", 400, 400)
	popup.add_head_content("<TITLE>Admin Newscaster</TITLE>")
	popup.set_content(dat)
	popup.open()

/datum/admins/proc/Game()
	if(!check_rights(0))	return

	var/dat = {"
		<center>"} + span_bold("Game Panel") + {"</center><hr>\n
		<A href='byond://?src=\ref[src];[HrefToken()];c_mode=1'>Change Game Mode</A><br>
		"}
	if(GLOB.master_mode == "secret")
		dat += "<A href='byond://?src=\ref[src];[HrefToken()];f_secret=1'>(Force Secret Mode)</A><br>"

	dat += {"
		<BR>
		<A href='byond://?src=\ref[src];[HrefToken()];create_object=1'>Create Object</A><br>
		<A href='byond://?src=\ref[src];[HrefToken()];quick_create_object=1'>Quick Create Object</A><br>
		<A href='byond://?src=\ref[src];[HrefToken()];create_turf=1'>Create Turf</A><br>
		<A href='byond://?src=\ref[src];[HrefToken()];create_mob=1'>Create Mob</A><br>
		<br><A href='byond://?src=\ref[src];[HrefToken()];vsc=airflow'>Edit Airflow Settings</A><br>
		<A href='byond://?src=\ref[src];[HrefToken()];vsc=phoron'>Edit Phoron Settings</A><br>
		<A href='byond://?src=\ref[src];[HrefToken()];vsc=default'>Choose a default ZAS setting</A><br>
		"}

	var/datum/browser/popup = new(owner, "admin2", "Game Panel", 220, 295)
	popup.set_content(dat)
	popup.open()

/*
/datum/admins/proc/Secrets(var/datum/admin_secret_category/active_category = null)
	if(!check_rights(0))	return

	// Print the header with category selection buttons.
	var/dat = span_bold("The first rule of adminbuse is: you don't talk about the adminbuse.") + "<HR>"
	for(var/datum/admin_secret_category/category in admin_secrets.categories)
		if(!category.can_view(usr))
			continue
		dat += "<A href='byond://?src=\ref[src];[HrefToken()];admin_secrets_panel=\ref[category]'>[category.name]</A> "
	dat += "<HR>"

	// If a category is selected, print its description and then options
	if(istype(active_category) && active_category.can_view(usr))
		dat += span_bold("[active_category.name]") + "<BR>"
		if(active_category.desc)
			dat += span_italics("[active_category.desc]") + "<BR>"
		for(var/datum/admin_secret_item/item in active_category.items)
			if(!item.can_view(usr))
				continue
			dat += "<A href='byond://?src=\ref[src];[HrefToken()];admin_secrets=\ref[item]'>[item.name()]</A><BR>"
		dat += "<BR>"

	var/datum/browser/popup = new(usr, "secrets", "Secrets", 500, 500)
	popup.set_content(dat)
	popup.open()
	return
*/

/////////////////////////////////////////////////////////////////////////////////////////////////admins2.dm merge
//i.e. buttons/verbs


/datum/admins/proc/restart()
	set category = "Server.Game"
	set name = "Restart"
	set desc="Restarts the world"
	if (!check_rights_for(usr.client, R_HOLDER))
		return
	var/confirm = alert(usr, "Restart the game world?", "Restart", "Yes", "Cancel") // Not tgui_alert for safety
	if(!confirm || confirm == "Cancel")
		return
	if(confirm == "Yes")
		to_world(span_danger("Restarting world!" ) + span_notice("Initiated by [usr.client.holder.fakekey ? "Admin" : usr.key]!"))
		log_admin("[key_name(usr)] initiated a reboot.")

		feedback_set_details("end_error","admin reboot - by [usr.key] [usr.client.holder.fakekey ? "(stealth)" : ""]")
		feedback_add_details("admin_verb","R") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

		if(blackbox)
			blackbox.save_all_data_to_sql()

		sleep(50)
		world.Reboot()


/datum/admins/proc/announce()
	set category = "Admin.Chat"
	set name = "Announce"
	set desc="Announce your desires to the world"
	if(!check_rights(0))	return

	var/message = tgui_input_text(usr, "Global message to send:", "Admin Announce", multiline = TRUE, prevent_enter = TRUE)
	if(message)
		if(!check_rights(R_SERVER,0))
			message = sanitize(message, 500, extra = 0)
		message = replacetext(message, "\n", "<br>") // required since we're putting it in a <p> tag
		send_ooc_announcement(message, "From [usr.client.holder.fakekey ? "Administrator" : usr.key]")
		log_admin("Announce: [key_name(usr)] : [message]")
	feedback_add_details("admin_verb","A") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//VOREStation Edit to this verb for the purpose of making it compliant with the annunciator system
var/datum/announcement/priority/admin_pri_announcer = new
var/datum/announcement/minor/admin_min_announcer = new
/datum/admins/proc/intercom()
	set category = "Fun.Event Kit"
	set name = "Intercom Msg"
	set desc = "Send an intercom message, like an arrivals announcement."
	if(!check_rights(0))	return

	var/channel = tgui_input_list(usr, "Channel for message:","Channel", radiochannels)

	if(channel) //They picked a channel
		var/sender = tgui_input_text(usr, "Name of sender (max 75):", "Announcement", "Announcement Computer")

		if(sender) //They put a sender
			sender = sanitize(sender, 75, extra = 0)
			var/message = tgui_input_text(usr, "Message content (max 500):", "Contents", "This is a test of the announcement system.", multiline = TRUE, prevent_enter = TRUE)
			var/msgverb = tgui_input_text(usr, "Name of verb (Such as 'states', 'says', 'asks', etc):", "Verb", "says")
			if(message) //They put a message
				message = sanitize(message, 500, extra = 0)
				//VOREStation Edit Start
				if(msgverb)
					msgverb = sanitize(msgverb, 50, extra = 0)
				else
					msgverb = "states"
				GLOB.global_announcer.autosay("[message]", "[sender]", "[channel == "Common" ? null : channel]", states = msgverb) //Common is a weird case, as it's not a "channel", it's just talking into a radio without a channel set.
				//VOREStation Edit End
				log_admin("Intercom: [key_name(usr)] : [sender]:[message]")

	feedback_add_details("admin_verb","IN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/intercom_convo()
	set category = "Fun.Event Kit"
	set name = "Intercom Convo"
	set desc = "Send an intercom conversation, like several uses of the Intercom Msg verb."
	set waitfor = FALSE //Why bother? We have some sleeps. You can leave tho!
	if(!check_rights(0))	return

	var/channel = tgui_input_list(usr, "Channel for message:","Channel", radiochannels)

	if(!channel) //They picked a channel
		return

	var/speech_verb = tgui_alert(usr, "What speech verb to use for the conversation?", "Type", list("states", "says"))
	if(!speech_verb)
		return

	to_chat(usr, span_notice(span_bold("Intercom Convo Directions") + "<br>Start the conversation with the sender, a pipe (|), and then the message on one line. Then hit enter to \
		add another line, and type a (whole) number of seconds to pause between that message, and the next message, then repeat the message syntax up to 20 times. For example:<br>\
		--- --- ---<br>\
		Some Guy|Hello guys, what's up?<br>\
		5<br>\
		Other Guy|Hey, good to see you.<br>\
		5<br>\
		Some Guy|Yeah, you too.<br>\
		--- --- ---<br>\
		The above will result in those messages playing, with a 5 second gap between each. Maximum of 20 messages allowed."))

	var/list/decomposed
	var/message = tgui_input_text(usr,"See your chat box for instructions. Keep a copy elsewhere in case it is rejected when you click OK.", "Input Conversation", "", multiline = TRUE, prevent_enter = TRUE)

	if(!message)
		return

	//Split on pipe or \n
	decomposed = splittext(message,regex("\\||$","m"))
	decomposed += "0" //Tack on a final 0 sleep to make 3-per-message evenly

	//Time to find how they screwed up.
	//Wasn't the right length
	if((decomposed.len) % 3) //+1 to accomidate the lack of a wait time for the last message
		to_chat(usr, span_warning("You passed [decomposed.len] segments (senders+messages+pauses). You must pass a multiple of 3, minus 1 (no pause after the last message). That means a sender and message on every other line (starting on the first), separated by a pipe character (|), and a number every other line that is a pause in seconds."))
		return

	//Too long a conversation
	if((decomposed.len / 3) > 20)
		to_chat(usr, span_warning("This conversation is too long! 20 messages maximum, please."))
		return

	//Missed some sleeps, or sanitized to nothing.
	for(var/i = 1; i < decomposed.len; i++)

		//Sanitize sender
		var/clean_sender = sanitize(decomposed[i])
		if(!clean_sender)
			to_chat(usr, span_warning("One part of your conversation was not able to be sanitized. It was the sender of the [(i+2)/3]\th message."))
			return
		decomposed[i] = clean_sender

		//Sanitize message
		var/clean_message = sanitize(decomposed[++i])
		if(!clean_message)
			to_chat(usr, span_warning("One part of your conversation was not able to be sanitized. It was the body of the [(i+2)/3]\th message."))
			return
		decomposed[i] = clean_message

		//Sanitize wait time
		var/clean_time = text2num(decomposed[++i])
		if(!isnum(clean_time))
			to_chat(usr, span_warning("One part of your conversation was not able to be sanitized. It was the wait time after the [(i+2)/3]\th message."))
			return
		if(clean_time > 60)
			to_chat(usr, span_warning("Max 60 second wait time between messages for sanity's sake please."))
			return
		decomposed[i] = clean_time

	log_admin("Intercom convo started by: [key_name(usr)] : [sanitize(message)]")
	feedback_add_details("admin_verb","IN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	//Sanitized AND we still have a chance to send it? Wow!
	if(LAZYLEN(decomposed))
		for(var/i = 1; i < decomposed.len; i++)
			var/this_sender = decomposed[i]
			var/this_message = decomposed[++i]
			var/this_wait = decomposed[++i]
			GLOB.global_announcer.autosay("[this_message]", "[this_sender]", "[channel == "Common" ? null : channel]", states = speech_verb) //Common is a weird case, as it's not a "channel", it's just talking into a radio without a channel set.	//VOREStation Edit
			sleep(this_wait SECONDS)

/datum/admins/proc/toggleooc()
	set category = "Server.Chat"
	set desc="Globally Toggles OOC"
	set name="Toggle Player OOC"

	if(!check_rights(R_ADMIN))
		return

	CONFIG_SET(flag/ooc_allowed, !CONFIG_GET(flag/ooc_allowed))
	if (CONFIG_GET(flag/ooc_allowed))
		to_world(span_world("The OOC channel has been globally enabled!"))
	else
		to_world(span_world("The OOC channel has been globally disabled!"))
	log_and_message_admins("toggled OOC.")
	feedback_add_details("admin_verb","TOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/togglelooc()
	set category = "Server.Chat"
	set desc="Globally Toggles LOOC"
	set name="Toggle Player LOOC"

	if(!check_rights(R_ADMIN))
		return

	CONFIG_SET(flag/looc_allowed, !CONFIG_GET(flag/looc_allowed))
	if (CONFIG_GET(flag/looc_allowed))
		to_world(span_world("The LOOC channel has been globally enabled!"))
	else
		to_world(span_world("The LOOC channel has been globally disabled!"))
	log_and_message_admins("toggled LOOC.")
	feedback_add_details("admin_verb","TLOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/toggledsay()
	set category = "Server.Chat"
	set desc="Globally Toggles DSAY"
	set name="Toggle DSAY"

	if(!check_rights(R_ADMIN))
		return

	CONFIG_SET(flag/dsay_allowed, !CONFIG_GET(flag/dsay_allowed))
	if (CONFIG_GET(flag/dsay_allowed))
		to_world(span_world("Deadchat has been globally enabled!"))
	else
		to_world(span_world("Deadchat has been globally disabled!"))
	log_admin("[key_name(usr)] toggled deadchat.")
	message_admins("[key_name_admin(usr)] toggled deadchat.", 1)
	feedback_add_details("admin_verb","TDSAY") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc

/datum/admins/proc/toggleoocdead()
	set category = "Server.Chat"
	set desc="Toggle Dead OOC."
	set name="Toggle Dead OOC"

	if(!check_rights(R_ADMIN))
		return

	CONFIG_SET(flag/dooc_allowed, !CONFIG_GET(flag/dooc_allowed))
	log_admin("[key_name(usr)] toggled Dead OOC.")
	message_admins("[key_name_admin(usr)] toggled Dead OOC.", 1)
	feedback_add_details("admin_verb","TDOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/togglehubvisibility()
	set category = "Server.Config"
	set desc="Globally Toggles Hub Visibility"
	set name="Toggle Hub Visibility"

	if(!check_rights(R_ADMIN))
		return

	world.visibility = !(world.visibility)
	log_admin("[key_name(usr)] toggled hub visibility.")
	message_admins("[key_name_admin(usr)] toggled hub visibility.  The server is now [world.visibility ? "visible" : "invisible"] ([world.visibility]).", 1)
	feedback_add_details("admin_verb","THUB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc

/datum/admins/proc/toggletraitorscaling()
	set category = "Server.Game"
	set desc="Toggle traitor scaling"
	set name="Toggle Traitor Scaling"
	CONFIG_SET(flag/traitor_scaling, !CONFIG_GET(flag/traitor_scaling))
	log_admin("[key_name(usr)] toggled Traitor Scaling to [CONFIG_GET(flag/traitor_scaling)].")
	message_admins("[key_name_admin(usr)] toggled Traitor Scaling [CONFIG_GET(flag/traitor_scaling) ? "on" : "off"].", 1)
	feedback_add_details("admin_verb","TTS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/startnow()
	set category = "Server.Game"
	set desc="Start the round ASAP"
	set name="Start Now"

	if(!check_rights(R_SERVER|R_EVENT))
		return
	if(SSticker.current_state > GAME_STATE_PREGAME)
		to_chat(usr, span_warning("Error: Start Now: Game has already started."))
		return
	if(!SSticker.start_immediately)
		SSticker.start_immediately = TRUE
		var/msg = ""
		if(SSticker.current_state == GAME_STATE_INIT)
			msg = " (The server is still setting up, but the round will be started as soon as possible.)"
		log_admin("[key_name(usr)] has started the game.[msg]")
		message_admins(span_notice("[key_name_admin(usr)] has started the game.[msg]"))
		feedback_add_details("admin_verb","SN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else
		SSticker.start_immediately = FALSE
		to_world(span_filter_system(span_blue("Immediate game start canceled. Normal startup resumed.")))
		log_and_message_admins("cancelled immediate game start.")

/datum/admins/proc/toggleenter()
	set category = "Server.Game"
	set desc="People can't enter"
	set name="Toggle Entering"
	CONFIG_SET(flag/enter_allowed, !CONFIG_GET(flag/enter_allowed))
	if (!CONFIG_GET(flag/enter_allowed))
		to_world(span_world("New players may no longer enter the game."))
	else
		to_world(span_world("New players may now enter the game."))
	log_admin("[key_name(usr)] toggled new player game entering.")
	message_admins(span_blue("[key_name_admin(usr)] toggled new player game entering."), 1)
	world.update_status()
	feedback_add_details("admin_verb","TE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleAI()
	set category = "Server.Game"
	set desc="People can't be AI"
	set name="Toggle AI"
	CONFIG_SET(flag/allow_ai, !CONFIG_GET(flag/allow_ai))
	if (!CONFIG_GET(flag/allow_ai))
		to_world(span_world("The AI job is no longer chooseable."))
	else
		to_world(span_world("The AI job is chooseable now."))
	log_admin("[key_name(usr)] toggled AI allowed.")
	world.update_status()
	feedback_add_details("admin_verb","TAI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleaban()
	set category = "Server.Game"
	set desc="Respawn basically"
	set name="Toggle Respawn"
	CONFIG_SET(flag/abandon_allowed, !CONFIG_GET(flag/abandon_allowed))
	if(CONFIG_GET(flag/abandon_allowed))
		to_world(span_world("You may now respawn."))
	else
		to_world(span_world("You may no longer respawn :("))
	message_admins(span_blue("[key_name_admin(usr)] toggled respawn to [CONFIG_GET(flag/abandon_allowed) ? "On" : "Off"]."), 1)
	log_admin("[key_name(usr)] toggled respawn to [CONFIG_GET(flag/abandon_allowed) ? "On" : "Off"].")
	world.update_status()
	feedback_add_details("admin_verb","TR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/togglepersistence()
	set category = "Server.Config"
	set desc="Whether persistent data will be saved from now on."
	set name="Toggle Persistent Data"
	CONFIG_SET(flag/persistence_disabled, !CONFIG_GET(flag/persistence_disabled))
	message_admins(span_blue("[key_name_admin(usr)] toggled persistence to [CONFIG_GET(flag/persistence_disabled) ? "Off" : "On"]."), 1)
	log_admin("[key_name(usr)] toggled persistence to [CONFIG_GET(flag/persistence_disabled) ? "Off" : "On"].")
	world.update_status()
	feedback_add_details("admin_verb","TPD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/togglemaploadpersistence()
	set category = "Server.Config"
	set desc="Whether mapload persistent data will be saved from now on."
	set name="Toggle Mapload Persistent Data"
	CONFIG_SET(flag/persistence_ignore_mapload, !CONFIG_GET(flag/persistence_ignore_mapload))
	if(!CONFIG_GET(flag/persistence_ignore_mapload))
		to_world(span_world("Persistence is now enabled."))
	else
		to_world(span_world("Persistence is no longer enabled."))
	message_admins(span_blue("[key_name_admin(usr)] toggled persistence to [CONFIG_GET(flag/persistence_ignore_mapload) ? "Off" : "On"]."), 1)
	log_admin("[key_name(usr)] toggled persistence to [CONFIG_GET(flag/persistence_ignore_mapload) ? "Off" : "On"].")
	world.update_status()
	feedback_add_details("admin_verb","TMPD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggle_aliens()
	set category = "Server.Game"
	set desc="Toggle alien mobs"
	set name="Toggle Aliens"
	CONFIG_SET(flag/aliens_allowed, !CONFIG_GET(flag/aliens_allowed))
	log_admin("[key_name(usr)] toggled Aliens to [CONFIG_GET(flag/aliens_allowed)].")
	message_admins("[key_name_admin(usr)] toggled Aliens [CONFIG_GET(flag/aliens_allowed) ? "on" : "off"].", 1)
	feedback_add_details("admin_verb","TA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggle_space_ninja()
	set category = "Server.Game"
	set desc="Toggle space ninjas spawning."
	set name="Toggle Space Ninjas"
	CONFIG_SET(flag/ninjas_allowed, !CONFIG_GET(flag/ninjas_allowed))
	log_admin("[key_name(usr)] toggled Space Ninjas to [CONFIG_GET(flag/ninjas_allowed)].")
	message_admins("[key_name_admin(usr)] toggled Space Ninjas [CONFIG_GET(flag/ninjas_allowed) ? "on" : "off"].", 1)
	feedback_add_details("admin_verb","TSN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/delay()
	set category = "Server.Game"
	set desc="Delay the game start/end"
	set name="Delay"

	if(!check_rights(R_SERVER|R_EVENT))	return
	if (SSticker.current_state >= GAME_STATE_PLAYING)
		SSticker.delay_end = !SSticker.delay_end
		log_admin("[key_name(usr)] [SSticker.delay_end ? "delayed the round end" : "has made the round end normally"].")
		message_admins(span_blue("[key_name(usr)] [SSticker.delay_end ? "delayed the round end" : "has made the round end normally"]."), 1)
		return
	GLOB.round_progressing = !GLOB.round_progressing
	if (!GLOB.round_progressing)
		to_world(span_world("The game start has been delayed."))
		log_admin("[key_name(usr)] delayed the game.")
	else
		to_world(span_world("The game will start soon."))
		log_admin("[key_name(usr)] removed the delay.")
	feedback_add_details("admin_verb","DELAY") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/adjump()
	set category = "Server.Game"
	set desc="Toggle admin jumping"
	set name="Toggle Jump"
	CONFIG_SET(flag/allow_admin_jump, !CONFIG_GET(flag/allow_admin_jump))
	message_admins(span_blue("Toggled admin jumping to [CONFIG_GET(flag/allow_admin_jump)]."))
	feedback_add_details("admin_verb","TJ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/adspawn()
	set category = "Server.Game"
	set desc="Toggle admin spawning"
	set name="Toggle Spawn"
	CONFIG_SET(flag/allow_admin_spawning, !CONFIG_GET(flag/allow_admin_spawning))
	message_admins(span_blue("Toggled admin item spawning to [CONFIG_GET(flag/allow_admin_spawning)]."))
	feedback_add_details("admin_verb","TAS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/adrev()
	set category = "Server.Game"
	set desc="Toggle admin revives"
	set name="Toggle Revive"
	CONFIG_SET(flag/allow_admin_rev, !CONFIG_GET(flag/allow_admin_rev))
	message_admins(span_blue("Toggled reviving to [CONFIG_GET(flag/allow_admin_rev)]."))
	feedback_add_details("admin_verb","TAR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/immreboot()
	set category = "Server.Game"
	set desc="Reboots the server post haste"
	set name="Immediate Reboot"
	if(!check_rights_for(usr.client, R_HOLDER))	return
	if(alert(usr, "Reboot server?","Reboot!","Yes","No") != "Yes") // Not tgui_alert for safety
		return
	to_world(span_filter_system("[span_red(span_bold("Rebooting world!"))] [span_blue("Initiated by [usr.client.holder.fakekey ? "Admin" : usr.key]!")]"))
	log_admin("[key_name(usr)] initiated an immediate reboot.")

	feedback_set_details("end_error","immediate admin reboot - by [usr.key] [usr.client.holder.fakekey ? "(stealth)" : ""]")
	feedback_add_details("admin_verb","IR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	if(blackbox)
		blackbox.save_all_data_to_sql()

	world.Reboot()

/datum/admins/proc/unprison(var/mob/M in GLOB.mob_list)
	set category = "Admin.Moderation"
	set name = "Unprison"
	if (M.z == 2)
		if (CONFIG_GET(flag/allow_admin_jump))
			M.loc = get_turf(pick(GLOB.latejoin))
			message_admins("[key_name_admin(usr)] has unprisoned [key_name_admin(M)]", 1)
			log_admin("[key_name(usr)] has unprisoned [key_name(M)]")
		else
			tgui_alert_async(usr, "Admin jumping disabled")
	else
		tgui_alert_async(usr, "[M.name] is not prisoned.")
	feedback_add_details("admin_verb","UP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

/proc/is_special_character(var/character) // returns 1 for special characters and 2 for heroes of gamemode
	if(!ticker || !ticker.mode)
		return 0
	var/datum/mind/M
	if (ismob(character))
		var/mob/C = character
		M = C.mind
	else if(istype(character, /datum/mind))
		M = character

	if(M)
		if(ticker.mode.antag_templates && ticker.mode.antag_templates.len)
			for(var/datum/antagonist/antag in ticker.mode.antag_templates)
				if(antag.is_antagonist(M))
					return 2
		if(M.special_role)
			return 1

	if(isrobot(character))
		var/mob/living/silicon/robot/R = character
		if(R.emagged)
			return 1

	return 0

/datum/admins/proc/spawn_fruit(seedtype in SSplants.seeds)
	set category = "Debug.Game"
	set desc = "Spawn the product of a seed."
	set name = "Spawn Fruit"

	if(!check_rights(R_SPAWN))	return

	if(!seedtype || !SSplants.seeds[seedtype])
		return
	var/amount = tgui_input_number(usr, "Amount of fruit to spawn", "Fruit Amount", 1)
	if(!isnull(amount))
		var/datum/seed/S = SSplants.seeds[seedtype]
		S.harvest(usr,0,0,amount)
	log_admin("[key_name(usr)] spawned [seedtype] fruit at ([usr.x],[usr.y],[usr.z])")

/datum/admins/proc/spawn_custom_item()
	set category = "Debug.Game"
	set desc = "Spawn a custom item."
	set name = "Spawn Custom Item"

	if(!check_rights(R_SPAWN))	return

	var/owner = tgui_input_list(usr, "Select a ckey.", "Spawn Custom Item", custom_items)
	if(!owner|| !custom_items[owner])
		return

	var/list/possible_items = custom_items[owner]
	var/datum/custom_item/item_to_spawn = tgui_input_list(usr, "Select an item to spawn.", "Spawn Custom Item", possible_items)
	if(!item_to_spawn)
		return

	item_to_spawn.spawn_item(get_turf(usr))

/datum/admins/proc/check_custom_items()
	set category = "Debug.Investigate"
	set desc = "Check the custom item list."
	set name = "Check Custom Items"

	if(!check_rights(R_SPAWN))	return

	if(!custom_items)
		to_chat(usr, "Custom item list is null.")
		return

	if(!custom_items.len)
		to_chat(usr, "Custom item list not populated.")
		return

	for(var/assoc_key in custom_items)
		to_chat(usr, "[assoc_key] has:")
		var/list/current_items = custom_items[assoc_key]
		for(var/datum/custom_item/item in current_items)
			to_chat(usr, "- name: [item.name] icon: [item.item_icon] path: [item.item_path] desc: [item.item_desc]")

/datum/admins/proc/spawn_plant(seedtype in SSplants.seeds)
	set category = "Debug.Game"
	set desc = "Spawn a spreading plant effect."
	set name = "Spawn Plant"

	if(!check_rights(R_SPAWN))	return

	if(!seedtype || !SSplants.seeds[seedtype])
		return
	new /obj/effect/plant(get_turf(usr), SSplants.seeds[seedtype])
	log_admin("[key_name(usr)] spawned [seedtype] vines at ([usr.x],[usr.y],[usr.z])")

/datum/admins/proc/spawn_atom(var/object as text)
	set name = "Spawn"
	set category = "Debug.Game"
	set desc = "(atom path) Spawn an atom"

	if(!check_rights(R_SPAWN))	return

	var/list/types = typesof(/atom)
	var/list/matches = new()

	for(var/path in types)
		if(findtext("[path]", object))
			matches += path

	if(matches.len==0)
		return

	var/chosen
	if(matches.len==1)
		chosen = matches[1]
	else
		chosen = tgui_input_list(usr, "Select an atom type", "Spawn Atom", matches)
		if(!chosen)
			return

	if(ispath(chosen,/turf))
		var/turf/T = get_turf(usr.loc)
		T.ChangeTurf(chosen)
	else
		new chosen(usr.loc)

	log_and_message_admins("spawned [chosen] at ([usr.x],[usr.y],[usr.z])")
	feedback_add_details("admin_verb","SA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/show_traitor_panel(var/mob/M in GLOB.mob_list)
	set category = "Admin.Events"
	set desc = "Edit mobs's memory and role"
	set name = "Show Traitor Panel"

	if(!istype(M))
		to_chat(usr, "This can only be used on instances of type /mob")
		return
	if(!M.mind)
		to_chat(usr, "This mob has no mind!")
		return

	M.mind.edit_memory()
	feedback_add_details("admin_verb","STP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/show_game_mode()
	set category = "Admin.Game"
	set desc = "Show the current round configuration."
	set name = "Show Game Mode"

	if(!ticker || !ticker.mode)
		tgui_alert_async(usr, "Not before roundstart!", "Alert")
		return

	var/out = span_large(span_bold("Current mode: [ticker.mode.name] (<a href='byond://?src=\ref[ticker.mode];[HrefToken()];debug_antag=self'>[ticker.mode.config_tag]</a>)")) + "<br/>"
	out += "<hr>"

	if(ticker.mode.ert_disabled)
		out += span_bold("Emergency Response Teams:") + "<a href='byond://?src=\ref[ticker.mode];[HrefToken()];toggle=ert'>disabled</a>"
	else
		out += span_bold("Emergency Response Teams:") + "<a href='byond://?src=\ref[ticker.mode];[HrefToken()];toggle=ert'>enabled</a>"
	out += "<br/>"

	if(ticker.mode.deny_respawn)
		out += span_bold("Respawning:") + "<a href='byond://?src=\ref[ticker.mode];[HrefToken()];toggle=respawn'>disallowed</a>"
	else
		out += span_bold("Respawning:") + "<a href='byond://?src=\ref[ticker.mode];[HrefToken()];toggle=respawn'>allowed</a>"
	out += "<br/>"

	out += span_bold("Shuttle delay multiplier:") + " <a href='byond://?src=\ref[ticker.mode];[HrefToken()];set=shuttle_delay'>[ticker.mode.shuttle_delay]</a><br/>"

	if(ticker.mode.auto_recall_shuttle)
		out += span_bold("Shuttle auto-recall:") + " <a href='byond://?src=\ref[ticker.mode];[HrefToken()];toggle=shuttle_recall'>enabled</a>"
	else
		out += span_bold("Shuttle auto-recall:") + " <a href='byond://?src=\ref[ticker.mode];[HrefToken()];toggle=shuttle_recall'>disabled</a>"
	out += "<br/><br/>"

	if(ticker.mode.event_delay_mod_moderate)
		out += span_bold("Moderate event time modifier:") + " <a href='byond://?src=\ref[ticker.mode];[HrefToken()];set=event_modifier_moderate'>[ticker.mode.event_delay_mod_moderate]</a><br/>"
	else
		out += span_bold("Moderate event time modifier:") + " <a href='byond://?src=\ref[ticker.mode];[HrefToken()];set=event_modifier_moderate'>unset</a><br/>"

	if(ticker.mode.event_delay_mod_major)
		out += span_bold("Major event time modifier:") + " <a href='byond://?src=\ref[ticker.mode];[HrefToken()];set=event_modifier_severe'>[ticker.mode.event_delay_mod_major]</a><br/>"
	else
		out += span_bold("Major event time modifier:") + " <a href='byond://?src=\ref[ticker.mode];[HrefToken()];set=event_modifier_severe'>unset</a><br/>"

	out += "<hr>"

	if(ticker.mode.antag_tags && ticker.mode.antag_tags.len)
		out += span_bold("Core antag templates:") + "</br>"
		for(var/antag_tag in ticker.mode.antag_tags)
			out += "<a href='byond://?src=\ref[ticker.mode];[HrefToken()];debug_antag=[antag_tag]'>[antag_tag]</a>.</br>"

	if(ticker.mode.round_autoantag)
		out += span_bold("Autotraitor <a href='byond://?src=\ref[ticker.mode];[HrefToken()];toggle=autotraitor'>enabled</a>.")
		if(ticker.mode.antag_scaling_coeff > 0)
			out += " (scaling with <a href='byond://?src=\ref[ticker.mode];[HrefToken()];set=antag_scaling'>[ticker.mode.antag_scaling_coeff]</a>)"
		else
			out += " (not currently scaling, <a href='byond://?src=\ref[ticker.mode];[HrefToken()];set=antag_scaling'>set a coefficient</a>)"
		out += "<br/>"
	else
		out += span_bold("Autotraitor <a href='byond://?src=\ref[ticker.mode];[HrefToken()];toggle=autotraitor'>disabled</a>.") + "<br/>"

	out += span_bold("All antag ids:")
	if(ticker.mode.antag_templates && ticker.mode.antag_templates.len)
		for(var/datum/antagonist/antag in ticker.mode.antag_templates)
			antag.update_current_antag_max()
			out += " <a href='byond://?src=\ref[ticker.mode];[HrefToken()];debug_antag=[antag.id]'>[antag.id]</a>"
			out += " ([antag.get_antag_count()]/[antag.cur_max]) "
			out += " <a href='byond://?src=\ref[ticker.mode];[HrefToken()];remove_antag_type=[antag.id]'>\[-\]</a><br/>"
	else
		out += " None."
	out += " <a href='byond://?src=\ref[ticker.mode];[HrefToken()];add_antag_type=1'>\[+\]</a><br/>"

	var/datum/browser/popup = new(owner, "edit_mode[src]", "Edit Game Mode")
	popup.set_content(out)
	popup.open()
	feedback_add_details("admin_verb","SGM")


/datum/admins/proc/toggletintedweldhelmets()
	set category = "Server.Config"
	set desc="Reduces view range when wearing welding helmets"
	set name="Toggle tinted welding helmets."
	CONFIG_SET(flag/welder_vision, !CONFIG_GET(flag/welder_vision))
	if (CONFIG_GET(flag/welder_vision))
		to_world(span_world("Reduced welder vision has been enabled!"))
	else
		to_world(span_world("Reduced welder vision has been disabled!"))
	log_admin("[key_name(usr)] toggled welder vision.")
	message_admins("[key_name_admin(usr)] toggled welder vision.", 1)
	feedback_add_details("admin_verb","TTWH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleguests()
	set category = "Server.Config"
	set desc="Guests can't enter"
	set name="Toggle guests"
	CONFIG_SET(flag/guests_allowed, !CONFIG_GET(flag/guests_allowed))
	if (!CONFIG_GET(flag/guests_allowed))
		to_world(span_world("Guests may no longer enter the game."))
	else
		to_world(span_world("Guests may now enter the game."))
	log_admin("[key_name(usr)] toggled guests game entering [CONFIG_GET(flag/guests_allowed)?"":"dis"]allowed.")
	message_admins(span_blue("[key_name_admin(usr)] toggled guests game entering [CONFIG_GET(flag/guests_allowed)?"":"dis"]allowed."), 1)
	feedback_add_details("admin_verb","TGU") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/update_mob_sprite(mob/living/carbon/human/H as mob)
	set category = "Admin.Game"
	set name = "Update Mob Sprite"
	set desc = "Should fix any mob sprite update errors."

	if (!check_rights_for(src, R_HOLDER))
		to_chat(src, "Only administrators may use this command.")
		return

	if(istype(H))
		H.regenerate_icons()

/proc/get_options_bar(whom, detail = 2, name = 0, link = 1, highlight_special = 1)
	if(!whom)
		return span_bold("(*null*)")
	var/mob/M
	var/client/C
	if(istype(whom, /client))
		C = whom
		M = C.mob
	else if(istype(whom, /mob))
		M = whom
		C = M.client
	else
		return span_bold("(*not a mob*)")
	switch(detail)
		if(0)
			return span_bold("[key_name(C, link, name, highlight_special)]")

		if(1)	//Private Messages
			return span_bold("[key_name(C, link, name, highlight_special)](<A href='byond://?_src_=holder;[HrefToken()];adminmoreinfo=\ref[M]'>?</A>)")

		if(2)	//Admins
			var/ref_mob = "\ref[M]"
			return span_bold("[key_name(C, link, name, highlight_special)](<A href='byond://?_src_=holder;[HrefToken()];adminmoreinfo=[ref_mob]'>?</A>) (<A href='byond://?_src_=holder;[HrefToken()];adminplayeropts=[ref_mob]'>PP</A>) (<A href='byond://?_src_=vars;[HrefToken()];Vars=[ref_mob]'>VV</A>) (<A href='byond://?_src_=holder;[HrefToken()];subtlemessage=[ref_mob]'>SM</A>) ([admin_jump_link(M)]) (<A href='byond://?_src_=holder;[HrefToken()];check_antagonist=1'>CA</A>) (<A href='byond://?_src_=holder;[HrefToken()];take_question=\ref[M]'>TAKE</A>)")

		if(3)	//Devs
			var/ref_mob = "\ref[M]"
			return span_bold("[key_name(C, link, name, highlight_special)](<A href='byond://?_src_=vars;[HrefToken()];Vars=[ref_mob]'>VV</A>)([admin_jump_link(M)]) (<A href='byond://?_src_=holder;[HrefToken()];take_question=\ref[M]'>TAKE</A>)")

		if(4)	//Event Managers
			var/ref_mob = "\ref[M]"
			return span_bold("[key_name(C, link, name, highlight_special)] (<A href='byond://?_src_=holder;[HrefToken()];adminmoreinfo=\ref[M]'>?</A>) (<A href='byond://?_src_=holder;[HrefToken()];adminplayeropts=[ref_mob]'>PP</A>) (<A href='byond://?_src_=vars;[HrefToken()];Vars=[ref_mob]'>VV</A>) (<A href='byond://?_src_=holder;[HrefToken()];subtlemessage=[ref_mob]'>SM</A>) ([admin_jump_link(M)]) (<A href='byond://?_src_=holder;[HrefToken()];take_question=\ref[M]'>TAKE</A>)")


/proc/ishost(whom)
	if(!whom)
		return 0
	var/client/C
	var/mob/M
	if(istype(whom, /client))
		C = whom
	if(istype(whom, /mob))
		M = whom
		C = M.client
	if(check_rights_for(C, R_HOST))
		return 1
	else
		return 0
//
//
//ALL DONE
//*********************************************************************************************************
//

//Returns 1 to let the dragdrop code know we are trapping this event
//Returns 0 if we don't plan to trap the event
/datum/admins/proc/cmd_ghost_drag(var/mob/observer/dead/frommob, var/mob/living/tomob)
	if(!istype(frommob))
		return //Extra sanity check to make sure only observers are shoved into things

	//Same as assume-direct-control perm requirements.
	if (!check_rights(R_VAREDIT,0) || !check_rights(R_ADMIN|R_DEBUG|R_EVENT,0))
		return 0
	if (!frommob.ckey)
		return 0
	var/question = ""
	if (tomob.ckey)
		question = "This mob already has a user ([tomob.key]) in control of it! "
	question += "Are you sure you want to place [frommob.name]([frommob.key]) in control of [tomob.name]?"
	var/ask = tgui_alert(usr, question, "Place ghost in control of mob?", list("Yes", "No"))
	if (ask != "Yes")
		return 1
	if (!frommob || !tomob) //make sure the mobs don't go away while we waited for a response
		return 1
	if(tomob.client) //No need to ghostize if there is no client
		tomob.ghostize(0)
	if(frommob.mind && frommob.mind.current) //Preserve teleop for original body when adminghosting.
		var/mob/body = frommob.mind.current
		if(body)
			if(body.teleop)
				body.teleop = tomob
	message_admins(span_adminnotice("[key_name_admin(usr)] has put [frommob.ckey] in control of [tomob.name]."))
	log_admin("[key_name(usr)] stuffed [frommob.ckey] into [tomob.name].")
	feedback_add_details("admin_verb","CGD")
	tomob.ckey = frommob.ckey
	qdel(frommob)
	return 1

/datum/admins/proc/force_antag_latespawn()
	set category = "Admin.Events"
	set name = "Force Template Spawn"
	set desc = "Force an antagonist template to spawn."

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	if(!ticker || !ticker.mode)
		to_chat(usr, "Mode has not started.")
		return

	var/antag_type = tgui_input_list(usr, "Choose a template.","Force Latespawn", GLOB.all_antag_types)
	if(!antag_type || !GLOB.all_antag_types[antag_type])
		to_chat(usr, "Aborting.")
		return

	var/datum/antagonist/antag = GLOB.all_antag_types[antag_type]
	message_admins("[key_name(usr)] attempting to force latespawn with template [antag.id].")
	antag.attempt_late_spawn()

/datum/admins/proc/force_mode_latespawn()
	set category = "Admin.Events"
	set name = "Force Mode Spawn"
	set desc = "Force autotraitor to proc."

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins) || !check_rights(R_ADMIN|R_EVENT|R_FUN))
		to_chat(usr, "Error: you are not an admin!")
		return

	if(!ticker || !ticker.mode)
		to_chat(usr, "Mode has not started.")
		return

	log_and_message_admins("attempting to force mode autospawn.")
	ticker.mode.try_latespawn()

/datum/admins/proc/paralyze_mob(mob/living/H as mob)
	set category = "Admin.Events"
	set name = "Toggle Paralyze"
	set desc = "Paralyzes a player. Or unparalyses them."

	var/msg

	if(check_rights(R_ADMIN|R_MOD|R_EVENT))
		if (H.paralysis == 0)
			H.SetParalysis(8000)
			msg = "has paralyzed [key_name(H)]."
			log_and_message_admins(msg)
		else
			if(tgui_alert(src, "[key_name(H)] is paralyzed, would you like to unparalyze them?","Paralyze Mob",list("Yes","No")) == "Yes")
				H.SetParalysis(0)
				msg = "has unparalyzed [key_name(H)]."
				log_and_message_admins(msg)

/datum/admins/proc/set_tcrystals(mob/living/carbon/human/H as mob)
	set category = "Debug.Game"
	set name = "Set Telecrystals"
	set desc = "Allows admins to change telecrystals of a user."
	set popup_menu = FALSE //VOREStation Edit - Declutter.
	var/crystals

	if(check_rights(R_ADMIN|R_EVENT))
		crystals = tgui_input_number(usr, "Amount of telecrystals for [H.ckey], currently [H.mind.tcrystals].", crystals)
		if (!isnull(crystals))
			H.mind.tcrystals = crystals
			var/msg = "[key_name(usr)] has modified [H.ckey]'s telecrystals to [crystals]."
			message_admins(msg)
	else
		to_chat(usr, "You do not have access to this command.")

/datum/admins/proc/add_tcrystals(mob/living/carbon/human/H as mob)
	set category = "Debug.Game"
	set name = "Add Telecrystals"
	set desc = "Allows admins to change telecrystals of a user by addition."
	set popup_menu = FALSE //VOREStation Edit - Declutter.
	var/crystals

	if(check_rights(R_ADMIN|R_EVENT))
		crystals = tgui_input_number(usr, "Amount of telecrystals to give to [H.ckey], currently [H.mind.tcrystals].", crystals)
		if (!isnull(crystals))
			H.mind.tcrystals += crystals
			var/msg = "[key_name(usr)] has added [crystals] to [H.ckey]'s telecrystals."
			message_admins(msg)
	else
		to_chat(usr, "You do not have access to this command.")


/datum/admins/proc/sendFax()
	set category = "Fun.Event Kit"
	set name = "Send Fax"
	set desc = "Sends a fax to this machine"
	var/department = tgui_input_list(usr, "Choose a fax", "Fax", GLOB.alldepartments)
	for(var/obj/machinery/photocopier/faxmachine/sendto in GLOB.allfaxes)
		if(sendto.department == department)

			if (!istype(src,/datum/admins))
				src = usr.client.holder
			if (!istype(src,/datum/admins))
				to_chat(usr, "Error: you are not an admin!")
				return

			var/replyorigin = tgui_input_text(src.owner, "Please specify who the fax is coming from", "Origin")

			var/obj/item/paper/admin/P = new /obj/item/paper/admin( null ) //hopefully the null loc won't cause trouble for us
			faxreply = P

			P.admindatum = src
			P.origin = replyorigin
			P.destination = sendto

			P.adminbrowse()


/datum/admins/var/obj/item/paper/admin/faxreply // var to hold fax replies in

/datum/admins/proc/faxCallback(var/obj/item/paper/admin/P, var/obj/machinery/photocopier/faxmachine/destination)
	var/customname = tgui_input_text(src.owner, "Pick a title for the report", "Title")

	P.name = "[P.origin] - [customname]"
	P.desc = "This is a paper titled '" + P.name + "'."

	var/shouldStamp = 1
	if(!P.sender) // admin initiated
		if(tgui_alert(usr, "Would you like the fax stamped?","Stamped?", list("Yes", "No")) != "Yes")
			shouldStamp = 0

	if(shouldStamp)
		P.stamps += "<hr>" + span_italics("This paper has been stamped by the [P.origin] Quantum Relay.")

		var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
		var/x = rand(-2, 0)
		var/y = rand(-1, 2)
		P.offset_x += x
		P.offset_y += y
		stampoverlay.pixel_x = x
		stampoverlay.pixel_y = y

		if(!P.ico)
			P.ico = new
		P.ico += "paper_stamp-cent"
		stampoverlay.icon_state = "paper_stamp-cent"

		if(!P.stamped)
			P.stamped = new
		P.stamped += /obj/item/stamp/centcomm
		P.add_overlay(stampoverlay)

	var/obj/item/rcvdcopy
	rcvdcopy = destination.copy(P)
	rcvdcopy.loc = null //hopefully this shouldn't cause trouble
	GLOB.adminfaxes += rcvdcopy



	if(destination.receivefax(P))
		to_chat(src.owner, span_notice("Message reply to transmitted successfully."))
		if(P.sender) // sent as a reply
			log_admin("[key_name(src.owner)] replied to a fax message from [key_name(P.sender)]")
			for(var/client/C in GLOB.admins)
				if(check_rights_for(C, (R_ADMIN | R_MOD | R_EVENT)))
					to_chat(C, span_log_message("[span_prefix("FAX LOG:")][key_name_admin(src.owner)] replied to a fax message from [key_name_admin(P.sender)] (<a href='byond://?_src_=holder;[HrefToken()];AdminFaxView=\ref[rcvdcopy]'>VIEW</a>)"))
		else
			log_admin("[key_name(src.owner)] has sent a fax message to [destination.department]")
			for(var/client/C in GLOB.admins)
				if(check_rights_for(C, (R_ADMIN | R_MOD | R_EVENT)))
					to_chat(C, span_log_message("[span_prefix("FAX LOG:")][key_name_admin(src.owner)] has sent a fax message to [destination.department] (<a href='byond://?_src_=holder;[HrefToken()];AdminFaxView=\ref[rcvdcopy]'>VIEW</a>)"))

		var/plaintext_title = P.sender ? "replied to [key_name(P.sender)]'s fax" : "sent a fax message to [destination.department]"
		var/fax_text = paper_html_to_plaintext(P.info)
		log_game(plaintext_title)
		log_game(fax_text)

		SSwebhooks.send(
			WEBHOOK_FAX_SENT,
			list(
				"name" = "[key_name(owner)] [plaintext_title].",
				"body" = fax_text
			)
		)

	else
		to_chat(src.owner, span_warning("Message reply failed."))

	spawn(100)
		qdel(P)
		faxreply = null
	return

/datum/admins/proc/set_uplink(mob/living/carbon/human/H as mob)
	set category = "Debug.Events"
	set name = "Set Uplink"
	set desc = "Allows admins to set up an uplink on a character. This will be required for a character to use telecrystals."
	set popup_menu = FALSE

	if(check_rights(R_ADMIN|R_DEBUG))
		traitors.spawn_uplink(H)
		H.mind.tcrystals = DEFAULT_TELECRYSTAL_AMOUNT
		H.mind.accept_tcrystals = 1
		var/msg = "[key_name(usr)] has given [H.ckey] an uplink."
		message_admins(msg)
	else
		to_chat(usr, "You do not have access to this command.")
