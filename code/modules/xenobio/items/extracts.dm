//VOREStation Note - we use different xenobio balance in extracts_vr, keep this unticked.

// Base
/obj/item/slime_extract
	name = "slime extract"
	desc = "Goo extracted from a slime, which can do different things depending on its color and what it is injected with."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey slime extract"
	force = 1
	w_class = ITEMSIZE_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 6
	origin_tech = list(TECH_BIO = 4)
	var/uses = 1 // uses before it goes inert
	var/enhanced = FALSE
	flags = OPENCONTAINER


/obj/item/slime_extract/Initialize(mapload)
	create_reagents(60)
	. = ..()

/obj/item/slime_extract/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/slimepotion/enhancer))
		if(enhanced)
			to_chat(user, span_warning("You cannot enhance this extract further!"))
			return ..()
		to_chat(user, span_notice("You apply the enhancer to the slime extract. It may now be reused one more time."))
		playsound(src, 'sound/effects/bubbles.ogg', 50, 1)
		uses += 2
		enhanced = TRUE
		name = initial(name) // To remove the 'inert' part of the name.
		qdel(O)
	..()

/obj/item/slime_extract/examine(mob/user)
	. = ..()
	if(uses)
		. += "This extract has [uses] more use\s."
	else
		. += "This extract is inert."

/decl/chemical_reaction/instant/slime
	var/required = null

/decl/chemical_reaction/instant/slime/can_happen(var/datum/reagents/holder)
	if(holder.my_atom && istype(holder.my_atom, required))
		var/obj/item/slime_extract/T = holder.my_atom
		if(T.uses > 0)
			return ..()
	return FALSE

/decl/chemical_reaction/instant/slime/on_reaction(var/datum/reagents/holder)
	var/obj/item/slime_extract/T = holder.my_atom
	T.uses--
	if(T.uses <= 0)
		T.visible_message("[icon2html(T,viewers(T))]<b>\The [T]</b> goes inert.")
		T.name = "inert [initial(T.name)]"


// ***************
// * Grey slimes *
// ***************


/obj/item/slime_extract/grey
	name = "grey slime extract"
	icon_state = "grey slime extract"
	description_info = "This extract will create a new grey baby slime if injected with phoron, or some new monkey cubes if injected with blood."

/decl/chemical_reaction/instant/slime/grey_new_slime
	name = "Slime Spawn"
	id = "m_spawn"
	result = null
	required_reagents = list(REAGENT_ID_PHORON = 5)
	result_amount = 1
	required = /obj/item/slime_extract/grey

/decl/chemical_reaction/instant/slime/grey_new_slime/on_reaction(var/datum/reagents/holder)
	holder.my_atom.visible_message(span_warning("Infused with phoron, the core begins to quiver and grow, and soon a new baby slime emerges from it!"))
	new /mob/living/simple_mob/slime/xenobio(get_turf(holder.my_atom))
	..()

/decl/chemical_reaction/instant/slime/grey_monkey
	name = "Slime Monkey"
	id = "m_monkey"
	result = null
	required_reagents = list(REAGENT_ID_BLOOD = 5)
	result_amount = 1
	required = /obj/item/slime_extract/grey

/decl/chemical_reaction/instant/slime/grey_monkey/on_reaction(var/datum/reagents/holder)
	for(var/i = 1 to 4)
		new /obj/item/reagent_containers/food/snacks/monkeycube(get_turf(holder.my_atom))
	..()

/decl/chemical_reaction/instant/slime/grey_slimejelly
	name = REAGENT_SLIMEJELLY
	id = "m_jelly"
	result = REAGENT_ID_SLIMEJELLY
	required_reagents = list(REAGENT_ID_PERIDAXON = 5)
	result_amount = 15
	required = /obj/item/slime_extract/grey

// ****************
// * Metal slimes *
// ****************


/obj/item/slime_extract/metal
	name = "metal slime extract"
	icon_state = "metal slime extract"
	description_info = "This extract will create a metamorphic liquid which will transform into metallic liquid it comes into contact with, when injected with phoron.  \
	It can also create a metallic binding liquid which will force metallic liquids to mix to form alloys when solified, when injected with water."

// 'Duplicates' liquid metals, consuming itself in the process.
/datum/reagent/toxin/metamorphic_metal
	name = REAGENT_METAMORPHIC
	id = REAGENT_ID_METAMORPHIC
	description = "A strange metallic liquid which can rearrange itself to take the form of other metals it touches."
	taste_description = "metallic"
	taste_mult = 1.1
	reagent_state = LIQUID
	color = "#666666"
	strength = 20

