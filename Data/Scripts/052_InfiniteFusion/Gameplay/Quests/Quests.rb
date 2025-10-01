def define_quest(quest_id,quest_type,quest_name,quest_description,quest_location,npc_sprite)
  case quest_type
  when :HOTEL_QUEST
    text_color = HotelQuestColor
  when :FIELD_QUEST
    text_color = FieldQuestColor
  when :LEGENDARY_QUEST
    text_color = LegendaryQuestColor
  when :ROCKET_QUEST
    text_color = TRQuestColor
  end
  new_quest = Quest.new(quest_id, quest_name, quest_description, npc_sprite, quest_location, quest_location, text_color)
  QUESTS[quest_id] = new_quest
end

QUESTS = {
    #Pokemart
    "pokemart_johto" => Quest.new("pokemart_johto", _INTL("Johto Pokémon"), _INTL("A traveler in the PokéMart wants you to show him a Pokémon native to the Johto region."), "traveler_johto", _INTL("Cerulean City"), HotelQuestColor),
    "pokemart_hoenn" => Quest.new("pokemart_hoenn", _INTL("Hoenn Pokémon"), _INTL("A traveler in the PokéMart you to show him a Pokémon native to the Hoenn region."), "traveler_hoenn", _INTL("Vermillion City"), HotelQuestColor),
    "pokemart_sinnoh" => Quest.new("pokemart_sinnoh", _INTL("Sinnoh Pokémon"), _INTL("A traveler in the Department Center wants you to show him a Pokémon native to the Sinnoh region."), "traveler_sinnoh", _INTL("Celadon City"), HotelQuestColor),
    "pokemart_unova" => Quest.new( "pokemart_unova", _INTL("Unova Pokémon"), _INTL("A traveler in the PokéMart wants you to show him a Pokémon native to the Unova region."), "traveler_unova", _INTL("Fuchsia City"), HotelQuestColor),
    "pokemart_kalos" => Quest.new("pokemart_kalos", _INTL("Kalos Pokémon"), _INTL("A traveler in the PokéMart wants you to show him a Pokémon native to the Kalos region."), "traveler_kalos", _INTL("Saffron City"), HotelQuestColor),
    "pokemart_alola" => Quest.new("pokemart_alola", _INTL("Alola Pokémon"), _INTL("A traveler in the PokéMart wants you to show him a Pokémon native to the Alola region."), "traveler_alola", _INTL("Cinnabar Island"), HotelQuestColor),


    #Pewter hotel
    "pewter_1" => Quest.new("pewter_1", _INTL("Mushroom Gathering"), _INTL("A lady in Pewter City wants you to bring her 3 TinyMushroom from Viridian Forest to make a stew."), "BW (74)", _INTL("Pewter City"), HotelQuestColor),
    "pewter_2" =>Quest.new("pewter_2", _INTL("Lost Medicine"), _INTL("A youngster in Pewter City needs your help to find a lost Revive. He lost it by sitting on a bench somewhere in Pewter City."), "BW (19)", _INTL("Pewter City"), HotelQuestColor),
    "pewter_3" =>Quest.new("pewter_3", _INTL("Bug Evolution "), _INTL("A Bug Catcher in Pewter City wants you to show him a fully-evolved Bug Pokémon."), "BWBugCatcher_male", _INTL("Pewter City"), HotelQuestColor),
    "pewter_field_1" => Quest.new("pewter_field_1", _INTL("Nectar garden"), _INTL("An old man wants you to bring differently colored flowers for the city's garden."),  "BW (039)", _INTL("Pewter City"), FieldQuestColor),
    "pewter_field_2" => Quest.new("pewter_field_2", _INTL("I Choose You!"), _INTL("A Pikachu in the PokéMart has lost its official Pokémon League Hat. Find one and give it to the Pikachu!"),  "YOUNGSTER_LeagueHat", _INTL("Pewter City"), FieldQuestColor),
    "pewter_field_3" => Quest.new("pewter_field_3", _INTL("Prehistoric Amber!"), _INTL("Meetup with a scientist in Viridian Forest to look for prehistoric amber."),  "BW (82)", _INTL("Pewter City"), FieldQuestColor),

    #Cerulean hotel
    "cerulean_1" => Quest.new("cerulean_1", _INTL("Playing Cupid"), _INTL("A boy in Cerulean City wants you bring a love letter to a Pokémon Breeder named Maude. She's probably somewhere in one of the routes near Cerulean City"), "BW (18)", _INTL("Cerulean City"), HotelQuestColor),
    "cerulean_2" => Quest.new("cerulean_2", _INTL("Type Experts"), _INTL("Defeat all of the Type Experts scattered around the Kanto region ({1}/{2})",pbGet(VAR_TYPE_EXPERTS_BEATEN),TOTAL_NB_TYPE_EXPERTS), "expert-normal", _INTL("Cerulean City"), HotelQuestColor),

    #Route 24
    "cerulean_field_1" => Quest.new("cerulean_field_1", _INTL("Field Research (Part 1)"), _INTL("Professor Oak's aide wants you to catch an Abra."),  "BW (82)", _INTL("Route 24"), FieldQuestColor),
    "cerulean_field_2" => Quest.new("cerulean_field_2", _INTL("Field Research (Part 2)"), _INTL("Professor Oak's aide wants you to encounter every Pokémon on Route 24."),  "BW (82)", _INTL("Route 24"), FieldQuestColor),
    "cerulean_field_3" => Quest.new("cerulean_field_3", _INTL("Field Research (Part 3)"), _INTL("Professor Oak's aide wants you to catch a Buneary using the Pokéradar."),  "BW (82)", _INTL("Route 24"), FieldQuestColor),

    #Vermillion City
    "vermillion_2" => Quest.new("vermillion_2", _INTL("Fishing for Sole"), _INTL("A fisherman wants you to fish up an old boot. Hook it up with the old rod in any body of water."), "BW (71)", _INTL("Cerulean City"), HotelQuestColor),
    "vermillion_1" => Quest.new("vermillion_1", _INTL("Unusual Types 1"), _INTL("A woman at the hotel wants you to show her a Water/Fire-type Pokémon"), "BW (58)", _INTL("Vermillion City"), HotelQuestColor),
    "vermillion_3" => Quest.new("vermillion_3", _INTL("Seafood Cocktail "), _INTL("Get some steamed Krabby legs from the S.S. Anne's kitchen and bring them back to the hotel before they get cold"), "BW (36)", _INTL("Vermillion City"), HotelQuestColor),
    "vermillion_field_1" => Quest.new("vermillion_field_1", _INTL("Building Materials "), _INTL("Get some wooden planks from Viridian City and some Bricks from Pewter City."),  "BW (36)", _INTL("Vermillion City"), FieldQuestColor),
    "vermillion_field_2" => Quest.new("vermillion_field_2", _INTL("Waiter on the Water"), _INTL("The S.S. Anne waiter wants you to take restaurant orders while he went to get a replacement cake."),  "BW (53)", _INTL("S.S. Anne"), FieldQuestColor),

    #Celadon City
    "celadon_1" => Quest.new("celadon_1", _INTL("Sun or Moon"), _INTL("Show the Pokémon that Eevee evolves when exposed to a Moon or Sun stone to help the scientist with her research."), "BW (82)", _INTL("Celadon City"), HotelQuestColor),
    "celadon_2" => Quest.new("celadon_2", _INTL("For Whom the Bell Tolls"), _INTL("Ring Lavender Town's bell when the time is right to reveal its secret."), "BW (40)", _INTL("Lavender Town"), HotelQuestColor),
    "celadon_3" => Quest.new("celadon_3", _INTL("Hardboiled"), _INTL("A lady wants you to give her an egg to make an omelette."), "BW (24)", _INTL("Celadon City"), HotelQuestColor),
    "celadon_field_1" => Quest.new("celadon_field_1", _INTL("A stroll with Eevee!"), _INTL("Walk Eevee around for a while until it gets tired."),  "BW (37)", _INTL("Celadon City"), FieldQuestColor),

    #Fuchsia City
    "fuchsia_1" => Quest.new("fuchsia_1", _INTL("Bicycle Race!"), _INTL("Go meet the Cyclist at the bottom of Route 17 and beat her time up the Cycling Road!"), "BW032", _INTL("Cycling Road"), HotelQuestColor),
    "fuchsia_2" => Quest.new("fuchsia_2", _INTL("Lost Pokémon!"), _INTL("Find the lost Chansey's trainer!"), "113", _INTL("Fuchsia City"), HotelQuestColor),
    "fuchsia_3" => Quest.new("fuchsia_3", _INTL("Cleaning up the Cycling Road"), _INTL("Get rid of all the Pokémon dirtying up the Cycling Road."), "BW (77)", _INTL("Fuchsia City"), HotelQuestColor),
    "fuchsia_4" => Quest.new("fuchsia_4", _INTL("Bitey Pokémon"), _INTL("A fisherman wants to know what is the sharp-toothed Pokémon that bit him in the Safari Zone's lake."), "BW (71)", _INTL("Fuchsia City"), HotelQuestColor),

    #Crimson City
    "crimson_1" => Quest.new("crimson_1", _INTL("Shellfish Rescue"), _INTL("Put all the stranded Shellders back in the water on the route to Crimson City."), "BW (48)", _INTL("Crimson City"), HotelQuestColor),
    "crimson_2" => Quest.new("crimson_2", _INTL("Fourth Round Rumble"), _INTL("Defeat Jeanette and her high-level Bellsprout in a Pokémon Battle"), "BW024", _INTL("Crimson City"), HotelQuestColor),
    "crimson_3" => Quest.new("crimson_3", _INTL("Unusual Types 2"), _INTL("A woman at the hotel wants you to show her a Normal/Ghost-type Pokémon"), "BW (58)", _INTL("Crimson City"), HotelQuestColor),
    "crimson_4" => Quest.new("crimson_4", _INTL("The Top of the Waterfall"), _INTL("Someone wants you to go investigate the top of a waterfall near Crimson City"), "BW (28)", _INTL("Crimson City"), HotelQuestColor),

    #Saffron City
    "saffron_1" => Quest.new("saffron_1", _INTL("Lost Puppies"), _INTL("Find all of the missing Growlithe in the routes around Saffron City."), "BW (73)", _INTL("Saffron City"), HotelQuestColor),
    "saffron_2" => Quest.new("saffron_2", _INTL("Invisible Pokémon"), _INTL("Find an invisible Pokémon in the eastern part of Saffron City."), "BW (57)", _INTL("Saffron City"), HotelQuestColor),
    "saffron_3" => Quest.new("saffron_3", _INTL("Bad to the Bone!"), _INTL("Find a Rare Bone using Rock Smash."), "BW (72)", _INTL("Saffron City"), HotelQuestColor),
    "saffron_field_1" => Quest.new("saffron_field_1", _INTL("Dancing Queen!"), _INTL("Dance with the Copycat Girl!"),  "BW (24)", _INTL("Saffron City (nightclub)"), FieldQuestColor),

    #Cinnabar Island
    "cinnabar_1" => Quest.new("cinnabar_1", _INTL("The transformation Pokémon"), _INTL("The scientist wants you to find some Quick Powder that can sometimes be found with wild Ditto in the mansion's basement."), "BW (82)", _INTL("Cinnabar Island"), HotelQuestColor),
    "cinnabar_2" => Quest.new("cinnabar_2", _INTL("Diamonds and Pearls"), _INTL("Find a Diamond Necklace to save the man's marriage."), "BW (71)", _INTL("Cinnabar Island"), HotelQuestColor),
    "cinnabar_3" => Quest.new("cinnabar_3", _INTL("Stolen artifact"), _INTL("Recover a stolen vase from a burglar in the Pokémon Mansion"), "BW (21)", _INTL("Cinnabar Island"), HotelQuestColor),

    #Goldenrod City
    "goldenrod_1" => Quest.new( "goldenrod_1", _INTL("Safari Souvenir!"), _INTL("Bring back a souvenir from the Fuchsia City Safari Zone"), "BW (28)", _INTL("Goldenrod City"), HotelQuestColor),
    "goldenrod_2" => Quest.new("goldenrod_2", _INTL("The Cursed Forest"), _INTL("A child wants you to find a floating tree stump in Ilex Forest. What could she be talking about?"), "BW109", _INTL("Goldenrod City"), HotelQuestColor),

    "goldenrod_police_1" => Quest.new("goldenrod_police_1", _INTL("Undercover police work!"), _INTL("Go see the police in Goldenrod City to help them with an important police operation."),  "BW (80)", _INTL("Goldenrod City"), FieldQuestColor),
    "pinkan_police" => Quest.new("pinkan_police", _INTL("Pinkan Island!"), _INTL("Team Rocket is planning a heist on Pinkan Island. You joined forces with the police to stop them!"),  "BW (80)", _INTL("Goldenrod City"), FieldQuestColor),

    #Violet City
    "violet_1" => Quest.new("violet_1", _INTL("Defuse the Pinecones!"), _INTL("Get rid of all the Pineco on Route 31 and Route 30"), "BW (64)", _INTL("Violet City"), HotelQuestColor),
    "violet_2" => Quest.new("violet_2", _INTL("Find Slowpoke's Tail!"), _INTL("Find a SlowpokeTail in some flowers, somewhere around Violet City!"), "BW (19)", _INTL("Violet City"), HotelQuestColor),

    #Blackthorn City
    "blackthorn_1" => Quest.new( "blackthorn_1", _INTL("Dragon Evolution"), _INTL("A Dragon Tamer in Blackthorn City wants you to show her a fully-evolved Dragon Pokémon."), "BW014", _INTL("Blackthorn City"), HotelQuestColor),
    "blackthorn_2" => Quest.new("blackthorn_2", _INTL("Sunken Treasure!"), _INTL("Find an old memorabilia on a sunken ship near Cinnabar Island."), "BW (28)", _INTL("Blackthorn City"), HotelQuestColor),
    "blackthorn_3" => Quest.new("blackthorn_3", _INTL("The Largest Carp"), _INTL("A fisherman wants you to fish up a Magikarp that's exceptionally high-level at Dragon's Den."), "BW (71)", _INTL("Blackthorn City"), HotelQuestColor),

    #Ecruteak City
    "ecruteak_1" => Quest.new("ecruteak_1", _INTL("Ghost Evolution"), _INTL("A girl in Ecruteak City wants you to show her a fully-evolved Ghost Pokémon."), "BW014", _INTL("Ecruteak City"), HotelQuestColor),

    #Kin Island
    "kin_1" => Quest.new("kin_1", _INTL("Banana Slamma!"), _INTL("Collect 30 bananas"), "BW059", _INTL("Kin Island"), HotelQuestColor),
    "kin_2" => Quest.new("kin_2", _INTL("Fallen Meteor"), _INTL("Investigate a crater near Bond Bridge."), "BW009", _INTL("Kin Island"), HotelQuestColor),
    "kin_field_1" => Quest.new("kin_field_1", _INTL("The rarest fish"), _INTL("A fisherman wants you to show him a Feebas. Apparently they can be fished around the Sevii Islands when it rains."),  "BW056", _INTL("Kin Island"), FieldQuestColor),

    "legendary_deoxys_1" => Quest.new("legendary_deoxys_1", _INTL("First Contact"), _INTL("Find the missing pieces of a fallen alien spaceship"), "BW (92)", _INTL("Bond Bridge"), LegendaryQuestColor),
    "legendary_deoxys_2" => Quest.new("legendary_deoxys_2", _INTL("First Contact (Part 2)"), _INTL("Ask the sailor at Cinnabar Island's harbour to take you to the uncharted island where the spaceship might be located"), "BW (92)", _INTL("Bond Bridge"), LegendaryQuestColor),

    #Necrozma quest
    "legendary_necrozma_1" => Quest.new("legendary_necrozma_1", _INTL("Mysterious prisms"), _INTL("You found a pedestal with a mysterious prism on it. There seems to be room for more prisms."), "BW_Sabrina", _INTL("Pokémon Tower"), LegendaryQuestColor),
    "legendary_necrozma_2" => Quest.new("legendary_necrozma_2", _INTL("The long night (Part 1)"), _INTL("A mysterious darkness has shrouded some of the region. Meet Sabrina outside of Saffron City's western gate to investigate."), "BW_Sabrina", _INTL("Lavender Town"), LegendaryQuestColor),
    "legendary_necrozma_3" => Quest.new("legendary_necrozma_1", _INTL("The long night (Part 2)"), _INTL("The mysterious darkness has expended. Meet Sabrina on top of Celadon City's Dept. Store to figure out the source of the darkness."), "BW_Sabrina", _INTL("Route 7"), LegendaryQuestColor),
    "legendary_necrozma_4" => Quest.new("legendary_necrozma_4", _INTL("The long night (Part 3)"), _INTL("Fuchsia City appears to be unaffected by the darkness. Go investigate to see if you can find out more information."), "BW_Sabrina", _INTL("Celadon City"), LegendaryQuestColor),
    "legendary_necrozma_5" => Quest.new("legendary_necrozma_5", _INTL("The long night (Part 4)"), _INTL("The mysterious darkness has expended yet again and strange plants have appeared. Follow the plants to see where they lead."), "BW_koga", _INTL("Fuchsia City"), LegendaryQuestColor),
    "legendary_necrozma_6" => Quest.new("legendary_necrozma_6", _INTL("The long night (Part 5)"), _INTL("You found a strange fruit that appears to be related to the mysterious darkness. Go see professor Oak to have it analyzed."), "BW029", _INTL("Safari Zone"), LegendaryQuestColor),
    "legendary_necrozma_7" => Quest.new("legendary_necrozma_7", _INTL("The long night (Part 6)"), _INTL("The strange plant you found appears to glow in the mysterious darkness that now covers the entire region. Try to follow the glow to find out the source of the disturbance."), "BW-oak", _INTL("Pallet Town"), LegendaryQuestColor),


    "legendary_meloetta_1" => Quest.new("legendary_meloetta_1", _INTL("A legendary band (Part 1)"), _INTL("The singer of a band in Saffron City wants you to help them recruit a drummer. They think they've heard some drumming around Crimson City..."), "BW107", _INTL("Saffron City"), LegendaryQuestColor),
    "legendary_meloetta_2" => Quest.new("legendary_meloetta_2", _INTL("A legendary band (Part 2)"), _INTL("The drummer from a legendary Pokéband wants you to find its former bandmates. The band manager talked about two former guitarists..."), "band_drummer", _INTL("Saffron City"), LegendaryQuestColor),
    "legendary_meloetta_3" => Quest.new("legendary_meloetta_3", _INTL("A legendary band (Part 3)"), _INTL("The drummer from a legendary Pokéband wants you to find its former bandmates. There are rumors about strange music that was heard around the region."), "band_drummer", _INTL("Saffron City"), LegendaryQuestColor),
    "legendary_meloetta_4" => Quest.new("legendary_meloetta_4", _INTL("A legendary band (Part 4)"), _INTL("You assembled the full band! Come watch the show on Saturday night."), "BW117", _INTL("Saffron City"), LegendaryQuestColor),

    "legendary_cresselia_1" => Quest.new(61, _INTL("Mysterious Lunar feathers"), _INTL("A mysterious entity asked you to collect Lunar Feathers for them. It said that they will come at night to tell you where to look. Whoever that may be..."), "lunarFeather", _INTL("Lavender Town"), LegendaryQuestColor),
    #removed
    #11 => Quest.new(11, "Powering the Lighthouse", "Catch some Voltorb to power up the lighthouse", QuestBranchHotels, "BW (43)", "Vermillion City", HotelQuestColor),
}

