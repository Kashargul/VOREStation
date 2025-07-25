/obj/effect/overmap/visitable/ship/Initialize(mapload)
	. = ..()
	GLOB.listening_objects += src

/obj/effect/overmap/visitable/ship/Destroy()
	GLOB.listening_objects -= src
	return ..()

/obj/effect/overmap/visitable/ship/MouseDrop(atom/over)
	if(!isliving(over) || !Adjacent(over) || !Adjacent(usr))
		return
	if(istype(over, /mob/living/simple_mob/vore/overmap))
		var/mob/living/simple_mob/vore/overmap/sdog = over
		if(!sdog.shipvore)
			return
	var/mob/living/L = over
	var/confirm = tgui_alert(L, "You COULD eat this spaceship...", "Eat spaceship?", list("Eat it!", "No, thanks."))
	if(confirm == "Eat it!")
		var/obj/belly/bellychoice = tgui_input_list(L, "Which belly?","Select A Belly", L.vore_organs)
		if(bellychoice)
			L.visible_message(span_warning("[L] is trying to stuff \the [src] into [L.gender == MALE ? "his" : L.gender == FEMALE ? "her" : "their"] [bellychoice]!"),span_notice("You begin putting \the [src] into your [bellychoice]!"))
			if(do_after(L, 5 SECONDS, src, exclusive = TASK_ALL_EXCLUSIVE))
				forceMove(bellychoice)
				SSskybox.rebuild_skyboxes(map_z)
				L.visible_message(span_warning("[L] eats a spaceship! This is totally normal."),"You eat the the spaceship! Yum, metal.")

/obj/effect/overmap/visitable/ship/proc/get_people_in_ship()
	. = list()
	for(var/mapz in map_z)
		var/list/thatz = GLOB.players_by_zlevel[mapz]
		. += thatz

/obj/effect/overmap/visitable/ship/hear_talk(mob/talker, list/message_pieces, verb)
	. = ..()

	var/list/listeners = get_people_in_ship()
	for(var/mob/M as anything in listeners)
		M.hear_say(message_pieces, verb, FALSE, talker)

/obj/effect/overmap/visitable/ship/show_message(msg, type, alt, alt_type)
	. = ..()

	var/list/listeners = get_people_in_ship()
	for(var/mob/M as anything in listeners)
		M.show_message(msg, type, alt, alt_type)

/obj/effect/overmap/visitable/ship/see_emote(source, message, m_type)
	. = ..()

	var/list/listeners = get_people_in_ship()
	for(var/mob/M as anything in listeners)
		M.show_message(message, m_type)
