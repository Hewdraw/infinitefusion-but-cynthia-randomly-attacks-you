def towerDialogue(event_id)
    if !$PokemonGlobal.towervalues.nil?
        pbCallBub(2,event_id, true)
        choice = Kernel.pbMessage("Leaving already?", ["No", "Yes"])
        case choice
        when 0
            pbCallBub(2,event_id, true)
            Kernel.pbMessage("Well continue on then, there is a Tower for you to climb.")
        when 1
            pbCallBub(2,event_id, true)
            Kernel.pbMessage("Oh, are we resetting for better starters?")
            resetTower
            transferPlayer(32, 10, 16)
        end
        return
    end
    intromessages = []
    if getLoopletType.nil?
        if $Trainer.numbadges == 0
            intromessages.push("Ah, I wasn't expecting you so soon.")
        else
            intromessages.push("Oh, you finally arrived.")
        end
        intromessages.push("Welcome to the Temporal Tower Mystery Dungeon.")
        intromessages.push("You may climb the Tower using only what you obtain inside of it.")
        intromessages.push("Please temporarily leave your belongings with me if you wish to do so.")
        intromessages.push("And you may want to take this.")
        intromessages.push(:obtainlooplet)
        intromessages.push("This Looplet will be able to slot in Emeras that you can obtain as a reward in the Tower.")
        intromessages.push("Every 2 badges you obtain out of Tower I will upgrade it for you when you come back here.")
        intromessages.push("Just let me know if you would like to give it a try.")
    else
        intromessages.push("Welcome back.")
        intromessages.push(:obtainlooplet)
    end
    intromessages.each do |message|
        case message
        when :obtainlooplet
            upgradeLooplet
        else
            pbCallBub(2,event_id, true)
            Kernel.pbMessage(message)
        end
    end

    options = []
    hintoptions = []
    if $PokemonGlobal.towerquicksave.nil?
        options.push("New Game")
    else
        options.push("Continue")
    end
    options.push("Chat")
    options.push("Exit")

    loop do
        pbCallBub(2,event_id, true)
        choice = Kernel.pbMessage("What can I do for you today?", options, options.length)
        case options[choice]
        when "New Game"
            pbCallBub(2,event_id, true)
            Kernel.pbMessage("Alright then, pick your Trainer Class and I will give you your starter Pokemon.")
            setupTower
            transferPlayer(32, 10, 10)
            break
        when "Continue"
            continueTower
            break
        when "Chat"
            loop do
                break if !towerChat(event_id)
            end
        when "Exit"
            pbCallBub(2,event_id, true)
            Kernel.pbMessage("Cowardice.")
            break
        end
    end
end

