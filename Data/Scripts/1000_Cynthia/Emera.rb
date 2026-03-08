EMERADICT = {
    :APPLE => {
        :name => "Apple",
        :description => "Heals your party for 1/16th when going up a floor.",
        :rarity => :COMMON,
        # :tutormove => :JUDGMENT,
        # :tutorcondition => -> (pokemon) {return pokemon.pbHasType?(:NORMAL)},
    }
}

def grantRandomEmera()
    itemlist = getEmeras() 
    raritylist = getEnderChestWeights()
    totalrarities = raritylist.sum - 1
    randomrarity = rand(totalrarities)
    raritylist.each_with_index do |rarity, i|
      if randomrarity < rarity
        randomrarity = i
        break
      else
        randomrarity -= rarity
      end
    end
    randomitem = itemlist[randomrarity][rand(itemlist[randomrarity].length)]
    itemname = EMERADICT[randomitem][:name]
    itemcolor = getEnderChestRarityColors()[randomrarity]
    if getLooplet.pbStoreEmera(randomitem)
      pbMessage("You got \\C[#{itemcolor}]#{itemname}\\C[0]!")
    end
end

def hasActiveEmera?(emera)
    return getLooplet.pbHasEmera?(emera)
end

def getEmeras
    return [
        [ #common
            :APPLE,
        ],
        [ #uncommon
            :APPLE,
        ],
        [
            :APPLE,
        ],
        [
            :APPLE,
        ],
    ]
end