// These objects are used by cyborgs to get around a lot of the limitations on stacks
// and the weird bugs that crop up when expecting borg module code to behave sanely.
/obj/item/stack/material/cyborg
	uses_charge = 1
	charge_costs = list(1000)
	gender = NEUTER
	matter = null // Don't shove it in the autholathe.

/obj/item/stack/material/cyborg/Initialize(mapload)
	. = ..()
	name = "[material.display_name] synthesiser"
	desc = "A device that synthesises [material.display_name]."
	matter = null

/obj/item/stack/material/cyborg/update_strings()
	return

/obj/item/stack/material/cyborg/plastic
	icon_state = "sheet-plastic"
	default_type = MAT_PLASTIC

/obj/item/stack/material/cyborg/steel
	icon_state = "sheet-metal"
	default_type = MAT_STEEL

/obj/item/stack/material/cyborg/plasteel
	icon_state = "sheet-plasteel"
	default_type = MAT_PLASTEEL

/obj/item/stack/material/cyborg/wood
	icon_state = "sheet-wood"
	default_type = MAT_WOOD

/obj/item/stack/material/cyborg/glass
	icon_state = "sheet-glass"
	default_type = MAT_GLASS

/obj/item/stack/material/cyborg/glass/reinforced
	icon_state = "sheet-rglass"
	default_type = MAT_RGLASS
	charge_costs = list(500, 1000)