def towerChat(event_id)
    $PokemonGlobal.dialogueread = [] if $PokemonGlobal.dialogueread.nil?
    options = []
    dialogue = []

    if $PokemonGlobal.towerlocation
        currentMap = getLocationFromMap($PokemonGlobal.towerlocation[0])
        if $PokemonGlobal.dialogueread.include?(currentMap)
            options.push("Current Area (Seen)")
        else
            options.push("Current Area")
        end
    end
    options += getItemDialogueOptions
    options.push("Exit")
    pbCallBub(2,event_id, true)
    choice = Kernel.pbMessage("What do you want to chat about?", options, options.length)
    case options[choice]
    when "Current Area", "Current Area (Seen)"
        $PokemonGlobal.dialogueread.push(currentMap) if currentMap && !$PokemonGlobal.dialogueread.include?(currentMap)
        case currentMap
        when "Pallet Town"
            dialogue.push("Ah Pallet Town, the start of the Kanto journey.")
            dialogue.push("You have been here before.")
            dialogue.push("It's just as you remember.")
            dialogue.push("There is a new rock by the water.")
            dialogue.push("...")
            dialogue.push("Anyway say hi to Shad for me.")
            dialogue.push("They're right outside your mom's house, can't miss them.")
        when "Dream Sequence"
            dialogue.push("How odd, where did the rock go?")
            dialogue.push("... Or the water for that matter.")
        when "Route 1"
            dialogue.push("Did you know that the Secret Garden on this route used to only open after beating the Route 22 rival?")
            dialogue.push("What a peculiar unlock condition.")
            dialogue.push("I've opened it early for you, have fun in there.")
        when "Viridian City"
            dialogue.push("You are at Viridian City?")
            dialogue.push("Say hi to Claire for me as well while you are there.")
            dialogue.push("You can find her in the Trainer School.")
        when "Route 22"
            dialogue.push("I do wonder, do you see what I have to say right as you enter a new area?")
            dialogue.push("Or perhaps after exploring the route to see if you missed something.")
            dialogue.push("Is it a spoiler if I point out the suspicious tree arrangement?")
            dialogue.push("Did you spot it already on your own?")
            dialogue.push("Or did you walk right past it and wonder what I am talking about?")
            dialogue.push("A curious circumstance.")
        when "Route 2"
            dialogue.push("Yes Shad did some gardening around the regions.")
            dialogue.push("No I did not stop them from doing any of it.")
            dialogue.push("Have fun with the extra grass.")
        when "Hidden Forest"
            dialogue.push("For legal reasons I do not have anything to say about this forest.")
        when "Viridian River"
            dialogue.push("Don't get me started on this area.")
            dialogue.push("Just know that for convenience reasons the starters now spawn right next to the entrance.")
            dialogue.push("And It's guaranteed that one of each type spawns.")
        when "Viridian Forest"
            dialogue.push("You would think that Viridian Forest would be the first big hurdle in a mod like this.")
            dialogue.push("But no you can actually get through it while stepping on less grass than Route 2.")
            dialogue.push("The oddities of pacing i guess.")
        when "Pewter City"
            dialogue.push("The first big city you have come across.")
            dialogue.push("No I am not counting Viridian City when you only get the parcel there and leave.")
            dialogue.push("But I will let you explore this one on your own.")
        when "Route 3"
            dialogue.push("Hey I am on that route if you want to battle.")
            dialogue.push("I will be holding back quite a lot for that one.")
            dialogue.push("It is probably worth trying before you go into Mt. Moon.")
            dialogue.push("But you might still want to get your badge first though.") if $Trainer.numbadges == 0
        when "Mt. Moon"
            dialogue.push("Welcome to the actual first big hurdle.")
            dialogue.push("... I should probably actually check if you have read the dialogue which that is referencing.")
            dialogue.push("Maybe later.")
        when "Mt. Moon Square"
            dialogue.push("Miku, Miku, You can call her Miku.")
            dialogue.push("Blue Hair, Blue Tie, Hiding in Mt. Moon Square.")
        else
            Kernel.pbMessage("todo")
        end
    when "Neru Phone"
        dialogue.push("Oh did Neru give you that phone?")
        dialogue.push("I would offer to give you my number but calling does not really work in here.")
    when "Digivice"
        dialogue.push("Showing off that you beat me once?")
        dialogue.push("Just know that future battles will not be as easy.")
        dialogue.push("And as a reminder the box does not heal Pokemon here.")
    when "Legendary Candy"
        dialogue.push("A respectable victory.")
        if $Trainer.numbadges == 1
            dialogue.push("And at 1 badge?")
            dialogue.push("I commend you for challenging yourself.")
        else
            dialogue.push("But did you do it when you could?")
            dialogue.push("Or did you have to come back to it later?")
        end
        if !$PokemonBag.pbHasItem?(:DIGIVICE)
            dialogue.push("Are you not also forgetting something on route 3?")
        end
    when "Premier Splicers"
        dialogue.push("Oh you found the Premier Splicers.")
        dialogue.push("Did you get the hint from the Tower?")
        dialogue.push("Or stumble upon it randomly?")
        dialogue.push("Maybe someone else even told you about it.")
        dialogue.push("Regardless it is still infinite super splicers.")
        dialogue.push("Enjoy the convenience.")
    when "Exit"
        return false
    end
    dialogue.each do |message|
        pbCallBub(2,event_id, true)
        Kernel.pbMessage(message)
    end
    $PokemonGlobal.dialogueread.push(options[choice]) if !["Current Area", "Current Area (Seen)"].include?(options[choice])
    return true
end

def getLocationFromMap(map_id)
    case map_id
    when 42, 43, 48, 67, 68, 69, 70, 71, 72, 76, 77, 205, 430, 551, 552, 593, 659, 740, 847
        return "Pallet Town"
    when 719, 720, 722, 723, 724 
        return "Dream Sequence"
    when 78, 185
        return "Route 1"
    when 79, 81, 83, 84, 85, 371, 458, 746
        return "Viridian City"
    when 171, 148
        return "Route 22"
    when 39, 86, 88, 89, 90, 92, 222, 511
        return "Route 2"
    when 655
        return "Hidden Forest"
    when 40, 669
        return "Viridian River"
    when 491
        return "Viridian Forest"
    when 91, 93, 96, 380, 381, 385, 386, 392, 459, 460
        return "Pewter City"
    when 379, 490
        return "Route 3"
    when 102, 103, 105, 496, 104
        return "Mt. Moon"
    when 767, 801, 802
        return "Mt. Moon"
        # return "Mt. Moon Darker"
    when 494, 515
        return "Mt. Moon Square"
    when 827, 828, 830, 831
        return "Mt. Moon"
        # return "Mt. Moon Observatory"
    end
    return nil
end

def getItemDialogueOptions
    itemlist = [
        :NERUPHONE,
        :DIGIVICE,
        :LEGENDARYCANDY,
        :PREMIERSPLICERS,
        #:SHADOWCRYSTAL,
    ]
    retlist = []
    itemlist.each do |item|
        next unless $PokemonBag.pbHasItem?(item)
        itemname = GameData::Item.get(item).name
        next if $PokemonGlobal.dialogueread.include?(itemname)
        retlist.push(itemname)
    end
    return retlist
end