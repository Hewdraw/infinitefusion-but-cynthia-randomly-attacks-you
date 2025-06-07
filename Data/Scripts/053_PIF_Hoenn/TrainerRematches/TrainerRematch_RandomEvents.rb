# frozen_string_literal: true

def printNPCTrainerCurrentTeam(trainer)
  team_string = "["
  trainer.currentTeam.each do |pokemon|
    name= get_pokemon_readable_internal_name(pokemon)
    level = pokemon.level
    formatted_info = "#{name} (lv.#{level}), "
    team_string += formatted_info
  end
  team_string += "]"
  echoln "Trainer's current team is: #{team_string}"
end

def applyTrainerRandomEvents(trainer)
  if trainer.has_pending_action
    echoln "Trainer has pending action"
  end

  return trainer if trainer.has_pending_action
  trainer.clear_previous_random_events

  #time_passed = trainer.getTimeSinceLastAction
  #return trainer if time_passed < TIME_FOR_RANDOM_EVENTS

  # Weighted chances out of 10
  weighted_events = [
    [:CATCH,   3],
    [:FUSE,    6],
    [:REVERSE, 1],
    [:UNFUSE,  20]
  ]

  # Create a flat array of events based on weight
  event_pool = weighted_events.flat_map { |event, weight| [event] * weight }

  selected_event = event_pool.sample

  if selected_event
    echoln "Trying to do random event: #{selected_event}"
  end


  return trainer if selected_event.nil?

  case selected_event
  when :CATCH
    trainer = catch_new_team_pokemon(trainer)
  when :FUSE
    trainer = fuse_random_team_pokemon(trainer)
  when :UNFUSE
    trainer = unfuse_random_team_pokemon(trainer)
  when :REVERSE
    trainer = reverse_random_team_pokemon(trainer)
  end
  trainer.set_pending_action(true)
  printNPCTrainerCurrentTeam(trainer)
  return trainer
end



def chooseEncounterType(trainerClass)
  water_trainer_classes = [:SWIMMER_F, :SWIMMER_M, :FISHERMAN]
  if water_trainer_classes.include?(trainerClass )
    chance_of_land_encounter = 1
    chance_of_surf_encounter= 5
    chance_of_cave_encounter = 1
    chance_of_fishing_encounter = 5
  else
    chance_of_land_encounter = 5
    chance_of_surf_encounter= 1
    chance_of_cave_encounter = 5
    chance_of_fishing_encounter = 1
  end

  if pbCheckHiddenMoveBadge(Settings::BADGE_FOR_SURF, false)
    chance_of_surf_encounter =0
    chance_of_fishing_encounter = 0
  end

  possible_encounter_types = []
  if $PokemonEncounters.has_land_encounters?
    possible_encounter_types += [:Land] * chance_of_land_encounter
  end
  if $PokemonEncounters.has_cave_encounters?
    possible_encounter_types += [:Cave] * chance_of_cave_encounter
  end
  if $PokemonEncounters.has_water_encounters?
    possible_encounter_types += [:GoodRod] * chance_of_fishing_encounter
    possible_encounter_types += [:Water] * chance_of_surf_encounter
  end
  echoln "possible_encounter_types: #{possible_encounter_types}"
  return getTimeBasedEncounter(possible_encounter_types.sample)
end


def getTimeBasedEncounter(encounter_type)
  time = pbGetTimeNow
  return $PokemonEncounters.find_valid_encounter_type_for_time(encounter_type, time)
end

def catch_new_team_pokemon(trainer)
  return trainer if trainer.currentTeam.length >= 6
  encounter_type = chooseEncounterType(trainer.trainerType)
  return trainer if !encounter_type

  echoln "Catching a pokemon via encounter_type #{encounter_type}"
  wild_pokemon = $PokemonEncounters.choose_wild_pokemon(encounter_type)
  echoln wild_pokemon
  if wild_pokemon
    trainer.currentTeam << Pokemon.new(wild_pokemon[0],wild_pokemon[1])
    trainer.log_catch_event(wild_pokemon[0])
  end
  return trainer
end




def reverse_random_team_pokemon(trainer)
  eligible_pokemon = trainer.list_team_fused_pokemon
  return trainer if eligible_pokemon.length < 1
  return trainer if trainer.currentTeam.length > 5
  pokemon_to_reverse = eligible_pokemon.sample
  old_species = pokemon_to_reverse.species
  trainer.currentTeam.delete(pokemon_to_reverse)

  body_pokemon = get_body_species_from_symbol(pokemon_to_reverse.species)
  head_pokemon = get_head_species_from_symbol(pokemon_to_reverse.species)

  pokemon_to_reverse.species = getFusedPokemonIdFromSymbols(head_pokemon,body_pokemon)
  trainer.currentTeam.push(pokemon_to_reverse)
  trainer.log_reverse_event(old_species,pokemon_to_reverse.species)
  return trainer
end


def unfuse_random_team_pokemon(trainer)
  eligible_pokemon = trainer.list_team_fused_pokemon
  return trainer if eligible_pokemon.length < 1
  return trainer if trainer.currentTeam.length > 5
  pokemon_to_unfuse = eligible_pokemon.sample

  echoln pokemon_to_unfuse.owner.name
  echoln trainer.trainerName
  return trainer if pokemon_to_unfuse.owner.name != trainer.trainerName

  body_pokemon = get_body_id_from_symbol(pokemon_to_unfuse.species)
  head_pokemon = get_head_id_from_symbol(pokemon_to_unfuse.species)

  level = calculateUnfuseLevelOldMethod(pokemon_to_unfuse,false)

  trainer.currentTeam.delete(pokemon_to_unfuse)
  trainer.currentTeam.push(Pokemon.new(body_pokemon,level))
  trainer.currentTeam.push(Pokemon.new(head_pokemon,level))
  trainer.log_unfusion_event(pokemon_to_unfuse.species, body_pokemon, head_pokemon)
  return trainer
end

def fuse_random_team_pokemon(trainer)
  eligible_pokemon = trainer.list_team_unfused_pokemon
  return trainer if eligible_pokemon.length < 2

  pokemon_to_fuse = eligible_pokemon.sample(2)
  body_pokemon = pokemon_to_fuse[0]
  head_pokemon = pokemon_to_fuse[1]
  fusion_species = getFusedPokemonIdFromSymbols(body_pokemon.species,head_pokemon.species)
  level = (body_pokemon.level + head_pokemon.level)/2
  fused_pokemon = Pokemon.new(fusion_species,level)

  trainer.currentTeam.delete(body_pokemon)
  trainer.currentTeam.delete(head_pokemon)
  trainer.currentTeam.push(fused_pokemon)
  trainer.log_fusion_event(body_pokemon.species,head_pokemon.species,fusion_species)
  return trainer
end

def getBestMatchingPreviousRandomEvent(trainer_data, previous_events)
  return nil if trainer_data.nil? || previous_events.nil?

  priority = [:CATCH, :EVOLVE, :FUSE, :UNFUSE, :REVERSE]
  event_message_map = {
    CATCH:   trainer_data.preRematchText_caught,
    EVOLVE:  trainer_data.preRematchText_evolved,
    FUSE:    trainer_data.preRematchText_fused,
    UNFUSE:  trainer_data.preRematchText_unfused,
    REVERSE: trainer_data.preRematchText_reversed
  }
  sorted_events = previous_events.sort_by do |event|
    priority.index(event.eventType) || Float::INFINITY
  end

  sorted_events.find { |event| event_message_map[event.eventType] }
end