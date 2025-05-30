/obj/item/voice_changer
	name = "voice changer"
	desc = "A voice scrambling module. If you can see this, report it as a bug on the tracker."
	var/voice = null //If set and item is present in mask/suit, this name will be used for the wearer's speech.
	var/active = TRUE

/obj/item/clothing/mask/gas/voice
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. It seems to house some odd electronics."
	var/obj/item/voice_changer/changer
	origin_tech = list(TECH_ILLEGAL = 4)

/obj/item/clothing/mask/gas/voice/verb/Toggle_Voice_Changer()
	set category = "Object"
	set src in usr

	changer.active = !changer.active
	to_chat(usr, span_notice("You [changer.active ? "enable" : "disable"] the voice-changing module in \the [src]."))

/obj/item/clothing/mask/gas/voice/verb/Set_Voice(name as text)
	set category = "Object"
	set src in usr

	var/voice = sanitize(name, MAX_NAME_LEN)
	if(!voice || !length(voice)) return
	changer.voice = voice
	to_chat(usr, span_notice("You are now mimicking <B>[changer.voice]</B>."))

/obj/item/clothing/mask/gas/voice/verb/Reset_Voice()
	set category = "Object"
	set src in usr

	changer.voice = null
	to_chat(usr, span_notice("You have reset your voice changer's mimicry feature."))

/obj/item/clothing/mask/gas/voice/Initialize(mapload)
	. = ..()
	changer = new(src)
