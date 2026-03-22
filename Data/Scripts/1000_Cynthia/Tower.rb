def setupTower()
    PokemonSelection.saveParty
    $PokemonBag.saveBagAndClear()
    $Trainer.party=[]
    $PokemonGlobal.towervalues = {
        :floor => 1,
        :badges => 0,
        :storage => PokemonStorage.new,
        :looplet => PokemonLooplet.new,
        :cynthiachance => 0,
        :maxcynthiachance => 10,
        :hatsunemikuchance => -10000,
        :maxmikuchance => 10,
        :ladder1 => nil,
        :ladder2 => nil,
        :ladder3 => nil,
        :activeevent => "Pokemon",
        :eventvariable => nil,
        :legendarylist => ["Articuno", "Diancie", "Entei", "Genesect", "Latias", "Meloetta", "Mew", "Moltres", "Reshirom", "Suikou", "Zapdos"],
    }
    pbAddPokemon(getTowerPokemon("Starter"), 5)
    pbAddPokemon(getTowerPokemon(), 5)
    pbAddPokemon(getTowerPokemon(), 5)
    $PokemonBag.pbStoreItem(:DIGIVICE)
    $PokemonBag.pbStoreItem(:INFINITESPLICERS)
    $PokemonBag.pbStoreItem(:LEGENDARYCANDY)
    $PokemonBag.pbStoreItem(:SHINYCHARM)
    $PokemonBag.pbStoreItem(:UNLIMITEDLOOPLET)
end

def resetTower()
    $PokemonGlobal.towervalues = nil
    $PokemonBag.restoreBag()
    PokemonSelection.restore
    pbMapInterpreter.pbSetSelfSwitch(2, "A", false, 21)
    pbMapInterpreter.pbSetSelfSwitch(2, "A", false, 32)
end

def getTowerPokemon(filter=nil)
    list = []
    GameData::Species.each do |data|
        next if data.get_previous_species != data.species
        next if data.id_number > NB_POKEMON
        next if [:MINIOR_C, :MELOETTA_P, :U_NECROZMA, :CASTFORM_SUNNY, :CASTFORM_RAINY, :CASTFORMSNOWY].include?(data.species)
        next if [:ORICORIO_1, :ORICORIO_2, :ORICORIO_3, :ORICORIO_4].include?(data.species) && rand(4) != 0 #randomly enable oricorio form, averages out
        next if [:ARTICUNO, :ZAPDOS, :MOLTRES, :MEWTWO, :MEW, :RAIKOU, :ENTEI, :SUICUNE, :LUGIA, :HOOH, :CELEBI, :ARCEUS, :KYOGRE, :GROUDON, :RAYQUAZA, :DIALGA, :PALKIA, :GIRATINA, :REGIGIGAS, :DARKRAI, :GENESECT, :RESHIRAM, :ZEKROM, :KYUREM, :LATIAS, :LATIOS, :DEOXYS, :JIRACHI, :REGIROCK, :RECICE, :REGISTEEL, :NECROZMA, :MELOETTA_A, :CRESSELIA, :DIANCIE].include?(data.species)
        next if data.base_stats.values.sum > 350 + ($PokemonGlobal.towervalues[:floor]*5)
        case filter
        when "Starter"
            next unless [Settings::KANTO_STARTERS, Settings::JOHTO_STARTERS, Settings::HOENN_STARTERS, Settings::SINNOH_STARTERS, Settings::KALOS_STARTERS, :EEVEE].flatten.include?(data.species)
        end
        list.push(data.species)
    end
    [:TRIPLE_KANTO1, :TRIPLE_JOHTO1, :TRIPLE_HOENN1, :TRIPLE_SINNOH1, :TRIPLE_KALOS1].each do |value|
        next if rand(3) != 0
        list.push(value)
    end
    list.push(:AGUMON, :GABUMON, :PALMON)
    list.push(:PIKACHU) if filter == "Starter"
    list.push(:GREATTUSK, :SCREAMTAIL, :FLUTTERMANE, :SLITHERWING, :SANDYSHOCKS, :ROARINGMOON, :IRONTREADS, :IRONBUNDLE, :IRONJUGULIS, :IRONMOTH, :IRONTHORNS, :IRONVALIANT) if $PokemonGlobal.towervalues[:floor] >= 100
    return list.sample