/decl/chemical_reaction/instant/slime/metal_metamorphic
	name = "Slime Metal"
	id = "m_metal"
	required_reagents = list(REAGENT_ID_PHORON = 5)
	result = REAGENT_ID_METAMORPHIC
	result_amount = REAGENTS_PER_SHEET // Makes enough to make one sheet of any metal.
	required = /obj/item/slime_extract/metal


/decl/chemical_reaction/instant/metamorphic
	result_amount = REAGENTS_PER_SHEET * 2


/obj/item/reagent_containers/glass/bottle/metamorphic
	name = "Metamorphic Metal Bottle"
	desc = "A small bottle. Contains some really weird liquid metal."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-4"
	prefill = list(REAGENT_ID_METAMORPHIC = 60)


// This is kind of a waste since iron is in the chem dispenser but it would be inconsistent if this wasn't here.
/decl/chemical_reaction/instant/metamorphic/iron
	name = "Morph into Iron"
	id = "morph_iron"
	required_reagents = list(REAGENT_ID_METAMORPHIC = REAGENTS_PER_SHEET, REAGENT_ID_IRON = REAGENTS_PER_SHEET)
	result = REAGENT_ID_IRON


/decl/chemical_reaction/instant/metamorphic/silver
	name = "Morph into Silver"
	id = "morph_silver"
	required_reagents = list(REAGENT_ID_METAMORPHIC = REAGENTS_PER_SHEET, REAGENT_ID_SILVER = REAGENTS_PER_SHEET)
	result = REAGENT_ID_SILVER


/decl/chemical_reaction/instant/metamorphic/gold
	name = "Morph into Gold"
	id = "morph_gold"
	required_reagents = list(REAGENT_ID_METAMORPHIC = REAGENTS_PER_SHEET, REAGENT_ID_GOLD = REAGENTS_PER_SHEET)
	result = REAGENT_ID_GOLD


/decl/chemical_reaction/instant/metamorphic/platinum
	name = "Morph into Platinum"
	id = "morph_platinum"
	required_reagents = list(REAGENT_ID_METAMORPHIC = REAGENTS_PER_SHEET, REAGENT_ID_PLATINUM = REAGENTS_PER_SHEET)
	result = REAGENT_ID_PLATINUM


/decl/chemical_reaction/instant/metamorphic/uranium
	name = "Morph into Uranium"
	id = "morph_uranium"
	required_reagents = list(REAGENT_ID_METAMORPHIC = REAGENTS_PER_SHEET, REAGENT_ID_URANIUM = REAGENTS_PER_SHEET)
	result = REAGENT_ID_URANIUM


/decl/chemical_reaction/instant/metamorphic/phoron
	name = "Morph into Phoron"
	id = "morph_phoron"
	required_reagents = list(REAGENT_ID_METAMORPHIC = REAGENTS_PER_SHEET, REAGENT_ID_PHORON = REAGENTS_PER_SHEET)
	result = REAGENT_ID_PHORON


// Creates 'alloys' which can be finalized with frost oil.
/decl/chemical_reaction/instant/slime/metal_binding
	name = "Slime Binding"
	id = "m_binding"
	required_reagents = list(REAGENT_ID_WATER = 5)
	result = REAGENT_ID_BINDING
	result_amount = REAGENTS_PER_SHEET // Makes enough to make one sheet of any metal.
	required = /obj/item/slime_extract/metal


/datum/reagent/toxin/binding_metal
	name = REAGENT_BINDING
	id = REAGENT_ID_BINDING
	description = "A strange metallic liquid which can bind other metals together that would otherwise require intense heat to alloy."
	taste_description = "metallic"
	taste_mult = 1.1
	reagent_state = LIQUID
	color = "#666666"
	strength = 20

/obj/item/reagent_containers/glass/bottle/binding
	name = "Binding Metal Bottle"
	desc = "A small bottle. Contains some really weird liquid metal."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-4"
	prefill = list(REAGENT_ID_BINDING = 60)


/decl/chemical_reaction/instant/binding
	name = "Bind into Steel"
	id = "bind_steel"
	result = REAGENT_ID_STEEL
	required_reagents = list(REAGENT_ID_BINDING = REAGENTS_PER_SHEET, REAGENT_ID_IRON = REAGENTS_PER_SHEET, REAGENT_ID_CARBON = REAGENTS_PER_SHEET)
	result_amount = REAGENTS_PER_SHEET

/datum/reagent/steel
	name = REAGENT_STEEL
	id = REAGENT_ID_STEEL
	description = "An 'alloy' of iron and carbon, forced to bind together by another strange metallic liquid."
	taste_description = "metallic"
	reagent_state = LIQUID
	color = "#888888"


/decl/chemical_reaction/instant/binding/plasteel // Two parts 'steel', one part platnium matches the smelter alloy recipe.
	name = "Bind into Plasteel"
	id = "bind_plasteel"
	required_reagents = list(REAGENT_ID_BINDING = REAGENTS_PER_SHEET, REAGENT_ID_STEEL = REAGENTS_PER_SHEET * 2, REAGENT_ID_PLATINUM = REAGENTS_PER_SHEET)
	result = REAGENT_ID_PLASTEEL

