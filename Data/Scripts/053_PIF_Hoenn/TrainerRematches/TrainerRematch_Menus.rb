




#####
# Util methods
#####








####
# Methods to be called from events
####


#actionType :
# :BATTLE
# :TRADE
# :PARTNER
def doPostBattleAction(actionType)
  event = pbMapInterpreter.get_character(0)
  map_id = $game_map.map_id if map_id.nil?
  trainer = getRebattledTrainer(event.id,map_id)
  trainer.clear_previous_random_events()

  return if !trainer
  case actionType
  when :BATTLE
    trainer = doNPCTrainerRematch(trainer)
  when :TRADE
    trainer = doNPCTrainerTrade(trainer)
  when :PARTNER
    partnerWithTrainer(event.id,map_id,trainer)
  end
  updateRebattledTrainer(event.id,map_id,trainer)

end

def setTrainerFriendship(trainer)
  params = ChooseNumberParams.new
  params.setRange(0,100)
  params.setDefaultValue($game_map.map_id)
  number = pbMessageChooseNumber("Frienship (0-100)?",params)
  trainer.friendship = number
  trainer.increase_friendship(0)
  return trainer
end

#party: array of pokemon team
# [[:SPECIES,level], ... ]
#
#def customTrainerBattle(trainerName, trainerType, party_array, default_level=50, endSpeech="", sprite_override=nil,custom_appearance=nil)
def postBattleActionsMenu()
  rematchCommand = "Rematch"
  tradeCommand = "Trade Offer"
  partnerCommand = "Partner up"
  cancelCommand = "See ya!"

  updateTeamDebugCommand = "(Debug) Simulate random event"
  resetTrainerDebugCommand = "(Debug) Reset trainer"
  setFriendshipDebugCommand = "(Debug) Set Friendship"
  printTrainerTeamDebugCommand = "(Debug) Print team"


  event = pbMapInterpreter.get_character(0)
  map_id = $game_map.map_id if map_id.nil?
  trainer = getRebattledTrainer(event.id,map_id)

  options = []
  options << rematchCommand
  options << tradeCommand if trainer.friendship_level >= 1
  options << partnerCommand if trainer.friendship_level >= 3

  options << updateTeamDebugCommand if $DEBUG
  options << resetTrainerDebugCommand if $DEBUG
  options << setFriendshipDebugCommand if $DEBUG
  options << printTrainerTeamDebugCommand if $DEBUG

  options << cancelCommand

  trainer = applyTrainerRandomEvents(trainer)
  showPrerematchDialog
  choice = optionsMenu(options,options.find_index(cancelCommand),options.find_index(cancelCommand))

  case options[choice]
  when rematchCommand
    doPostBattleAction(:BATTLE)
  when tradeCommand
    doPostBattleAction(:TRADE)
  when partnerCommand
    doPostBattleAction(:PARTNER)
  when updateTeamDebugCommand
    echoln("")
    echoln "---------------"
    makeRebattledTrainerTeamGainExp(trainer,true)
    evolveRebattledTrainerPokemon(trainer)
    applyTrainerRandomEvents(trainer)
  when resetTrainerDebugCommand
    resetTrainerRebattle(event.id,map_id)
  when setFriendshipDebugCommand
    trainer = getRebattledTrainer(event.id,map_id)
    trainer = setTrainerFriendship(trainer)
    updateRebattledTrainer(event.id,map_id,trainer)
  when printTrainerTeamDebugCommand
    trainer = getRebattledTrainer(event.id,map_id)
    printNPCTrainerCurrentTeam(trainer)
  when cancelCommand
  else
    return
  end
end

