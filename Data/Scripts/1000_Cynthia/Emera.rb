EMERADICT = {
    :EMERA => {
        :name => "Test Emera",
        :description => "Test",
        :rarity => :COMMON,
        :tutormove => :JUDGMENT,
        :tutorcondition => -> (pokemon) {return pokemon.pbHasType?(:NORMAL)},
    }
}