def getUnknownEvent()
    list = $PokemonGlobal.towervalues[:unknownlist] + ["Cynthia"]
    return list.sample
end

def resolveUnknownEvent(recursion = false)
    case $PokemonGlobal.towervalues[:activevariable]
    when "Cynthia"
        pbEncounterCynthia([:CHAMPION_Sinnoh, "Cynthia"])
        return
    when "Hot Spring"
        Kernel.pbMessage("You encounter a Torkoal heating up a spring.")
        choice = pbUnknownCommands(["Soak in the water.", "Splash the Torkoal with water.", "Gather herbs nearby."], ["You could probably rest up.", "Are you sure you want to anger it?", "You think you spot some Revival Herbs and Energy Roots."])
        case choice
        when 0
            $Trainer.party.each do |pkmn|
                pkmn.heal
            end
            Kernel.pbMessage("Your Pokemon heal from the rest.")
        when 1
            Kernel.pbMessage("Torkoal attacks")
            return if !pbLegendaryBattle("Torkoal")
        when 2
            pbItemBall(:REVIVALHERB, rand(3) + 2)
            pbItemBall(:ENERGYROOT, rand(3) + 2)
            Kernel.pbMessage("The Torkoal left while you gathered herbs.")
        end
    when "Berry Tree"
        Kernel.pbMessage("You spot a berry tree next to the road.") if !recursion
        helptext = ["A large variety of berries can be seen haning on the tree.", "You think you see something moving in the foliage.", "It will surely grow bigger. Requires a Mystic Water."]
        helptext[2] = "It will surely grow bigger. \\C[2]Requires a Mystic Water." if $PokemonBag.pbQuantity(:MYSTICWATER) == 0
        choice = pbUnknownCommands(["Gather some Berries.", "Shake the tree.", "Water the tree."], helptext)
        case choice
        when 0
            berrylist = [:CHERIBERRY, :CHESTOBERRY, :PECHABERRY, :RAWSTBERRY, :ASPEARBERRY, :LEPPABERRY, :ORANBERRY, :PERSIMBERRY, :LUMBERRY, :SITRUSBERRY, :FIGYBERRY, :WIKIBERRY, :MAGOBERRY, :AGUAVBERRY, :IAPAPABERRY, :OCCABERRY, :PASSHOBERRY, :WACANBERRY, :RINDOBERRY, :YACHEBERRY, :CHOPLEBERRY, :KEBIABERRY, :SHUCABERRY, :COBABERRY, :PAYAPABERRY, :TANGABERRY, :CHARTIBERRY, :KASIBBERRY, :HABANBERRY, :COLBURBERRY, :BABIRIBERRY, :CHILANBERRY, :LIECHIBERRY, :GANLONBERRY, :SALACBERRY, :PETAYABERRY, :APICOTBERRY, :LANSATBERRY, :STARFBERRY, :ENIGMABERRY, :MICLEBERRY, :CUSTAPBERRY, :JABOCABERRY, :ROWAPBERRY]
            berryamount = rand(10) + 6
            for i in 1..berryamount
                pbItemBall(berrylist.sample)
            end
        when 1
            Kernel.pbMessage("An angry Heracross flies out of the tree.")
            return if !pbLegendaryBattle("Heracross")
        when 2
            if $PokemonBag.pbQuantity(:MYSTICWATER) == 0
                Kernel.pbMessage("You don't have a Mystic Water.")
                return resolveUnknownEvent(true)
            end
            $PokemonBag.pbDeleteItem(:MYSTICWATER, 1)
            Kernel.pbMessage("The tree looks happy.")
            $PokemonGlobal.towervalues[:unknownlist].push("Big Tree")
        end
    when "Big Tree"
        Kernel.pbMessage("You find yourself in a familiar place near a massive berry tree next to the road.")
        Kernel.pbMessage("A Heracross jumps out of the tree looking happy to see you.")
        Kernel.pbMessage("It Guides you to a pile of Berries and seems to want to join you.")
        Kernel.pbMessage("You gained 5 of every berry.")
        berrylist = [:CHERIBERRY, :CHESTOBERRY, :PECHABERRY, :RAWSTBERRY, :ASPEARBERRY, :LEPPABERRY, :ORANBERRY, :PERSIMBERRY, :LUMBERRY, :SITRUSBERRY, :FIGYBERRY, :WIKIBERRY, :MAGOBERRY, :AGUAVBERRY, :IAPAPABERRY, :OCCABERRY, :PASSHOBERRY, :WACANBERRY, :RINDOBERRY, :YACHEBERRY, :CHOPLEBERRY, :KEBIABERRY, :SHUCABERRY, :COBABERRY, :PAYAPABERRY, :TANGABERRY, :CHARTIBERRY, :KASIBBERRY, :HABANBERRY, :COLBURBERRY, :BABIRIBERRY, :CHILANBERRY, :LIECHIBERRY, :GANLONBERRY, :SALACBERRY, :PETAYABERRY, :APICOTBERRY, :LANSATBERRY, :STARFBERRY, :ENIGMABERRY, :MICLEBERRY, :CUSTAPBERRY, :JABOCABERRY, :ROWAPBERRY]
        berrylist.each do |berry|
            $PokemonBag.pbStoreItem(berry, 5)
        end
        pbObtainAlpha("Heracross")
    when "Mining"
        pbBGMPlay("Mining")
        pbMiningGame
        pbBGMPlay("TemporalTower")
    when "Shadross"
        Kernel.pbMessage("You come across a purple skeleton.")
        Kernel.pbMessage("What will you try to get from him?")
        helptext = ["Perhaps you can get a discount. Costs 10 Sinnoh Coins.", "Teach something Shadow Bone+.", "Gives a lot of Special Attack.", "Theyre kinda sick, you might have to fight him for it."]
        helptext[0] = "Perhaps you can get a discount. \\C[2]Costs 10 Sinnoh Coins." if $PokemonBag.pbQuantity(:SINNOHCOIN) < 10
        helptext[3] = "Your Knife flashes from the looplet." if hasEmera?(:KNIFE)
        choice = pbUnknownCommands(["Shop Membership", "A Bone", "Calcium", "His Shades"], helptext)
        case choice
        when 0
            if $PokemonBag.pbQuantity(:SINNOHCOIN) < 10
                Kernel.pbMessage("You don't have enough Sinnoh Coins.")
                return resolveUnknownEvent(true)
            end
            $PokemonBag.pbDeleteItem(:SINNOHCOIN, 10)
            getLooplet.pbStoreEmera(:VIPCARD)
            Kernel.pbMessage("You got VIP Card.")
        when 1
            Kernel.pbMessage("not coded in yet, try something else")
            return resolveUnknownEvent(true)
        when 2
            Kernel.pbMessage("not coded in yet, try something else")
            return resolveUnknownEvent(true)
        when 3
            if hasEmera?(:KNIFE)
                return
            end
            Kernel.pbMessage("not coded in yet, try something else")
            return resolveUnknownEvent(true)
    when "Wandering Trader"
        Kernel.pbMessage("A Wandering Trader spawns next to you.")
        commonemera = getLooplet.pbRandomEmera(:COMMON)
        traderuncommonemera = getEmeras[1].sample
        uncommonemera = getLooplet.pbRandomEmera(:UNCOMMON)
        traderrareemera = getEmeras[2].sample
        rareemera = getLooplet.pbRandomEmera(:RARE)
        traderlegendaryemera = getEmeras[3].sample
        commandtext = []
        helptext = []
        trades = []
        if commonemera && traderuncommonemera
            commandtext.push("Trade")
            helptext.push(_INTL("Your \\C[7]{1}\\C[0] for a \\C[3]{2}\\C[0].", EMERADICT[commonemera][:name], EMERADICT[traderuncommonemera][:name]))
            trades.push(:UNCOMMON)
        end
        if uncommonemera && traderrareemera
            commandtext.push("Trade")
            helptext.push(_INTL("Your \\C[3]{1}\\C[0] for a \\C[1]{2}\\C[0].", EMERADICT[uncommonemera][:name], EMERADICT[traderrareemera][:name]))
            trades.push(:RARE)
        end
        if rareemera && traderlegendaryemera
            commandtext.push("Trade")
            helptext.push(_INTL("Your \\C[1]{1}\\C[0] for a \\C[6]{2}\\C[0].", EMERADICT[rareemera][:name], EMERADICT[traderlegendaryemera][:name]))
            trades.push(:LEGENDARY)
        end
        Kernel.pbMessage("Unfortunately you have nothing to trade him.") if commandtext.length == 0
        commandtext.push("Kill Him")
        helptext.push("I think he trampled one of your crops.")
        trades.push(:COMMON)
        choice = pbUnknownCommands(commandtext, helptext)
        itemcolor = getEnderChestRarityColors()[choice]
        case trades[choice]
        when :UNCOMMON
            getLooplet.pbRemoveEmera(commonemera)
            getLooplet.pbStoreEmera(traderuncommonemera)
            itemname = EMERADICT[traderuncommonemera][:name]
        when :RARE
            getLooplet.pbRemoveEmera(uncommonemera)
            getLooplet.pbStoreEmera(traderrareemera)
            itemname = EMERADICT[traderrareemera][:name]
        when :LEGENDARY
            getLooplet.pbRemoveEmera(rareemera)
            getLooplet.pbStoreEmera(traderlegendaryemera)
            itemname = EMERADICT[traderlegendaryemera][:name]
        when :COMMON
            return if !pbLegendaryBattle("Wandering Trader")
            Kernel.pbMessage("He dropped an Emera!")
            tradercommonemera = getEmeras[0].sample
            getLooplet.pbStoreEmera(tradercommonemera)
            itemname = EMERADICT[tradercommonemera][:name]
            itemcolor = getEnderChestRarityColors()[0]
        end
        pbMessage("You got \\C[#{itemcolor}]#{itemname}\\C[0]!")
    when "Warden"
        Kernel.pbMessage("A Warden crawls out of the ground.")
        return if !pbLegendaryBattle("Warden")
    end
    $PokemonGlobal.towervalues[:unknownlist].delete_if {|i| i == $PokemonGlobal.towervalues[:activevariable]}