end

def towerCynthiaEncounter()
    if $PokemonGlobal.towervalues[:floor] == 1
        pbTrainerBattle(:CHAMPION_Sinnoh, "Cynthia", nil, false, 1)
        return
    end
    return if ["Gym", "Elitefour", "Legendary"].include?($PokemonGlobal.towervalues[:activeevent])
    if rand($PokemonGlobal.towervalues[:maxcynthiachance]) < $PokemonGlobal.towervalues[:cynthiachance]
        pbEncounterCynthia([:CHAMPION_Sinnoh, "Cynthia"])
        $PokemonGlobal.towervalues[:cynthiachance] = 0 if !$PokemonGlobal.towervalues.nil?
        return
    end
    $PokemonGlobal.towervalues[:cynthiachance] += 1
end

def generateNextFloor()
    nextfloorevents = getTowerEvents()
    $PokemonGlobal.towervalues[:ladder1] = nextfloorevents[0]
    $PokemonGlobal.towervalues[:ladder2] = nextfloorevents[1]
    $PokemonGlobal.towervalues[:ladder3] = nextfloorevents[2]
    pbSetGraphic(1, "")
    if !$PokemonGlobal.towervalues[:ladder1].nil?
        pbSetGraphic(4, getFloorGraphic($PokemonGlobal.towervalues[:ladder1]))
        pbSetSelfSwitch(5, "A", true)
        pbSetSelfSwitch(13, "A", true)
        pbSetGraphic(6, getFloorGraphic($PokemonGlobal.towervalues[:ladder1]))
    end
    if !$PokemonGlobal.towervalues[:ladder2].nil?
        pbSetGraphic(7, getFloorGraphic($PokemonGlobal.towervalues[:ladder2]))
        pbSetSelfSwitch(8, "A", true)
        pbSetSelfSwitch(14, "A", true)
        pbSetGraphic(9, getFloorGraphic($PokemonGlobal.towervalues[:ladder2]))
    end
    if !$PokemonGlobal.towervalues[:ladder3].nil?
        pbSetGraphic(10, getFloorGraphic($PokemonGlobal.towervalues[:ladder3]))
        pbSetSelfSwitch(11, "A", true)
        pbSetSelfSwitch(15, "A", true)
        pbSetGraphic(12, getFloorGraphic($PokemonGlobal.towervalues[:ladder3]))
    end
end

def getTowerEvents()
    return [nil, "Elitefour", nil] if [81,83,85,87,89].include?($PokemonGlobal.towervalues[:floor])
    return [nil, "Gym", nil] if $PokemonGlobal.towervalues[:floor] % 10 == 9 && ![89].include?($PokemonGlobal.towervalues[:floor])

    nextfloorevents = []
    for _ in 1..3
        eventlist = []
        raritylist = []
        getTowerEventsList().each do |event, rarity|
            next if nextfloorevents.include?(event)
            eventlist.push(event)
            raritylist.push(rarity)
        end
        randomrarity = rand(raritylist.sum)
        raritylist.each_with_index do |rarity, i|
            if randomrarity < rarity
                randomrarity = i
                break
            else
                randomrarity -= rarity
            end
        end
        nextfloorevents.push(eventlist[randomrarity])
    end
    return nextfloorevents
end

