
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// fossils

/obj/item/fossil
	name = "Fossil"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "bone"
	desc = "It's a fossil."
	var/animal = 1

/obj/item/fossil/base/Initialize(mapload)
	..()
	var/list/l = list(/obj/item/fossil/bone = 9,/obj/item/fossil/skull = 3,
	/obj/item/fossil/skull/horned = 2)
	var/t = pickweight(l)
	new t(src.loc)
	return INITIALIZE_HINT_QDEL

/obj/item/fossil/bone
	name = "Fossilised bone"
	icon_state = "bone"
	desc = "It's a fossilised bone."

/obj/item/fossil/skull
	name = "Fossilised skull"
	icon_state = "skull"
	desc = "It's a fossilised skull."

/obj/item/fossil/skull/horned
	icon_state = "hskull"
	desc = "It's a fossilised, horned skull."

/obj/item/fossil/skull/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/fossil/bone))
		var/obj/o = new /obj/skeleton(get_turf(src))
		var/a = new /obj/item/fossil/bone
		var/b = new src.type
		o.contents.Add(a)
		o.contents.Add(b)
		qdel(W)
		qdel(src)

/obj/skeleton
	name = "Incomplete skeleton"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "uskel"
	desc = "Incomplete skeleton."
	var/bnum = 1
	var/breq
	var/bstate = 0
	var/plaque_contents = "Unnamed alien creature"

/obj/skeleton/Initialize(mapload)
	. = ..()
	breq = rand(6)+3
	desc = "An incomplete skeleton, looks like it could use [breq-bnum] more bones."

/obj/skeleton/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/fossil/bone))
		if(!bstate)
			bnum++
			src.contents.Add(new/obj/item/fossil/bone)
			qdel(W)
			if(bnum==breq)
				icon_state = "skel"
				src.bstate = 1
				src.density = TRUE
				src.name = "alien skeleton display"
				if(src.contents.Find(/obj/item/fossil/skull/horned))
					src.desc = "A creature made of [src.contents.len-1] assorted bones and a horned skull. The plaque reads \'[plaque_contents]\'."
				else
					src.desc = "A creature made of [src.contents.len-1] assorted bones and a skull. The plaque reads \'[plaque_contents]\'."
			else
				src.desc = "Incomplete skeleton, looks like it could use [src.breq-src.bnum] more bones."
				to_chat(user, "Looks like it could use [src.breq-src.bnum] more bones.")
		else
			..()
	else if(istype(W,/obj/item/pen))
		plaque_contents = sanitize(tgui_input_text(user, "What would you like to write on the plaque:","Skeleton plaque",""))
		user.visible_message("[user] writes something on the base of [src].","You relabel the plaque on the base of [icon2html(src,viewers(src))] [src].")
		if(src.contents.Find(/obj/item/fossil/skull/horned))
			src.desc = "A creature made of [src.contents.len-1] assorted bones and a horned skull. The plaque reads \'[plaque_contents]\'."
		else
			src.desc = "A creature made of [src.contents.len-1] assorted bones and a skull. The plaque reads \'[plaque_contents]\'."
	else
		..()

//shells and plants do not make skeletons
/obj/item/fossil/shell
	name = "Fossilised shell"
	icon_state = "shell"
	desc = "It's a fossilised shell."

/obj/item/fossil/plant
	name = "Fossilised plant"
	icon_state = "plant1"
	desc = "It's fossilised plant remains."
	animal = 0

/obj/item/fossil/plant/Initialize(mapload)
	. = ..()
	icon_state = "plant[rand(1,4)]"
