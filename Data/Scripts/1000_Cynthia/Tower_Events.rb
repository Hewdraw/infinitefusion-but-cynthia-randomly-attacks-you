def getUnknownEvent()
    list = $PokemonGlobal.towervalues.unknownlist + ["Cynthia"]
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
            $PokemonGlobal.towervalues.unknownlist.push("Big Tree")
        end
    when "Big Tree"
        Kernel.pbMessage("You find yourself in a familiar place near a massive berry tree next to the road.")
        Kernel.pbMessage("A Heracross jumps out of the tree looking happy to see you.")
        Kernel.pbMessage("It Guides you to a pile of Berries and seems to want to join you.")
        berrylist = [:CHERIBERRY, :CHESTOBERRY, :PECHABERRY, :RAWSTBERRY, :ASPEARBERRY, :LEPPABERRY, :ORANBERRY, :PERSIMBERRY, :LUMBERRY, :SITRUSBERRY, :FIGYBERRY, :WIKIBERRY, :MAGOBERRY, :AGUAVBERRY, :IAPAPABERRY, :OCCABERRY, :PASSHOBERRY, :WACANBERRY, :RINDOBERRY, :YACHEBERRY, :CHOPLEBERRY, :KEBIABERRY, :SHUCABERRY, :COBABERRY, :PAYAPABERRY, :TANGABERRY, :CHARTIBERRY, :KASIBBERRY, :HABANBERRY, :COLBURBERRY, :BABIRIBERRY, :CHILANBERRY, :LIECHIBERRY, :GANLONBERRY, :SALACBERRY, :PETAYABERRY, :APICOTBERRY, :LANSATBERRY, :STARFBERRY, :ENIGMABERRY, :MICLEBERRY, :CUSTAPBERRY, :JABOCABERRY, :ROWAPBERRY]
        berrylist.each do |berry|
            pbItemBall(berry, 5)
        end
        pbObtainAlpha("Heracross")
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