def towerIncreaseFloor(nextfloor)
    $PokemonGlobal.towervalues[:activeevent] = $PokemonGlobal.towervalues[nextfloor]
    $PokemonGlobal.towervalues[:floor] += 1
    newlevel = 4 + [$PokemonGlobal.towervalues[:floor], 30].min + [(($PokemonGlobal.towervalues[:floor] - 30) * 66 / 170), 0].max
    Kernel.pbMessage(_INTL("You reached floor {1}!", $PokemonGlobal.towervalues[:floor]))
    Kernel.pbMessage(_INTL("Your party grew to Lv. {1}!", newlevel))
    $Trainer.party.each do |pkmn|
        oldlevel = pkmn.level
        pkmn.level = newlevel
        pkmn.calc_stats
        movelist = pkmn.getMoveList
        moves = []
        for i in movelist
            next if i[0] > pkmn.level || i[0] <= oldlevel
            if pbCynthiaGetBadgeCount <= 3
                pbLearnMove(pkmn, i[1], true)
            else
                Kernel.pbMessage(_INTL("{1} can learn {2}!", pkmn.name, GameData::Move.get(i[1]).name))
            end
        end
        gainedhp = 1
        gainedhp += pkmn.totalhp / 16 if hasEmera?(:APPLE)
        pkmn.hp = [pkmn.hp + gainedhp, pkmn.totalhp].min
        newspecies = pkmn.check_evolution_on_level_up
        if newspecies
          pbFadeOutInWithMusic {
            evo = PokemonEvolutionScene.new
            evo.pbStartScreen(pkmn, newspecies)
            evo.pbEvolution
            evo.pbEndScreen
          }
        end
    end
    if hasEmera?(:BREWINGSTAND)
        itemlist = [:FULLHEAL, :FULLRESTORE, :HYPERPOTION, :MAXELIXIR, :MAXPOTION, :POTION, :SUPERPOTION, :ANTIDOTE, :AWAKENING, :BURNHEAL, :ICEHEAL, :PARALYZEHEAL, :ELIXIR, :ETHER, :MAXETHER]
        item = itemlist.sample
        $PokemonBag.pbStoreItem(item)
    end
    pbSetSelfSwitch(2, "A", false)
    case $PokemonGlobal.towervalues[:activeevent]
    when "Legendary"
        $PokemonGlobal.towervalues[:eventvariable] = $PokemonGlobal.towervalues[:legendarylist].sample
        $PokemonGlobal.towervalues[:legendarylist].delete_if {|i| i == $PokemonGlobal.towervalues[:eventvariable]}
    when "Unknown"
        $PokemonGlobal.towervalues[:eventvariable] = ["Cynthia", "Hot Spring"].sample #todo
    end
    pbSetGraphic(1, getFloorGraphic($PokemonGlobal.towervalues[:activeevent]))
    pbSetGraphic(4, "")
    pbSetSelfSwitch(5, "A", false)
    pbSetSelfSwitch(13, "A", false)
    pbSetGraphic(6, "")
    pbSetGraphic(7, "")
    pbSetSelfSwitch(8, "A", false)
    pbSetSelfSwitch(14, "A", false)
    pbSetGraphic(9, "")
    pbSetGraphic(10, "")
    pbSetSelfSwitch(11, "A", false)
    pbSetSelfSwitch(15, "A", false)
    pbSetGraphic(12, "")
end

def getTowerEventsList()
    eventlist =  {
        "Pokemon" => 50,
        "Chest" => 25,
        "Unknown" => 0, #todo
        "Miku" => 10,
        "Shop" => 10,
        "Heal" => 10,
        "Tutor" => 25,
        "Legendary" => [$PokemonGlobal.towervalues[:floor] - 46, 0].max / 3,
    }
    eventlist["Pokemon"] *= 2 if $PokemonGlobal.towervalues[:floor] <= 10
    eventlist["Miku"] = 0 if getEmeras.flatten.length == 0
    eventlist["Miku"] = 0 if $PokemonGlobal.towervalues[:floor] <= 5
    eventlist["Shop"] = 0 if $PokemonGlobal.towervalues[:floor] <= 5
    eventlist["Shop"] /= 2 if $PokemonGlobal.towervalues[:floor] <= 20
    eventlist["Legendary"] = 0 if $PokemonGlobal.towervalues[:legendarylist].length == 0
    $Trainer.party.each do |pkmn|
        eventlist["Heal"] += 10 if pkmn.hp <= pkmn.totalhp / 10
    end
    eventlist["Heal"] += 100 if $PokemonGlobal.towervalues[:floor] % 10 == 8
    eventlist["Heal"] += 50 if $PokemonGlobal.towervalues[:floor] == 1
    return eventlist
end

