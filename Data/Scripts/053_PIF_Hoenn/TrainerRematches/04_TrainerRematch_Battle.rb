# frozen_string_literal: true

# After each rematch, all of the trainer's Pokémon gain EXP
#
# Gained Exp is calculated from the Pokemon that is in the first slot in the player's team
# so the trainer's levels will scale with the player's.
#
# e.g. If the player uses a stronger Pokemon in the battle, the NPC will get more experience
# as a result
#
def makeRebattledTrainerTeamGainExp(trainer, playerWon=true, gained_exp=nil)
  return if !trainer
  updated_team = []

  trainer_pokemon = $Trainer.party[0]
  return if !trainer_pokemon
  for pokemon in trainer.currentTeam
    if !gained_exp  #Set depending on first pokemon in party if not given a specific amount
      gained_exp = trainer_pokemon.level * trainer_pokemon.base_exp
      gained_exp /= 2 if playerWon   #trainer lost so he's not getting full exp
      gained_exp /= trainer.currentTeam.length
    end
    growth_rate = pokemon.growth_rate
    new_exp = growth_rate.add_exp(pokemon.exp, gained_exp)
    pokemon.exp = new_exp
    updated_team.push(pokemon)
  end
  trainer.currentTeam = updated_team
  return trainer
end

def evolveRebattledTrainerPokemon(trainer)
  updated_team = []
  for pokemon in trainer.currentTeam
    evolution_species = pokemon.check_evolution_on_level_up(false)
    if evolution_species
      trainer.log_evolution_event(pokemon.species,evolution_species)
      trainer.set_pending_action(true)
      pokemon.species = evolution_species if evolution_species
    end
    updated_team.push(pokemon)
  end
  trainer.currentTeam = updated_team
  return trainer
end

def healRebattledTrainerPokemon(trainer)
  for pokemon in trainer.currentTeam
    pokemon.calc_stats
    pokemon.heal
  end
  return trainer
end

def doNPCTrainerRematch(trainer)
  return generateTrainerRematch(trainer)
end
def generateTrainerRematch(trainer)
  trainer_data = GameData::Trainer.try_get(trainer.trainerType, trainer.trainerName, 0)

  loseDialog = trainer_data&.loseText_rematch ? trainer_data.loseText_rematch :  "..."
  if customTrainerBattle(trainer.trainerName,trainer.trainerType, trainer.currentTeam,nil,loseDialog)
    updated_trainer = makeRebattledTrainerTeamGainExp(trainer,true)
    updated_trainer = healRebattledTrainerPokemon(updated_trainer)
  else
    updated_trainer =makeRebattledTrainerTeamGainExp(trainer,false)
  end
  updated_trainer.set_pending_action(false)
  updated_trainer = evolveRebattledTrainerPokemon(updated_trainer)
  trainer.increase_friendship(5)
  return updated_trainer
end

def showPrerematchDialog()
  event = pbMapInterpreter.get_character(0)
  map_id = $game_map.map_id if map_id.nil?
  trainer = getRebattledTrainer(event.id,map_id)
  return "" if trainer.nil?

  trainer_data = GameData::Trainer.try_get(trainer.trainerType, trainer.trainerName, 0)

  all_previous_random_events = trainer.previous_random_events

  if all_previous_random_events
    previous_random_event = getBestMatchingPreviousRandomEvent(trainer_data, trainer.previous_random_events)

    if previous_random_event
      event_message_map = {
        CATCH:   trainer_data.preRematchText_caught,
        EVOLVE:  trainer_data.preRematchText_evolved,
        FUSE:    trainer_data.preRematchText_fused,
        UNFUSE:  trainer_data.preRematchText_unfused,
        REVERSE: trainer_data.preRematchText_reversed
      }

      message_text = event_message_map[previous_random_event.eventType] || trainer_data.preRematchText
    else
      message_text = trainer_data.preRematchText
    end
  end

  if previous_random_event
    message_text = message_text.gsub("<CAUGHT_POKEMON>", getSpeciesRealName(previous_random_event.caught_pokemon).to_s)
    message_text = message_text.gsub("<UNEVOLVED_POKEMON>", getSpeciesRealName(previous_random_event.unevolved_pokemon).to_s)
    message_text = message_text.gsub("<EVOLVED_POKEMON>", getSpeciesRealName(previous_random_event.evolved_pokemon).to_s)
    message_text = message_text.gsub("<HEAD_POKEMON>", getSpeciesRealName(previous_random_event.fusion_head_pokemon).to_s)
    message_text = message_text.gsub("<BODY_POKEMON>", getSpeciesRealName(previous_random_event.fusion_body_pokemon).to_s)
    message_text = message_text.gsub("<FUSED_POKEMON>", getSpeciesRealName(previous_random_event.fusion_fused_pokemon).to_s)
    message_text = message_text.gsub("<UNREVERSED_POKEMON>", getSpeciesRealName(previous_random_event.unreversed_pokemon).to_s)
    message_text = message_text.gsub("<REVERSED_POKEMON>", getSpeciesRealName(previous_random_event.reversed_pokemon).to_s)
    message_text = message_text.gsub("<UNFUSED_POKEMON>", getSpeciesRealName(previous_random_event.unfused_pokemon).to_s)
  else
    message_text = trainer_data.preRematchText
  end
  if message_text
    split_messages = message_text.split("<br>")
    split_messages.each do |msg|
      pbCallBub(2,event.id)
      pbMessage(msg)
    end
  end

end
