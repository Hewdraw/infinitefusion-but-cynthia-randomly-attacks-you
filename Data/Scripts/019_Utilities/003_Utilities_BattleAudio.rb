#===============================================================================
# Load various wild battle music
#===============================================================================
def pbGetWildBattleBGM(_wildParty)   # wildParty is an array of Pokémon objects
  if $PokemonGlobal.nextBattleBGM
    return $PokemonGlobal.nextBattleBGM.clone
  end
  if rand(200) == 0
    $PokemonGlobal.cynthiachance += 1000
    if rand(10) == 0
      $PokemonGlobal.hatsunemikuchance += 1000
      return pbStringToAudioFile("Miku")
    end
    return pbStringToAudioFile("CynthiaEncounter1")
  end
  ret = nil
  if !ret
    # Check map metadata
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    music = (map_metadata) ? map_metadata.wild_battle_BGM : nil
    ret = pbStringToAudioFile(music) if music && music != ""
  end
  if !ret
    # Check global metadata
    music = GameData::Metadata.get.wild_battle_BGM
    ret = pbStringToAudioFile(music) if music && music!=""
  end
  ret = pbStringToAudioFile("Battle wild") if !ret
  return ret
end

def pbGetWildVictoryME
  if $PokemonGlobal.nextBattleME
    return $PokemonGlobal.nextBattleME.clone
  end
  ret = pbStringToAudioFile(Settings::WILD_VICTORY_MUSIC)
  ret.name = "../../Audio/ME/"+ret.name
  return ret
end

def pbGetWildCaptureME
  if $PokemonGlobal.nextBattleCaptureME
    return $PokemonGlobal.nextBattleCaptureME.clone
  end
  ret = nil
  if !ret
    # Check map metadata
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    music = (map_metadata) ? map_metadata.wild_capture_ME : nil
    ret = pbStringToAudioFile(music) if music && music != ""
  end
  if !ret
    # Check global metadata
    music = GameData::Metadata.get.wild_capture_ME
    ret = pbStringToAudioFile(music) if music && music!=""
  end
  ret = pbStringToAudioFile("Battle capture success") if !ret
  ret.name = "../../Audio/ME/"+ret.name
  return ret
end

#===============================================================================
# Load/play various trainer battle music
#===============================================================================
def pbPlayTrainerIntroME(trainer_type)
  trainer_type_data = GameData::TrainerType.get(trainer_type)
  return if nil_or_empty?(trainer_type_data.intro_ME)
  bgm = pbStringToAudioFile(trainer_type_data.intro_ME)
  pbMEPlay(bgm)
end