###################
# HOENN QUESTS   ##
# ################

#route 102
define_quest("route_102_rematch",:FIELD_QUEST,_INTL("Trainer Rematches"), _INTL("A lass you battled wants to switch up her team and rematch you!"),_INTL("Route 102"),"NPC_Hoenn_Lass")

    #Route 116
define_quest("route116_glasses",:FIELD_QUEST,_INTL("Lost glasses"), _INTL("A trainer has lost their glasses, help him find them!"),_INTL("Route 116"),"NPC_Hoenn_BugManiac")

#Route 104 (South)
define_quest("route104_rivalWeather",:FIELD_QUEST,_INTL("Weather Watch"), _INTL("Help your rival with fieldwork and find a Pokémon that only appears when it's windy!"),_INTL("Route 104"),"rival")

#Petalburg woods
define_quest("petalburgwoods_spores",:FIELD_QUEST,_INTL("Spores Harvest"), _INTL("A scientist has tasked you to collect 4 spore samples from the large mushrooms that can be found in the woods!"),_INTL("Petalburg Woods"),"NPC_Hoenn_Scientist")

#Route 104 (North)
define_quest("route104_oricorio",:FIELD_QUEST,_INTL("Special Flowery Grass"), _INTL("Find an Oricorio in the flowery grass behind the flower shop."),_INTL("Route 104"),"NPC_Hoenn_AromaLady")
define_quest("route104_oricorio_forms",:FIELD_QUEST,_INTL("Nectar Flowers"), _INTL("Find all 4 types of nectar flowers to transform Oricorio."),_INTL("Route 104"),"NPC_Hoenn_AromaLady")

#Route 115
define_quest("route115_secretBase",:FIELD_QUEST,_INTL("Your Very Own Secret Base!"), _INTL("Talk to Aarune near his secret base to learn how to make your own."),_INTL("Route 115"),"NPC_Hoenn_AromaLady")

#Rustboro
define_quest("rustboro_whismur",:FIELD_QUEST,_INTL("Volume Booster!"), _INTL("Find a Wingull to fuse with a Whismur to make it louder."),_INTL("Rustboro City"),"NPC_schoolgirl")
