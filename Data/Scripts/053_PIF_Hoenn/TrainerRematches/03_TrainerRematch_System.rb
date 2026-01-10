# frozen_string_literal: true

class PokemonGlobalMetadata
  #Map that keeps track of all the npc trainers the player has battled
  # [map_id,event_id] =>BattledTrainer
  attr_accessor :battledTrainers
end

TIME_FOR_RANDOM_EVENTS = 60#3600 #1 hour


## Extend pbTrainerBattle to call postTrainerBattleAction at the end of every trainer battle
alias original_pbTrainerBattle pbTrainerBattle
def pbTrainerBattle(trainerID, trainerName,endSpeech=nil,
                    doubleBattle=false, trainerPartyID=0,
                    *args)
  result = original_pbTrainerBattle(trainerID, trainerName, endSpeech,doubleBattle,trainerPartyID, *args)
  postTrainerBattleActions(trainerID, trainerName,trainerPartyID) if Settings::GAME_ID == :IF_HOENN
  return result
end
def postTrainerBattleActions(trainerID, trainerName,trainerVersion)
  trainer = registerBattledTrainer(@event_id,$game_map.map_id,trainerID,trainerName,trainerVersion)
  makeRebattledTrainerTeamGainExp(trainer)
end


#Do NOT call this alone. Rebattlable trainers are always intialized after
# defeating them.
# Having a rematchable trainer that is not registered will cause crashes.
def registerBattledTrainer(event_id, mapId, trainerType, trainerName, trainerVersion=0)
  key = [event_id,mapId]
  $PokemonGlobal.battledTrainers = {} unless $PokemonGlobal.battledTrainers
  trainer = BattledTrainer.new(trainerType, trainerName, trainerVersion,key)
  $PokemonGlobal.battledTrainers[key] = trainer
  return trainer
end

def unregisterBattledTrainer(event_id, mapId)
  key = [event_id,mapId]
  $PokemonGlobal.battledTrainers = {} unless $PokemonGlobal.battledTrainers
  if  $PokemonGlobal.battledTrainers.has_key?(key)
    $PokemonGlobal.battledTrainers[key] =nil
    echoln "Unregistered Battled Trainer #{key}"
  else
    echoln "Could not unregister Battled Trainer #{key}"
  end
end

def resetTrainerRebattle(event_id, map_id)
  trainer = getRebattledTrainer(event_id,map_id)

  trainerType = trainer.trainerType
  trainerName = trainer.trainerName

  unregisterBattledTrainer(event_id,map_id)
  registerBattledTrainer(event_id,map_id,trainerType,trainerName)
end

def updateRebattledTrainer(event_id,map_id,updated_trainer)
  key = [event_id,map_id]
  updateRebattledTrainerWithKey(key,updated_trainer)
end

def updateRebattledTrainerWithKey(key,updated_trainer)
  $PokemonGlobal.battledTrainers = {} if !$PokemonGlobal.battledTrainers
  $PokemonGlobal.battledTrainers[key] = updated_trainer
end

def getRebattledTrainerKey(event_id, map_id)
  return [event_id,map_id]
end

def getRebattledTrainerFromKey(key)
  $PokemonGlobal.battledTrainers = {} if !$PokemonGlobal.battledTrainers
  return $PokemonGlobal.battledTrainers[key]
end
def getRebattledTrainer(event_id,map_id)
  key = getRebattledTrainerKey(event_id, map_id)
  return getRebattledTrainerFromKey(key)
end

