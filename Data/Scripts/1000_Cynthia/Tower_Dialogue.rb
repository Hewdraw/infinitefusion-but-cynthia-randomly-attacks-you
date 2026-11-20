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
            intromessages.push("Ah, i wasn't expecting you so soon.")
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
        choice = Kernel.pbMessage("What can i do for you today?", options)
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
            Kernel.pbMessage("todo")
        when "Exit"
            pbCallBub(2,event_id, true)
            Kernel.pbMessage("Cowardice.")
            break
        end
    end
end