TRAINERCLASSDICT = {
    :ACETRAINER => {
        :name => "Ace Trainer",
        :emera => :TRAININGGEAR,
    },
    :BUGCATCHER => {
        :name => "Bug Catcher",
        :emera => :CATCHINGNET,
    },
    :GAMBLER => {
        :name => "Gambler",
        :emera => :STICKYKEY,
    },
}

def selectTrainerClass()
    Kernel.pbMessage("Select your Trainer Class.")
    trainerlist = []
    namelist = []
    descriptionlist = []
    namelist.push("Random")
    descriptionlist.push("Choose a random class.")
    unlockedclasses = getUnlockedClasses
    TRAINERCLASSDICT.each do |trainerclass, dict|
        next unless unlockedclasses.include?(trainerclass)
        trainerlist.push(trainerclass)
        namelist.push(dict[:name])
        descriptionlist.push(EMERADICT[dict[:emera]][:description])
    end
    choice = pbUnknownCommands(namelist, descriptionlist)
    if choice == 0
        choice = rand(trainerlist.length)+1
        Kernel.pbMessage("Randomed the #{namelist[choice]}")
    end
    trainerclass = trainerlist[choice-1]
    getLooplet.pbStoreEmera(TRAINERCLASSDICT[trainerclass][:emera])

    if hasEmera?(:TRAININGGEAR)
        itemlist = [:FIRESTONE, :THUNDERSTONE, :WATERSTONE, :LEAFSTONE, :MOONSTONE, :SUNSTONE, :DUSKSTONE, :DAWNSTONE, :SHINYSTONE, :MISTSTONE, :ICESTONE, :MAGNETSTONE]
        gainedlist = []
        while gainedlist.length < 3
            item = itemlist.sample
            next if item == :MISTSTONE && rand(2) == 0
            gainedlist.push(item) if !gainedlist.include?(item)
        end
        gainedlist.each do |item|
            pbReceiveItem(item)
        end
    end
    if hasEmera?(:STICKYKEY)
        pbReceiveItem(:METRONOME)
    end
end

def getUnlockedClasses()
    $PokemonGlobal.towerclasses = [:ACETRAINER, :BUGCATCHER] if $PokemonGlobal.towerclasses.nil?
    return $PokemonGlobal.towerclasses
end

def unlockClass(trainerclass)
    unlockedclasses = getUnlockedClasses()
    return false if unlockedclasses.include?(trainerclass)
    $PokemonGlobal.towerclasses.push(trainerclass)
    classname = TRAINERCLASSDICT[trainerclass][:name]
    Kernel.pbMessage("You unlocked the #{classname} class in Temporal Tower.")
end