/obj/item/rig_module/cleaner_launcher

	name = "mounted space cleaner launcher"
	desc = "A shoulder-mounted micro-cleaner dispenser."
	selectable = 1
	icon_state = "grenadelauncher"

	interface_name = "integrated cleaner launcher"
	interface_desc = "Discharges loaded cleaner grenades against the wearer's location."

	var/fire_force = 30
	var/fire_distance = 10

	charges = list(
		list("cleaner grenade",   "cleaner grenade",   /obj/item/grenade/chem_grenade/cleaner,  9),
		)

/obj/item/rig_module/cleaner_launcher/accepts_item(var/obj/item/input_device, var/mob/living/user)

	if(!istype(input_device) || !istype(user))
		return 0

	var/datum/rig_charge/accepted_item
	for(var/charge in charges)
		var/datum/rig_charge/charge_datum = charges[charge]
		if(input_device.type == charge_datum.product_type)
			accepted_item = charge_datum
			break

	if(!accepted_item)
		return 0

	if(accepted_item.charges >= 5)
		to_chat(user, span_danger("Another grenade of that type will not fit into the module."))
		return 0

	to_chat(user, span_boldnotice("You slot \the [input_device] into the suit module."))
	user.drop_from_inventory(input_device)
	qdel(input_device)
	accepted_item.charges++
	return 1

/obj/item/rig_module/cleaner_launcher/engage(atom/target)

	if(!..())
		return 0

	if(!target)
		return 0

	var/mob/living/carbon/human/H = holder.wearer

	if(!charge_selected)
		to_chat(H, span_danger("You have not selected a grenade type."))
		return 0

	var/datum/rig_charge/charge = charges[charge_selected]

	if(!charge)
		return 0

	if(charge.charges <= 0)
		to_chat(H, span_danger("Insufficient grenades!"))
		return 0

	charge.charges--
	var/obj/item/grenade/new_grenade = new charge.product_type(get_turf(H))
	H.visible_message(span_danger("[H] launches \a [new_grenade]!"))
	new_grenade.activate(H)
	new_grenade.throw_at(target,fire_force,fire_distance)
