TOWER_EVENTS = {
    :HOTSPRING => {
        :location => "Hot Spring",
        :image => "TORKOAL",
        :floorrequirement => 0,
    },
    :LUMINOUSSPRING => {
        :location => "Luminous",
        :location2 => "Spring",
        :image => "217_0",
        :floorrequirement => 0,
    },
    :ROUTE33 => {
        :location => "Route 33",
        :image => "berrytreeLIECHIBERRY",
        :floorrequirement => 0,
    },
    :ROUTE332 => {
        :location => "Route 33",
        :image => "berrytreeLIECHIBERRY",
        :floorrequirement => false,
    },
    :SECRETBAZAAR => {
        :location => "Secret",
        :location2 => "Bazaar",
        :image => "KIRLIA",
        :floorrequirement => 0,
    },
    :SINNOHUNDERGROUND => {
        :location => "Underground",
        :location2 => "Path",
        :image => "BW_rocksmash",
        :floorrequirement => 0,
    },
    :VIENFOREST => {
        :location => "Vien Forest",
        :image => "BW155",
        :floorrequirement => false, #todo
    },
    :VIENFOREST2 => {
        :location => "Vien Forest",
        :image => "BW155",
        :floorrequirement => false,
    },
    :WANDERINGTRADER => {
        :location => "Plains",
        :location2 => "Biome",
        :image => "Dipshit",
        :floorrequirement => 10,
    },
    :WISHCAVE => {
        :location => "Wish Cave",
        :image => "WishingStone",
        :floorrequirement => 0,
    },
}

def getUnknownEventList()
    list = []
    TOWER_EVENTS.each do |key, value|
        next if value[:floorrequirement] == false
        next unless value[:floorrequirement] <= $PokemonGlobal.towervalues[:floor]
        list.push(key)
    end
    return list
end

def towerPokemon()
    amount = 1
    amount += 1 if hasEmera?(:POKEDEX)
    for _ in 0...amount do
        optioncount = 3
        options = []
        while options.length < optioncount
            mon = getTowerPokemon()
            options.push(mon) if !options.include?(mon)
        end
        if hasEmera?(:CAPTURESTYLER)
            options.each do |mon|
                pbAddPokemon(mon, 5)
                $PokemonBag.pbStoreItem(:SINNOHCOIN) if hasEmera?(:ROTOMDEX)
            end
            next
        end
        namearray = []
        options.each do |pokemon|
            monname = PBSpecies.getName(pokemon)
            monname = "Alolan " + monname if pokemon.to_s[0...5] == "ALOLA"
            monname = "Galarian " + monname if pokemon.to_s[0...5] == "GALAR"
            monname = "Hisuian " + monname if pokemon.to_s[0...5] == "HISUI"
            monname = "Paldean " + monname if pokemon.to_s[0...6] == "PALDEA"
            monname += " F" if pokemon == :NIDORANfE
            monname += " M" if pokemon == :NIDORANmA
            monname += " Baile" if pokemon == :ORICORIO_1
            monname += " Pom-Pom" if pokemon == :ORICORIO_2
            monname += " Pa'u" if pokemon == :ORICORIO_3
            monname += " Sensu" if pokemon == :ORICORIO_3
            monname += " Combat Breed" if pokemon == :PALDEATAUROS
            monname += " Blaze Breed" if pokemon == :PALDEATAUROSFIRE
            monname += " Aqua Breed" if pokemon == :PALDEATAUROSWATER
            namearray.push(monname)
        end
        choice = Kernel.pbMessage("Pick one", namearray)
        pbAddPokemon(options[choice], 5)
        $PokemonBag.pbStoreItem(:SINNOHCOIN) if hasEmera?(:ROTOMDEX)
    end
end

def getUnknownEvent()
    list = $PokemonGlobal.towervalues[:unknownlist]
    return list.sample
end

