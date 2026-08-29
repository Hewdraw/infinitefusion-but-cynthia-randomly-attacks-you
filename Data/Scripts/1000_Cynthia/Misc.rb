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

def increaseInevitable()
    $PokemonGlobal.cynthiachance += 1
    $PokemonGlobal.cynthiadoubleschance += 1
    $PokemonGlobal.cynthiatripleschance += 1
    $PokemonGlobal.cynthiafieldchance += 5000
    $PokemonGlobal.cynthiaupgradechance += 1
    $PokemonGlobal.cynthiahandschance += 1
    $PokemonGlobal.hatsunemikuchance += 1
end