def failAllIncompleteRocketQuests()
  for trainer_quest in $Trainer.quests
    finishTRQuest("tr_cerulean_1", :FAILURE) if trainer_quest.id == "tr_cerulean_1" && !pbCompletedQuest?("tr_cerulean_1")
    finishTRQuest("tr_cerulean_2", :FAILURE) if trainer_quest.id == "tr_cerulean_2" && !pbCompletedQuest?("tr_cerulean_2")
    finishTRQuest("tr_cerulean_3", :FAILURE) if trainer_quest.id == "tr_cerulean_3" && !pbCompletedQuest?("tr_cerulean_3")
    finishTRQuest("tr_cerulean_4", :FAILURE) if trainer_quest.id == "tr_cerulean_4" && !pbCompletedQuest?("tr_cerulean_4")

    finishTRQuest("tr_celadon_1", :FAILURE) if trainer_quest.id == "tr_celadon_1" && !pbCompletedQuest?("tr_celadon_1")
    finishTRQuest("tr_celadon_2", :FAILURE) if trainer_quest.id == "tr_celadon_2" && !pbCompletedQuest?("tr_celadon_2")
    finishTRQuest("tr_celadon_3", :FAILURE) if trainer_quest.id == "tr_celadon_3" && !pbCompletedQuest?("tr_celadon_3")
    finishTRQuest("tr_celadon_4", :FAILURE) if trainer_quest.id == "tr_celadon_4" && !pbCompletedQuest?("tr_celadon_4")
  end
end

def Kernel.setRocketPassword(variableNum)
  abilityIndex = rand(233)
  speciesIndex = rand(PBSpecies.maxValue - 1)

  word1 = PBSpecies.getName(speciesIndex)
  word2 = GameData::Ability.get(abilityIndex).name
  password = _INTL("{1}'s {2}", word1, word2)
  pbSet(variableNum, password)
end

def initialize_quest_points
  return if $Trainer.quest_points
  $Trainer.quest_points = get_completed_quests(false).length
end

def player_has_quest_journal?
  return $PokemonBag.pbHasItem?(:DEVONSCOPE) || $PokemonBag.pbHasItem?(:NOTEBOOK)
end