/datum/reagent/plasteel
	name = REAGENT_PLASTEEL
	id = REAGENT_ID_PLASTEEL
	description = "An 'alloy' of iron, carbon, and platinum, forced to bind together by another strange metallic liquid."
	taste_description = "metallic"
	reagent_state = LIQUID
	color = "#AAAAAA"


// ***************
// * Blue slimes *
// ***************


/obj/item/slime_extract/blue
	name = "blue slime extract"
	icon_state = "blue slime extract"
	description_info = "This extract will create frost oil when injected with phoron, which can be used to solidify liquid metals.  \
	The extract can also create a slime stability agent when injected with blood, which reduces the odds of newly created slimes mutating into \
	a different color when a slime reproduces."

/decl/chemical_reaction/instant/slime/blue_frostoil
	name = "Slime Frost Oil"
	id = "m_frostoil"
	result = REAGENT_ID_FROSTOIL
	required_reagents = list(REAGENT_ID_PHORON = 5)
	result_amount = 20
	required = /obj/item/slime_extract/blue


/decl/chemical_reaction/instant/slime/blue_stability
	name = "Slime Stability"
	id = "m_stability"
	required_reagents = list(REAGENT_ID_BLOOD = 5)
	result_amount = 1
	required = /obj/item/slime_extract/blue

/decl/chemical_reaction/instant/slime/blue_stability/on_reaction(var/datum/reagents/holder)
	new /obj/item/slimepotion/stabilizer(get_turf(holder.my_atom))
	..()


// *****************
// * Purple slimes *
// *****************


/obj/item/slime_extract/purple
	name = "purple slime extract"
	icon_state = "purple slime extract"
	description_info = "This extract can create a slime steroid agent when injected with phoron, which increases the amount of slime extracts the processor \
	can extract from a slime specimen."


/decl/chemical_reaction/instant/slime/purple_steroid
	name = "Slime Steroid"
	id = "m_steroid"
	required_reagents = list(REAGENT_ID_PHORON = 5)
	result_amount = 1
	required = /obj/item/slime_extract/purple

/decl/chemical_reaction/instant/slime/purple_steroid/on_reaction(var/datum/reagents/holder)
	new /obj/item/slimepotion/steroid(get_turf(holder.my_atom))
	..()


// *****************
// * Orange slimes *
// *****************


/obj/item/slime_extract/orange
	name = "orange slime extract"
	icon_state = "orange slime extract"
	description_info = "This extract creates a fire when injected with phoron, after a five second delay."

/decl/chemical_reaction/instant/slime/orange_fire
	name = "Slime Fire"
	id = "m_fire"
	required_reagents = list(REAGENT_ID_PHORON = 5)
	result_amount = 1
	required = /obj/item/slime_extract/orange

/decl/chemical_reaction/instant/slime/orange_fire/on_reaction(var/datum/reagents/holder)
	log_and_message_admins("Orange extract reaction (fire) has been activated in [get_area(holder.my_atom)].  Last fingerprints: [holder.my_atom.fingerprintslast]")
	holder.my_atom.visible_message(span_danger("\The [src] begins to vibrate violently!"))
	playsound(holder.my_atom, 'sound/effects/phasein.ogg', 75, 1)
	spawn(5 SECONDS)
		if(holder && holder.my_atom)
			var/turf/simulated/T = get_turf(holder.my_atom)
			if(!istype(T))
				return

			for(var/turf/simulated/target_turf in view(2, T))
				target_turf.assume_gas(GAS_VOLATILE_FUEL, 33, 1500+T0C)
				target_turf.assume_gas(GAS_O2, 66, 1500+T0C)
				spawn(0)
					target_turf.hotspot_expose(1500+T0C, 400)

			playsound(T, 'sound/effects/phasein.ogg', 75, 1)
	..()


// *****************
// * Yellow slimes *
// *****************

/obj/item/slime_extract/yellow
	name = "yellow slime extract"
	icon_state = "yellow slime extract"
	description_info = "This extract will create a special 10k capacity power cell that self recharges slowly over time, when injected with phoron.  \
	When injected with blood, it will create a glob of slime which glows brightly.  If injected with water, it will emit a strong EMP, after a five second delay."

/decl/chemical_reaction/instant/slime/yellow_emp
	name = "Slime EMP"
	id = "m_emp"
	required_reagents = list(REAGENT_ID_WATER = 5)
	result_amount = 1
	required = /obj/item/slime_extract/yellow