def towerEvent()
    case $PokemonGlobal.towervalues[:activeevent]
    when "Pokemon"
        options = [getTowerPokemon(), getTowerPokemon(), getTowerPokemon()]
        if hasEmera?(:CAPTURESTYLER)
            options.push(getTowerPokemon())
            choice = Kernel.pbMessage("Pick one", [_INTL("{1}", PBSpecies.getName(options[0])), _INTL("{1}", PBSpecies.getName(options[1])), _INTL("{1}", PBSpecies.getName(options[2])), _INTL("{1}", PBSpecies.getName(options[3]))])
        else
            choice = Kernel.pbMessage("Pick one", [_INTL("{1}", PBSpecies.getName(options[0])), _INTL("{1}", PBSpecies.getName(options[1])), _INTL("{1}", PBSpecies.getName(options[2]))])
        end
        pbAddPokemon(options[choice], 5)
        $PokemonBag.pbStoreItem(:SINNOHCOIN) if hasEmera?(:ROTOMDEX)
    when "Chest"
        enderChest()
    when "Unknown"
        case $PokemonGlobal.towervalues[:eventvariable]
        when "Cynthia"
            return if !pbEncounterCynthia([:CHAMPION_Sinnoh, "Cynthia"])
        when "Hot Spring"
            choice = Kernel.pbMessage("You encounter a Torkoal heating up a spring." ["Soak in the water.", "Fight.", "Gather herbs nearby."])
            case choice
            when 0
                Kernel.pbMessage("Your Pokemon heal from the rest.")
            when 1
                return if !pbLegendaryBattle("Torkoal")
            when 2
                pbItemBall(:REVIVALHERB, 3)
                pbItemBall(:ENERGYROOT, 5)
                Kernel.pbMessage("The Torkoal left while you gathered herbs.")
            end
        when "Berry Tree"
            choice = Kernel.pbMessage("You spot a large berry tree next to the road." ["Gather some Berries.", "Shake the tree.", "Water the tree."])
            case choice
            when 0
            when 1
                Kernel.pbMessage("An angry Heracross flies out of the tree.")
                return if !pbLegendaryBattle("Heracross")
            when 2
            end
        end
    when "Miku"
        pbEncounterCynthia([:CREATOR_Minecraft, "Hatsune Miku"], [nil, :Sound_of_Future])
        return if $PokemonGlobal.towervalues.nil?
        grantRandomEmera if hasEmera?(:WISHINGSTAR)
        grantRandomEmera
    when "Shop"
        Undertale()
        return if $PokemonGlobal.towervalues.nil?
    when "Heal"
        $Trainer.party.each do |pkmn|
            pkmn.heal
        end
        Kernel.pbMessage(_INTL("Your Pokémon were fully healed."))
    when "Tutor"
        while true
            chosen = 0
            pbFadeOutIn {
                scene = PokemonParty_Scene.new
                screen = PokemonPartyScreen.new(scene, $Trainer.party)
                screen.pbStartScene(_INTL("Choose a Pokémon."), false)
                chosen = screen.pbChoosePokemon
                screen.pbEndScene
            }
            if chosen < 0
                break if Kernel.pbMessage("Skip tutoring a move?", ["No", "Yes"]) == 1
            else
                break if pbTowerMoveScreen($Trainer.party[chosen])
            end
        end
    when "Legendary"
        case $PokemonGlobal.towervalues[:eventvariable]
        when "Articuno", "Mew", "Moltres", "Zapdos"
            $PokemonGlobal.nextBattleBGM = "Legendary Birds"
        when "Diancie"
            $PokemonGlobal.nextBattleBGM = "VSDiancie"
        when "Entei", "Suikou"
            $PokemonGlobal.nextBattleBGM = "VSBeasts"
        when "Genesect"
            $PokemonGlobal.nextBattleBGM = "VSMiguel"
        when "Latias"
            $PokemonGlobal.nextBattleBGM = "VSLati"
        when "Meloetta"
            $PokemonGlobal.nextBattleBGM = "VSMeloetta"
        when "Reshirom"
            $PokemonGlobal.nextBattleBGM = "VSReshiramZekrom"
        end
        if $PokemonGlobal.towervalues[:eventvariable] == "Genesect"
            return if !pbTrainerBattle(:SUPERNERD, "Miguel", nil, false, 8)
            pbAddPokemon(:GENESECT, 5)
            $PokemonBag.pbStoreItem(:OMNIDRIVE)
            $PokemonBag.pbStoreItem(:BURNDRIVE)
            $PokemonBag.pbStoreItem(:SHOCKDRIVE)
            $PokemonBag.pbStoreItem(:DOUSEDRIVE)
            $PokemonBag.pbStoreItem(:CHILLDRIVE)
        else
            return if !pbLegendaryBattle($PokemonGlobal.towervalues[:eventvariable])
            pbAddPokemon(:MELOETTA_A, 5) if $PokemonGlobal.towervalues[:eventvariable] == "Meloetta"
        end
        $PokemonGlobal.towervalues[:eventvariable] = nil
    when "Gym"
        case $PokemonGlobal.towervalues[:badges]
        when 0
            $PokemonGlobal.nextBattleBGM = "kanto_gym_battle-BW"
            return if !pbTrainerBattle(:LEADER_Brock, "Brock")
        when 1
            $PokemonGlobal.nextBattleBGM = "kanto_gym_battle-BW"
            return if !pbTrainerBattle(:LEADER_Misty, "Misty")
        when 2
            $PokemonGlobal.nextBattleBGM = "kanto_gym_battle-BW"
            return if !pbTrainerBattle(:LEADER_Surge, "Lt. Surge")
        when 3
            $PokemonGlobal.nextBattleBGM = "kanto_gym_battle-BW"
            return if !pbTrainerBattle(:LEADER_Erika, "Erika")
        when 4
            $PokemonGlobal.nextBattleBGM = "kanto_gym_battle-BW"
            return if !pbTrainerBattle(:LEADER_Koga, "Koga")
        when 5
            $PokemonGlobal.nextBattleBGM = "kanto_gym_battle-BW"
            return if !pbTrainerBattle(:LEADER_Sabrina, "Sabrina")
        when 6
            $PokemonGlobal.nextBattleBGM = "kanto_gym_battle-BW"
            return if !pbTrainerBattle(:LEADER_Blaine, "Blaine")
        when 7
            $PokemonGlobal.nextBattleBGM = "Giovanni"
            return if !pbTrainerBattle(:LEADER_Giovanni, "Giovanni")
        when 8
            $PokemonGlobal.nextBattleBGM = "johto_gym_battle-BW"
            return if !pbTrainerBattle(:LEADER_Whitney, "Whitney")
        when 9
            $PokemonGlobal.nextBattleBGM = "johto_gym_battle-BW"
            return if !pbTrainerBattle(:LEADER_Kurt, "Kurt")
        when 10
            $PokemonGlobal.nextBattleBGM = "johto_gym_battle-BW"
            return if !pbTrainerBattle(:LEADER_Falkner, "Falkner")
        when 11
            $PokemonGlobal.nextBattleBGM = "johto_gym_battle-BW"
            return if !pbTrainerBattle(:LEADER_Clair, "Clair")
        when 12
            $PokemonGlobal.nextBattleBGM = "johto_gym_battle-BW"
            return if !pbTrainerBattle(:LEADER_Morty, "Morty")
        when 13
            $PokemonGlobal.nextBattleBGM = "johto_gym_battle-BW"
            return if !pbTrainerBattle(:LEADER_Pryce, "Pryce")
        when 14
            $PokemonGlobal.nextBattleBGM = "johto_gym_battle-BW"
            return if !pbTrainerBattle(:LEADER_Jasmine, "Jasmine")
        when 15
            $PokemonGlobal.nextBattleBGM = "johto_gym_battle-BW"
            return if !pbTrainerBattle(:LEADER_Chuck, "Chuck")
        end
        grantRandomEmera
        $PokemonGlobal.towervalues[:badges] += 1
    when "Elitefour"
        case $PokemonGlobal.towervalues[:floor]
        when 81, 82
            $PokemonGlobal.nextBattleBGM = "kanto_gym_battle-BW"
            return if !pbTrainerBattle(:ELITEFOUR_Lorelei, "Lorelei")
        when 83, 84
            $PokemonGlobal.nextBattleBGM = "kanto_gym_battle-BW"
            return if !pbTrainerBattle(:ELITEFOUR_Bruno, "Bruno")
        when 85, 86
            $PokemonGlobal.nextBattleBGM = "kanto_gym_battle-BW"
            return if !pbTrainerBattle(:ELITEFOUR_Agatha, "Agatha")
        when 87, 88
            $PokemonGlobal.nextBattleBGM = "kanto_gym_battle-BW"
            return if !pbTrainerBattle(:ELITEFOUR_Lance, "Lance", nil, false, 2)
        when 89, 90
            $PokemonGlobal.nextBattleBGM = "champion_blue"
            return if !pbTrainerBattle(:CHAMPION, "Blue")
        end
        grantRandomEmera
    when nil
        return
    end
    $PokemonGlobal.towervalues[:activeevent] = nil
    generateNextFloor
