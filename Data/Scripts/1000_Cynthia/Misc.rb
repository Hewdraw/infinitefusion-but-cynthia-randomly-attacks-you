PARADOXLIST = {
    [:ENTEI] => [:GOUGINGFIRE],
    [:SUICUNE] => [:WALKINGWAKE],
    [:RAIKOU] => [:RAGINGBOLT],
    [:ENRAICUNE] => [:MAIMINGSOUL],
    [:PHANPY, :DONPHAN] => [:GREATTUSK, :IRONTREADS],
    [:IGGLYBUFF, :JIGGLYPUFF, :WIGGLYTUFF] => [:SCREAMTAIL],
    [:MISDREAVUS, :MISMAGIUS] => [:FLUTTERMANE],
    [:LARVESTA, :VOLCARONA] => [:IRONMOTH, :SLITHERWING],
    [:MAGNEMITE, :MAGNETON, :MAGNEZONE] => [:SANDYSHOCKS],
    [:BAGON, :SHELGON, :SALAMENCE] => [:ROARINGMOON],
    [:DELIBIRD] => [:IRONBUNDLE],
    [:DEINO, :ZWEILOUS, :HYDREIGON] => [:IRONJUGULIS],
    [:LARVITAR, :PUPITAR, :TYRANITAR] => [:IRONTHORNS],
    [:RALTS, :KIRLIA, :GARDEVOIR, :GALLADE] => [:IRONVALIANT],
    [:MAKUHITA, :HARIYAMA] => [:IRONHANDS],
    [:DIANCIE] => [:MAGEARNA],
    [:GENESECT] => [:REAPINGSHELL],
    [:KABUTO, :KABUTOPS] => [:IRONHARVESTER],
    [:RESHIRAM] => [:ZEKROM],
    [:CHARIZARD] => [:METALGREYMON],
    [:WARGREYMON] => [:CHARIZARD],
    [:CHARMELEON] => [:GREYMON],
    [:CHARMANDER] => [:AGUMON],
    [:FERALIGATR] => [:WEREGARURUMON],
    [:METALGARURUMON] => [:FERALIGATR],
    [:CROCONAW] => [:GARURUMON],
    [:TOTODILE] => [:GABUMON],
    [:VENUSAUR] => [:LILLYMON],
    [:ROSEMON, :ROSEMONBM] => [:VENUSAUR],
    [:IVYSAUR] => [:TOGEMON],
    [:BULBASAUR] => [:PALMON],
    [:SQUIRTLE, :WARTORTLE, :BLASTOISE] => [:MACHINEDRAMON],
    [:MELOETTA_P, :MELOETTA_A] => [:VOCALLEEK, :VOCALDRILL, :VOCALCELL],
    [:ROTOM] => [:STEREOROTOM],
    [:GIBLE, :GABITE, :GARCHOMP] => [:ALPHAMON],
}