/decl/chemical_reaction/instant/slime/yellow_emp/on_reaction(var/datum/reagents/holder)
	log_and_message_admins("Yellow extract reaction (emp) has been activated in [get_area(holder.my_atom)].  Last fingerprints: [holder.my_atom.fingerprintslast]")
	holder.my_atom.visible_message(span_danger("\The [src] begins to vibrate violently!"))
	playsound(holder.my_atom, 'sound/effects/phasein.ogg', 75, 1)
	spawn(5 SECONDS)
		if(holder && holder.my_atom)
			empulse(get_turf(holder.my_atom), 2, 4, 7, 10) // As strong as a normal EMP grenade.
			playsound(holder.my_atom, 'sound/effects/phasein.ogg', 75, 1)
	..()


/decl/chemical_reaction/instant/slime/yellow_battery
	name = "Slime Cell"
	id = "m_cell"
	required_reagents = list(REAGENT_ID_PHORON = 5)
	result_amount = 1
	required = /obj/item/slime_extract/yellow

/decl/chemical_reaction/instant/slime/yellow_battery/on_reaction(var/datum/reagents/holder)
	new /obj/item/cell/slime(get_turf(holder.my_atom))
	..()


/decl/chemical_reaction/instant/slime/yellow_flashlight
	name = "Slime Flashlight"
	id = "m_flashlight"
	required_reagents = list(REAGENT_ID_BLOOD = 5)
	result_amount = 1
	required = /obj/item/slime_extract/yellow

/decl/chemical_reaction/instant/slime/yellow_flashlight/on_reaction(var/datum/reagents/holder)
	new /obj/item/flashlight/slime(get_turf(holder.my_atom))
	..()

// ***************
// * Gold slimes *
// ***************

/obj/item/slime_extract/gold
	name = "gold slime extract"
	icon_state = "gold slime extract"
	description_info = "This extract will create 5u liquid gold when injected with phoron."


/decl/chemical_reaction/instant/slime/gold_gold
	name = "Slime Gold"
	id = "m_gold"
	result = REAGENT_ID_GOLD
	required_reagents = list(REAGENT_ID_PHORON = 5)
	result_amount = 5
	required = /obj/item/slime_extract/gold


// *****************
// * Silver slimes *
// *****************

/obj/item/slime_extract/silver
	name = "silver slime extract"
	icon_state = "silver slime extract"
	description_info = "This extract will create 5u liquid silver when injected with phoron."


/decl/chemical_reaction/instant/slime/silver_silver
	name = "Slime Silver"
	id = "m_silver"
	result = REAGENT_ID_SILVER
	required_reagents = list(REAGENT_ID_PHORON = 5)
	result_amount = 5
	required = /obj/item/slime_extract/silver


// **********************
// * Dark Purple slimes *
// **********************


/obj/item/slime_extract/dark_purple
	name = "dark purple slime extract"
	icon_state = "dark purple slime extract"
	description_info = "This extract will create 40u liquid phoron when injected with water."


/decl/chemical_reaction/instant/slime/dark_purple_phoron
	name = "Slime Phoron"
	id = "m_phoron_harvest"
	result = REAGENT_ID_PHORON
	required_reagents = list(REAGENT_ID_WATER = 5)
	result_amount = REAGENTS_PER_SHEET * 2
	required = /obj/item/slime_extract/dark_purple


// ********************
// * Dark Blue slimes *
// ********************


/obj/item/slime_extract/dark_blue
	name = "dark blue slime extract"
	icon_state = "dark blue slime extract"
	description_info = "This extract will massively lower the temperature of the surrounding atmosphere when injected with phoron.  \
	Slimes will suffer massive harm from the cold snap and most colors will die instantly.  Other entities are also chilled, however \
	cold-resistant armor like winter coats can protect from this.  Note that the user is not immune to the extract's effects."


/decl/chemical_reaction/instant/slime/dark_blue_cold_snap
	name = "Slime Cold Snap"
	id = "m_cold_snap"
	required_reagents = list(REAGENT_ID_PHORON = 5)
	result_amount = 1
	required = /obj/item/slime_extract/dark_blue