end

def pbObtainAlpha(species)
    trainer = pbLoadTrainer(:ALPHA_POKEMON, species)
    pokemon = trainer.party[0]
    pokemon.ev = {}
    GameData::Stat.each_main do |s|
        if s.id == :HP
            pokemon.ev[s.id] = 252
        end
        pokemon.ev[s.id] = 0
    end
    pokemon.raid = nil
    pokemon.hpbars = nil
    pbAddPokemon(pokemon)
end

def pbUnknownCommands(commands, help)
    msgwin = pbCreateMessageWindow(nil)
    oldlbl = msgwin.letterbyletter
    msgwin.letterbyletter = false
    help.each do |text|
        isDarkSkin = isDarkWindowskin(msgwin.windowskin)
        text.gsub!(/\\[Cc]\[([0-9]+)\]/) {
        m = $1.to_i
        next getSkinColor(msgwin.windowskin, m, isDarkSkin)
        }
    end
    cmdwindow = Window_CommandPokemonEx.new(commands)
    cmdwindow.z = 99999
    cmdwindow.visible = true
    cmdwindow.resizeToFit(cmdwindow.commands)
    pbPositionNearMsgWindow(cmdwindow, msgwin, :right)
    cmdwindow.index = 0
    command = 0
    msgwin.text = help[cmdwindow.index]
    msgwin.width = msgwin.width
    loop do
      Graphics.update
      Input.update
      oldindex = cmdwindow.index
      cmdwindow.update
      if oldindex != cmdwindow.index
        msgwin.text = help[cmdwindow.index]
      end
      msgwin.update
      yield if block_given?
      if Input.trigger?(Input::USE)
        command = cmdwindow.index
        break
      end
      pbUpdateSceneMap
    end
    ret = command
    cmdwindow.dispose
    Input.update
    msgwin.letterbyletter = oldlbl
    msgwin.dispose
    return ret
end