REGIONALLIST = [
    [:RATTATA, :ALOLARATTATA],
    [:RATICATE, :ALOLARATICATE],
    [:RAICHU, :ALOLARAICHU],
    [:SANDSHREW, :ALOLASANDSHREW],
    [:SANDSLASH, :ALOLASANDSLASH],
    [:VULPIX, :ALOLAVULPIX],
    [:NINETALES, :ALOLANINETALES],
    [:DIGLETT, :ALOLADIGLETT],
    [:DUGTRIO, :ALOLADUGTRIO],
    [:MEOWTH, :ALOLAMEOWTH, :GALARMEOWTH],
    [:PERSIAN, :ALOLAPERSIAN, :GALARPERSIAN],
    [:PERRSERKER, :ALOLAPERRSERKER, :KANTOPERRSERKER],
    [:GROWLITHE, :HISUIGROWLITHE],
    [:ARCANINE, :HISUIARCANINE],
    [:GEODUDE, :ALOLAGEODUDE],
    [:GRAVELER, :ALOLAGRAVELER],
    [:GOLEM, :ALOLAGOLEM],
    [:PONYTA, :GALARPONYTA],
    [:RAPIDASH, :GALARRAPIDASH],
    [:SLOWPOKE, :GALARSLOWPOKE],
    [:SLOWBRO, :GALARSLOWBRO],
    [:SLOWKING, :GALARSLOWKING],
    [:FARFETCHD, :GALARFARFETCHD],
    [:SIRFETCHD, :KANTOSIRFETCHD],
    [:GRIMER, :ALOLAGRIMER],
    [:MUK, :ALOLAMUK],
    [:VOLTORB, :HISUIVOLTORB],
    [:ELECTRODE, :HISUIELECTRODE],
    [:EXEGGUTOR, :ALOLAEXEGGUTOR],
    [:MAROWAK, :ALOLAMAROWAK],
    [:WEEZING, :GALARWEEZING],
    [:MRMIME, :GALARMRMIME],
    [:MRRIME, :KANTOMRRIME],
    [:TAUROS, :PALDEATAUROS, :PALDEATAUROSFIRE, :PALDEATAUROSWATER],
    [:ARTICUNO, :GALARARTICUNO],
    [:ZAPDOS, :GALARZAPDOS],
    [:MOLTRES, :GALARMOLTRES],
    [:ZAPMOLTICUNO, :GALARZAPMOLTICUNO],
    [:TYPHLOSION, :HISUITYPHLOSION],
    [:WOOPER, :PALDEAWOOPER],
    [:QUAGSIRE, :PALDEAQUAGSIRE],
    [:CLODSIRE, :JOHTOCLODSIRE],
    [:QWILFISH, :HISUIQWILFISH],
    [:OVERQWIL, :JOHTOOVERQWIL],
    [:SNEASEL, :HISUISNEASEL],
    [:WEAVILE, :HISUIWEAVILE],
    [:SNEASLER, :JOHTOSNEASLER],
    [:CORSOLA, :GALARCORSOLA],
    [:CURSOLA, :JOHTOCURSOLA],
    [:ZIGZAGOON, :GALARZIGZAGOON],
    [:LINOONE, :GALARLINOONE],
    [:OBSTAGOON, :HOENNOBSTAGOON],
    [:YAMASK, :GALARYAMASK],
    [:COFAGRIGUS, :GALARCOFAGRIGUS],
    [:RUNERIGUS, :UNOVARUNERIGUS],
    [:ZORUA, :HISUIZORUA],
    [:ZOROARK, :HISUIZOROARK],
    [:STUNFISK, :GALARSTUNFISK],
    [:SLIGGOO, :HISUISLIGGOO],
    [:GOODRA, :HISUIGOODRA],
    [:URSALUNA, :BLOODMOONURSALUNA],
    [:SHELLOS_E, :SHELLOS_W],
    [:GASTRODON_E, :GASTRODON_W],
    [:LYCANROC_D, :LYCANROC_N, :DUSKLYCANROC],
]

TRIPLEFUSIONS = {
    :ZAPMOLTICUNO => [[:ARTICUNO, :GALARARTICUNO], [:ZAPDOS, :GALARZAPDOS], [:MOLTRES, :GALARMOLTRES]],
    :ENRAICUNE => [[:RAIKOU, :RAGINGBOLT], [:ENTEI, :GOUGINGFIRE], [:SUICUNE, :WALKINGWAKE]],
    :KYODONQUAZA => [[:KYOGRE], [:GROUDON], [:RAYQUAZA]],
    :PALDIATINA => [[:PALKIA, :PALKIAORIGIN], [:DIALGA, :DIALGAORIGIN], [:GIRATINA, :GIRATINAORIGIN]],
    :ZEKYUSHIRAM => [[:ZEKROM], [:RESHIRAM], [:KYUREM]],
    :CELEMEWCHI => [[:MEW], [:CELEBI], [:JIRACHI]],
    :DEOSECTWO => [[:MEWTWO], [:DEOXYS], [:GENESECT]],
    #todo regis
    :TRIPLE_KANTO1 => [[:BULBASAUR, :IVYSAUR, :VENUSAUR, :PALMON, :TOGEMON, :LILLYMON, :ROSEMON, :ROSEMONBM], [:CHARMANDER, :CHARMELEON, :CHARIZARD, :AGUMON, :GREYMON, :METALGREYMON, :WARGREYMON, :OMNIMON], [:SQUIRTLE, :WARTORTLE, :BLASTOISE, :MACHINEDRAMON]],
    :TRIPLE_JOHTO1 => [[:CHIKORITA, :BAYLEAF, :MEGANIUM], [:CYNDAQUIL, :QUILAVA, :TYPHLOSION, :HISUITYPHLOSION], [:TOTODILE, :CROCONAW, :FERALIGATR, :GABUMON, :GARURUMON, :WEREGARURUMON, :METALGARURUMON, :OMNIMON]],
    :TRIPLE_HOENN1 => [[:TREECKO, :GROVYLE, :SCEPTILE], [:TORCHIC, :COMBUSKEN, :BLAZIKEN], [:MUDKIP, :MARSHTOMP, :SWAMPERT]],
    :TRIPLE_SINNOH1 => [[:TURTWIG, :GROTLE, :TORTERRA], [:CHIMCHAR, :MONFERNO, :INFERNAPE], [:PIPLUP, :PRINPLUP, :EMPOLEON]],
    :TRIPLE_KALOS1 => [[:CHESPIN, :QUILLADIN, :CHESNAUGHT], [:FENNEKIN, :BRAIXEN, :DELPHOX], [:FROAKIE, :FROGADIER, :GRENINJA]],
    :SHROOMAWGROSS => [[:MAWILE], [:SHROOMISH, :BRELOOM], [:BELDUM, :METANG, :METAGROSS]],
    :RATEKANDSHREW => [[:RATTATA, :RATICATE, :ALOLARATTATA, :ALOLARATICATE], [:EKANS, :ARBOK, :SEVIPER], [:SANDSHREW, :SANDSLASH, :ALOLASANDSHREW, :ALOLASANDSLASH]],
    :MISTEON => [[:EEVEE, :VAPOREON, :JOLTEON, :FLAREON, :ESPEON, :UMBREON, :GLACEON, :LEAFEON, :SYLVEON, :KECLEON]],
    :DUGTRIO => [[:DIGLETT]],
    :ALOLADUGTRIO => [[:ALOLADIGLETT]],
    :MAGNETON => [[:MAGNEMITE]],
}