// This iterates over a ZAS zone's contents, so that things seperated in other zones aren't subjected to the temperature drop.
/decl/chemical_reaction/instant/slime/dark_blue_cold_snap/on_reaction(var/datum/reagents/holder)
	var/turf/simulated/T = get_turf(holder.my_atom)
	if(!T) // Nullspace lacks zones.
		return

	if(!istype(T))
		return

	var/zone/Z = T.zone
	if(!Z) // Paranoid.
		return

	log_and_message_admins("Dark Blue extract reaction (cold snap) has been activated in [get_area(holder.my_atom)].  Last fingerprints: [holder.my_atom.fingerprintslast]")

	var/list/nearby_things = view(T)

	// Hurt mobs.
	for(var/mob/living/L in nearby_things)
		var/turf/simulated/their_turf = get_turf(L)
		if(!istype(their_turf)) // Not simulated.
			continue

		if(!(their_turf in Z.contents)) // Not in the same zone.
			continue

		if(istype(L, /mob/living/simple_mob/slime))
			var/mob/living/simple_mob/slime/S = L
			if(S.cold_resist >= 1) // Immune to cold.
				to_chat(S, span_warning("A chill is felt around you, however it cannot harm you."))
				continue
			if(S.client) // Don't instantly kill player slimes.
				to_chat(S, span_danger("You feel your body crystalize as an intense chill overwhelms you!"))
				S.inflict_cold_damage(100)
			else
				S.inflict_cold_damage(200) // Metal slimes can survive this 'slime nuke'.
			continue

		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			var/protection = H.get_cold_protection()

			if(protection < 1)
				var/cold_factor = abs(protection - 1)
				H.bodytemperature = between(50, (H.bodytemperature - ((H.bodytemperature - 50) * cold_factor) ), H.bodytemperature)

			if(protection < 0.7)
				to_chat(L, span_danger("A chilling wave of cold overwhelms you!"))
			else
				to_chat(L, span_warning("A chilling wave of cold passes by you, as your armor protects you from it."))
			continue

	// Now make it very cold.
	var/datum/gas_mixture/env = T.return_air()
	if(env)
		// This is most likely physically impossible but when has that stopped slimes before?
		env.add_thermal_energy(-10 * 1000 * 1000) // For a moderately sized room this doesn't actually lower it that much.

	playsound(T, 'sound/effects/phasein.ogg', 75, 1)

	..()


// **************
// * Red slimes *
// **************

/obj/item/slime_extract/red
	name = "red slime extract"
	icon_state = "red slime extract"
	description_info = "This extract will create a slime mutator agent when injected with phoron, which increases a slime's odds of mutating \
	into a different color when reproducing by 12%.  Injecting with blood causes all slimes that can see the user to enrage, becoming very violent and \
	out of control."


/decl/chemical_reaction/instant/slime/red_enrage
	name = "Slime Enrage"
	id = "m_enrage"
	required_reagents = list(REAGENT_ID_BLOOD = 5)
	result_amount = 1
	required = /obj/item/slime_extract/red

/decl/chemical_reaction/instant/slime/red_enrage/on_reaction(var/datum/reagents/holder)
	for(var/mob/living/simple_mob/slime/S in view(get_turf(holder.my_atom)))
		if(S.stat)
			continue

		if(istype(S, /mob/living/simple_mob/slime/xenobio))
			var/mob/living/simple_mob/slime/xenobio/X = S
			if(X.harmless)
				continue
			if(!X.client)
				X.enrage()

		S.add_modifier(/datum/modifier/berserk, 30 SECONDS)

		if(S.client) // Player slimes always have free will.
			to_chat(S, span_warning("An intense wave of rage is felt from inside, but you remain in control of yourself."))

	for(var/mob/living/carbon/human/H in view(get_turf(holder.my_atom)))
		if(H.species.name == SPECIES_PROMETHEAN)
			H.add_modifier(/datum/modifier/berserk, 30 SECONDS)
			to_chat(H, span_warning("An intense wave of rage is felt from inside, but you remain in control of yourself."))

	log_and_message_admins("Red extract reaction (enrage) has been activated in [get_area(holder.my_atom)].  Last fingerprints: [holder.my_atom.fingerprintslast]")

	playsound(holder.my_atom, 'sound/effects/phasein.ogg', 75, 1)
	..()



/decl/chemical_reaction/instant/slime/red_mutation
	name = "Slime Mutation"
	id = "m_mutation"
	required_reagents = list(REAGENT_ID_PHORON = 5)
	result_amount = 1
	required = /obj/item/slime_extract/red

/decl/chemical_reaction/instant/slime/red_mutation/on_reaction(var/datum/reagents/holder)
	new /obj/item/slimepotion/mutator(get_turf(holder.my_atom))
	..()

// ***************
// * Green slime *
// ***************

/obj/item/slime_extract/green
	name = "green slime extract"
	icon_state = "green slime extract"
	description_info = "This extract will create 5u of liquid uranium when injected with phoron."

/decl/chemical_reaction/instant/slime/green_uranium
	name = "Slime Uranium"
	id = "m_uranium"
	result = REAGENT_ID_URANIUM
	required_reagents = list(REAGENT_ID_PHORON = 5)
	result_amount = 5
	required = /obj/item/slime_extract/green


// ***************
// * Pink slimes *
// ***************

/obj/item/slime_extract/pink
	name = "pink slime extract"
	icon_state = "pink slime extract"
	description_info = "This extract will create 30u of blood clotting agent if injected with blood.  It can also create 30u of bone binding agent if injected \
	with phoron.  When injected with water, it will create an organ-mending agent.  The slime medications have a very low threshold for overdosage, however."


