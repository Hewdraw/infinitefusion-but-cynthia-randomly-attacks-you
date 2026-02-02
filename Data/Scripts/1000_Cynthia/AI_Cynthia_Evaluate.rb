class PokeBattle_AI
  def pbCynthiaCommandPhase(battlerlist)
    currentscore = pbCynthiaEvaluatePosition(battlerlist)
  end
  def pbCynthiaEvaluatePosition

  end
end

      # AI controls this battler
      if ($PokemonSystem.aicontrolplayer == 1 && @opponent) || !pbOwnedByPlayer?(idxBattler)
        @battleAI.pbDefaultChooseEnemyCommand(idxBattler)
        next
      end