end

def getFloorGraphic(event)
    case event
    when "Pokemon"
        return "BW164"
    when "Chest"
        return "ChestSprite"
    when "Unknown"
        case $PokemonGlobal.towervalues[:eventvariable]
        when "Cynthia"
            return "BW126"
        when "Hot Spring"
            return "TORKOAL"
        when nil
            return "201_27"
        end
    when "Miku"
        return "HatsuneMiku"
    when "Shop"
        return "TheSketon"
    when "Heal"
        return "BWNurse"
    when "Tutor"
        return "Claire_Overworld"
    when "Legendary"
        case $PokemonGlobal.towervalues[:eventvariable]
        when "Articuno"
            return "144"
        when "Diancie"
            return "DIANCIE"
        when "Entei"
            return "244_0"
        when "Genesect"
            return "fossil_nerd"
        when "Latias"
            return "LATIAS"
        when "Meloetta"
            return "melostand"
        when nil, "Mew"
            return "151"
        when "Moltres"
            return "146"
        when "Reshirom"
            return "BW (5)"
        when "Suikou"
            return "243_245"
        when "Zapdos"
            return "145"
        end
    when "Gym"
        return ["BW_brock", "BWLeaderMisty", "BW_surge", "BW_Erika", "BW_koga2", "BW_Sabrina", "BW_Blaine", "BW_giovanni", "BW_Whitney", "Kurt_overworld_by_Knuckles", "BW_Falkner", "BW_Clair", "BW_Morty", "BW_Pryce", "BW_Jasmine", "BW_Chuck"][$PokemonGlobal.towervalues[:badges]]
    when "Elitefour"
        case $PokemonGlobal.towervalues[:floor]
        when 81, 82
            return "BW_Lorelei"
        when 83, 84
            return "Bruno_OW"
        when 85, 86
            return "Agatha_OW"
        when 87, 88
            return "BW_Lance"
        when 89, 90
            return "gary_oak_overworld_bw_completed_by_malice936-d5ruwuc"
        end
    end