/decl/chemical_reaction/instant/slime/pink_clotting
	name = "Slime Clotting Med"
	id = "m_clotting"
	result = REAGENT_ID_SLIMEBLEEDFIXER
	required_reagents = list(REAGENT_ID_BLOOD = 5)
	result_amount = 30
	required = /obj/item/slime_extract/pink


/decl/chemical_reaction/instant/slime/pink_bone_fix
	name = "Slime Bone Med"
	id = "m_bone_fixer"
	result = REAGENT_ID_SLIMEBONEFIXER
	required_reagents = list(REAGENT_ID_PHORON = 5)
	result_amount = 30
	required = /obj/item/slime_extract/pink


/decl/chemical_reaction/instant/slime/pink_organ_fix
	name = "Slime Organ Med"
	id = "m_organ_fixer"
	result = REAGENT_ID_SLIMEORGANFIXER
	required_reagents = list(REAGENT_ID_WATER = 5)
	result_amount = 30
	required = /obj/item/slime_extract/pink


/datum/reagent/myelamine/slime
	name = REAGENT_SLIMEBLEEDFIXER
	id = REAGENT_ID_SLIMEBLEEDFIXER
	description = "A slimy liquid which appears to rapidly clot internal hemorrhages by increasing the effectiveness of platelets at low quantities.  Toxic in high quantities."
	taste_description = "slime"
	overdose = 5
	wiki_flag = WIKI_SPOILER

/datum/reagent/osteodaxon/slime
	name = REAGENT_SLIMEBONEFIXER
	id = REAGENT_ID_SLIMEBONEFIXER
	description = "A slimy liquid which can be used to heal bone fractures at low quantities.  Toxic in high quantities."
	taste_description = "slime"
	overdose = 5
	wiki_flag = WIKI_SPOILER

/datum/reagent/peridaxon/slime
	name = REAGENT_SLIMEORGANFIXER
	id = REAGENT_ID_SLIMEORGANFIXER
	description = "A slimy liquid which is used to encourage recovery of internal organs and nervous systems in low quantities.  Toxic in high quantities."
	taste_description = "slime"
	overdose = 5
	wiki_flag = WIKI_SPOILER


// **************
// * Oil slimes *
// **************

/obj/item/slime_extract/oil
	name = "oil slime extract"
	icon_state = "oil slime extract"
	description_info = "This extract cause a moderately sized delayed explosion if injected with phoron.  The delay is five seconds.  Extract enhancers will \
	increase the power of the explosion instead of allowing for multiple explosions."


/decl/chemical_reaction/instant/slime/oil_griff
	name = "Slime Explosion"
	id = "m_boom"
	required_reagents = list(REAGENT_ID_BLOOD = 5)
	result_amount = 1
	required = /obj/item/slime_extract/oil


/decl/chemical_reaction/instant/slime/oil_griff/on_reaction(var/datum/reagents/holder)
	..()
	var/obj/item/slime_extract/E = holder.my_atom
	var/power = 1
	if(E.enhanced)
		power++
	E.uses = 0

	playsound(holder.my_atom, 'sound/effects/phasein.ogg', 75, 1)
	holder.my_atom.visible_message(span_danger("\The [holder.my_atom] begins to vibrate violently!"))
	log_and_message_admins("Oil extract reaction (explosion) has been activated in [get_area(holder.my_atom)].  Last fingerprints: [holder.my_atom.fingerprintslast]")

	spawn(5 SECONDS)
		if(holder && holder.my_atom)
			explosion(get_turf(holder.my_atom), 1 * power, 3 * power, 6 * power)

		if(holder && holder.my_atom) // Explosion may or may not have deleted the extract.
			qdel(holder.my_atom)

// ********************
// * Bluespace slimes *
// ********************

/obj/item/slime_extract/bluespace
	name = "bluespace slime extract"
	icon_state = "bluespace slime extract"
	description_info = "This extract creates slime crystals.  When injected with water, it creates five 'lesser' slime crystals, which allow for limited \
	short ranged, random teleporting.  When injected with phoron, it creates one 'greater' slime crystal, which allows for a one time precise teleport to \
	a specific area."

/decl/chemical_reaction/instant/slime/bluespace_lesser
	name = "Slime Lesser Tele"
	id = "m_tele_lesser"
	required_reagents = list(REAGENT_ID_WATER = 5)
	result_amount = 1
	required = /obj/item/slime_extract/bluespace

/decl/chemical_reaction/instant/slime/bluespace_lesser/on_reaction(var/datum/reagents/holder)
	for(var/i = 1 to 5)
		new /obj/item/slime_crystal(get_turf(holder.my_atom))
	..()

