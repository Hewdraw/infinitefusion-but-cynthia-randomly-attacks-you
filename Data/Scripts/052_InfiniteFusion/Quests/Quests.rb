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
    "pokemart_johto" => Quest.new("pokemart_johto", "Johto Pokémon", "A traveler in the PokéMart wants you to show him a Pokémon native to the Johto region.", QuestBranchHotels, "traveler_johto", "Cerulean City", HotelQuestColor),
    "pokemart_hoenn" => Quest.new("pokemart_hoenn", "Hoenn Pokémon", "A traveler in the PokéMart you to show him a Pokémon native to the Hoenn region.", QuestBranchHotels, "traveler_hoenn", "Vermillion City", HotelQuestColor),
    "pokemart_sinnoh" => Quest.new("pokemart_sinnoh", "Sinnoh Pokémon", "A traveler in the Department Center wants you to show him a Pokémon native to the Sinnoh region.", QuestBranchHotels, "traveler_sinnoh", "Celadon City", HotelQuestColor),
    "pokemart_unova" => Quest.new( "pokemart_unova", "Unova Pokémon", "A traveler in the PokéMart wants you to show him a Pokémon native to the Unova region.", QuestBranchHotels, "traveler_unova", "Fuchsia City", HotelQuestColor),
    "pokemart_kalos" => Quest.new("pokemart_kalos", "Kalos Pokémon", "A traveler in the PokéMart wants you to show him a Pokémon native to the Kalos region.", QuestBranchHotels, "traveler_kalos", "Saffron City", HotelQuestColor),
    "pokemart_alola" => Quest.new("pokemart_alola", "Alola Pokémon", "A traveler in the PokéMart wants you to show him a Pokémon native to the Alola region.", QuestBranchHotels, "traveler_alola", "Cinnabar Island", HotelQuestColor),


    #Pewter hotel
    "pewter_1" => Quest.new("pewter_1", "Mushroom Gathering", "A lady in Pewter City wants you to bring her 3 TinyMushroom from Viridian Forest to make a stew.", QuestBranchHotels, "BW (74)", "Pewter City", HotelQuestColor),
    "pewter_2" =>Quest.new("pewter_2", "Lost Medicine", "A youngster in Pewter City needs your help to find a lost Revive. He lost it by sitting on a bench somewhere in Pewter City.", QuestBranchHotels, "BW (19)", "Pewter City", HotelQuestColor),
    "pewter_3" =>Quest.new("pewter_3", "Bug Evolution ", "A Bug Catcher in Pewter City wants you to show him a fully-evolved Bug Pokémon.", QuestBranchHotels, "BWBugCatcher_male", "Pewter City", HotelQuestColor),
    "pewter_field_1" => Quest.new("pewter_field_1", "Nectar garden", "An old man wants you to bring differently colored flowers for the city's garden.", QuestBranchField, "BW (039)", "Pewter City", FieldQuestColor),
    "pewter_field_2" => Quest.new("pewter_field_2", "I Choose You!", "A Pikachu in the PokéMart has lost its official Pokémon League Hat. Find one and give it to the Pikachu!", QuestBranchField, "YOUNGSTER_LeagueHat", "Pewter City", FieldQuestColor),
    "pewter_field_3" => Quest.new("pewter_field_3", "Prehistoric Amber!", "Meetup with a scientist in Viridian Forest to look for prehistoric amber.", QuestBranchField, "BW (82)", "Pewter City", FieldQuestColor),

    #Cerulean hotel
    "cerulean_1" => Quest.new("cerulean_1", "Playing Cupid", "A boy in Cerulean City wants you bring a love letter to a Pokémon Breeder named Maude. She's probably somewhere in one of the routes near Cerulean City", QuestBranchHotels, "BW (18)", "Cerulean City", HotelQuestColor),
    "cerulean_2" => Quest.new("cerulean_2", "Type Experts", "Defeat all of the Type Experts scattered around the Kanto region (#{pbGet(VAR_TYPE_EXPERTS_BEATEN)}/#{TOTAL_NB_TYPE_EXPERTS})", QuestBranchHotels, "expert-normal", "Cerulean City", HotelQuestColor),

    #Route 24
    "cerulean_field_1" => Quest.new("cerulean_field_1", "Field Research (Part 1)", "Professor Oak's aide wants you to catch an Abra.", QuestBranchField, "BW (82)", "Route 24", FieldQuestColor),
    "cerulean_field_2" => Quest.new("cerulean_field_2", "Field Research (Part 2)", "Professor Oak's aide wants you to encounter every Pokémon on Route 24.", QuestBranchField, "BW (82)", "Route 24", FieldQuestColor),
    "cerulean_field_3" => Quest.new("cerulean_field_3", "Field Research (Part 3)", "Professor Oak's aide wants you to catch a Buneary using the Pokéradar.", QuestBranchField, "BW (82)", "Route 24", FieldQuestColor),

    #Vermillion City
    "vermillion_2" => Quest.new("vermillion_2", "Fishing for Sole", "A fisherman wants you to fish up an old boot. Hook it up with the old rod in any body of water.", QuestBranchHotels, "BW (71)", "Cerulean City", HotelQuestColor),
    "vermillion_1" => Quest.new("vermillion_1", "Unusual Types 1", "A woman at the hotel wants you to show her a Water/Fire-type Pokémon", QuestBranchHotels, "BW (58)", "Vermillion City", HotelQuestColor),
    "vermillion_3" => Quest.new("vermillion_3", "Seafood Cocktail ", "Get some steamed Krabby legs from the S.S. Anne's kitchen and bring them back to the hotel before they get cold", QuestBranchHotels, "BW (36)", "Vermillion City", HotelQuestColor),
    "vermillion_field_1" => Quest.new("vermillion_field_1", "Building Materials ", "Get some wooden planks from Viridian City and some Bricks from Pewter City.", QuestBranchField, "BW (36)", "Vermillion City", FieldQuestColor),
    "vermillion_field_2" => Quest.new("vermillion_field_2", "Waiter on the Water", "The S.S. Anne waiter wants you to take restaurant orders while he went to get a replacement cake.", QuestBranchField, "BW (53)", "S.S. Anne", FieldQuestColor),

    #Celadon City
    "celadon_1" => Quest.new("celadon_1", "Sun or Moon", "Show the Pokémon that Eevee evolves when exposed to a Moon or Sun stone to help the scientist with her research.", QuestBranchHotels, "BW (82)", "Celadon City", HotelQuestColor),
    "celadon_2" => Quest.new("celadon_2", "For Whom the Bell Tolls", "Ring Lavender Town's bell when the time is right to reveal its secret.", QuestBranchHotels, "BW (40)", "Lavender Town", HotelQuestColor),
    "celadon_3" => Quest.new("celadon_3", "Hardboiled", "A lady wants you to give her an egg to make an omelette.", QuestBranchHotels, "BW (24)", "Celadon City", HotelQuestColor),
    "celadon_field_1" => Quest.new("celadon_field_1", "A stroll with Eevee!", "Walk Eevee around for a while until it gets tired.", QuestBranchField, "BW (37)", "Celadon City", FieldQuestColor),

    #Fuchsia City
    "fuchsia_1" => Quest.new("fuchsia_1", "Bicycle Race!", "Go meet the Cyclist at the bottom of Route 17 and beat her time up the Cycling Road!", QuestBranchHotels, "BW032", "Cycling Road", HotelQuestColor),
    "fuchsia_2" => Quest.new("fuchsia_2", "Lost Pokémon!", "Find the lost Chansey's trainer!", QuestBranchHotels, "113", "Fuchsia City", HotelQuestColor),
    "fuchsia_3" => Quest.new("fuchsia_3", "Cleaning up the Cycling Road", "Get rid of all the Pokémon dirtying up the Cycling Road.", QuestBranchHotels, "BW (77)", "Fuchsia City", HotelQuestColor),
    "fuchsia_4" => Quest.new("fuchsia_4", "Bitey Pokémon", "A fisherman wants to know what is the sharp-toothed Pokémon that bit him in the Safari Zone's lake.", QuestBranchHotels, "BW (71)", "Fuchsia City", HotelQuestColor),

    #Crimson City
    "crimson_1" => Quest.new("crimson_1", "Shellfish Rescue", "Put all the stranded Shellders back in the water on the route to Crimson City.", QuestBranchHotels, "BW (48)", "Crimson City", HotelQuestColor),
    "crimson_2" => Quest.new("crimson_2", "Fourth Round Rumble", "Defeat Jeanette and her high-level Bellsprout in a Pokémon Battle", QuestBranchHotels, "BW024", "Crimson City", HotelQuestColor),
    "crimson_3" => Quest.new("crimson_3", "Unusual Types 2", "A woman at the hotel wants you to show her a Normal/Ghost-type Pokémon", QuestBranchHotels, "BW (58)", "Crimson City", HotelQuestColor),
    "crimson_4" => Quest.new("crimson_4", "The Top of the Waterfall", "Someone wants you to go investigate the top of a waterfall near Crimson City", QuestBranchHotels, "BW (28)", "Crimson City", HotelQuestColor),

    #Saffron City
    "saffron_1" => Quest.new("saffron_1", "Lost Puppies", "Find all of the missing Growlithe in the routes around Saffron City.", QuestBranchHotels, "BW (73)", "Saffron City", HotelQuestColor),
    "saffron_2" => Quest.new("saffron_2", "Invisible Pokémon", "Find an invisible Pokémon in the eastern part of Saffron City.", QuestBranchHotels, "BW (57)", "Saffron City", HotelQuestColor),
    "saffron_3" => Quest.new("saffron_3", "Bad to the Bone!", "Find a Rare Bone using Rock Smash.", QuestBranchHotels, "BW (72)", "Saffron City", HotelQuestColor),
    "saffron_field_1" => Quest.new("saffron_field_1", "Dancing Queen!", "Dance with the Copycat Girl!", QuestBranchField, "BW (24)", "Saffron City (nightclub)", FieldQuestColor),

    #Cinnabar Island
    "cinnabar_1" => Quest.new("cinnabar_1", "The transformation Pokémon", "The scientist wants you to find some Quick Powder that can sometimes be found with wild Ditto in the mansion's basement.", QuestBranchHotels, "BW (82)", "Cinnabar Island", HotelQuestColor),
    "cinnabar_2" => Quest.new("cinnabar_2", "Diamonds and Pearls", "Find a Diamond Necklace to save the man's marriage.", QuestBranchHotels, "BW (71)", "Cinnabar Island", HotelQuestColor),
    "cinnabar_3" => Quest.new("cinnabar_3", "Stolen artifact", "Recover a stolen vase from a burglar in the Pokémon Mansion", QuestBranchHotels, "BW (21)", "Cinnabar Island", HotelQuestColor),

    #Goldenrod City
    "goldenrod_1" => Quest.new( "goldenrod_1", "Safari Souvenir!", "Bring back a souvenir from the Fuchsia City Safari Zone", QuestBranchHotels, "BW (28)", "Goldenrod City", HotelQuestColor),
    "goldenrod_2" => Quest.new("goldenrod_2", "The Cursed Forest", "A child wants you to find a floating tree stump in Ilex Forest. What could she be talking about?", QuestBranchHotels, "BW109", "Goldenrod City", HotelQuestColor),

    "goldenrod_police_1" => Quest.new("goldenrod_police_1", "Undercover police work!", "Go see the police in Goldenrod City to help them with an important police operation.", QuestBranchField, "BW (80)", "Goldenrod City", FieldQuestColor),
    "pinkan_police" => Quest.new("pinkan_police", "Pinkan Island!", "Team Rocket is planning a heist on Pinkan Island. You joined forces with the police to stop them!", QuestBranchField, "BW (80)", "Goldenrod City", FieldQuestColor),

    #Violet City
    "violet_1" => Quest.new("violet_1", "Defuse the Pinecones!", "Get rid of all the Pineco on Route 31 and Route 30", QuestBranchHotels, "BW (64)", "Violet City", HotelQuestColor),
    "violet_2" => Quest.new("violet_2", "Find Slowpoke's Tail!", "Find a SlowpokeTail in some flowers, somewhere around Violet City!", QuestBranchHotels, "BW (19)", "Violet City", HotelQuestColor),

    #Blackthorn City
    "blackthorn_1" => Quest.new( "blackthorn_1", "Dragon Evolution", "A Dragon Tamer in Blackthorn City wants you to show her a fully-evolved Dragon Pokémon.", QuestBranchHotels, "BW014", "Blackthorn City", HotelQuestColor),
    "blackthorn_2" => Quest.new("blackthorn_2", "Sunken Treasure!", "Find an old memorabilia on a sunken ship near Cinnabar Island.", QuestBranchHotels, "BW (28)", "Blackthorn City", HotelQuestColor),
    "blackthorn_3" => Quest.new("blackthorn_3", "The Largest Carp", "A fisherman wants you to fish up a Magikarp that's exceptionally high-level at Dragon's Den.", QuestBranchHotels, "BW (71)", "Blackthorn City", HotelQuestColor),

    #Ecruteak City
    "ecruteak_1" => Quest.new("ecruteak_1", "Ghost Evolution", "A girl in Ecruteak City wants you to show her a fully-evolved Ghost Pokémon.", QuestBranchHotels, "BW014", "Ecruteak City", HotelQuestColor),

    #Kin Island
    "kin_1" => Quest.new("kin_1", "Banana Slamma!", "Collect 30 bananas", QuestBranchHotels, "BW059", "Kin Island", HotelQuestColor),
    "kin_2" => Quest.new("kin_2", "Fallen Meteor", "Investigate a crater near Bond Bridge.", QuestBranchHotels, "BW009", "Kin Island", HotelQuestColor),
    "kin_field_1" => Quest.new("kin_field_1", "The rarest fish", "A fisherman wants you to show him a Feebas. Apparently they can be fished around the Sevii Islands when it rains.", QuestBranchField, "BW056", "Kin Island", FieldQuestColor),

    "legendary_deoxys_1" => Quest.new("legendary_deoxys_1", "First Contact", "Find the missing pieces of a fallen alien spaceship", QuestBranchHotels, "BW (92)", "Bond Bridge", LegendaryQuestColor),
    "legendary_deoxys_2" => Quest.new("legendary_deoxys_2", "First Contact (Part 2)", "Ask the sailor at Cinnabar Island's harbour to take you to the uncharted island where the spaceship might be located", QuestBranchHotels, "BW (92)", "Bond Bridge", LegendaryQuestColor),

    #Necrozma quest
    "legendary_necrozma_1" => Quest.new("legendary_necrozma_1", "Mysterious prisms", "You found a pedestal with a mysterious prism on it. There seems to be room for more prisms.", QuestBranchLegendary, "BW_Sabrina", "Pokémon Tower", LegendaryQuestColor),
    "legendary_necrozma_2" => Quest.new("legendary_necrozma_2", "The long night (Part 1)", "A mysterious darkness has shrouded some of the region. Meet Sabrina outside of Saffron City's western gate to investigate.", QuestBranchLegendary, "BW_Sabrina", "Lavender Town", LegendaryQuestColor),
    "legendary_necrozma_3" => Quest.new("legendary_necrozma_1", "The long night (Part 2)", "The mysterious darkness has expended. Meet Sabrina on top of Celadon City's Dept. Store to figure out the source of the darkness.", QuestBranchLegendary, "BW_Sabrina", "Route 7", LegendaryQuestColor),
    "legendary_necrozma_4" => Quest.new("legendary_necrozma_4", "The long night (Part 3)", "Fuchsia City appears to be unaffected by the darkness. Go investigate to see if you can find out more information.", QuestBranchLegendary, "BW_Sabrina", "Celadon City", LegendaryQuestColor),
    "legendary_necrozma_5" => Quest.new("legendary_necrozma_5", "The long night (Part 4)", "The mysterious darkness has expended yet again and strange plants have appeared. Follow the plants to see where they lead.", QuestBranchLegendary, "BW_koga", "Fuchsia City", LegendaryQuestColor),
    "legendary_necrozma_6" => Quest.new("legendary_necrozma_6", "The long night (Part 5)", "You found a strange fruit that appears to be related to the mysterious darkness. Go see professor Oak to have it analyzed.", QuestBranchLegendary, "BW029", "Safari Zone", LegendaryQuestColor),
    "legendary_necrozma_7" => Quest.new("legendary_necrozma_7", "The long night (Part 6)", "The strange plant you found appears to glow in the mysterious darkness that now covers the entire region. Try to follow the glow to find out the source of the disturbance.", QuestBranchLegendary, "BW-oak", "Pallet Town", LegendaryQuestColor),


    "legendary_meloetta_1" => Quest.new("legendary_meloetta_1", "A legendary band (Part 1)", "The singer of a band in Saffron City wants you to help them recruit a drummer. They think they've heard some drumming around Crimson City...", QuestBranchLegendary, "BW107", "Saffron City", LegendaryQuestColor),
    "legendary_meloetta_2" => Quest.new("legendary_meloetta_2", "A legendary band (Part 2)", "The drummer from a legendary Pokéband wants you to find its former bandmates. The band manager talked about two former guitarists...", QuestBranchLegendary, "band_drummer", "Saffron City", LegendaryQuestColor),
    "legendary_meloetta_3" => Quest.new("legendary_meloetta_3", "A legendary band (Part 3)", "The drummer from a legendary Pokéband wants you to find its former bandmates. There are rumors about strange music that was heard around the region.", QuestBranchLegendary, "band_drummer", "Saffron City", LegendaryQuestColor),
    "legendary_meloetta_4" => Quest.new("legendary_meloetta_4", "A legendary band (Part 4)", "You assembled the full band! Come watch the show on Saturday night.", QuestBranchLegendary, "BW117", "Saffron City", LegendaryQuestColor),

    "legendary_cresselia_1" => Quest.new(61, "Mysterious Lunar feathers", "A mysterious entity asked you to collect Lunar Feathers for them. It said that they will come at night to tell you where to look. Whoever that may be...", QuestBranchLegendary, "lunarFeather", "Lavender Town", LegendaryQuestColor),
    #removed
    #11 => Quest.new(11, "Powering the Lighthouse", "Catch some Voltorb to power up the lighthouse", QuestBranchHotels, "BW (43)", "Vermillion City", HotelQuestColor),
}

###################
# HOENN QUESTS   ##
# ################

    #Route 116
define_quest("route116_glasses",:FIELD_QUEST,"Lost glasses", "A trainer has lost their glasses, help him find them!","Route 116","NPC_Hoenn_BugManiac")
define_quest("petalburgwoods_spores",:FIELD_QUEST,"Spores harvest", "A scientist has tasked you to collect 4 spore samples from the large mushrooms that can be found imn the woods!","Petalburg Woods","NPC_Hoenn_Scientist")