def pbGetTrainerBattleBGM(trainer)   # can be a Player, NPCTrainer or an array of them
  if $PokemonGlobal.nextBattleBGM
    return $PokemonGlobal.nextBattleBGM.clone
  end
  if rand(75) == 0
    $PokemonGlobal.cynthiachance += 1000
    if rand(10) == 0
      $PokemonGlobal.hatsunemikuchance += 1000
      return pbStringToAudioFile("Miku")
    end
    return pbStringToAudioFile("CynthiaEncounter1")
  end
  ret = nil
  music = nil
  trainerarray = (trainer.is_a?(Array)) ? trainer : [trainer]
  trainerarray.each do |t|
    trainer_type_data = GameData::TrainerType.get(t.trainer_type)
    music = trainer_type_data.battle_BGM if trainer_type_data.battle_BGM
    if trainer_type_data.id == :GHOST_Cynthia
      return pbStringToAudioFile("VSGhostCynthia")
    end
    if trainer_type_data.id == :CHAMPION_Sinnoh2
      return pbStringToAudioFile("VSCynthia2")
    end
    if trainer_type_data.id == :WuhuIslandExecutioner
      return pbStringToAudioFile("VSLiterallyCynthia")
    end
    if trainer_type_data.id == :CHAMPION_Sinnoh
      if $Trainer.numbadges <= 2
        return pbStringToAudioFile("CynthiaEncounter1")
      end
      if $Trainer.numbadges <= 5
        return pbStringToAudioFile("CynthiaEncounter2")
      end
      if $Trainer.numbadges <= 7
        return pbStringToAudioFile("CynthiaEncounter3")
      end
      if $Trainer.numbadges <= 9
        return pbStringToAudioFile("CynthiaEncounter4")
      end
      if $Trainer.numbadges <= 12
        return pbStringToAudioFile("CynthiaEncounter5")
      end
      if $Trainer.numbadges <= 14
        return pbStringToAudioFile("CynthiaEncounter6")
      end
      return pbStringToAudioFile("CynthiaEncounter7")
    end
    if trainer_type_data.id == :Skeleton_Dev && trainerarray.length() == 1
      return pbStringToAudioFile("TheSkeletonAppears")
    end
    if [:Non_Skeleton_Dev, :Upside_Down_Dev].include?(trainer_type_data.id) && trainerarray.length() == 1
      return pbStringToAudioFile("CtcUNOwen")
    end
    if trainer_type_data.id == :Skeleton_Dev
      return pbStringToAudioFile("ShadHewDuel")
    end
    if trainer_type_data.id == :CREATOR_Minecraft || trainer_type_data.id == :CREATOR_Minecraft2 || trainer_type_data.id == :COOLTRAINER_MIKU
      return pbStringToAudioFile("Miku")
    end
    if trainer_type_data.id == :TYPE_EXPERT_FAIRY
      return pbStringToAudioFile("MikuFairy")
    end
    if trainer_type_data.id == :YOUNGSTER && trainer_type_data.name == "Joe"
      return pbStringToAudioFile("Volo")
    end
    if trainer_type_data.id == :TEAMROCKET
      return pbStringToAudioFile("Dennis")
    end
    if trainer_type_data.id == :LEADER_Giovanni
      return pbStringToAudioFile("VSGiovanni")
    end
  end
  ret = pbStringToAudioFile(music) if music && music!=""
  if !ret
    # Check map metadata
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    music = (map_metadata) ? map_metadata.trainer_battle_BGM : nil
    ret = pbStringToAudioFile(music) if music && music != ""
  end
  if !ret
    # Check global metadata
    music = GameData::Metadata.get.trainer_battle_BGM
    if music && music!=""
      ret = pbStringToAudioFile(music)
    end
  end
  ret = pbStringToAudioFile("Battle trainer") if !ret
  return ret
end

def pbGetTrainerBattleBGMFromType(trainertype)
  if $PokemonGlobal.nextBattleBGM
    return $PokemonGlobal.nextBattleBGM.clone
  end
  trainer_type_data = GameData::TrainerType.get(trainertype)
  ret = trainer_type_data.battle_BGM if trainer_type_data.battle_BGM
  if !ret
    # Check map metadata
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    music = (map_metadata) ? map_metadata.trainer_battle_BGM : nil
    ret = pbStringToAudioFile(music) if music && music != ""
  end
  if !ret
    # Check global metadata
    music = GameData::Metadata.get.trainer_battle_BGM
    ret = pbStringToAudioFile(music) if music && music!=""
  end
  ret = pbStringToAudioFile("Battle trainer") if !ret
  return ret
end

def pbGetTrainerVictoryME(trainer)   # can be a Player, NPCTrainer or an array of them
begin
  if $PokemonGlobal.nextBattleME
    return $PokemonGlobal.nextBattleME.clone
  end
  if trainer.is_a?(Array)
    npcTrainer=trainer[0]
  else
    npcTrainer=trainer
  end

  if is_gym_leader(npcTrainer)
    ret = pbStringToAudioFile(Settings::LEADER_VICTORY_MUSIC)
  else
    ret = pbStringToAudioFile(Settings::TRAINER_VICTORY_MUSIC)
  end
  ret.name = "../../Audio/ME/"+ret.name
  return ret
rescue
  ret = pbStringToAudioFile(Settings::TRAINER_VICTORY_MUSIC)
  ret.name = "../../Audio/ME/"+ret.name
  return ret
end

end

GYM_LEADERS=[:LEADER_Brock,:LEADER_Misty, :LEADER_Surge, :LEADER_Erika, :LEADER_Koga, :LEADER_Sabrina, :LEADER_Blaine,
             :LEADER_Giovanni, :ELITEFOUR_Lorelei, :ELITEFOUR_Bruno, :ELITEFOUR_Agatha, :ELITEFOUR_Lance, :CHAMPION,
             :LEADER_Whitney, :LEADER_Kurt, :LEADER_Falkner, :LEADER_Clair, :LEADER_Morty, :LEADER_Pryce, :LEADER_Chuck,
             :LEADER_Jasmine, :CHAMPION_Sinnoh]
def is_gym_leader(trainer)
  return GYM_LEADERS.include?(trainer.trainer_type)
end