/decl/chemical_reaction/instant/slime/bluespace_greater
	name = "Slime Greater Tele"
	id = "m_tele_lesser"
	required_reagents = list(REAGENT_ID_PHORON = 5)
	result_amount = 1
	required = /obj/item/slime_extract/bluespace

/decl/chemical_reaction/instant/slime/bluespace_greater/on_reaction(var/datum/reagents/holder)
	new /obj/item/disposable_teleporter/slime(get_turf(holder.my_atom))
	..()

// *******************
// * Cerulean slimes *
// *******************

/obj/item/slime_extract/cerulean
	name = "cerulean slime extract"
	icon_state = "cerulean slime extract"
	description_info = "This extract creates a slime extract enhancer agent, when injected with phoron.  The agent allows an extract to have more \
	'charges' before it goes inert."


/decl/chemical_reaction/instant/slime/cerulean_enhancer
	name = "Slime Enhancer"
	id = "m_enhancer"
	required_reagents = list(REAGENT_ID_PHORON = 5)
	result_amount = 1
	required = /obj/item/slime_extract/cerulean

/decl/chemical_reaction/instant/slime/cerulean_enhancer/on_reaction(var/datum/reagents/holder)
	new /obj/item/slimepotion/enhancer(get_turf(holder.my_atom))
	..()

// ****************
// * Amber slimes *
// ****************

/obj/item/slime_extract/amber
	name = "amber slime extract"
	icon_state = "amber slime extract"
	description_info = "This extract creates a slime feeding agent when injected with phoron, which will instantly feed the slime and make it reproduce.  When \
	injected with water, it will create a very delicious and filling product."


/decl/chemical_reaction/instant/slime/amber_slimefood
	name = "Slime Feeding"
	id = "m_slime_food"
	required_reagents = list(REAGENT_ID_PHORON = 5)
	result_amount = 1
	required = /obj/item/slime_extract/amber

/decl/chemical_reaction/instant/slime/amber_slimefood/on_reaction(var/datum/reagents/holder)
	new /obj/item/slimepotion/feeding(get_turf(holder.my_atom))
	..()


/decl/chemical_reaction/instant/slime/amber_peoplefood
	name = "Slime Food"
	id = "m_people_food"
	required_reagents = list(REAGENT_ID_WATER = 5)
	result_amount = 1
	required = /obj/item/slime_extract/amber

/decl/chemical_reaction/instant/slime/amber_peoplefood/on_reaction(var/datum/reagents/holder)
	new /obj/item/reagent_containers/food/snacks/slime(get_turf(holder.my_atom))
	..()


// *******************
// * Sapphire slimes *
// *******************
// Renamed from adamantine.

/obj/item/slime_extract/sapphire
	name = "sapphire slime extract"
	icon_state = "sapphire slime extract"
	description_info = "This extract will create one 'slime cube' when injected with phoron.  The slime cube is needed to create a Promethean."


/decl/chemical_reaction/instant/slime/sapphire_promethean
	name = "Slime Promethean"
	id = "m_promethean"
	required_reagents = list(REAGENT_ID_PHORON = 5)
	result_amount = 1
	required = /obj/item/slime_extract/sapphire

/decl/chemical_reaction/instant/slime/sapphire_promethean/on_reaction(var/datum/reagents/holder)
	new /obj/item/slime_cube(get_turf(holder.my_atom))
	..()

// ***************
// * Ruby slimes *
// ***************

/obj/item/slime_extract/ruby
	name = "ruby slime extract"
	icon_state = "ruby slime extract"
	description_info = "This extract will cause all entities close to the extract to become stronger for ten minutes, when injected with phoron.  \
	When injected with blood, makes a slime loyalty agent which will make the slime fight other dangerous entities but not station crew."

/decl/chemical_reaction/instant/slime/ruby_swole
	name = "Slime Strength"
	id = "m_strength"
	required_reagents = list(REAGENT_ID_PHORON = 5)
	result_amount = 1
	required = /obj/item/slime_extract/ruby

/decl/chemical_reaction/instant/slime/ruby_swole/on_reaction(var/datum/reagents/holder)
	for(var/mob/living/L in range(1, holder.my_atom))
		L.add_modifier(/datum/modifier/slime_strength, 10 MINUTES, src)
	..()


/datum/modifier/slime_strength
	name = "slime strength"
	desc = "You feel much stronger than usual."
	mob_overlay_state = "pink_sparkles"

	on_created_text = span_warning("Twinkling spores of goo surround you.  It makes you feel stronger and more robust.")
	on_expired_text = span_notice("The spores of goo have faded, and you feel your strength returning to what it was before.")
	stacks = MODIFIER_STACK_EXTEND

	max_health_flat = 50
	outgoing_melee_damage_percent = 2
	disable_duration_percent = 0.5
	incoming_damage_percent = 0.75


