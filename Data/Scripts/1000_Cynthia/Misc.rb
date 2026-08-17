TRIPLEFUSIONS = {
    :ZAPMOLTICUNO => [[:ARTICUNO, :GALARARTICUNO], [:ZAPDOS, :GALARZAPDOS], [:MOLTRES, :GALARMOLTRES]],
    :ENRAICUNE => [[:RAIKOU, :RAGINGBOLT], [:ENTEI, :GOUGINGFIRE], [:SUICUNE, :WALKINGWAKE]],
    :KYODONQUAZA => [[:KYOGRE], [:GROUDON], [:RAYQUAZA]],
    :PALDIATINA => [[:PALKIA, :PALKIAORIGIN], [:DIALGA, :DIALGAORIGIN], [:GIRATINA, :GIRATINAORIGIN]],
    :ZEKYUSHIRAM => [[:ZEKROM], [:RESHIRAM], [:KYUREM]],
    :CELEMEWCHI => [[:MEW], [:CELEBI], [:JIRACHI]],
    :DEOSECTWO => [[:MEWTWO], [:DEOXYS], [:GENESECT]],
    #todo regis
    :TRIPLE_KANTO1 => [[:BULBASAUR, :IVYSAUR, :VENUSAUR, :PALMON, :TOGEMON, :LILYMON, :ROSEMON, :ROSEMONBM], [:CHARMANDER, :CHARMELEON, :CHARIZARD, :AGUMON, :GREYMON, :METALGREYMON, :WARGREYMON, :OMNIMON], [:SQUIRTLE, :WARTORTLE, :BLASTOISE, :MACHINEDRAMON]],
    :TRIPLE_JOHTO1 => [[:CHIKORITA, :BAYLEAF, :MEGANIUM], [:CYNDAQUIL, :QUILAVA, :TYPHLOSION, :HISUITYPHLOSION], [:TOTODILE, :CROCONAW, :FERALIGATR, :GABUMON, :GARURUMON, :WEREGARURUMON, :METALGARURUMON, :OMNIMON]],
    :TRIPLE_HOENN1 => [[:TREEKO, :GROVYLE, :SCEPTILE], [:TORCHIC, :COMBUSKEN, :BLAZIKEN], [:MUDKIP, :MARSHTOMP, :SWAMPERT]],
    :TRIPLE_SINNOH1 => [[:TURTWIG, :GROTLE, :TORTERRA], [:CHIMCHAR, :MONFERNO, :INFERNAPE], [:PIPLUP, :PRINPLUP, :EMPOLEON]],
    :TRIPLE_KALOS1 => [[:CHESPIN, :QUILLADIN, :CHESNAUGHT], [:FENNEKIN, :BRAIXEN, :DELPHOX], [:FROAKIE, :FROGADIER, :GRENINJA]],
    :DUGTRIO => [[:DIGLETT]],
    :ALOLADUGTRIO => [[:ALOLADIGLETT]],
    :MAGNETON => [[:MAGNEMITE]],
}

def tripleFusion(item=false)
    $PokemonGlobal.triplefusions = [] if $PokemonGlobal.triplefusions.nil?
    TRIPLEFUSIONS.each do |triple, materials|
        next if $PokemonGlobal.triplefusions.include?(triple)
        materialcount = []
        if materials.length == 1
            $Trainer.party.each do |mon|
                materials.each do |material|
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
                Kernel.pbMessage("Are you fucking stupid. I'm doing it anyways.")
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
end