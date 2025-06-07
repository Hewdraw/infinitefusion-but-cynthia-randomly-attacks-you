# frozen_string_literal: true
HOENN_RIVAL_EVENT_NAME = "HOENN_RIVAL"
TEMPLATE_CHARACTER_FILE = "NPC_template"

class Player < Trainer
  attr_accessor :rival_appearance

  alias pokemonEssentials_player_initialize initialize
  def initialize(*args)
    pokemonEssentials_player_initialize(*args)
    @rival_appearance = init_rival_appearance
  end



  def init_rival_appearance
    if isPlayerMale
      return TrainerAppearance.new(5,
                            HAT_MAY,
                            CLOTHES_MAY,
                            getFullHairId(HAIR_MAY,3) ,
                            0, 0, 0)
    else
      return TrainerAppearance.new(5,
                                   HAT_BRENDAN,
                                   CLOTHES_BRENDAN,
                                   getFullHairId(HAIR_BRENDAN,3),
                                   0, 0, 0)
    end
  end

  def rival_appearance
    @rival_appearance = init_rival_appearance if !@rival_appearance
    return @rival_appearance
  end

  def rival_appearance=(value)
    @rival_appearance = value
  end
end

BATTLED_TRAINER_RIVAL_KEY = "rival"

def init_rival_name
  rival_name = "Brendan" if isPlayerFemale
  rival_name = "May" if isPlayerMale
  pbSet(VAR_RIVAL_NAME,rival_name)
end
def set_rival_hat(hat)
  $Trainer.rival_appearance = TrainerAppearance.new(
    $Trainer.rival_appearance.skin_color,
      hat,
    $Trainer.rival_appearance.clothes,
    $Trainer.rival_appearance.hair,
    $Trainer.rival_appearance.hair_color,
    $Trainer.rival_appearance.clothes_color,
    $Trainer.rival_appearance.hat_color,
      )
end


class Sprite_Character
  alias PIF_typeExpert_checkModifySpriteGraphics checkModifySpriteGraphics
  def checkModifySpriteGraphics(character)
    PIF_typeExpert_checkModifySpriteGraphics(character)
    return if character == $game_player
    setSpriteToAppearance($Trainer.rival_appearance) if isPlayerFemale && character.name == HOENN_RIVAL_EVENT_NAME && character.character_name == TEMPLATE_CHARACTER_FILE
    setSpriteToAppearance($Trainer.rival_appearance) if isPlayerMale && character.name == HOENN_RIVAL_EVENT_NAME && character.character_name == TEMPLATE_CHARACTER_FILE
  end
end

def get_rival_starter
  case get_rival_starter_type()
  when :GRASS
    return obtainStarter(0)
  when :FIRE
    return obtainStarter(1)
  when :WATER
    return obtainStarter(2)
  else
          #fallback, should not happen
          return obtainStarter(0)
  end
end


def get_rival_starter_type()
  player_chosen_starter_index = pbGet(VAR_HOENN_CHOSEN_STARTER_INDEX)
  case player_chosen_starter_index
  when 0 #GRASS
    return :FIRE
  when 1 #FIRE
    return :WATER
  when 2 #WATER
    return :GRASS
  end
end



#Rival catches a Pokemon the same type as the player's starter and fuses it with their starter
def updateRivalTeamForSecondBattle()
  rival_trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY]
  rival_starter = rival_trainer.currentTeam[0]
  rival_starter_species= rival_starter.species

  player_chosen_starter_index = pbGet(VAR_HOENN_CHOSEN_STARTER_INDEX)
  case player_chosen_starter_index
  when 0 #GRASS
    pokemon_species = getFusionSpeciesSymbol(:LOTAD, rival_starter_species) if isPlayerFemale()
    pokemon_species = getFusionSpeciesSymbol(rival_starter_species,:SHROOMISH) if isPlayerMale()
  when 1 #FIRE
    pokemon_species = getFusionSpeciesSymbol(:SLUGMA,rival_starter_species) if isPlayerFemale()
    pokemon_species = getFusionSpeciesSymbol(rival_starter_species,:NUMEL) if isPlayerMale()
  when 2 #WATER
    pokemon_species = getFusionSpeciesSymbol(rival_starter_species,:WINGULL) if isPlayerFemale()
    pokemon_species = getFusionSpeciesSymbol(:WAILMER,rival_starter_species) if isPlayerMale()
  end
  team = []
  team << Pokemon.new(pokemon_species,15)

  rival_trainer.currentTeam = team
  $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY] = rival_trainer
end