/decl/chemical_reaction/instant/slime/ruby_loyalty
	name = "Slime Loyalty"
	id = "m_strength"
	required_reagents = list(REAGENT_ID_BLOOD = 5)
	result_amount = 1
	required = /obj/item/slime_extract/ruby

/decl/chemical_reaction/instant/slime/ruby_loyalty/on_reaction(var/datum/reagents/holder)
	new /obj/item/slimepotion/loyalty(get_turf(holder.my_atom))
	..()


// *****************
// * Emerald slime *
// *****************

/obj/item/slime_extract/emerald
	name = "emerald slime extract"
	icon_state = "emerald slime extract"
	description_info = "This extract will cause all entities close to the extract to become more agile for ten minutes, when injected with phoron."

/decl/chemical_reaction/instant/slime/emerald_fast
	name = "Slime Agility"
	id = "m_agility"
	required_reagents = list(REAGENT_ID_PHORON = 5)
	result_amount = 1
	required = /obj/item/slime_extract/emerald

/decl/chemical_reaction/instant/slime/emerald_fast/on_reaction(var/datum/reagents/holder)
	for(var/mob/living/L in range(1, holder.my_atom))
		L.add_modifier(/datum/modifier/slime_agility, 10 MINUTES, src)
	..()

/datum/modifier/slime_agility
	name = "slime agility"
	desc = "You feel much faster than usual."
	mob_overlay_state = "green_sparkles"

	on_created_text = span_warning("Twinkling spores of goo surround you.  It makes you feel fast and more agile.")
	on_expired_text = span_notice("The spores of goo have faded, and you feel your agility returning to what it was before.")
	stacks = MODIFIER_STACK_EXTEND

	evasion = 30
	slowdown = -1
	attack_speed_percent = 0.75


// *********************
// * Light Pink slimes *
// *********************

/obj/item/slime_extract/light_pink
	name = "light pink slime extract"
	icon_state = "light pink slime extract"
	description_info = "This extract creates a slime docility agent when injected with water, which will make the slime be harmless forever.  \
	When injected with phoron, it instead creates a slime friendship agent, which makes the slime consider the user their ally.  The agent \
	might be useful on other specimens as well."

/decl/chemical_reaction/instant/slime/light_pink_docility
	name = "Slime Docility"
	id = "m_docile"
	required_reagents = list(REAGENT_ID_WATER = 5)
	result_amount = 1
	required = /obj/item/slime_extract/light_pink

/decl/chemical_reaction/instant/slime/light_pink_docility/on_reaction(var/datum/reagents/holder)
	new /obj/item/slimepotion/docility(get_turf(holder.my_atom))
	..()


/decl/chemical_reaction/instant/slime/light_pink_friendship
	name = "Slime Friendship"
	id = "m_friendship"
	required_reagents = list(REAGENT_ID_PHORON = 5)
	result_amount = 1
	required = /obj/item/slime_extract/light_pink

/decl/chemical_reaction/instant/slime/light_pink_friendship/on_reaction(var/datum/reagents/holder)
	new /obj/item/slimepotion/friendship(get_turf(holder.my_atom))
	..()


// ******************
// * Rainbow slimes *
// ******************


/obj/item/slime_extract/rainbow
	name = "rainbow slime extract"
	icon_state = "rainbow slime extract"
	description_info = "This extract will create a baby slime of a random color when injected with phoron, or a slime unification agent if injected with water, \
	which makes slimes stop attacking other slime colors."


/decl/chemical_reaction/instant/slime/rainbow_random_slime
	name = "Slime Random Slime"
	id = "m_rng_slime"
	required_reagents = list(REAGENT_ID_PHORON = 5)
	result_amount = 1
	required = /obj/item/slime_extract/rainbow


/decl/chemical_reaction/instant/slime/rainbow_random_slime/on_reaction(var/datum/reagents/holder)
	var/mob/living/simple_mob/slime/xenobio/S
	var/list/slime_types = typesof(/mob/living/simple_mob/slime/xenobio)

	while(slime_types.len)
		S = pick(slime_types)
		if(initial(S.rainbow_core_candidate) == TRUE)
			break
		else
			slime_types -= S
			S = null

	if(S)
		new S(get_turf(holder.my_atom))
	..()

/decl/chemical_reaction/instant/slime/rainbow_unity
	name = "Slime Unity"
	id = "m_unity"
	required_reagents = list(REAGENT_ID_WATER = 5)
	result_amount = 1
	required = /obj/item/slime_extract/rainbow

/decl/chemical_reaction/instant/slime/rainbow_unity/on_reaction(var/datum/reagents/holder)
	new /obj/item/slimepotion/unity(get_turf(holder.my_atom))
	..()
