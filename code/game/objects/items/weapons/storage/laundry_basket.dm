// -----------------------------
//        Laundry Basket
// -----------------------------
// An item designed for hauling the belongings of a character.
// So this cannot be abused for other uses, we make it two-handed and inable to have its storage looked into.
/obj/item/storage/laundry_basket
	name = "laundry basket"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "laundry-empty"
	item_state_slots = list(slot_r_hand_str = "laundry", slot_l_hand_str = "laundry")
	desc = "The peak of thousands of years of laundry evolution."

	w_class = ITEMSIZE_HUGE
	max_w_class = ITEMSIZE_LARGE
	max_storage_space = ITEMSIZE_COST_NORMAL * 8
	storage_slots = 20
	use_to_pickup = TRUE
	allow_quick_empty = 1
	allow_quick_gather = 1
	collection_mode = 1
	var/linked


/obj/item/storage/laundry_basket/attack_hand(mob/living/user as mob)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.get_organ(BP_R_HAND)
		if (user.hand)
			temp = H.get_organ(BP_L_HAND)
		if(!temp)
			to_chat(user, span_warning("You need two hands to pick this up!"))
			return

	if(user.get_inactive_hand())
		to_chat(user, span_warning("You need your other hand to be empty"))
		return
	return ..()

/obj/item/storage/laundry_basket/attack_self(mob/user as mob)
	var/turf/T = get_turf(user)
	to_chat(user, span_notice("You dump the [src]'s contents onto \the [T]."))
	return ..()

/obj/item/storage/laundry_basket/pickup(mob/user)
	var/obj/item/storage/laundry_basket/offhand/O = new(user)
	O.name = "[name] - second hand"
	O.desc = "Your second grip on the [name]."
	O.linked = src
	user.put_in_inactive_hand(O)
	linked = O
	return

/obj/item/storage/laundry_basket/update_icon()
	if(contents.len)
		icon_state = "laundry-full"
	else
		icon_state = "laundry-empty"
	return


/obj/item/storage/laundry_basket/MouseDrop(obj/over_object)
	if(over_object == usr)
		return
	else
		return ..()

/obj/item/storage/laundry_basket/dropped(mob/user)
	if(linked)
		QDEL_NULL(linked)
	return ..()

/obj/item/storage/laundry_basket/show_to(mob/user)
	return

/obj/item/storage/laundry_basket/open(mob/user)


//Offhand
/obj/item/storage/laundry_basket/offhand
	icon = 'icons/obj/weapons.dmi'
	icon_state = "offhand"
	name = "second hand"
	use_to_pickup = FALSE

/obj/item/storage/laundry_basket/offhand/dropped(mob/user)
	SHOULD_CALL_PARENT(FALSE)
	if(user.isEquipped(linked))
		user.drop_from_inventory(linked)
	return