TRIPLETYPES = {
    :ICEFIREELECTRICFLYING => [:ICE, :FIRE, :ELECTRIC, :FLYING],
    :FIREWATERELECTRIC => [:FIRE, :WATER, :ELECTRIC],
    :WATERGROUNDFLYINGDRAGON => [:WATER, :GROUND, :FLYING, :DRAGON],
    :GHOSTSTEELWATERDRAGON => [:GHOST, :STEEL, :WATER, :DRAGON],
    :FIREWATERGRASS => [:FIRE, :WATER, :GRASS],
    :GRASSSTEELPSYCHIC => [:GRASS, :STEEL, :PSYCHIC],
    :BUGSTEELPSYCHIC => [:BUG, :STEELP, :SYCHIC],
    :ICEROCKSTEELELECTRICDRAGON => [:ICE, :ROCK, :STEEL, :ELECTRIC, :DRAGON],
    :ELECTRICDRAGON => [:ELECTRIC, :DRAGON],
    :ICEFIREELECTRICDRAGON => [:ICE, :FIRE, :ELECTRIC, :DRAGON],
    :PSYCHICDARKFIGHTINGFLYING => [:PSYCHIC, :DARK, :FIGHTING, :FLYING],
    :FIREWATERELECTRICDRAGON => [:FIRE, :WATER, :ELECTRIC, :DRAGON],
    :NORMALFIGHTINGFLYINGPOISONGROUNDROCKBUGGHOSTSTEELFIREWATERGRASSELECTRICPSYCHICICEDRAGONDARKFAIRY => [:NORMAL, :FIGHTING, :FLYING, :POISON, :GROUND, :ROCK, :BUG, :GHOST, :STEEL, :FIRE, :WATER, :GRASS, :ELECTRIC, :PSYCHIC, :ICE, :DRAGON, :DARK, :FAIRY],
    :FLYINGGROUNDFIREWATERELECTRICDRAGONFAIRY => [:FLYING, :GROUND, :FIRE, :WATER, :ELECTRIC, :DRAGON, :FAIRY],
    :FLYINGDRAGONFAIRY => [:FLYING, :DRAGON, :FAIRY],
    :FIREWATERGRASSFLYINGPOISON => [:FIRE, :WATER, :GRASS, :FLYING, :POISON],
    :FIREWATERGRASSFIGHTINGGROUND => [:FIRE, :WATER, :GRASS, :FIGHTING, :GROUND],
    :FIREWATERGRASSFIGHTINGGROUNDSTEEL => [:FIRE, :WATER, :GRASS, :FIGHTING, :GROUND, :STEEL],
    :FIREWATERGRASSFIGHTINGPSYCHICDARK => [:FIRE, :WATER, :GRASS, :FIGHTING, :PSYCHIC, :DARK],
    :FAIRYGRASSPSYCHICSTEELFIGHTINGGUN => [:FAIRY, :GRASS, :PSYCHIC, :STEEL, :FIGHTING, :GUN],
    :DARKNORMALPOISONGROUNDICESTEEL => [:DARK, :NORMAL, :POISON, :GROUND, :ICE, :STEEL],
    :QMARKSGUNSOUND => [:QMARKS, :GUN, :SOUND],
}