def resolveUnknownEvent(recursion = false)
    case $PokemonGlobal.towervalues[:activevariable]
    when :HOTSPRING
        Kernel.pbMessage("You encounter a Torkoal heating up a spring.")
        choice = pbUnknownCommands(["Soak in the water.", "Splash the Torkoal with water.", "Gather herbs nearby."], ["You could probably rest up.", "Are you sure you want to anger it?", "You think you spot some Revival Herbs and Energy Roots."])
        case choice
        when 0
            $Trainer.party.each do |pkmn|
                pkmn.heal
            end
            Kernel.pbMessage("Your Pokemon heal from the rest.")
        when 1
            Kernel.pbMessage("Torkoal attacks.")
            return if !pbLegendaryBattle("Torkoal", true)
        when 2
            pbItemBall(:REVIVALHERB, rand(3) + 2)
            pbItemBall(:ENERGYROOT, rand(3) + 2)
            Kernel.pbMessage("The Torkoal left while you gathered herbs.")
        end
    when :LUMINOUSSPRING
        Kernel.pbMessage("You encounter a spring radiating a bright light.") if !recursion
        Kernel.pbMessage("An Ursaring is standing at the edge staring at the spring.") if !recursion
        choice = pbUnknownCommands(["Have a Pokemon enter the spring.", "Attack the Ursaring.", "Look around nearby."], ["A powerful energy comes from the spring", "It doesn't appear to be paying attention to you.", "Something glimmers in the bushes."])
        case choice
        when 0
            scene = PokemonParty_Scene.new
            screen = PokemonPartyScreen.new(scene,$Trainer.party)
            screen.pbStartScene(_INTL("Teach which Pokémon?"),false,annot)
            evolved = false
            loop do
                chosen = screen.pbChoosePokemon
                break if chosen<0
                pokemon = $Trainer.party[chosen]
                evolutions = getEvolvedSpecies(pokemon)
                forcedevolutions = []
                if evolutions.empty?
                    forcedevolutions = [[pokemon.species, nil, :MISTSTONE]]
                else
                    evolutions.each do |evolution|
                        forcedevolutions.push(evolution) if evolution[2] == :MISTSTONE
                    end
                end
                evolutions = forcedevolutions if !forcedevolutions.empty?
                newspecies = evolutions[rand(evolutions.length - 1)][0]
                next false if newspecies == nil
                next false if newspecies == :OMNIMON && pokemon.species != :OMNIMON
                evo = PokemonEvolutionScene.new
                evo.pbStartScreen(pokemon, newspecies)
                evo.pbEvolution
                evo.pbEndScreen
                if !forcedevolutions.empty?
                    pokemon.ability = :FORCEDEVOLUTION
                    pokemon.calc_stats
                    pokemon.miststone = true
                end
                return true
            end
            screen.pbEndScene
            return resolveUnknownEvent(true) if !evolved
        when 1
            Kernel.pbMessage("The Ursaring is caught by surprise and falls into the spring.")
            Kernel.pbMessage("After a moment an angry Ursaluna jumps out at you.")
            return if !pbLegendaryBattle("Ursaluna", true)
        when 2
            pbItemBall(:REVIVALHERB, rand(3) + 2)
            pbItemBall(:ENERGYROOT, rand(3) + 2)
            Kernel.pbMessage("The Torkoal left while you gathered herbs.")
        end
    when :ROUTE33
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
            return if !pbLegendaryBattle("Heracross", true)
        when 2
            if $PokemonBag.pbQuantity(:MYSTICWATER) == 0
                Kernel.pbMessage("You don't have a Mystic Water.")
                return resolveUnknownEvent(true)
            end
            $PokemonBag.pbDeleteItem(:MYSTICWATER, 1)
            Kernel.pbMessage("The tree looks happy.")
            $PokemonGlobal.towervalues[:unknownlist].push("Big Tree")
        end
    when :ROUTE332
        Kernel.pbMessage("You find yourself in a familiar place near a massive berry tree next to the road.")
        Kernel.pbMessage("A Heracross jumps out of the tree looking happy to see you.")
        Kernel.pbMessage("It Guides you to a pile of Berries and seems to want to join you.")
        Kernel.pbMessage("You gained 5 of every berry.")
        berrylist = [:CHERIBERRY, :CHESTOBERRY, :PECHABERRY, :RAWSTBERRY, :ASPEARBERRY, :LEPPABERRY, :ORANBERRY, :PERSIMBERRY, :LUMBERRY, :SITRUSBERRY, :FIGYBERRY, :WIKIBERRY, :MAGOBERRY, :AGUAVBERRY, :IAPAPABERRY, :OCCABERRY, :PASSHOBERRY, :WACANBERRY, :RINDOBERRY, :YACHEBERRY, :CHOPLEBERRY, :KEBIABERRY, :SHUCABERRY, :COBABERRY, :PAYAPABERRY, :TANGABERRY, :CHARTIBERRY, :KASIBBERRY, :HABANBERRY, :COLBURBERRY, :BABIRIBERRY, :CHILANBERRY, :LIECHIBERRY, :GANLONBERRY, :SALACBERRY, :PETAYABERRY, :APICOTBERRY, :LANSATBERRY, :STARFBERRY, :ENIGMABERRY, :MICLEBERRY, :CUSTAPBERRY, :JABOCABERRY, :ROWAPBERRY]
        berrylist.each do |berry|
            $PokemonBag.pbStoreItem(berry, 5)
        end
        pbObtainAlpha("Heracross")
    when :SECRETBAZAAR
        Kernel.pbMessage("You find a hidden staircase into a secret bazaar.") if !recursion
        Kernel.pbMessage("4 Pokemon are offering you their service before you leave.") if !recursion
        choice = pbUnknownCommands(["Mime Jr.", "Swalot", "Shedinja", "Lickilicky"], ["Heal your party.", "Gain random items.", "Obtain an Escape Orb.", "Clean anything Sticky that you have."])
        case choice
        when 0
            Kernel.pbMessage("Mime Jr. uses Heal Pulse.")
            $Trainer.party.each do |pkmn|
                pkmn.heal
            end
            Kernel.pbMessage("Your Pokemon are fully healed.")
        when 1
            enderChest()
        when 2
            pbReceiveItem(:ESCAPEORB)
        when 3
            didsomething = false
            if hasEmera?(:STICKYKEY)
                getLooplet.pbRemoveEmera(:STICKYKEY)
                getLooplet.pbStoreEmera(:KEY)
                Kernel.pbMessage("Your Sticky Key is now clean.")
                didsomething = true
            end
            stickybarbs = $PokemonBag.pbQuantity(:STICKYBARB)
            if $PokemonBag.pbDeleteItem(:SINNOHCOIN, stickybarbs)
                $PokemonBag.pbStoreItem(:BARB, stickybarbs)
                Kernel.pbMessage("Your Sticky Barbs are now clean.")
                didsomething = true
            end
            $Trainer.party.each do |pkmn|
                if pkmn.hasAbility?(:STICKYHOLD)
                    pkmn.ability = :HOLD
                    Kernel.pbMessage("Your #{pkmn.name}'s Sticky Hold is now clean.")
                    didsomething = true
                end
                pkmn.moves.each_with_index do |move, i|
                    next unless move.id == :STICKYWEB
                    pkmn.moves[i] = Pokemon::Move.new(:WEB)
                    Kernel.pbMessage("Your #{pkmn.name}'s Sticky Web is now clean.")
                    didsomething = true
                end
            end
            if !didsomething
                Kernel.pbMessage("There is nothing to clean.")
                return resolveUnknownEvent(true)
            end
        end
    when :SINNOHUNDERGROUND
        pbBGMPlay("Mining")
        pbMiningGame
        pbBGMPlay("TemporalTower")
    when :SHADROSS #todo
        Kernel.pbMessage("You come across a purple skeleton.")
        Kernel.pbMessage("What will you try to get from him?")
        helptext = ["Perhaps you can get a discount later. Costs 10 Sinnoh Coins.", "Teach something Shadow Bone+.", "Gives a lot of Special Attack.", "Theyre kinda sick, you might have to fight him for it."]
        helptext[0] = "Perhaps you can get a discount later. \\C[2]Costs 10 Sinnoh Coins." if $PokemonBag.pbQuantity(:SINNOHCOIN) < 10
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
            pbItemBall(:GOLDENCALCIUM)
        when 3
            if hasEmera?(:KNIFE)
                return
            end
            Kernel.pbMessage("not coded in yet, try something else")
            return resolveUnknownEvent(true)
        end
    when :VIENFOREST
        Kernel.pbMessage("A dying tree is blocking your path on the mountains.") if !recursion
        helptext = ["Surely nothing will care about it.", "It might be quite the trek.", "Help out the wildlife in the area. Requires a Miracle Seed."]
        helptext[2] = "Help out the wildlife in the area. \\C[2]Requires a Miracle Seed." if $PokemonBag.pbQuantity(:MIRACLESEED) == 0
        choice = pbUnknownCommands(["Cut it down.", "Find a different Path.", "Plant a new tree next to it."], helptext)
        case choice
        when 0
            Kernel.pbMessage("As you move to cut it down the tree rises from the ground to reveal a torterra below you.")
            return if !pbLegendaryBattle("Torterra", true)
        when 1
            Kernel.pbMessage("You come across a Rock Statue emanating a strange power inside a cave.")
            #todo something when player has regirock
            hasgarchomp = false
            $Trainer.party.each do |pokemon|
                next unless pokemon.isFusionOf(:GARCHOMP)
                hasgarchomp = pokemon
            end
            if hasgarchomp
                Kernel.pbMessage("Your #{pokemon.name} jumps out and breaks the statue.")
                Kernel.pbMessage("Regirock awakens.")
                Kernel.pbMessage("I should warn you this is a placeholder battle.")
                return if !pbLegendaryBattle("Regirock")
            else
                Kernel.pbMessage("You try to break it but seem unable to.")
                Kernel.pbMessage("You gather some of the rocks laying around before leaving the cave.")
                itemlist = [:HARDSTONE, :SMOOTHROCK, :ROCKGEM, :OVALSTONE]
                itemlist.each do |item|
                    pbItemBall(item)
                end
            end
        when 2
            if $PokemonBag.pbQuantity(:MIRACLESEED) == 0
                Kernel.pbMessage("You don't have a Miracle Seed.")
                return resolveUnknownEvent(true)
            end
            $PokemonBag.pbDeleteItem(:MIRACLESEED, 1)
            Kernel.pbMessage("The dying tree disappears as a new one sprouts. How preculiar.")
            $PokemonGlobal.towervalues[:unknownlist].push("Torterra2")
        end
    when :VIENFOREST2
        Kernel.pbMessage("You find yourself in a familiar place with a grown up tree blocking your path on the mountains.")
        Kernel.pbMessage("Suddenly a Torterra rises from the ground below you looking happy to see you.")
        pbObtainAlpha("Torterra")
        Kernel.pbMessage("It presents you with a cool rock it picked up.")
        #pbReceiveItem(:ROCKIUMZ) todo make this work
    when :WANDERINGTRADER
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
        itemcolor = getEnderChestRarityColors()[(choice+1) % 4]
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
            grantRandomEmera([1,0,0,0])
        end
        pbMessage("You got \\C[#{itemcolor}]#{itemname}\\C[0]!")
    when :WARDEN
        Kernel.pbMessage("A Warden crawls out of the ground.")
        return if !pbLegendaryBattle("Warden")
    when :WISHCAVE
        Kernel.pbMessage("A Wishing Stone appears before you.")
        if !$PokemonGlobal.towervalues[:legendarylist].include?("Jirachi")
            Kernel.pbMessage("Your Jirachi wakes up from its slumber.")
            towerPokemon()
            grantRandomEmera()
            pbItemBall(:SINNOHCOIN, 11)
            enderChest()
        else
            choice = Kernel.pbMessage("What do you wish for?", ["Money", "Items", "Friends", "Power", "Fight"])
            case choice
            when 0
                pbItemBall(:SINNOHCOIN, 33)
            when 1
                enderChest()
                enderChest()
                enderChest()
            when 2
                towerPokemon()
                towerPokemon()
                towerPokemon()
            when 3
                grantRandomEmera([0,5,2,1])
            when 4
                $PokemonGlobal.nextBattleBGM = "VSJirachi"
                return if !pbLegendaryBattle("Jirachi")
                $PokemonGlobal.towervalues[:legendarylist].delete_if {|i| i == "Jirachi"}
            end
        end
    end
    $PokemonGlobal.towervalues[:unknownlist].delete_if {|i| i == $PokemonGlobal.towervalues[:activevariable]}
    $PokemonGlobal.towervalues[:unknownlist] = getUnknownEventList() if $PokemonGlobal.towervalues[:unknownlist].length == 0
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