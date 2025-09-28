
BATTLED_TRAINER_WALLY_KEY = "wally"

SWITCH_WALLY_CATCHING_POKEMON = 2022
SWITCH_WALLY_GAVE_POKEMON = 2023
SWITCH_WALLY_GAVE_POKEMON_DIALOGUE = 2024

COMMON_EVENT_WALLY_FOLLOWING_DIALOGUE = 199

def wally_initialize()
  trainer_type = :RIVAL2
  trainer_name = "Wally"
  battledTrainer = BattledTrainer.new(trainer_type,trainer_name,0,BATTLED_TRAINER_WALLY_KEY)
  battledTrainer.currentTeam =[]#team
  $PokemonGlobal.battledTrainers={} if !$PokemonGlobal.battledTrainers
  $PokemonGlobal.battledTrainers[BATTLED_TRAINER_WALLY_KEY] = battledTrainer
  return battledTrainer
end

def wally_add_pokemon(pokemon_species,level)
  trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_WALLY_KEY]
  pokemon = Pokemon.new(pokemon_species,level)
  trainer.currentTeam.push(pokemon)
  updateRebattledTrainerWithKey(BATTLED_TRAINER_WALLY_KEY,trainer)
end

def wally_remove_pokemon(pokemon_species)

  trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_WALLY_KEY]
  echoln trainer.currentTeam
  trainer.currentTeam.each { |pokemon|
    if pokemon.species == pokemon_species
      trainer.currentTeam.delete(pokemon)
      updateRebattledTrainerWithKey(BATTLED_TRAINER_WALLY_KEY, trainer)
      return
    end
  }
end
def wally_fuse_pokemon(with_fusion_screen=true)

  head_pokemon_index=0
  body_pokemon_index=1

  trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_WALLY_KEY]

  body_pokemon = trainer.currentTeam[body_pokemon_index]
  head_pokemon = trainer.currentTeam[head_pokemon_index]
  return if head_pokemon.isFusion? || body_pokemon.isFusion?
  npcTrainerFusionScreenPokemon(head_pokemon.clone,body_pokemon.clone) if with_fusion_screen

  fusion_species = getFusedPokemonIdFromSymbols(body_pokemon.species,head_pokemon.species)
  level = (body_pokemon.level + head_pokemon.level)/2
  fused_pokemon = Pokemon.new(fusion_species,level)

  trainer.currentTeam.delete(body_pokemon)
  trainer.currentTeam.delete(head_pokemon)
  trainer.currentTeam.push(fused_pokemon)

  updateRebattledTrainerWithKey(BATTLED_TRAINER_WALLY_KEY,trainer)
end


def npcTrainerFusionScreenPokemon(headPokemon,bodyPokemon)
  fusionScene = PokemonFusionScene.new
  newSpecies = getFusedPokemonIdFromSymbols(bodyPokemon.species,headPokemon.species)

  newDexNumber = getDexNumberForSpecies(newSpecies)
  if fusionScene.pbStartScreen(bodyPokemon, headPokemon, newDexNumber, :DNASPLICERS)
    fusionScene.pbFusionScreen(false, false, false,false)
    fusionScene.pbEndScreen
  end
end

def npcTrainerFusionScreen(headSpecies,bodySpecies)
  fusionScene = PokemonFusionScene.new
  newid = getFusedPokemonIdFromSymbols(bodySpecies,headSpecies)
  fusionScene.pbStartScreen(Pokemon.new(bodySpecies,100), Pokemon.new(headSpecies,100), newid, :DNASPLICERS)
end

def getWallyTrainer()
  return $PokemonGlobal.battledTrainers[BATTLED_TRAINER_WALLY_KEY]
end
def wally_follow(eventId)
  trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_WALLY_KEY]
  partnerWithTrainer(eventId, $game_map.map_id, trainer,BATTLED_TRAINER_WALLY_KEY, COMMON_EVENT_WALLY_FOLLOWING_DIALOGUE)
end

def wally_unfollow()
  unpartnerWithTrainer()
end


