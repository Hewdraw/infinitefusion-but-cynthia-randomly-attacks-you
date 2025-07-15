def pbEncounterCynthia(force_miku = false, trainer_override = nil)
  chanceincrease = 1
  if !Settings::FLUTES_CHANGE_WILD_ENCOUNTER_LEVELS
    chanceincrease *= 2 if $PokemonMap.blackFluteUsed
  end
  first_pkmn = $Trainer.first_pokemon
  if first_pkmn
    case first_pkmn.item_id
    when :CLEANSETAG
      chanceincrease *= 2
    when :PUREINCENSE
      chanceincrease *= 2
    else   # Ignore ability effects if an item effect applies
      case first_pkmn.ability_id
      when :STENCH, :WHITESMOKE, :QUICKFEET, :INTIMIDATE, :MENACE, :KEENEYE
        chanceincrease *= 2
      when :SANDVEIL
        if GameData::Weather.get($game_screen.weather_type).category == :Sandstorm
          chanceincrease *= 2
        end
      end
    end
  end
  numbadges = $Trainer.numbadges
  $PokemonGlobal.cynthiachance += chanceincrease
  if $PokemonGlobal.cynthiaupgradechance == nil
    $PokemonGlobal.cynthiaupgradechance = 0
  end
  if $PokemonGlobal.cynthiabadgetier == nil
    $PokemonGlobal.cynthiabadgetier = numbadges
  end
  if numbadges > $PokemonGlobal.cynthiabadgetier
    $PokemonBag.pbDeleteItem(:SINNOHCOIN, 999)
    if $PokemonGlobal.pcItemStorage
      $PokemonGlobal.pcItemStorage.pbDeleteItem(:SINNOHCOIN,999)
    end
    $PokemonGlobal.cynthiaupgradechance = 0
    $PokemonGlobal.cynthiabadgetier = numbadges
    $PokemonGlobal.cynthiachance = 1000
  end
  if rand(120) < $PokemonGlobal.cynthiachance || (repel_active && !$PokemonTemp.pokeradar)
    if $PokemonGlobal.cynthiahandschance == nil
      $PokemonGlobal.cynthiahandschance = -10
    end
    $PokemonGlobal.cynthiahandschance += 1
    if rand(150) < $PokemonGlobal.cynthiahandschance
      $PokemonGlobal.cynthiahandschance = 1000
    end
    $PokemonGlobal.cynthiachance = 0
    if getDayOfTheWeek().to_s == "MONDAY" && !($Trainer.numbadges == 0)
      $PokemonGlobal.cynthiaupgradechance += 18
    end
    for mon in $Trainer.party
      if pokemonExceedsLevelCap(mon) || numbadges == 16
        $PokemonGlobal.cynthiaupgradechance += 1
        break
      end
    end
    badgeupgradechance = 32
    if rand(25) < $PokemonGlobal.cynthiaupgradechance
      numbadges += 1
      $PokemonGlobal.cynthiaupgradechance = 0
      badgeupgradechance / 2
    end
    if rand(30) == 0
      numbadges += 1
      badgeupgradechance / 4
    end
    while rand(badgeupgradechance) == 0 && numbadges > $Trainer.numbadges
      numbadges += 1
      if badgeupgradechance == 16
        badgeupgradechance / 2
      end
    end
    if numbadges > 17
      numbadges == 17
    end
    badges = []
    badges.append((2..6).to_a) #0
    badges.append((7..12).to_a) #1
    badges.append((13..18).to_a) #2
    badges.append((19..23).to_a) #3
    badges.append((24..28).to_a) #4
    badges.append((29..33).to_a) #5
    badges.append((34..38).to_a) #6
    badges.append((39..43).to_a) #7
    badges.append((44..48).to_a) #8
    badges.append((49..53).to_a) #9
    badges.append((54..58).to_a) #10
    badges.append((59..63).to_a) #11
    badges.append((64..68).to_a) #12
    badges.append((69..73).to_a) #13
    badges.append((74..78).to_a) #14
    badges.append((79..83).to_a) #15
    badges.append((84..88).to_a) #16
    badges.append((89..93).to_a) #17

    currentbadge = badges[numbadges]

    mikumaxchance = 70
    if $PokemonGlobal.hatsunemikuchance == nil
      $PokemonGlobal.hatsunemikuchance = 1
    else
      $PokemonGlobal.hatsunemikuchance += 1
    end
    if getDayOfTheWeek().to_s == "MONDAY" && !($Trainer.numbadges == 0)
      $PokemonGlobal.hatsunemikuchance += 3
      mikumaxchance = 30
    end

    if rand(mikumaxchance) < $PokemonGlobal.hatsunemikuchance
      $PokemonGlobal.hatsunemikuchance = 0
      if numbadges > 11 #temporary
        numbadges = 11
      end
      pbTrainerBattle(:CREATOR_Minecraft, "Hatsune Miku", "sorrgy accident..", true, numbadges)
    elsif $PokemonGlobal.partner
      pbDoubleTrainerBattle(:CHAMPION_Sinnoh, "Cynthia", currentbadge[pbCynthiaRollEncounter], nil, :CHAMPION_Sinnoh, "Cynthia", currentbadge[pbCynthiaRollEncounter])
    elsif numbadges >= $Trainer.numbadges + 2
      pbTrainerBattle(:CHAMPION_Sinnoh, "Cynthia", nil, false, currentbadge[pbCynthiaRollEncounter], false, 1, nil, :CHAMPION_Sinnoh2)
    elsif numbadges > $Trainer.numbadges
      pbTrainerBattle(:CHAMPION_Sinnoh, "Cynthia", "sorrgy accident..", false, currentbadge[pbCynthiaRollEncounter], false, 1, "Hatsune Miku", :CREATOR_Minecraft2)
    else
      pbTrainerBattle(:CHAMPION_Sinnoh, "Cynthia", nil, false, currentbadge[pbCynthiaRollEncounter])
    end
  end
end


  # mikumaxchance = 70
  # if $PokemonGlobal.hatsunemikuchance == nil
  #   $PokemonGlobal.hatsunemikuchance = 1
  # else
  #   $PokemonGlobal.hatsunemikuchance += 1
  # end
  # if getDayOfTheWeek().to_s == "MONDAY" && !($Trainer.numbadges == 0)
  #   $PokemonGlobal.hatsunemikuchance += 3
  #   mikumaxchance = 30
  # end
  # if rand(mikumaxchance) < $PokemonGlobal.hatsunemikuchance
  #   numbadges = $Trainer.numbadges

  #   $PokemonGlobal.hatsunemikuchance = 0
  #   if getDayOfTheWeek().to_s == "MONDAY" && !($Trainer.numbadges == 0)
  #     $PokemonGlobal.cynthiaupgradechance += 18
  #   end
  #   badgeupgradechance = 32
  #   if rand(25) < $PokemonGlobal.cynthiaupgradechance
  #     numbadges += 1
  #     $PokemonGlobal.cynthiaupgradechance = 0
  #     badgeupgradechance / 2
  #   end
  #   if rand(30) == 0
  #     numbadges += 1
  #     badgeupgradechance / 4
  #   end
  #   while rand(badgeupgradechance) == 0 && numbadges > $Trainer.numbadges
  #     numbadges += 1
  #     if badgeupgradechance == 16
  #       badgeupgradechance / 2
  #     end
  #   end

  #   if numbadges > 11 #temporary
  #     numbadges = 11
  #   end
  #   pbTrainerBattle(:CREATOR_Minecraft, "Hatsune Miku", "sorrgy accident..", true, numbadges)
  #   return false
  # end