end

def getNextFloorDescription(nextfloor)
    message = ""
    case $PokemonGlobal.towervalues[nextfloor]
    when "Pokemon"
        message = "Pick one of three pokemon."
    when "Chest"
        message = "Gain some items."
    when "Unknown"
        message = "?"
    when "Miku"
        message = "Fight Hatsune Miku for an Emera."
    when "Shop"
        message = "Spend Sinnoh Coins at the skeleton shop."
    when "Heal"
        message = "Heal up, you'll need it."
    when "Tutor"
        message = "Learn an obtainable move."
    when "Legendary"
        message = "Fight a legendary battle."
    when "Gym"
        message = "Fight a Gym Trainer and earn a badge."
    when "Elitefour"
        message = "Fight a Pokemon League member."
    when nil
        return
    end
    Kernel.pbMessage(message)
end

def pbTowerMoveScreen(pkmn)
    retval = true
    pbFadeOutIn {
        scene = MoveRelearner_Scene.new
        screen = MoveRelearnerScreen.new(scene)
        retval = screen.pbStartScreenTower(pkmn)
    }
    return retval
end

class MoveRelearnerScreen
    def pbStartScreenTower(pkmn)
        moves = []
        tutorUtil = FusionTutorService.new(pkmn)
        pbCreatePreEvolutionTree(pkmn.species).each do |species|
          moves.push(pbGetSpeciesEggMoves(species))
          moves.push(GameData::Species.get_species_form(species, 0).tutor_moves)
          moves.push(pbGetRelearnableMoves(pkmn))
          moves.push(tutorUtil.getCompatibleMoves(false))
          moves.push(tutorUtil.getCompatibleMoves(true))
        end
        moves = moves.flatten.uniq

        @scene.pbStartScene(pkmn, moves)
        loop do
            move = @scene.pbChooseMove
            if move
                if @scene.pbConfirm(_INTL("Teach {1}?", GameData::Move.get(move).name))
                    if pbLearnMove(pkmn, move)
                        @scene.pbEndScene
                        return true
                    end
                end
            else
                @scene.pbEndScene
                return false
            end
        end
    end
