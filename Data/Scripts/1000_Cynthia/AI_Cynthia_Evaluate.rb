class PokeBattle_AI
  def pbCynthiaCommandPhase
    print(@battle.opponent)
    print(@battle.player)
    #currentscore = pbCynthiaEvaluatePosition
    idxBattler = -1
    loop do
      break if @battle.decision!=0   # Battle ended, stop choosing actions
      idxBattler += 1
      break if idxBattler>=@battle.battlers.length
      next if !@battle.battlers[idxBattler]
      next if @battle.choices[idxBattler][0]!=:None    # Action is forced, can't choose one
      next if !@battle.pbCanShowCommands?(idxBattler)   # Action is forced, can't choose one
      # AI controls this battler
      next unless ($PokemonSystem.aicontrolplayer == 1 && @battle.opponent) || !@battle.pbOwnedByPlayer?(idxBattler)
      pbDefaultChooseEnemyCommand(idxBattler)
    end
  end
  def pbCynthiaEvaluatePosition

  end
end