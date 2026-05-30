TRAINERCLASSDICT = {
    :ACETRAINER => {
        :name => "Ace Trainer",
        :emera => :TRAININGGEAR,
    },
    :BUGCATCHER => {
        :name => "Bug Catcher",
        :emera => :CATCHINGNET,
    },
    # :GAMBLER => {
    #     :name => "Gambler",
    #     :emera => :,
    # },
}

def selectTrainerClass()
    Kernel.pbMessage("Select your Trainer Class.")
    trainerlist = []
    namelist = []
    descriptionlist = []
    namelist.push("Random")
    descriptionlist.push("Choose a random class.")
    TRAINERCLASSDICT.each do |trainerclass, dict|
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
end