end

def getTowerItems()
    items = [
        [ #common
            [:AIRBALLOON, 5],
            [:BRIGHTPOWDER, 1],
            [:ROCKYHELMET, 1],
            [:EJECTBUTTON, 5],
            [:REDCARD, 5],
            [:SHEDSHELL, 1],
            [:SMOKEBALL, 1],
            [:GRIPCLAW, 1],
            [:BINDINGBAND, 1],
            [:BIGROOT, 1],
            [:SHELLBELL, 1],
            [:MENTALHERB, 5],
            [:WHITEHERB, 5],
            [:POWERHERB, 5],
            [:MUSCLEBAND, 1],
            [:WISEGLASSES, 1],
            [:RAZORCLAW, 1],
            [:SCOPELENS, 1],
            [:WIDELENS, 1],
            [:ZOOMLENS, 1],
            [:KINGSROCK, 1],
            [:RAZORFANG, 1],
            [:QUICKCLAW, 1],
            [:FOCUSBAND, 1],
            [:FOCUSSASH, 5],
            [:HYPERPOTION, 5],
            [:FULLHEAL, 5],
            [:REVIVE, 1],
            [:HPUP, 5],
            [:PROTEIN, 5],
            [:IRON, 5],
            [:CALCIUM, 5],
            [:ZINC, 5],
            [:CARBOS, 5],
            [:LUMBERRY, 5],
            [:SITRUSBERRY, 5],
            [:MANKEYPAW, 1],
            [:ABILITYCAPSULE, 5],
            [:BERSERKGENE, 5],
            [:BANANA, 5],
            [:SAFETYGOGGLES, 1],
            [:PROTECTIVEPADS, 1],
            [:TERRAINEXTENDER, 1],
            [:ELECTRICSEED, 5],
            [:PSYCHICSEED, 5],
            [:MISTYSEED, 5],
            [:GRASSYSEED, 5],
            [:WEAKNESSPOLICY, 5],
            [:GOLDENBOTTLECAP, 5],
            [:ABILITYPATCH, 5],
            [:HEALTHMOCHI, 5],
            [:MUSCLEMOCHI, 5],
            [:RESISTMOCHI, 5],
            [:GENIUSMOCHI, 5],
            [:CLEVERMOCHI, 5],
            [:SWIFTMOCHI, 5],
            [:REDCARD, 5],
            [:DUSKSTONE, 1],
            [:FIRESTONE, 1],
            [:LEAFSTONE, 1],
            [:MOONSTONE, 1],
            [:SHINYSTONE, 1],
            [:SUNSTONE, 1],
            [:THUNDERSTONE, 1],
            [:WATERSTONE, 1],
            [:METALCOAT, 1],
            [:DAWNSTONE, 1],
            [:ICESTONE, 1],
            [:WHIPPEDDREAM, 1],
            [:EJECTPACK, 5],
            [:BLUNDERPOLICY, 5],
            [:THROATSPRAY, 5],
            [:SILKSCARF, 1],
            [:BLACKBELT, 1],
            [:BLACKGLASSES, 1],
            [:CHARCOAL, 1],
            [:DRAGONFANG, 1],
            [:HARDSTONE, 1],
            [:MAGNET, 1],
            [:MIRACLESEED, 1],
            [:MYSTICWATER, 1],
            [:NEVERMELTICE, 1],
            [:POISONBARB, 1],
            [:SHARPBEAK, 1],
            [:SILVERPOWDER, 1],
            [:SOFTSAND, 1],
            [:SPELLTAG, 1],
            [:TWISTEDSPOON, 1],
            [:HEATROCK, 1],
            [:DAMPROCK, 1],
            [:SMOOTHROCK, 1],
            [:ICYROCK, 1],
            [:LOADEDDICE, 1],
            [:REPEL, 1],
        ],
        [ #rare
            [:EVIOLITE, 1],
            [:REAPERCLOTH, 1],
            [:MAGMARIZER, 1],
            [:ELECTIRIZER, 1],
            [:PROTECTOR, 1],
            [:DUBIOUSDISC, 1],
            [:LIGHTCLAY, 1],
            [:BLACKSLUDGE, 1],
            [:EXPERTBELT, 1],
            [:METRONOME, 1],
            [:FLAMEORB, 1],
            [:TOXICORB, 1],
            [:FROSTORB, 1],
            [:SHOCKORB, 1],
            [:LIGHTBALL, 1],
            [:THICKCLUB, 1],
            [:STICK, 1],
            [:MAXPOTION, 5],
            [:FULLRESTORE, 5],
            [:MAXREVIVE, 1],
            [:REVIVALHERB, 1],
            [:PPMAX, 1],
            [:PRISMSCALE, 1],
            [:DRAGONSCALE, 1],
            [:DEEPSEASCALE, 1],
            [:DEEPSEATOOTH, 1],
            [:UPGRADE, 1],
            [:OVALSTONE, 1],
            [:LUCKYPUNCH, 1],
            [:FISTPLATE, 1],
            [:DREADPLATE, 1],
            [:FLAMEPLATE, 1],
            [:DRACOPLATE, 1],
            [:STONEPLATE, 1],
            [:ZAPPLATE, 1],
            [:IRONPLATE, 1],
            [:MEADOWPLATE, 1],
            [:SPLASHPLATE, 1],
            [:ICICLEPLATE, 1],
            [:PIXIEPLATE, 1],
            [:TOXICPLATE, 1],
            [:SKYPLATE, 1],
            [:INSECTPLATE, 1],
            [:EARTHPLATE, 1],
            [:SPOOKYPLATE, 1],
            [:MINDPLATE, 1],
            [:METALPOWDER, 1],
            [:QUICKPOWDER, 1],
        ],
        [ #super rare
            [:CHOICEBAND, 1],
            [:CHOICESPECS, 1],
            [:CHOICESCARF, 1],
            [:LEFTOVERS, 1],
            [:LIFEORB, 1],
            [:ASSAULTVEST, 1],
            [:DIAMONDCHESTPLATE, 1],
            [:HEAVYDUTYBOOTS, 1],
            [:MISTSTONE, 1],
            [:ENCHANTINGTABLE, 1],
        ],
        [ #secret rare
            [:SACREDASH, 1],
            [:BUNDLEOFBALLOONS, 1],
            #[:TOTEMOFUNDYING, 1],
            #[:ENDCRYSTAL, 1],
            [:ELYTRA, 1],
            #[:ENDERPEARL, 1],
            #[:GOLDENAPPLE, 1],
            [:WELLSPRINGMASK, 1],
            [:HEARTHFLAMEMASK, 1],
            [:CORNERSTONEMASK, 1],
        ],
        [ #ultimate rare
            [:PYRITE, 1],
            [:MEGASHARD, 1],
            [:MODIFIEDBOOSTERENERGY, 1],
        ],
    ]

    items[3].push([:BEEGPP, 1]) if !$PokemonBag.pbHasItem?(:BEEGPP)
    items[3].push([:HPMAX, 1]) if !$PokemonBag.pbHasItem?(:HPMAX)
    items[3].push([:GOLDENBANANA, 1]) if !$PokemonBag.pbHasItem?(:GOLDENBANANA)
    items[3].push([:MECHUMETAL, 1]) if !$PokemonBag.pbHasItem?(:MECHUMETAL)

    items[4].push([:OMNIDRIVE, 1]) if !$PokemonBag.pbHasItem?(:OMNIDRIVE)

    return items
end