# This sets up the rival's main team for the game
# Fir further battle, we can just add Pokemon and gain exp the same way as other
# trainer rematches
#
# Basically, rival catches a pokemon the type of their rival's starter - fuses it with their starters
# Has a team composed of fire/grass, water/grass, water/fire pokemon
def updateRivalTeamForThirdBattle()
  rival_trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY]
  rival_starter = rival_trainer.currentTeam[0]
  starter_species= rival_starter.species

  rival_starter.level=20
  team = []
  team << rival_starter
  rival_trainer.currentTeam = team
  $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY] = rival_trainer
  evolveRivalTeam

  evolution_species = rival_starter.check_evolution_on_level_up(false)
  if evolution_species
    starter_species = evolution_species
  end

  player_chosen_starter_index = pbGet(VAR_HOENN_CHOSEN_STARTER_INDEX)
  case player_chosen_starter_index
  when 0 #GRASS
    if isPlayerFemale()
      fire_grass_pokemon = starter_species
      water_fire_pokemon = getFusionSpeciesSymbol(:NUMEL,:WINGULL)
      water_grass_pokemon = getFusionSpeciesSymbol(:WAILMER,:SHROOMISH)
    end
    if isPlayerMale()
      fire_grass_pokemon = starter_species
      water_fire_pokemon = getFusionSpeciesSymbol(:LOMBRE,:WINGULL)
      water_grass_pokemon = getFusionSpeciesSymbol(:SLUGMA,:WAILMER)
    end
    contains_starter = [fire_grass_pokemon]
    other_pokemon = [water_fire_pokemon,water_grass_pokemon]

  when 1 #FIRE
    if isPlayerFemale()
      fire_grass_pokemon = getFusionSpeciesSymbol(:SHROOMISH,:NUMEL)
      water_fire_pokemon = getFusionSpeciesSymbol(:LOMBRE,:WAILMER)
      water_grass_pokemon = starter_species
    end
    if isPlayerMale()
      fire_grass_pokemon = getFusionSpeciesSymbol(:LOMBRE,:SLUGMA,)
      water_fire_pokemon = getFusionSpeciesSymbol(:SHROOMISH,:WINGULL,)
      water_grass_pokemon = starter_species
    end
    contains_starter = [water_grass_pokemon]
    other_pokemon = [water_fire_pokemon,fire_grass_pokemon]

  when 2 #WATER
    if isPlayerFemale()
      fire_grass_pokemon = getFusionSpeciesSymbol(:SLUGMA,:SHROOMISH)
      water_fire_pokemon = starter_species
      water_grass_pokemon = getFusionSpeciesSymbol(:WAILMER,:NUMEL)
    end
    if isPlayerMale()
      fire_grass_pokemon = getFusionSpeciesSymbol(:LOMBRE,:NUMEL,)
      water_fire_pokemon = starter_species
      water_grass_pokemon = getFusionSpeciesSymbol(:SLUGMA,:WINGULL)
    end
    contains_starter = [water_fire_pokemon]
    other_pokemon = [water_grass_pokemon,fire_grass_pokemon]
  end

  team = []
  team << Pokemon.new(other_pokemon[0],18)
  team << Pokemon.new(other_pokemon[1],18)
  team << Pokemon.new(contains_starter[0],20)

  rival_trainer.currentTeam = team
  $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY] = rival_trainer
end

def levelUpRivalTeam(experience=0)
  rival_trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY]
  updated_trainer =makeRebattledTrainerTeamGainExp(rival_trainer,false,experience)
  $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY] = updated_trainer
end

def evolveRivalTeam()
  rival_trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY]
  updated_trainer = evolveRebattledTrainerPokemon(rival_trainer)
  $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY] = updated_trainer
end

def addPokemonToRivalTeam(species,level)
  rival_trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY]
  rival_trainer.currentTeam << Pokemon.new(species,level)
  $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY] = rival_trainer
end

def initializeRivalBattledTrainer
  trainer_type = :RIVAL1
  trainer_name = isPlayerMale ? "May" : "Brendan"
  trainer_appearance = $Trainer.rival_appearance
  rivalBattledTrainer = BattledTrainer.new(trainer_type,trainer_name,0)
  rivalBattledTrainer.set_custom_appearance(trainer_appearance)
  echoln rivalBattledTrainer.currentTeam
  team = []
  team<<Pokemon.new(get_rival_starter,5)
  rivalBattledTrainer.currentTeam =team
  return rivalBattledTrainer
end

def hoennRivalBattle(loseDialog="...")
  $PokemonGlobal.battledTrainers = {} if !$PokemonGlobal.battledTrainers
  if !$PokemonGlobal.battledTrainers.has_key?(BATTLED_TRAINER_RIVAL_KEY)
    rival_trainer = initializeRivalBattledTrainer()
    $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY] = rival_trainer
  else
    rival_trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY]
  end
  echoln rival_trainer
  echoln rival_trainer.currentTeam
  return customTrainerBattle(rival_trainer.trainerName,rival_trainer.trainerType, rival_trainer.currentTeam,rival_trainer,loseDialog,nil,rival_trainer.custom_appearance)
end