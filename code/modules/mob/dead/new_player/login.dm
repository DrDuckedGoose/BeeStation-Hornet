/mob/dead/new_player/authenticated/Login()
	if(!client)
		return
	if(!client.logged_in)
		log_admin_private("/mob/dead/new_player/authenticated/Login() was called on [key_name(src)] without the assigned client being authenticated! Possible auth bypass! Caller: [key_name(usr)]")
		qdel(client)
		qdel(src)
		return
	if(CONFIG_GET(flag/use_exp_tracking))
		client.set_exp_from_db()
		if(!client) // client null during sleep
			return
		client.set_db_player_flags()
		if(!client) // client null during sleep
			return
	if(!mind)
		mind = new /datum/mind(key)
		mind.active = TRUE
		mind.set_current(src)

	. = ..()
	if(!. || !client)
		return FALSE

	if(client.logged_in && client.external_uid)
		to_chat(src, span_good("Successfully signed in as [span_bold("[client.display_name_chat()]")]"))

	var/motd = global.config.motd
	if(motd)
		to_chat(src, "<div class=\"motd\">[motd]</div>", handle_whitespace=FALSE, allow_linkify = TRUE)

	if(GLOB.admin_notice)
		to_chat(src, span_notice("<b>Admin Notice:</b>\n \t [GLOB.admin_notice]"))

	var/spc = CONFIG_GET(number/soft_popcap)
	if(spc && living_player_count() >= spc)
		to_chat(src, span_notice("<b>Server Notice:</b>\n \t [CONFIG_GET(string/soft_popcap_message)]"), allow_linkify = TRUE)

	sight |= SEE_TURFS

	client.playtitlemusic()

	// Check if user should be added to interview queue
	if (!client.holder && CONFIG_GET(flag/panic_bunker) && CONFIG_GET(flag/panic_bunker_interview) && !(client.ckey in GLOB.interviews.approved_ckeys))
		var/required_living_minutes = CONFIG_GET(number/panic_bunker_living)
		var/living_minutes = client.get_exp_living(TRUE)
		if (required_living_minutes > living_minutes)
			client.interviewee = TRUE
			register_for_interview()
			return

	new_player_panel()
	if(SSticker.current_state < GAME_STATE_SETTING_UP)
		var/tl = SSticker.GetTimeLeft()
		to_chat(src, "Please set up your character and select \"Ready\". The game will start [tl > 0 ? "in about [DisplayTimeText(tl)]" : "soon"].")
