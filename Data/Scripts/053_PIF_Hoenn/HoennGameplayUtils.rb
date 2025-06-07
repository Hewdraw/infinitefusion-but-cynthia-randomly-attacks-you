# available channels
# :NEWS
# :WEATHER
#
def showTVText(channel = :NEWS)
  case channel
  when :NEWS
    pbMessage(getTVNewsCaption())
  end
end

SWITCH_REPORTER_AT_PETALBURG = 2026

def getTVNewsCaption()
  if $game_switches[SWITCH_REPORTER_AT_PETALBURG]
    return _INTL("It's showing the local news. There's a berry-growing contest going on in Petalburg Town!")
  else
    return _INTL("It’s a rerun of PokéChef Deluxe. Nothing important on the news right now.")
  end
end

def hoennSelectStarter
  starters = [obtainStarter(0), obtainStarter(1), obtainStarter(2)]
  selected_starter = StartersSelectionScene.new(starters).startScene
  pbAddPokemonSilent(selected_starter)
  return selected_starter
end
