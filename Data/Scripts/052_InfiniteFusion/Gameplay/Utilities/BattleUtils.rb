def generateEggGroupTeam(eggGroup)
  teamComplete = false
  generatedTeam = []
  while !teamComplete
    species = rand(PBSpecies.maxValue)
    if getPokemonEggGroups(species).include?(eggGroup)
      generatedTeam << species
    end
    teamComplete = generatedTeam.length == 3
  end
  return generatedTeam
end

def generateSimpleTrainerParty(teamSpecies, level)
  team = []
  for species in teamSpecies
    poke = Pokemon.new(species, level)
    team << poke
  end
  return team
end

def Kernel.getRoamingMap(roamingArrayPos)
  curmap = $PokemonGlobal.roamPosition[roamingArrayPos]
  mapinfos = $RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")
  text = mapinfos[curmap].name #,(curmap==$game_map.map_id) ? _INTL("(this map)") : "")
  return text
end

def Kernel.getItemNamesAsString(list)
  strList = ""
  for i in 0..list.length - 1
    id = list[i]
    name = PBItems.getName(id)
    strList += name
    if i != list.length - 1 && list.length > 1
      strList += ","
    end
  end
  return strList
end

def getCurrentLevelCap()
  current_max_level = Settings::LEVEL_CAPS[$Trainer.badge_count]
  current_max_level *= Settings::HARD_MODE_LEVEL_MODIFIER if pbCynthiaGetBadgeCount >= 8
  return current_max_level.floor
end

def pokemonExceedsLevelCap(pokemon)
  return pokemon.level >= $PokemonGlobal.towervalues[:floor] + 4 if !$PokemonGlobal.towervalues.nil?
  return false if $Trainer.badge_count >= Settings::NB_BADGES
  current_max_level = getCurrentLevelCap()
  return pokemon.level >= current_max_level
end

def get_spritecharacter_for_event(event_id)
  for sprite in $scene.spriteset.character_sprites
    if sprite.character.id == event_id
      return sprite
    end
  end
end

def setForcedAltSprites(forcedSprites_map)
  $PokemonTemp.forced_alt_sprites = forcedSprites_map
end