def tripleFusion(item=false)
    $PokemonGlobal.triplefusions = [] if $PokemonGlobal.triplefusions.nil?
    TRIPLEFUSIONS.each do |triple, materials|
        next if $PokemonGlobal.triplefusions.include?(triple)
        materialcount = []
        if materials.length == 1
            $Trainer.party.each do |mon|
                materials[0].each do |material|
                    materialcount.push(material) if mon.isFusionOf(material)
                end
            end
        else
            materials.each do |material|
                material.each do |mat|
                    next unless $Trainer.has_species_or_fusion?(mat)
                    materialcount.push(mat)
                    break
                end
            end
        end
        next if materialcount.length < [materials.length, 3].max()
        $PokemonGlobal.triplefusions.push(triple)
        if !item
            pbCallBub(2, 43)
            materialstring = "Your "
            materialcount.each_with_index do |material, i|
                materialstring += GameData::Species.get(material).real_name
                if i == materialcount.length - 2
                    materialstring += " and "
                else
                    materialstring += ", "
                end
            end
            materialstring += "..."
            Kernel.pbMessage(materialstring)
            pbCallBub(2, 43)
            Kernel.pbMessage("My machine could clone them into a single Pokémon.")
            pbCallBub(2, 43)
            choice = Kernel.pbMessage("Would you like to do this?", ["Yes", "No"])
            if choice == 1
                pbCallBub(2, 43)
                Kernel.pbMessage("Are you fucking stupid? I'm doing it anyways.")
            else
                pbCallBub(2, 43)
                Kernel.pbMessage("Very well... Let's proceed then.")
            end
            pbSet(3, triple)
        else
            materialstring = "Fusing together "
            materialcount.each_with_index do |material, i|
                materialstring += GameData::Species.get(material).real_name
                if i == materialcount.length - 2
                    materialstring += " and "
                else
                    materialstring += ", "
                end
            end
            materialstring += "."
            Kernel.pbMessage(materialstring)
            pbAddPokemon(triple, 5)
        end
        return true
    end
    return false
end

def transForm(pkmn, species)
    level = pkmn.level
    pbMessage(_INTL("{1} changed form!", pkmn.name))
    pkmn.species = species
    movelist = pkmn.getMoveList
    for i in movelist
        next if i[0]!=0
        pbLearnMove(pkmn,i[1],true)
    end
    if pkmn.miststone
        preevo = GameData::Species.get(pkmn.species).get_previous_species
        evolutions = GameData::Species.get(preevo).get_evolutions(true)
        evolutions.each do |evolution|
            next unless evolution[2] == :MISTSTONE
            pkmn.ability = :FORCEDEVOLUTION
            pkmn.calc_stats
            break
        end
    end
    pkmn.level = level
end

def battleTransForm(battler, species)
    battler.pokemon.setOriginalForm
    level = battler.level
    battler.pokemon.species = species
    battler.species = species
    battler.level = level
    battler.pbUpdate(true)
    battler.battle.scene.pbChangePokemon(battler,battler.pokemon)
    battler.battle.scene.pbRefreshOne(battler.index)
    if battler.pokemon.originalability == :LEGENDARYPRESSURE
        battler.ability = :LEGENDARYPRESSURE 
        battler.pokemon.ability = :LEGENDARYPRESSURE
    end
    battler.pbUpdate(true)
end

def isDarkWorld()
    return true if [21, 32, 38, 428, 805].include?($game_map.map_id)
    return false
end

def getSoulSprite(viewport)
    heartsprite = Sprite.new(viewport)
    if $PokemonGlobal.towervalues.nil?
        heartsprite.bitmap = Bitmap.new("Graphics/Undertale/PlayerHeart/Default/UndertaleHeart")
    else
        heartsprite.bitmap = Bitmap.new("Graphics/Undertale/PlayerHeart/Default/UndertaleHardcore")
    end
    color = "Patience" if hasEmera?(:LUNARDIAL)
    color = "Kindness" if hasEmera?(:MOSS) || hasEmera?(:MOSSPLUS)
    color = "Perseverance" if hasEmera?(:INDIEPROOF)
    case color
    when "Bravery"
        heartsprite.tone = Tone.new(-3, -89, -255)
    when "Integrity"
        heartsprite.tone = Tone.new(-255, -195, 0)
    when "Justice"
        heartsprite.tone = Tone.new(0, 0, -255)
    when "Kindness"
        heartsprite.tone = Tone.new(-255, -63, -255)
    when "Patience"
        heartsprite.tone = Tone.new(-189, -3, 0)
    when "Perseverance"
        heartsprite.tone = Tone.new(-42, -202, -38)
    else
        heartsprite.tone = Tone.new(0, -255, -255)
    end
    heartsprite.angle -= 90
    return heartsprite
end