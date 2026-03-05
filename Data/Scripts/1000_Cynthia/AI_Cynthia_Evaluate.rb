class PokeBattle_AI
  def pbCynthiaCommandPhase
    #currentscore = pbCynthiaEvaluatePosition
    @playerside = []
    @opponentside = []
    idxBattler = -1
    loop do
      break if @battle.decision!=0   # Battle ended, stop choosing actions
      idxBattler += 1
      break if idxBattler>=@battle.battlers.length
      battler = @battle.battlers[idxBattler]
      next if !battler
      @playerside.push(battler) if battler.idxOwnSide == 0
      @opponentside.push(battler) if battler.idxOpposingSide == 0
      next if @battle.choices[idxBattler][0]!=:None    # Action is forced, can't choose one
      next if !@battle.pbCanShowCommands?(idxBattler)   # Action is forced, can't choose one
      # AI controls this battler
      next unless ($PokemonSystem.aicontrolplayer == 1 && @battle.opponent) || !@battle.pbOwnedByPlayer?(idxBattler)
      pbDefaultChooseEnemyCommand(idxBattler)
    end
  end

  def pbCynthiaEvaluatePosition
    playerscore = 0
    opponentscore = 0
    @playerside.each do |battler|
      
    end
    @opponentside.each do |battler|
      
    end
  end
end