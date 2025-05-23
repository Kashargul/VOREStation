///SCI TELEPAD///
/obj/machinery/telepad
	name = "telepad"
	desc = "A bluespace telepad used for teleporting objects to and from a location."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle"
	anchored = TRUE
	use_power = USE_POWER_IDLE
	circuit = /obj/item/circuitboard/telesci_pad
	idle_power_usage = 200
	active_power_usage = 5000
	var/efficiency

/obj/machinery/telepad/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/bluespace_crystal(src)
	component_parts += new /obj/item/stock_parts/capacitor(src)
	component_parts += new /obj/item/stock_parts/capacitor(src)
	component_parts += new /obj/item/stock_parts/console_screen(src)
	component_parts += new /obj/item/stack/cable_coil(src, 5)
	RefreshParts()
	update_icon()

/obj/machinery/telepad/RefreshParts()
	var/E
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		E += C.rating
	efficiency = E

/obj/machinery/telepad/attackby(obj/item/W as obj, mob/user as mob)
	src.add_fingerprint(user)

	if(default_deconstruction_screwdriver(user, W))
		return
	if(default_deconstruction_crowbar(user, W))
		return
	if(default_part_replacement(user, W))
		return
	if(panel_open)
		if(istype(W, /obj/item/multitool))
			var/obj/item/multitool/M = W
			M.connectable = src
			to_chat(user, span_warning("You save the data in the [M.name]'s buffer."))
			return 1

	return ..()
