class PokeBattle_AI
  def pbCynthiaGetStatIncrease(stat, change, target)
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    originalstages = target.stages[stat] + 6
    if target.hasActiveAbility?(:CONTRARY)
      change *= -1
    end
    stages =  originalstages + change
    stages = [0, stages].max
    stages = [12, stages].min
    stateffect = (stageMul[stages].to_f / stageDiv[stages].to_f) / (stageMul[originalstages].to_f / stageDiv[originalstages].to_f)
    stateffect = (stateffect + (-1 * (originalstages - 6))) / (1 + (-1 * (originalstages - 6))) if change < 0 && originalstages < 6
    return stateffect
  end

  def pbCynthiaGetMoveScoreStatus(move,user,target)
    skill = 100 #temporary
    score = 32
    userThreattable = pbCynthiaAssessThreat(target, user, false, true)
    userThreat = userThreattable[:highestDamage]
    userPhysicalThreat = userThreattable[:physicalDamage]
    userSpecialThreat = userThreattable[:specialDamage]
    opposingThreat = 0
    opposingPhysicalThreat = 0
    opposingSpecialThreat = 0
    outspeedsopponent = true
    user.eachOpposing do |opponent|
      if @threattable[user][opponent] == nil
        @threattable[user][opponent] = pbCynthiaAssessThreat(user, opponent, true, true)
      end
      opposingThreat += @threattable[user][opponent][:highestDamage]
      opposingPhysicalThreat += @threattable[user][opponent][:physicalDamage]
      opposingSpecialThreat += @threattable[user][opponent][:specialDamage]
      outspeedsopponent = false if opponent.pbSpeed >= user.pbSpeed
    end
    case move.function
    #---------------------------------------------------------------------------
    when "000", "001", "002", "048", "06A", "06B", "06C", "06D", "06E", "06F", "075", "076", "077", "079", "07A", "07B", "07E", "07F", "080", "085", "086", "087", "088", "089", "08A", "08B", "08C", "08D", "08E", "08F", "090", "091", "092", "094", "095", "096", "097", "098", "099", "09A", "09B", "09F", "0A0", "0A4", "0A5", "0A9", "0BD", "0BF", "0C0", "0C1", "0C3", "0EE", "106", "107", "108", "109", "133", "134", "144", "157", "164", "166", "169", "177", "178", "185", "192" ,"195"  # No extra effect
      score = 0
    #---------------------------------------------------------------------------
    when "003", "004" #sleep
      score *= 1.5 if user.hasActiveAbility?(:BADDREAMS)
      score *= 1.5 if user.pbHasMove?(:NIGHTMARE) || user.pbHasMove?(:DREAMEATER)
      score = 0 if target.effects[PBEffects::Yawn]>0 || target.hasActiveAbility?([:MARVELSCALE, :GUTS, :QUICKFEET]) || target.pbHasMoveFunction?("011","0B4", "0D9") || !target.pbCanSleep?(user,false)
    # #---------------------------------------------------------------------------
    when "005", "006", "0BE"
      score = 0 if target.effects[PBEffects::Yawn]>0 || target.hasActiveAbility?([:GUTS,:MARVELSCALE,:TOXICBOOST,:QUICKFEET, :POISONHEAL, :MAGICGUARD]) || target.pbHasMoveFunction?("0D9") || !target.pbCanPoison?(user,false) || (target.hasActiveAbility?(:SYNCHRONIZE) && user.pbCanPoisonSynchronize?(target))
    #---------------------------------------------------------------------------
    when "007", "008", "009", "0C5"
      score = 99 if target.pbSpeed > user.pbSpeed && target.pbSpeed / 4 < user.pbSpeed
      score = 0 if target.effects[PBEffects::Yawn]>0 || !target.pbCanParalyze?(user,false) || (move.id == :THUNDERWAVE && Effectiveness.ineffective?(pbCalcTypeMod(move.type,user,target))) || target.hasActiveAbility?([:QUICKFEET, :MARVELSCALE, :GUTS]) || target.pbHasMoveFunction?("0D9") || (target.hasActiveAbility?(:SYNCHRONIZE) && user.pbCanParalyzeSynchronize?(target))
    #---------------------------------------------------------------------------
    when "00A", "00B", "0C6" #todo better damage calcs
      score = 10 if opposingPhysicalThreat < opposingSpecialThreat
      score -= 10 if target.hasActiveAbility?(:MAGICGUARD)
      score = 0 if target.effects[PBEffects::Yawn]>0 || !target.pbCanBurn?(user,false) || target.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET,:FLAREBOOST]) || target.pbHasMoveFunction?("0D9") || (target.hasActiveAbility?(:SYNCHRONIZE) && user.pbCanBurnSynchronize?(target))
    #---------------------------------------------------------------------------
    when "00C", "00D", "00E", "135", "187" #todo better damage calcs
      score = 10 if opposingSpecialThreat < opposingPhysicalThreat
      score -= 10 if target.hasActiveAbility?(:MAGICGUARD)
      score = 0 if target.effects[PBEffects::Yawn]>0 || !target.pbCanFreeze?(user,false) || target.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET]) || target.pbHasMoveFunction?("0D9")
    #---------------------------------------------------------------------------
    when "00F"
      #todo flinching (maybe handle elsewhere?)
    #---------------------------------------------------------------------------
    when "010"
      #todo stomp handle elsewhere
    #---------------------------------------------------------------------------
    when "011"
      #todo snore handle elsewhere
    #---------------------------------------------------------------------------
    when "012"
      score += @threattable[user][target][:highestDamage]
      score = 0 if !(user.turnCount==0) || target.hasActiveAbility?([:INNERFOCUS, :SHIELDDUST, :STEADFAST]) || target.effects[PBEffects::Substitute]>0
    #---------------------------------------------------------------------------
    when "013", "014", "015", "040", "041"
      score = 0 if !target.pbCanConfuse?(user,false,move)
    #---------------------------------------------------------------------------
    when "016"
      score = 0 if !target.pbCanAttract?(user,false) || (target.hasActiveItem?(:DESTINYKNOT) && user.pbCanAttract?(target,false))
    #---------------------------------------------------------------------------
    when "018"
      score = 0 if ![:POISON, :BURN, :PARALYSIS].include?(user.status)
    #---------------------------------------------------------------------------
    when "019", "191"
      @battle.pbParty(user.index).each do |pkmn|
        score += 20 if pkmn && pkmn.status != :NONE
      end
    #---------------------------------------------------------------------------
    when "01A"
      score = 0 if user.pbOwnSide.effects[PBEffects::Safeguard]>0 || user.status != :NONE
    #---------------------------------------------------------------------------
    when "01B"
      score *= 1.5
      score = 0 if user.status == :NONE || !target.pbCanInflictStatus?(user.status, user, false, move)
    #---------------------------------------------------------------------------
    when "01C", "029"
      if !user.statStageAtMax?(:ATTACK)
        statincrease = pbCynthiaGetStatIncrease(:ATTACK, 1, user)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = [score, userPhysicalThreat * statincrease].max() if (userhp / [userPhysicalThreat*statincrease, opposingThreat].max.ceil).ceil < damagethreshold
      else
        score = 0
      end
      user.eachOpposing do |opponent|
        score = 0 if opponent.hasActiveAbility?(:UNAWARE)
      end
    #---------------------------------------------------------------------------
    when "01D", "01E", "0C8"
      if !user.statStageAtMax?(:DEFENSE)
        statincrease = pbCynthiaGetStatIncrease(:DEFENSE, 1, user)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = [score, opposingPhysicalThreat * statincrease].max() if damagethreshold < (userhp / ([userThreat, opposingPhysicalThreat / statincrease].max.ceil)).ceil
      else
        score = 0
      end
      user.eachOpposing do |opponent|
        score = 0 if opponent.hasActiveAbility?(:UNAWARE)
      end
    #---------------------------------------------------------------------------
    when "01F"
      if !user.statStageAtMax?(:SPEED)
        score = 100
        statincrease = pbCynthiaGetStatIncrease(:SPEED, 1, user)
        user.eachOpposing do |opponent|
          score = 0 if user.pbSpeed * statincrease <= opponent.pbSpeed
          score = 0 if opponent.hasActiveAbility?(:SPEEDBOOST)
        end
      else
        score = 0
      end
      score = 0 if outspeedsopponent
    #---------------------------------------------------------------------------
    when "020"
      if !user.statStageAtMax?(:SPECIAL_ATTACK)
        statincrease = pbCynthiaGetStatIncrease(:SPECIAL_ATTACK, 1, user)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = [score, userSpecialThreat * statincrease].max() if (userhp / [userSpecialThreat*statincrease, opposingThreat].max.ceil).ceil < damagethreshold
      else
        score = 0
      end
      user.eachOpposing do |opponent|
        score = 0 if opponent.hasActiveAbility?(:UNAWARE)
      end
    #---------------------------------------------------------------------------
    when "021"
      if !user.statStageAtMax?(:SPECIAL_DEFENSE)
        statincrease = pbCynthiaGetStatIncrease(:SPECIAL_DEFENSE, 1, user)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = [score, opposingSpecialThreat * statincrease].max() if damagethreshold < (userhp / ([userThreat, opposingSpecialThreat / statincrease].max.ceil)).ceil
      else
        score = 0
      end
      user.eachOpposing do |opponent|
        score = 0 if opponent.hasActiveAbility?(:UNAWARE)
      end
      score += 32 if user.pbHasType?(:ELECTRIC) && user.effects[PBEffects::Charge] == 0 && opposingThreat < 50 && userThreat < 100
    #---------------------------------------------------------------------------
    when "022"
      score = [score, 66 - opposingThreat].max()
      score = 0 if user.stages[:EVASION] >= 1
      user.eachOpposing do |opponent|
        opponent.eachMove do |opponentmove|
          score = 0 if ["0A5", "13B", "147", "185", "188", "192"].include?(opponentmove.function)
        end
        score = 0 if opponent.hasActiveAbility?([:COMPOUNDEYES, :NOGUARD])
        score = 0 if opponent.stages[:ACCURACY] >= 1
      end
    #---------------------------------------------------------------------------
    when "023"
      score = [score, 100 - opposingThreat].max()
      score *= 1/2 if !outspeedsopponent
      score *= 2 if user.hasActiveItem?(:SCOPELENS)
      score *= 1.5 if user.hasActiveAbility?([:SNIPER, :SUPERSNIPER])
      user.eachOpposing do |opponent|
        score *= [opponent.stages[:DEFENSE], opponent.stages[:SPECIAL_DEFENSE]].max() + 1
        score = 0 if opponent.hasActiveAbility?([:BATTLERARMOR, :SHELLARMOR])
      end
      score *= -([user.stages[:ATTACK], user.stages[:SPECIAL_ATTACK]].min() + 1)
      score = 0 if user.effects[PBEffects::FocusEnergy]>=1
    #---------------------------------------------------------------------------
    when "024", "025"
      if !user.statStageAtMax?(:DEFENSE) || !user.statStageAtMax?(:ATTACK)
        defstatincrease = pbCynthiaGetStatIncrease(:DEFENSE, 1, user)
        atkstatincrease = pbCynthiaGetStatIncrease(:ATTACK, 1, user)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = [score, opposingPhysicalThreat * defstatincrease].max() if damagethreshold < (userhp / ([userThreat, opposingPhysicalThreat / defstatincrease].max.ceil)).ceil
        score = [score, userPhysicalThreat * atkstatincrease].max() if (userhp / [userPhysicalThreat*atkstatincrease, opposingThreat].max.ceil).ceil < damagethreshold
      else
        score = 0
      end
      user.eachOpposing do |opponent|
        score = 0 if opponent.hasActiveAbility?(:UNAWARE)
      end
    #---------------------------------------------------------------------------
    when "026"
      if !user.statStageAtMax?(:SPEED) || !user.statStageAtMax?(:ATTACK)
        speedstatincrease = pbCynthiaGetStatIncrease(:SPEED, 1, user)
        atkstatincrease = pbCynthiaGetStatIncrease(:ATTACK, 1, user)
        speedscore = 100
        user.eachOpposing do |opponent|
          speedscore = 0 if user.pbSpeed * speedstatincrease <= opponent.pbSpeed
          speedscore = 0 if opponent.hasActiveAbility?(:SPEEDBOOST)
          atkstatincrease = 1 if opponent.hasActiveAbility?(:UNAWARE)
        end
        speedscore = 0 if outspeedsopponent
        score = [score, speedscore].max()
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = [score, userPhysicalThreat * atkstatincrease].max() if (userhp / [userPhysicalThreat * atkstatincrease, opposingThreat].max.ceil).ceil < damagethreshold
      else
        score = 0
      end
    #---------------------------------------------------------------------------
    when "027", "028"
      if !user.statStageAtMax?(:ATTACK) || !user.statStageAtMax?(:SPECIAL_ATTACK)
        statincrease = [pbCynthiaGetStatIncrease(:ATTACK, 1, user), pbCynthiaGetStatIncrease(:SPECIAL_ATTACK, 1, user)].max
        if move.function=="028"   # Growth
          statincrease = [pbCynthiaGetStatIncrease(:ATTACK, 2, user), pbCynthiaGetStatIncrease(:SPECIAL_ATTACK, 2, user)].max if [:Sun, :HarshSun].include?(@battle.pbWeather)
        end
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = [score, userThreat * statincrease].max() if (userhp / [userThreat*statincrease, opposingThreat].max.ceil).ceil < damagethreshold
      else
        score = 0
      end
      user.eachOpposing do |opponent|
        score = 0 if opponent.hasActiveAbility?(:UNAWARE)
      end
    #---------------------------------------------------------------------------
    when "02A"
      if !user.statStageAtMax?(:DEFENSE) || !user.statStageAtMax?(:SPECIAL_DEFENSE)
        statincrease = [pbCynthiaGetStatIncrease(:DEFENSE, 1, user), pbCynthiaGetStatIncrease(:SPECIAL_DEFENSE, 1, user)].max
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = [score, opposingThreat * statincrease].max() if damagethreshold < (userhp / ([userThreat, opposingThreat / statincrease].max.ceil)).ceil
      else
        score = 0
      end
      user.eachOpposing do |opponent|
        score = 0 if opponent.hasActiveAbility?(:UNAWARE)
      end
    #---------------------------------------------------------------------------
    when "02B"
      if !user.statStageAtMax?(:SPEED) || !user.statStageAtMax?(:SPECIAL_ATTACK) || !user.statStageAtMax?(:SPECIAL_DEFENSE)
        speedstatincrease = pbCynthiaGetStatIncrease(:SPEED, 1, user)
        atkstatincrease = pbCynthiaGetStatIncrease(:SPECIAL_ATTACK, 1, user)
        defstatincrease = pbCynthiaGetStatIncrease(:SPECIAL_DEFENSE, 1, user)
        speedscore = 100
        user.eachOpposing do |opponent|
          speedscore = 0 if user.pbSpeed * speedstatincrease <= opponent.pbSpeed
          speedscore = 0 if opponent.hasActiveAbility?(:SPEEDBOOST)
          atkstatincrease = 1 if opponent.hasActiveAbility?(:UNAWARE)
          defstatincrease = 1 if opponent.hasActiveAbility?(:UNAWARE)
        end
        speedscore = 0 if outspeedsopponent
        score = [score, speedscore].max()
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = [score, opposingSpecialThreat * defstatincrease].max() if damagethreshold < (userhp / ([userThreat, opposingSpecialThreat / defstatincrease].max.ceil)).ceil
        score = [score, userSpecialThreat * atkstatincrease].max() if (userhp / [userSpecialThreat * atkstatincrease, opposingThreat].max.ceil).ceil < damagethreshold
      else
        score = 0
      end
    #---------------------------------------------------------------------------
    when "02C"
      if !user.statStageAtMax?(:SPECIAL_ATTACK) || !user.statStageAtMax?(:SPECIAL_DEFENSE)
        defstatincrease = pbCynthiaGetStatIncrease(:SPECIAL_DEFENSE, 1, user)
        atkstatincrease = pbCynthiaGetStatIncrease(:SPECIAL_ATTACK, 1, user)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = [score, opposingSpecialThreat * defstatincrease].max() if damagethreshold < (userhp / ([userThreat, opposingSpecialThreat / defstatincrease].max.ceil)).ceil
        score = [score, userSpecialThreat * atkstatincrease].max() if (userhp / [userSpecialThreat*atkstatincrease, opposingThreat].max.ceil).ceil < damagethreshold
      else
        score = 0
      end
      user.eachOpposing do |opponent|
        score = 0 if opponent.hasActiveAbility?(:UNAWARE)
      end
    #---------------------------------------------------------------------------
    when "02D"
      score = [score, 100 - opposingThreat].max()
    #---------------------------------------------------------------------------
    when "02E"
      if !user.statStageAtMax?(:ATTACK)
        statincrease = pbCynthiaGetStatIncrease(:ATTACK, 2, user)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = [score, userPhysicalThreat * statincrease].max() if (userhp / [userPhysicalThreat*statincrease, opposingThreat].max.ceil).ceil < damagethreshold
      else
        score = 0
      end
      user.eachOpposing do |opponent|
        score = 0 if opponent.hasActiveAbility?(:UNAWARE)
      end
    #---------------------------------------------------------------------------
    when "02F", "136"
      if !user.statStageAtMax?(:DEFENSE)
        statincrease = pbCynthiaGetStatIncrease(:DEFENSE, 2, user)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = [score, opposingPhysicalThreat * statincrease].max() if damagethreshold < (userhp / ([userPhysicalThreat, opposingThreat / statincrease].max.ceil)).ceil
      else
        score = 0
      end
      user.eachOpposing do |opponent|
        score = 0 if opponent.hasActiveAbility?(:UNAWARE)
      end
    #---------------------------------------------------------------------------
    when "030", "031"
      if !user.statStageAtMax?(:SPEED)
        score = 100
        statincrease = pbCynthiaGetStatIncrease(:SPEED, 2, user)
        user.eachOpposing do |opponent|
          score = 0 if user.pbSpeed * statincrease <= opponent.pbSpeed
          score = 0 if opponent.hasActiveAbility?(:SPEEDBOOST)
        end
      else
        score = 0
      end
      score = 0 if outspeedsopponent
    #---------------------------------------------------------------------------
    when "032"
      if !user.statStageAtMax?(:SPECIAL_ATTACK)
        statincrease = pbCynthiaGetStatIncrease(:SPECIAL_ATTACK, 2, user)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = [score, userSpecialThreat * statincrease].max() if (userhp / [userSpecialThreat*statincrease, opposingThreat].max.ceil).ceil < damagethreshold
      else
        score = 0
      end
      user.eachOpposing do |opponent|
        score = 0 if opponent.hasActiveAbility?(:UNAWARE)
      end
    #---------------------------------------------------------------------------
    when "033"
      if !user.statStageAtMax?(:SPECIAL_DEFENSE)
        statincrease = pbCynthiaGetStatIncrease(:SPECIAL_DEFENSE, 2, user)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = [score, opposingSpecialThreat * statincrease].max() if damagethreshold < (userhp / ([userThreat, opposingSpecialThreat / statincrease].max.ceil)).ceil
      else
        score = 0
      end
      user.eachOpposing do |opponent|
        score = 0 if opponent.hasActiveAbility?(:UNAWARE)
      end
    #---------------------------------------------------------------------------
    when "034"
      score = [score, 66 - opposingThreat].max()
      score = 0 if user.stages[:EVASION] >= 1
      user.eachOpposing do |opponent|
        opponent.eachMove do |opponentmove|
          score = 0 if ["0A5", "13B", "147", "185", "188", "192"].include?(opponentmove.function)
        end
        score = 0 if opponent.hasActiveAbility?([:COMPOUNDEYES, :NOGUARD])
        score = 0 if opponent.stages[:ACCURACY] >= 1
      end
    #---------------------------------------------------------------------------
    when "035"
      if !user.statStageAtMax?(:SPEED) || !user.statStageAtMax?(:ATTACK) || !user.statStageAtMax?(:SPECIAL_ATTACK)
        speedstatincrease = pbCynthiaGetStatIncrease(:SPEED, 2, user)
        atkstatincrease = [pbCynthiaGetStatIncrease(:ATTACK, 2, user), pbCynthiaGetStatIncrease(:SPECIAL_ATTACK, 2, user)].max()
        speedscore = 100
        user.eachOpposing do |opponent|
          speedscore = 0 if user.pbSpeed * speedstatincrease <= opponent.pbSpeed
          speedscore = 0 if opponent.hasActiveAbility?(:SPEEDBOOST)
          atkstatincrease = 1 if opponent.hasActiveAbility?(:UNAWARE)
        end
        speedscore = 0 if outspeedsopponent
        score = [score, speedscore].max()
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = [score, userThreat * atkstatincrease].max() if (userhp / [userThreat * atkstatincrease, opposingThreat].max.ceil).ceil < damagethreshold
      else
        score = 0
      end
      defstatincrease = [pbCynthiaGetStatIncrease(:DEFENSE, 1, user), pbCynthiaGetStatIncrease(:SPECIAL_DEFENSE, 1, user)].min()
      if user.hasActiveItem?(:WHITEHERB)
        defstatincrease = 1
      end
      score = 0 if outspeedsopponent && opposingThreat / defstatincrease >= 100
    #---------------------------------------------------------------------------
    when "036"
      if !user.statStageAtMax?(:SPEED) || !user.statStageAtMax?(:ATTACK)
        speedstatincrease = pbCynthiaGetStatIncrease(:SPEED, 2, user)
        atkstatincrease = pbCynthiaGetStatIncrease(:ATTACK, 1, user)
        speedscore = 100
        user.eachOpposing do |opponent|
          speedscore = 0 if user.pbSpeed * speedstatincrease <= opponent.pbSpeed
          speedscore = 0 if opponent.hasActiveAbility?(:SPEEDBOOST)
          atkstatincrease = 1 if opponent.hasActiveAbility?(:UNAWARE)
        end
        speedscore = 0 if outspeedsopponent
        score = [score, speedscore].max()
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = [score, userPhysicalThreat * atkstatincrease].max() if (userhp / [userPhysicalThreat * atkstatincrease, opposingThreat].max.ceil).ceil < damagethreshold
      else
        score = 0
      end
    #---------------------------------------------------------------------------
    when "037"
      score = [score, 66 - opposingThreat].max()
    #---------------------------------------------------------------------------
    when "038"
      if !user.statStageAtMax?(:DEFENSE)
        statincrease = pbCynthiaGetStatIncrease(:DEFENSE, 3, user)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = [score, opposingPhysicalThreat * statincrease].max() if damagethreshold < (userhp / ([userThreat, opposingPhysicalThreat / statincrease].max.ceil)).ceil
      else
        score = 0
      end
      user.eachOpposing do |opponent|
        score = 0 if opponent.hasActiveAbility?(:UNAWARE)
      end
    #---------------------------------------------------------------------------
    when "039"
      if !user.statStageAtMax?(:SPECIAL_ATTACK)
        statincrease = pbCynthiaGetStatIncrease(:SPECIAL_ATTACK, 1, user)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = [score, userSpecialThreat * statincrease].max() if (userhp / [userSpecialThreat*statincrease, opposingThreat].max.ceil).ceil < damagethreshold
      else
        score = 0
      end
      user.eachOpposing do |opponent|
        score = 0 if opponent.hasActiveAbility?(:UNAWARE)
      end
    #---------------------------------------------------------------------------
    when "03A"
      if !user.statStageAtMax?(:ATTACK)
        statincrease = pbCynthiaGetStatIncrease(:ATTACK, 12, user)
        userhp = ((100 * user.hp / user.totalhp) - 50) / (100 * user.hp / user.totalhp)
        if user.hasActiveItem?(:SITRUSBERRY)
          userhp = 100.0 * ((100 * user.hp / user.totalhp) + 25) / (100 * user.hp / user.totalhp)
        end
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = [score, userPhysicalThreat * statincrease].max() if (userhp / [userPhysicalThreat*statincrease, opposingThreat].max.ceil).ceil < damagethreshold
      else
        score = 0
      end
      user.eachOpposing do |opponent|
        score = 0 if opponent.hasActiveAbility?(:UNAWARE)
      end
    #---------------------------------------------------------------------------
    when "03B"
      if user.hasActiveAbility?(:CONTRARY)
        if !user.statStageAtMax?(:DEFENSE) || !user.statStageAtMax?(:ATTACK)
          defstatincrease = pbCynthiaGetStatIncrease(:DEFENSE, -1, user)
          atkstatincrease = pbCynthiaGetStatIncrease(:ATTACK, -1, user)
          userhp = 100.0
          userhp = userhp - opposingThreat if !outspeedsopponent
          damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
          score = [score, opposingPhysicalThreat * defstatincrease].max() if damagethreshold < (userhp / ([userThreat, opposingPhysicalThreat / defstatincrease].max.ceil)).ceil
          score = [score, userPhysicalThreat * atkstatincrease].max() if (userhp / [userPhysicalThreat*atkstatincrease, opposingThreat].max.ceil).ceil < damagethreshold
        else
          score = 0
        end
        user.eachOpposing do |opponent|
          score = 0 if opponent.hasActiveAbility?(:UNAWARE)
        end
      elsif user.hasActiveItem?(:WHITEHERB) && user.hasActiveAbility?(:UNBURDEN)
        score = 100
      else
        score = -32
      end
    #---------------------------------------------------------------------------
    when "03C"
      if user.hasActiveAbility?(:CONTRARY)
        if !user.statStageAtMax?(:DEFENSE) || !user.statStageAtMax?(:SPECIAL_DEFENSE)
          statincrease = [pbCynthiaGetStatIncrease(:DEFENSE, -1, user), pbCynthiaGetStatIncrease(:SPECIAL_DEFENSE, -1, user)].max()
          userhp = 100.0
          userhp = userhp - opposingThreat if !outspeedsopponent
          damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
          score = [score, opposingThreat * statincrease].max() if damagethreshold < (userhp / ([userThreat, opposingThreat / statincrease].max.ceil)).ceil
        else
          score = 0
        end
        user.eachOpposing do |opponent|
          score = 0 if opponent.hasActiveAbility?(:UNAWARE)
        end
      elsif user.hasActiveItem?(:WHITEHERB) && user.hasActiveAbility?(:UNBURDEN)
        score = 100
      else
        score = -32
      end
    #---------------------------------------------------------------------------
    when "03D"
      if user.hasActiveAbility?(:CONTRARY)
        if !user.statStageAtMax?(:SPEED) || !user.statStageAtMax?(:DEFENSE) || !user.statStageAtMax?(:SPECIAL_DEFENSE)
          speedstatincrease = pbCynthiaGetStatIncrease(:SPEED, -1, user)
          defstatincrease = [pbCynthiaGetStatIncrease(:DEFENSE, -1, user), pbCynthiaGetStatIncrease(:SPECIAL_DEFENSE, -1, user)].max()
          speedscore = 100
          user.eachOpposing do |opponent|
            speedscore = 0 if user.pbSpeed * speedstatincrease <= opponent.pbSpeed
            speedscore = 0 if opponent.hasActiveAbility?(:SPEEDBOOST)
            defstatincrease = 1 if opponent.hasActiveAbility?(:UNAWARE)
          end
          speedscore = 0 if outspeedsopponent
          score = [score, speedscore].max()
          userhp = 100.0
          userhp = userhp - opposingThreat if !outspeedsopponent
          damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
          score = [score, opposingThreat * defstatincrease].max() if damagethreshold < (userhp / ([userThreat, opposingThreat / defstatincrease].max.ceil)).ceil
        else
          score = 0
        end
      elsif user.hasActiveItem?(:WHITEHERB) && user.hasActiveAbility?(:UNBURDEN)
        score = 100
      else
        score = -32
      end
    #---------------------------------------------------------------------------
    when "03E"
      if user.hasActiveAbility?(:CONTRARY)
        if !user.statStageAtMax?(:SPEED)
          score = 100
          statincrease = pbCynthiaGetStatIncrease(:SPEED, -1, user)
          user.eachOpposing do |opponent|
            score = 0 if user.pbSpeed * statincrease <= opponent.pbSpeed
            score = 0 if opponent.hasActiveAbility?(:SPEEDBOOST)
          end
        else
          score = 0
        end
        score = 0 if outspeedsopponent
      elsif user.hasActiveItem?(:WHITEHERB) && user.hasActiveAbility?(:UNBURDEN)
        score = 100
      else
        score = -32
      end
    #---------------------------------------------------------------------------
    when "03F"
      if user.hasActiveAbility?(:CONTRARY)
        if !user.statStageAtMax?(:SPECIAL_ATTACK)
          statincrease = pbCynthiaGetStatIncrease(:SPECIAL_ATTACK, -2, user)
          userhp = 100.0
          userhp = userhp - opposingThreat if !outspeedsopponent
          damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
          score = [score, userSpecialThreat * statincrease].max() if (userhp / [userSpecialThreat*statincrease, opposingThreat].max.ceil).ceil < damagethreshold
        else
          score = 0
        end
        user.eachOpposing do |opponent|
          score = 0 if opponent.hasActiveAbility?(:UNAWARE)
        end
      elsif user.hasActiveItem?(:WHITEHERB) && user.hasActiveAbility?(:UNBURDEN)
        score = 100
      else
        score = -32
      end
      score = 0 if user.effects[PBEffects::FocusEnergy]>= 2 && user.hasActiveItem?(:SCOPELENS)
    #---------------------------------------------------------------------------
    when "042"
      score = 0
      if target.pbCanLowerStatStage?(:ATTACK,user)
        statincrease = pbCynthiaGetStatIncrease(:ATTACK, -1, target)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = opposingPhysicalThreat * statincrease if damagethreshold < (userhp / [userThreat, opposingPhysicalThreat * statincrease].max.ceil).ceil
      else
        score = 0
      end
      score = 0 if user.hasActiveAbility?(:UNAWARE)
      score = 0 if target.hasActiveAbility?([:CONTRARY, :COMPETITIVE, :DEFIANT])
    #---------------------------------------------------------------------------
    when "043"
      score = 0
      if target.pbCanLowerStatStage?(:DEFENSE,user)
        statincrease = pbCynthiaGetStatIncrease(:DEFENSE, -1, target)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = userPhysicalThreat / statincrease if (userhp / ([userPhysicalThreat / statincrease, opposingThreat]).max.ceil).ceil < damagethreshold
      else
        score = 0
      end
      score = 0 if user.hasActiveAbility?(:UNAWARE)
      score = 0 if target.hasActiveAbility?([:CONTRARY, :COMPETITIVE, :DEFIANT])
    #---------------------------------------------------------------------------
    when "044"
      if target.pbCanLowerStatStage?(:SPEED,user)
        score = 100
        statincrease = pbCynthiaGetStatIncrease(:SPEED, -1, target)
        score = 0 if user.pbSpeed <= target.pbSpeed * statincrease
        score = 0 if target.hasActiveAbility?(:SPEEDBOOST)
      else
        score = 0
      end
      score = 0 if outspeedsopponent
      score = 0 if target.hasActiveAbility?([:CONTRARY, :COMPETITIVE, :DEFIANT])
    #---------------------------------------------------------------------------
    when "045"
      score = 0
      if target.pbCanLowerStatStage?(:SPECIAL_ATTACK,user)
        statincrease = pbCynthiaGetStatIncrease(:SPECIAL_ATTACK, -1, target)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = opposingSpecialThreat * statincrease if damagethreshold < (userhp / [userThreat, opposingSpecialThreat * statincrease].max.ceil).ceil
      else
        score = 0
      end
      score = 0 if user.hasActiveAbility?(:UNAWARE)
      score = 0 if target.hasActiveAbility?([:CONTRARY, :COMPETITIVE, :DEFIANT])
    #---------------------------------------------------------------------------
    when "046"
      score = 0
      if target.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user)
        statincrease = pbCynthiaGetStatIncrease(:SPECIAL_DEFENSE, -1, target)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = userSpecialThreat / statincrease if (userhp / ([userSpecialThreat / statincrease, opposingThreat]).max.ceil).ceil < damagethreshold
      else
        score = 0
      end
      score = 0 if user.hasActiveAbility?(:UNAWARE)
      score = 0 if target.hasActiveAbility?([:CONTRARY, :COMPETITIVE, :DEFIANT])
    #---------------------------------------------------------------------------
    when "047"
      score = 66 - opposingThreat
      score = 0 if !target.pbCanLowerStatStage?(:ACCURACY,user)
    #---------------------------------------------------------------------------
    when "049"
      score *= 2 if target.pbOwnSide.effects[PBEffects::AuroraVeil]>0 ||
                     target.pbOwnSide.effects[PBEffects::Reflect]>0 ||
                     target.pbOwnSide.effects[PBEffects::LightScreen]>0 ||
      score *= 1.5 if user.pbOwnSide.effects[PBEffects::Spikes]>0
      score *= 1.5 if user.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
      score *= 1.5 if user.pbOwnSide.effects[PBEffects::StealthRock]
      score = 0 if !target.pbCanLowerStatStage?(:EVASION,user)
    #---------------------------------------------------------------------------
    when "04A"
      score = 0
      if target.pbCanLowerStatStage?(:ATTACK,user) || target.pbCanLowerStatStage?(:DEFENSE,user)
        atkstatincrease = pbCynthiaGetStatIncrease(:ATTACK, -1, target)
        defstatincrease = pbCynthiaGetStatIncrease(:DEFENSE, -1, target)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = opposingPhysicalThreat * atkstatincrease if damagethreshold < (userhp / [userThreat, opposingPhysicalThreat * atkstatincrease].max.ceil).ceil
        score = userPhysicalThreat / defstatincrease if (userhp / ([userPhysicalThreat / defstatincrease, opposingThreat]).max.ceil).ceil < damagethreshold
      else
        score = 0
      end
      score = 0 if user.hasActiveAbility?(:UNAWARE)
      score = 0 if target.hasActiveAbility?([:CONTRARY, :COMPETITIVE, :DEFIANT])
    #---------------------------------------------------------------------------
    when "04B"
      score = 0
      if target.pbCanLowerStatStage?(:ATTACK,user)
        statincrease = pbCynthiaGetStatIncrease(:ATTACK, -2, target)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = opposingPhysicalThreat * statincrease if damagethreshold < (userhp / [userThreat, opposingPhysicalThreat * statincrease].max.ceil).ceil
      else
        score = 0
      end
      score = 0 if user.hasActiveAbility?(:UNAWARE)
      score = 0 if target.hasActiveAbility?([:CONTRARY, :COMPETITIVE, :DEFIANT])
    #---------------------------------------------------------------------------
    when "04C"
      score = 0
      if target.pbCanLowerStatStage?(:DEFENSE,user)
        statincrease = pbCynthiaGetStatIncrease(:DEFENSE, -2, target)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = userPhysicalThreat / statincrease if (userhp / ([userPhysicalThreat / statincrease, opposingThreat]).max.ceil).ceil < damagethreshold
      else
        score = 0
      end
      score = 0 if user.hasActiveAbility?(:UNAWARE)
      score = 0 if target.hasActiveAbility?([:CONTRARY, :COMPETITIVE, :DEFIANT])
    #---------------------------------------------------------------------------
    when "04D"
      if target.pbCanLowerStatStage?(:SPEED,user)
        score = 100
        statincrease = pbCynthiaGetStatIncrease(:SPEED, -2, target)
        score = 0 if user.pbSpeed <= target.pbSpeed * statincrease
        score = 0 if target.hasActiveAbility?(:SPEEDBOOST)
      else
        score = 0
      end
      score = 0 if outspeedsopponent
      score = 0 if target.hasActiveAbility?([:CONTRARY, :COMPETITIVE, :DEFIANT])
    #---------------------------------------------------------------------------
    when "04E"
      score = 0
      if target.pbCanLowerStatStage?(:SPECIAL_ATTACK,user)
        statincrease = pbCynthiaGetStatIncrease(:SPECIAL_ATTACK, -1, target)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = opposingSpecialThreat * statincrease if damagethreshold < (userhp / [userThreat, opposingSpecialThreat * statincrease].max.ceil).ceil
      else
        score = 0
      end
      score = 0 if user.hasActiveAbility?(:UNAWARE)
      score = 0 if target.hasActiveAbility?([:CONTRARY, :COMPETITIVE, :DEFIANT, :OBLIVIOUS])
      score = 0 if user.gender==2 || target.gender==2 || user.gender==target.gender
    #---------------------------------------------------------------------------
    when "04F"
      score = 0
      if target.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user)
        statincrease = pbCynthiaGetStatIncrease(:SPECIAL_DEFENSE, -2, target)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = userSpecialThreat / statincrease if (userhp / ([userSpecialThreat / statincrease, opposingThreat]).max.ceil).ceil < damagethreshold
      else
        score = 0
      end
      score = 0 if user.hasActiveAbility?(:UNAWARE)
      score = 0 if target.hasActiveAbility?([:CONTRARY, :COMPETITIVE, :DEFIANT])
    #---------------------------------------------------------------------------
    when "050" #todo
      avg = 0; anyChange = false
      GameData::Stat.each_battle do |s|
        next if target.stages[s.id]==0
        avg += target.stages[s.id]
        anyChange = true
      end
      if anyChange
        score += avg*10
      else
        score -= 90
      end
      score = 0 if target.effects[PBEffects::Substitute]>0
    #---------------------------------------------------------------------------
    when "051" #todo
      stages = 0
      @battle.eachBattler do |b|
        totalStages = 0
        GameData::Stat.each_battle { |s| totalStages += b.stages[s.id] }
        if b.opposes?(user)
          stages += totalStages
        else
          stages -= totalStages
        end
      end
      score += stages*10
    #---------------------------------------------------------------------------
    when "052" #todo
      aatk = user.stages[:ATTACK]
      aspa = user.stages[:SPECIAL_ATTACK]
      oatk = target.stages[:ATTACK]
      ospa = target.stages[:SPECIAL_ATTACK]
      if aatk>=oatk && aspa>=ospa
        score -= 80
      else
        score += (oatk-aatk)*10
        score += (ospa-aspa)*10
      end
    #---------------------------------------------------------------------------
    when "053" #todo
      adef = user.stages[:DEFENSE]
      aspd = user.stages[:SPECIAL_DEFENSE]
      odef = target.stages[:DEFENSE]
      ospd = target.stages[:SPECIAL_DEFENSE]
      if adef>=odef && aspd>=ospd
        score -= 80
      else
        score += (odef-adef)*10
        score += (ospd-aspd)*10
      end
    #---------------------------------------------------------------------------
    when "054" #todo
      userStages = 0; targetStages = 0
      GameData::Stat.each_battle do |s|
        userStages   += user.stages[s.id]
        targetStages += target.stages[s.id]
      end
      score = (targetStages-userStages)*10
    #---------------------------------------------------------------------------
    when "055" #todo
      equal = true
      GameData::Stat.each_battle do |s|
        stagediff = target.stages[s.id] - user.stages[s.id]
        score += stagediff*10
        equal = false if stagediff!=0
      end
      score = 0 if equal
    #---------------------------------------------------------------------------
    when "056" #todo
      score = 0 if user.pbOwnSide.effects[PBEffects::Mist]>0
    #---------------------------------------------------------------------------
    when "057" #todo
      aatk = pbRoughStat(user,:ATTACK,skill)
      adef = pbRoughStat(user,:DEFENSE,skill)
      if aatk==adef ||
         user.effects[PBEffects::PowerTrick]   # No flip-flopping
        score -= 90
      elsif adef>aatk   # Prefer a higher Attack
        score += 30
      else
        score -= 30
      end
    #---------------------------------------------------------------------------
    when "058" #todo 
      aatk   = pbRoughStat(user,:ATTACK,skill)
      aspatk = pbRoughStat(user,:SPECIAL_ATTACK,skill)
      oatk   = pbRoughStat(target,:ATTACK,skill)
      ospatk = pbRoughStat(target,:SPECIAL_ATTACK,skill)
      if aatk<oatk && aspatk<ospatk
        score += 50
      elsif aatk+aspatk<oatk+ospatk
        score += 30
      else
        score -= 50
      end
    #---------------------------------------------------------------------------
    when "059" #todo
      adef   = pbRoughStat(user,:DEFENSE,skill)
      aspdef = pbRoughStat(user,:SPECIAL_DEFENSE,skill)
      odef   = pbRoughStat(target,:DEFENSE,skill)
      ospdef = pbRoughStat(target,:SPECIAL_DEFENSE,skill)
      if adef<odef && aspdef<ospdef
        score += 50
      elsif adef+aspdef<odef+ospdef
        score += 30
      else
        score -= 50
      end
    #---------------------------------------------------------------------------
    when "05A" #todo
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif user.hp>=(user.hp+target.hp)/2
        score -= 90
      else
        score += 40
      end
    #---------------------------------------------------------------------------
    when "05B"
      score 100 if @battle.sideSizes[0]>=2 || @battle.sideSizes[1]>=2
      score = 0 if user.pbOwnSide.effects[PBEffects::Tailwind]>0
    #---------------------------------------------------------------------------
    when "05C" #todo
      moveBlacklist = [
         "002",   # Struggle
         "014",   # Chatter
         "05C",   # Mimic
         "05D",   # Sketch
         "0B6"    # Metronome
      ]
      if user.effects[PBEffects::Transform] || !target.lastRegularMoveUsed
        score -= 90
      else
        lastMoveData = GameData::Move.get(target.lastRegularMoveUsed)
        if moveBlacklist.include?(lastMoveData.function_code) ||
           lastMoveData.type == :SHADOW
          score -= 90
        end
        user.eachMove do |m|
          next if m != target.lastRegularMoveUsed
          score -= 90
          break
        end
      end
      score = 0
    #---------------------------------------------------------------------------
    when "05D" #todo
      moveBlacklist = [
         "002",   # Struggle
         "014",   # Chatter
         "05D"    # Sketch
      ]
      if user.effects[PBEffects::Transform] || !target.lastRegularMoveUsed
        score -= 90
      else
        lastMoveData = GameData::Move.get(target.lastRegularMoveUsed)
        if moveBlacklist.include?(lastMoveData.function_code) ||
           lastMoveData.type == :SHADOW
          score -= 90
        end
        user.eachMove do |m|
          next if m != target.lastRegularMoveUsed
          score -= 90   # User already knows the move that will be Sketched
          break
        end
      end
      score = 0
    #---------------------------------------------------------------------------
    when "05E" #todo
      if !user.canChangeType?
        score -= 90
      else
        has_possible_type = false
        user.eachMoveWithIndex do |m,i|
          break if i>0
          next if GameData::Type.get(m.type).pseudo_type
          next if user.pbHasType?(m.type)
          has_possible_type = true
          break
        end
        score -= 90 if !has_possible_type
      end
    #---------------------------------------------------------------------------
    when "05F" #todo
      if !user.canChangeType?
        score -= 90
      elsif !target.lastMoveUsed || !target.lastMoveUsedType ||
         GameData::Type.get(target.lastMoveUsedType).pseudo_type
        score -= 90
      else
        aType = nil
        target.eachMove do |m|
          next if m.id!=target.lastMoveUsed
          aType = m.pbCalcType(user)
          break
        end
        if !aType
          score -= 90
        else
          has_possible_type = false
          GameData::Type.each do |t|
            next if t.pseudo_type || user.pbHasType?(t.id) ||
                    !Effectiveness.resistant_type?(target.lastMoveUsedType, t.id)
            has_possible_type = true
            break
          end
          score -= 90 if !has_possible_type
        end
      end
    #---------------------------------------------------------------------------
    when "060" #todo
      if !user.canChangeType?
        score -= 90
      elsif skill>=PBTrainerAI.mediumSkill
        new_type = nil
        case @battle.field.terrain
        when :Electric
          new_type = :ELECTRIC if GameData::Type.exists?(:ELECTRIC)
        when :Grassy
          new_type = :GRASS if GameData::Type.exists?(:GRASS)
        when :Misty
          new_type = :FAIRY if GameData::Type.exists?(:FAIRY)
        when :Psychic
          new_type = :PSYCHIC if GameData::Type.exists?(:PSYCHIC)
        end
        if !new_type
          envtypes = {
             :None        => :NORMAL,
             :Grass       => :GRASS,
             :TallGrass   => :GRASS,
             :MovingWater => :WATER,
             :StillWater  => :WATER,
             :Puddle      => :WATER,
             :Underwater  => :WATER,
             :Cave        => :ROCK,
             :Rock        => :GROUND,
             :Sand        => :GROUND,
             :Forest      => :BUG,
             :ForestGrass => :BUG,
             :Snow        => :ICE,
             :Ice         => :ICE,
             :Volcano     => :FIRE,
             :Graveyard   => :GHOST,
             :Sky         => :FLYING,
             :Space       => :DRAGON,
             :UltraSpace  => :PSYCHIC
          }
          new_type = envtypes[@battle.environment]
          new_type = nil if !GameData::Type.exists?(new_type)
          new_type ||= :NORMAL
        end
        score -= 90 if !user.pbHasOtherType?(new_type)
      end
    #---------------------------------------------------------------------------
    when "061" #todo
      if target.effects[PBEffects::Substitute]>0 || !target.canChangeType?
        score -= 90
      elsif !target.pbHasOtherType?(:WATER)
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "062" #todo
      if !user.canChangeType? || target.pbTypes(true).length == 0
        score -= 90
      elsif user.pbTypes == target.pbTypes &&
         user.effects[PBEffects::Type3] == target.effects[PBEffects::Type3]
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "063" #todo
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      end
      if target.unstoppableAbility? || [:TRUANT, :SIMPLE].include?(target.ability)
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "064" #todo
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      end
      if target.unstoppableAbility? || [:TRUANT, :INSOMNIA].include?(target.ability_id)
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "065" #todo
      score -= 40   # don't prefer this move
      if !target.ability || user.ability==target.ability ||
         [:MULTITYPE, :RKSSYSTEM].include?(user.ability_id) ||
         [:FLOWERGIFT, :FORECAST, :ILLUSION, :IMPOSTER, :MULTITYPE, :RKSSYSTEM,
          :TRACE, :WONDERGUARD, :ZENMODE].include?(target.ability_id)
        score -= 90
      end
      if target.ability == :TRUANT && user.opposes?(target)
        score -= 90
      elsif target.ability == :SLOWSTART && user.opposes?(target)
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "066" #todo
      score -= 40   # don't prefer this move
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      end
      if !user.ability || user.ability==target.ability ||
        [:MULTITYPE, :RKSSYSTEM, :TRUANT].include?(target.ability_id) ||
        [:FLOWERGIFT, :FORECAST, :ILLUSION, :IMPOSTER, :MULTITYPE, :RKSSYSTEM,
         :TRACE, :ZENMODE].include?(user.ability_id)
        score -= 90
      end
      if user.ability == :TRUANT && user.opposes?(target)
        score += 90
      elsif user.ability == :SLOWSTART && user.opposes?(target)
        score += 90
      end
    #---------------------------------------------------------------------------
    when "067" #todo
      score -= 40   # don't prefer this move
      if (!user.ability && !target.ability) ||
         user.ability==target.ability ||
         [:ILLUSION, :MULTITYPE, :RKSSYSTEM, :WONDERGUARD].include?(user.ability_id) ||
         [:ILLUSION, :MULTITYPE, :RKSSYSTEM, :WONDERGUARD].include?(target.ability_id)
        score -= 90
      end
      if target.ability == :TRUANT && user.opposes?(target)
        score -= 90
      elsif target.ability == :SLOWSTART && user.opposes?(target)
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "068" #todo
      if target.effects[PBEffects::Substitute]>0 ||
         target.effects[PBEffects::GastroAcid]
        score -= 90
      end
      score -= 90 if [:MULTITYPE, :RKSSYSTEM, :SLOWSTART, :TRUANT].include?(target.ability_id)
    #---------------------------------------------------------------------------
    when "069" #todo
      score -= 70
    #---------------------------------------------------------------------------
    when "070" #todo
      score -= 90 if target.hasActiveAbility?(:STURDY)
      score -= 90 if target.level>user.level
    #---------------------------------------------------------------------------
    when "071" #todo
      if target.effects[PBEffects::HyperBeam]>0
        score -= 90
      else
        attack = pbRoughStat(user,:ATTACK,skill)
        spatk  = pbRoughStat(user,:SPECIAL_ATTACK,skill)
        if attack*1.5<spatk
          score -= 60
        elsif target.lastMoveUsed
          moveData = GameData::Move.get(target.lastMoveUsed)
          score += 60 if moveData.physical?
        end
      end
      score = 10
    #---------------------------------------------------------------------------
    when "072" #todo
      if target.effects[PBEffects::HyperBeam]>0
        score -= 90
      else
        attack = pbRoughStat(user,:ATTACK,skill)
        spatk  = pbRoughStat(user,:SPECIAL_ATTACK,skill)
        if attack>spatk*1.5
          score -= 60
        elsif target.lastMoveUsed
          moveData = GameData::Move.get(target.lastMoveUsed)
          score += 60 if moveData.special?
        end
      end
      score = 10
    #---------------------------------------------------------------------------
    when "073" #todo
      score -= 90 if target.effects[PBEffects::HyperBeam]>0
    #---------------------------------------------------------------------------
    when "074" #todo
      target.eachAlly do |b|
        next if !b.near?(target)
        score += 10
      end
    #---------------------------------------------------------------------------
    when "078"
      #todo flinch
    #---------------------------------------------------------------------------
    when "07C" #todo
      score -= 20 if target.status == :PARALYSIS   # Will cure status
    #---------------------------------------------------------------------------
    when "07D" #todo
      score -= 20 if target.status == :SLEEP &&   # Will cure status
                     target.statusCount > 1
    #---------------------------------------------------------------------------
    when "081" #todo
      attspeed = pbRoughStat(user,:SPEED,skill)
      oppspeed = pbRoughStat(target,:SPEED,skill)
      score += 30 if oppspeed>attspeed
    #---------------------------------------------------------------------------
    when "082" #todo
      score += 20 if @battle.pbOpposingBattlerCount(user)>1
    #---------------------------------------------------------------------------
    when "083" #todo
      user.eachAlly do |b|
        next if !b.pbHasMove?(move.id)
        score += 20
      end
    #---------------------------------------------------------------------------
    when "084" #todo
      attspeed = pbRoughStat(user,:SPEED,skill)
      oppspeed = pbRoughStat(target,:SPEED,skill)
      score += 30 if oppspeed>attspeed
    #---------------------------------------------------------------------------
    when "093" #todo
      score += 25 if user.effects[PBEffects::Rage]
    #---------------------------------------------------------------------------
    when "09C"
      hasAlly = false
      user.eachAlly do |b|
        hasAlly = true
        score += 30
        break
      end
      score -= 90 if !hasAlly
    #---------------------------------------------------------------------------
    when "09D" #todo
      score = 0 if user.effects[PBEffects::MudSport]
    #---------------------------------------------------------------------------
    when "09E" #todo
      score = 0 if user.effects[PBEffects::WaterSport]
    #---------------------------------------------------------------------------
    when "0A1"
      score = 0 if user.pbOwnSide.effects[PBEffects::LuckyChant]>0
    #---------------------------------------------------------------------------
    when "0A2", "190" #TODO
      score *= 2 if user.hasActiveItem?(:LIGHTCLAY)
      score = 0 if user.pbOwnSide.effects[PBEffects::Reflect]>0
    #---------------------------------------------------------------------------
    when "0A3", "189" #TODO
      score *= 2 if user.hasActiveItem?(:LIGHTCLAY)
      score = 0 if user.pbOwnSide.effects[PBEffects::LightScreen]>0
    #---------------------------------------------------------------------------
    when "0A6" #todo
      score -= 90 if target.effects[PBEffects::Substitute]>0
      score -= 90 if user.effects[PBEffects::LockOn]>0
    #---------------------------------------------------------------------------
    when "0A7" #todo
      if target.effects[PBEffects::Foresight]
        score -= 90
      elsif target.pbHasType?(:GHOST)
        score += 70
      elsif target.stages[:EVASION]<=0
        score -= 60
      end
    #---------------------------------------------------------------------------
    when "0A8" #todo
      if target.effects[PBEffects::MiracleEye]
        score -= 90
      elsif target.pbHasType?(:DARK)
        score += 70
      elsif target.stages[:EVASION]<=0
        score -= 60
      end
    #---------------------------------------------------------------------------
    when "0AA" #todo
      if user.effects[PBEffects::ProtectRate]>1 ||
         target.effects[PBEffects::HyperBeam]>0
        score -= 90
      else
        score -= user.effects[PBEffects::ProtectRate]*40
        score += 30 if target.effects[PBEffects::TwoTurnAttack]
      end
    #---------------------------------------------------------------------------
    when "0AB" #todo
    #---------------------------------------------------------------------------
    when "0AC" #todo
    #---------------------------------------------------------------------------
    when "0AD" #todo
    #---------------------------------------------------------------------------
    when "0AE" #todo
      score -= 40
      score -= 100 if !target.lastRegularMoveUsed ||
         !GameData::Move.get(target.lastRegularMoveUsed).flags[/e/]   # Not copyable by Mirror Move
    #---------------------------------------------------------------------------
    when "0AF"
      blacklist = ["002", "014", "158", "05C", "05D", "069", "071", "072", "073", "09C", "0AD", "0AA", "0AB", "0AC", "0E8", "149", "14A", "14B", "14C", "168", "0AE", "0AF", "0B0", "0B3", "0B4", "0B5", "0B6", "0B1", "0B2", "117", "16A", "0E6", "0E7", "0F1", "0F2", "0F3", "115", "171", "172", "133", "134"]
      if outspeedsopponent
        moveID = @battle.lastMoveUsed
        calledmove = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(moveID))
        if @battle.lastMoveUsed && !blacklist.include?(calledmove.function)
          score = pbCynthiaRegisterMove(user, calledmove, nil, true)
        end
      else
        score = 0
      end
    #---------------------------------------------------------------------------
    when "0B0" #todo
    #---------------------------------------------------------------------------
    when "0B1" #todo
    #---------------------------------------------------------------------------
    when "0B2" #todo
    #---------------------------------------------------------------------------
    when "0B3" #todo?
    #---------------------------------------------------------------------------
    when "0B4" #todo
      if user.asleep?
        score += 100   # Because it can only be used while asleep
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "0B5" #todo
    #---------------------------------------------------------------------------
    when "0B6" #todo
    #---------------------------------------------------------------------------
    when "0B7" #todo
      score -= 90 if target.effects[PBEffects::Torment]
    #---------------------------------------------------------------------------
    when "0B8" #todo
      score -= 90 if user.effects[PBEffects::Imprison]
    #---------------------------------------------------------------------------
    when "0B9" #todo
      score -= 90 if target.effects[PBEffects::Disable]>0
    #---------------------------------------------------------------------------
    when "0BA" #todo
      score -= 90 if target.effects[PBEffects::Taunt]>0
    #---------------------------------------------------------------------------
    when "0BB", "186" #todo
      score -= 90 if target.effects[PBEffects::HealBlock]>0
    #---------------------------------------------------------------------------
    when "0BC" #todo
      aspeed = pbRoughStat(user,:SPEED,skill)
      ospeed = pbRoughStat(target,:SPEED,skill)
      if target.effects[PBEffects::Encore]>0
        score -= 90
      elsif aspeed>ospeed
        if !target.lastRegularMoveUsed
          score -= 90
        else
          moveData = GameData::Move.get(target.lastRegularMoveUsed)
          if moveData.category == 2 &&   # Status move
             [:User, :BothSides].include?(moveData.target)
            score += 60
          elsif moveData.category != 2 &&   # Damaging move
             moveData.target == :NearOther &&
             Effectiveness.ineffective?(pbCalcTypeMod(moveData.type, target, user))
            score += 60
          end
        end
      end
    #---------------------------------------------------------------------------
    when "0C2" #todo?
    #---------------------------------------------------------------------------
    when "0C3" #todo?
    #---------------------------------------------------------------------------
    when "0C4" #todo?
    #---------------------------------------------------------------------------
    when "0C7" #todo?
      score += 20 if !target.hasActiveAbility?(:INNERFOCUS) &&
                     target.effects[PBEffects::Substitute]==0
    #---------------------------------------------------------------------------
    when "0C9" #todo?
    #---------------------------------------------------------------------------
    when "0CA" #todo?
    #---------------------------------------------------------------------------
    when "0CB" #todo?
    #---------------------------------------------------------------------------
    when "0CC" #todo?
    #---------------------------------------------------------------------------
    when "0CD" #todo!
    #---------------------------------------------------------------------------
    when "0CE" #todo?
    #---------------------------------------------------------------------------
    when "0CF" #todo
      score += 40 if target.effects[PBEffects::Trapping]==0
    #---------------------------------------------------------------------------
    when "0D0" #todo
      score += 40 if target.effects[PBEffects::Trapping]==0
    #---------------------------------------------------------------------------
    when "0D1" #todo
    #---------------------------------------------------------------------------
    when "0D2" #todo
    #---------------------------------------------------------------------------
    when "0D3" #todo
    #---------------------------------------------------------------------------
    when "0D4" #todo
      if user.hp<=user.totalhp/4
        score -= 90
      elsif user.hp<=user.totalhp/2
        score -= 50
      end
    #---------------------------------------------------------------------------
    when "0D5", "0D6" #todo
      score *= 2 if opposingThreat < 66 && opposingThreat > 33 && user.hp <= user.totalhp * 3 / 4 && !outspeedsopponent
      score *= 2 if opposingThreat < 100 && user.hp <= user.totalhp / 2
      score *= 2 if opposingThreat < 100 && user.hp <= user.totalhp / 4
      score = 0 if !user.canHeal?
      score = 0 if user.hp >= user.totalhp * 3 / 4
    #---------------------------------------------------------------------------
    when "0D7" #todo
      score -= 90 if @battle.positions[user.index].effects[PBEffects::Wish]>0
    #---------------------------------------------------------------------------
    when "0D8" #todo
      score *= 2 if opposingThreat < 66 && opposingThreat > 33 && user.hp <= user.totalhp * 3 / 4 && !outspeedsopponent
      score *= 2 if opposingThreat < 100 && user.hp <= user.totalhp / 2
      score *= 2 if opposingThreat < 100 && user.hp <= user.totalhp / 4
      score = 0 if !user.canHeal?
      score = 0 if user.hp >= user.totalhp * 3 / 4
    #---------------------------------------------------------------------------
    when "0D9" #todo
      if user.hp==user.totalhp || !user.pbCanSleep?(user,false,nil,true)
        score -= 90
      else
        score += 70
        score -= user.hp*140/user.totalhp
        score += 30 if user.status != :NONE
      end
    #---------------------------------------------------------------------------
    when "0DA" #todo
      score -= 90 if user.effects[PBEffects::AquaRing]
    #---------------------------------------------------------------------------
    when "0DB" #todo
      score -= 90 if user.effects[PBEffects::Ingrain]
    #---------------------------------------------------------------------------
    when "0DC", "184" #todo
      if target.effects[PBEffects::LeechSeed]>=0
        score -= 90
      elsif skill>=PBTrainerAI.mediumSkill && target.pbHasType?(:GRASS)
        score -= 90
      else
        score += 60 if user.turnCount==0
      end
    #---------------------------------------------------------------------------
    when "0DD" #todo
      if target.hasActiveAbility?(:LIQUIDOOZE)
        score -= 70
      else
        score += 20 if user.hp<=user.totalhp/2
      end
    #---------------------------------------------------------------------------
    when "0DE" #todo
      if !target.asleep?
        score -= 100
      elsif target.hasActiveAbility?(:LIQUIDOOZE)
        score -= 70
      else
        score += 20 if user.hp<=user.totalhp/2
      end
    #---------------------------------------------------------------------------
    when "0DF" #todo
      if user.opposes?(target)
        score -= 100
      else
        score += 20 if target.hp<target.totalhp/2 &&
                       target.effects[PBEffects::Substitute]==0
      end
    #---------------------------------------------------------------------------
    when "0E0" #todo
      score = 100
      score = 0 if (opposingThreat < 100 && outspeedsopponent) || (opposingThreat < 50 && !outspeedsopponent)
    #---------------------------------------------------------------------------
    when "0E1" #todo
    #---------------------------------------------------------------------------
    when "0E2" #todo
      score = 100
      score = 0 if (opposingThreat < 100 && outspeedsopponent) || (opposingThreat < 50 && !outspeedsopponent)
    #---------------------------------------------------------------------------
    when "0E3", "0E4"
      score = 100
      score = 0 if (opposingThreat < 100 && outspeedsopponent) || (opposingThreat < 50 && !outspeedsopponent)
    #---------------------------------------------------------------------------
    when "0E5" #todo
      if @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
        score -= 90
      else
        score -= 90 if target.effects[PBEffects::PerishSong]>0
      end
    #---------------------------------------------------------------------------
    when "0E6" #todo
      score += 50
      score -= user.hp*100/user.totalhp
      score += 30 if user.hp<=user.totalhp/10
    #---------------------------------------------------------------------------
    when "0E7" #todo
      score = 100
      score = 0 if (opposingThreat < 100 && outspeedsopponent) || (opposingThreat < 50 && !outspeedsopponent)
    #---------------------------------------------------------------------------
    when "0E8" #todo
      score -= 25 if user.hp>user.totalhp/2
      if skill>=PBTrainerAI.mediumSkill
        score -= 90 if user.effects[PBEffects::ProtectRate]>1
        score -= 90 if target.effects[PBEffects::HyperBeam]>0
      else
        score -= user.effects[PBEffects::ProtectRate]*40
      end
    #---------------------------------------------------------------------------
    when "0E9" #todo
      if target.hp==1
        score -= 90
      elsif target.hp<=target.totalhp/8
        score -= 60
      elsif target.hp<=target.totalhp/4
        score -= 30
      end
    #---------------------------------------------------------------------------
    when "0EA" #todo
    #---------------------------------------------------------------------------
    when "0EB" #todo
      if target.effects[PBEffects::Ingrain] ||
         (skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:SUCTIONCUPS))
        score -= 90
      else
        ch = 0
        @battle.pbParty(target.index).each_with_index do |pkmn,i|
          ch += 1 if @battle.pbCanSwitchLax?(target.index,i)
        end
        score -= 90 if ch==0
      end
      if score>20
        score += 50 if target.pbOwnSide.effects[PBEffects::Spikes]>0
        score += 50 if target.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
        score += 50 if target.pbOwnSide.effects[PBEffects::StealthRock]
      end
    #---------------------------------------------------------------------------
    when "0EC" #todo
      if !target.effects[PBEffects::Ingrain] &&
         !(skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:SUCTIONCUPS))
        score += 40 if target.pbOwnSide.effects[PBEffects::Spikes]>0
        score += 40 if target.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
        score += 40 if target.pbOwnSide.effects[PBEffects::StealthRock]
      end
    #---------------------------------------------------------------------------
    when "0ED" #todo
      if !@battle.pbCanChooseNonActive?(user.index)
        score -= 80
      else
        score -= 40 if user.effects[PBEffects::Confusion]>0
        total = 0
        GameData::Stat.each_battle { |s| total += user.stages[s.id] }
        if total<=0 || user.turnCount==0
          score -= 60
        else
          score += total*10
          # special case: user has no damaging moves
          hasDamagingMove = false
          user.eachMove do |m|
            next if !m.damagingMove?
            hasDamagingMove = true
            break
          end
          score += 75 if !hasDamagingMove
        end
      end
    #---------------------------------------------------------------------------
    when "0EF" #todo
      score -= 90 if target.effects[PBEffects::MeanLook]>=0
    #---------------------------------------------------------------------------
    when "0F0" #todo
      score += 20 if target.item
    #---------------------------------------------------------------------------
    when "0F1" #todo
      if !user.item && target.item
        score += 40
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "0F2" #todo
      if !user.item && !target.item
        score -= 90
      elsif target.hasActiveAbility?(:STICKYHOLD)
        score -= 90
      elsif user.hasActiveItem?([:FLAMEORB,:TOXICORB,:STICKYBARB,:IRONBALL,
                                 :CHOICEBAND,:CHOICESCARF,:CHOICESPECS])
        score += 50
      elsif !user.item && target.item
        score -= 30 if user.lastMoveUsed &&
                       GameData::Move.get(user.lastMoveUsed).function_code == "0F2"   # Trick/Switcheroo
      end
    #---------------------------------------------------------------------------
    when "0F3" #todo
      if !user.item || target.item
        score -= 90
      else
        if user.hasActiveItem?([:FLAMEORB,:TOXICORB,:STICKYBARB,:IRONBALL,
                                :CHOICEBAND,:CHOICESCARF,:CHOICESPECS])
          score += 50
        else
          score -= 80
        end
      end
    #---------------------------------------------------------------------------
    when "0F4", "0F5" #todo
      if target.effects[PBEffects::Substitute]==0
        if skill>=PBTrainerAI.highSkill && target.item && target.item.is_berry?
          score += 30
        end
      end
    #---------------------------------------------------------------------------
    when "0F6" #todo
      if !user.recycleItem || user.item
        score -= 80
      elsif user.recycleItem
        score += 30
      end
    #---------------------------------------------------------------------------
    when "0F7" #todo
      if !user.item || !user.itemActive? ||
         user.unlosableItem?(user.item) || user.item.is_poke_ball?
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "0F8" #todo
      score -= 90 if target.effects[PBEffects::Embargo]>0
    #---------------------------------------------------------------------------
    when "0F9" #todo
      if @battle.field.effects[PBEffects::MagicRoom]>0
        score -= 90
      else
        score += 30 if !user.item && target.item
      end
    #---------------------------------------------------------------------------
    when "0FA" #todo
      score -= 25
    #---------------------------------------------------------------------------
    when "0FB" #todo
      score -= 30
    #---------------------------------------------------------------------------
    when "0FC" #todo
      score -= 40
    #---------------------------------------------------------------------------
    when "0FD" #todo
      score -= 30
      if target.pbCanParalyze?(user,false)
        score += 30
        aspeed = pbRoughStat(user,:SPEED,skill)
        ospeed = pbRoughStat(target,:SPEED,skill)
        if aspeed<ospeed
          score += 30
        elsif aspeed>ospeed
          score -= 40
        end
        score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET])
      end
    #---------------------------------------------------------------------------
    when "0FE" #todo
      score -= 30
      if target.pbCanBurn?(user,false)
        score += 30
        score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET,:FLAREBOOST])
      end
    #---------------------------------------------------------------------------
    when "0FF" #todo
      score *= 2 if user.hasActiveItem?(:HEATROCK)
      score *= 2 if user.hasActiveAbility?([:CHLOROPHYLL, :HARVEST, :FLOWERGIFT, :FORECAST, :LEAFGUARD, :SOLARPOWER, :PROTOSYNTHESIS, :ORICHALCUMPULSE])
      score *= 1.5 if user.pbHasType?(:FIRE)
      score *= 2 if user.pbHasMove?(:SOLARBEAM) || user.pbHasMove?(:SOLARBLADE) || user.pbHasMove?(:GROWTH) || user.pbHasMove?(:WEATHERBALL) || user.pbHasMove?(:MOONLIGHT) || user.pbHasMove?(:SYNTHESIS) || user.pbHasMove?(:MORNINGSUN)
      score *= 2 if @battle.pbWeather == :Rain
      user.eachOpposing do |opponent|
        score *= 2 if opponent.pbHasType?(:WATER) && outspeedsopponent
      end
      score = 0 if @battle.pbCheckGlobalAbility(:AIRLOCK) || @battle.pbCheckGlobalAbility(:CLOUDNINE) || @battle.pbWeather == :Sun
    #---------------------------------------------------------------------------
    when "100" #todo
      score *= 2 if user.hasActiveItem?(:DAMPROCK)
      score *= 2 if user.hasActiveAbility?([:SWIFTSWIM, :DRYSKIN, :FORECAST, :HYDRATION, :RAINDISH])
      score *= 1.5 if user.pbHasType?(:WATER)
      score *= 2 if user.pbHasMove?(:THUNDER) || user.pbHasMove?(:HURRICANE) || user.pbHasMove?(:BLEAKWINDSTORM) || user.pbHasMove?(:WILDBOLTSTORM) || user.pbHasMove?(:SANDSEARSTORM) || user.pbHasMove?(:WEATHERBALL) || user.pbHasMove?(:ELECTROSHOT)
      score *= 2 if @battle.pbWeather == :Sun
      score = 0 if @battle.pbCheckGlobalAbility(:AIRLOCK) || @battle.pbCheckGlobalAbility(:CLOUDNINE) || @battle.pbWeather == :Rain
    #---------------------------------------------------------------------------
    when "101" #todo
      score *= 2 if user.hasActiveItem?(:SMOOTHROCK)
      score *= 2 if user.hasActiveAbility?([:SANDRUSH, :SANDFORCE, :SANDVEIL])
      score *= 1.5 if user.pbHasType?(:ROCK)
      score *= 2 if user.pbHasMove?(:WEATHERBALL) || user.pbHasMove?(:SHOREUP)
      score = 0 if @battle.pbCheckGlobalAbility(:AIRLOCK) || @battle.pbCheckGlobalAbility(:CLOUDNINE) || @battle.pbWeather == :Sandstorm
    #---------------------------------------------------------------------------
    when "102", "179"
      score *= 2 if user.hasActiveItem?(:ICYROCK)
      score *= 2 if user.hasActiveAbility?([:SLUSHRUSH, :ICEBODY, :SNOWCLOAK, :FORECAST, :ICEFACE])
      score *= 1.5 if user.pbHasType?(:ICE)
      score *= 2 if user.pbHasMove?(:WEATHERBALL) || user.pbHasMove?(:BLIZZARD) || user.pbHasMove?(:AURORAVEIL)
      score = 0 if @battle.pbCheckGlobalAbility(:AIRLOCK) || @battle.pbCheckGlobalAbility(:CLOUDNINE) || @battle.pbWeather == :Hail || @battle.pbWeather == :Snow
    #---------------------------------------------------------------------------
    when "103" #todo
      if user.pbOpposingSide.effects[PBEffects::Spikes]>=3
        score -= 90
      else
        canChoose = false
        user.eachOpposing do |b|
          next if !@battle.pbCanChooseNonActive?(b.index)
          canChoose = true
          break
        end
        if !canChoose
          # Opponent can't switch in any Pokemon
        score -= 90
        else
          score += 10*@battle.pbAbleNonActiveCount(user.idxOpposingSide)
          score += [40,26,13][user.pbOpposingSide.effects[PBEffects::Spikes]]
        end
      end
    #---------------------------------------------------------------------------
    when "104" #todo
      if user.pbOpposingSide.effects[PBEffects::ToxicSpikes]>=2
        score -= 90
      else
        canChoose = false
        user.eachOpposing do |b|
          next if !@battle.pbCanChooseNonActive?(b.index)
          canChoose = true
          break
        end
        if !canChoose
          # Opponent can't switch in any Pokemon
          score -= 90
        else
          score += 8*@battle.pbAbleNonActiveCount(user.idxOpposingSide)
          score += [26,13][user.pbOpposingSide.effects[PBEffects::ToxicSpikes]]
        end
      end
    #---------------------------------------------------------------------------
    when "105" #todo
      if user.pbOpposingSide.effects[PBEffects::StealthRock]
        score -= 90
      else
        canChoose = false
        user.eachOpposing do |b|
          next if !@battle.pbCanChooseNonActive?(b.index)
          canChoose = true
          break
        end
        if !canChoose
          # Opponent can't switch in any Pokemon
          score -= 90
        else
          score += 10*@battle.pbAbleNonActiveCount(user.idxOpposingSide)
        end
      end
    #---------------------------------------------------------------------------
    when "10A" #todo
      score += 20 if user.pbOpposingSide.effects[PBEffects::AuroraVeil]>0
      score += 20 if user.pbOpposingSide.effects[PBEffects::Reflect]>0
      score += 20 if user.pbOpposingSide.effects[PBEffects::LightScreen]>0
    #---------------------------------------------------------------------------
    when "10B" #todo
      score += 10*(user.stages[:ACCURACY]-target.stages[:EVASION])
    #---------------------------------------------------------------------------
    when "10C" #todo
      score = 100 if opposingThreat < 25
      score = 0 if opposingThreat >= 25
    #---------------------------------------------------------------------------
    when "10D" #todo
      if user.pbHasType?(:GHOST)
        if target.effects[PBEffects::Curse]
          score -= 90
        elsif user.hp<=user.totalhp/2
          if @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
            score -= 90
          else
            score -= 50
            score -= 30 if @battle.switchStyle
          end
        end
      else
        if !user.statStageAtMax?(:DEFENSE) || !user.statStageAtMax?(:ATTACK)
          defstatincrease = pbCynthiaGetStatIncrease(:DEFENSE, 1, user)
          atkstatincrease = pbCynthiaGetStatIncrease(:ATTACK, 1, user)
          userhp = 100.0
          userhp = userhp - opposingThreat if !outspeedsopponent
          damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
          score = [score, opposingPhysicalThreat * defstatincrease].max() if damagethreshold < (userhp / ([userThreat, opposingPhysicalThreat / defstatincrease].max.ceil)).ceil
          score = [score, userPhysicalThreat * atkstatincrease].max() if (userhp / [userPhysicalThreat*atkstatincrease, opposingThreat].max.ceil).ceil < damagethreshold
        else
          score = 0
        end
        user.eachOpposing do |opponent|
          score = 0 if opponent.hasActiveAbility?(:UNAWARE)
        end
        score = 0 if outspeedsopponent && opposingThreat > 32
      end
    #---------------------------------------------------------------------------
    when "10E" #todo
      score -= 40
    #---------------------------------------------------------------------------
    when "10F" #todo
      if target.effects[PBEffects::Nightmare] ||
         target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif !target.asleep?
        score -= 90
      else
        score -= 90 if target.statusCount<=1
        score += 50 if target.statusCount>3
      end
    #---------------------------------------------------------------------------
    when "110" #todo
      score += 30 if user.effects[PBEffects::Trapping]>0
      score += 30 if user.effects[PBEffects::LeechSeed]>=0
      if @battle.pbAbleNonActiveCount(user.idxOwnSide)>0
        score += 80 if user.pbOwnSide.effects[PBEffects::Spikes]>0
        score += 80 if user.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
        score += 80 if user.pbOwnSide.effects[PBEffects::StealthRock]
      end
    #---------------------------------------------------------------------------
    when "111" #todo
      if @battle.positions[target.index].effects[PBEffects::FutureSightCounter]>0
        score -= 100
      elsif @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
        # Future Sight tends to be wasteful if down to last Pokemon
        score -= 70
      end
    #---------------------------------------------------------------------------
    when "112"
      if !user.statStageAtMax?(:DEFENSE) || !user.statStageAtMax?(:SPECIAL_DEFENSE) || !(user.effects[PBEffects::Stockpile]>=3)
        statincrease = [pbCynthiaGetStatIncrease(:DEFENSE, 1, user), pbCynthiaGetStatIncrease(:SPECIAL_DEFENSE, 1, user)].max
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = [score, opposingThreat * statincrease].max() if damagethreshold < (userhp / ([userThreat, opposingThreat / statincrease].max.ceil)).ceil
      else
        score = 0
      end
      user.eachOpposing do |opponent|
        score = 0 if opponent.hasActiveAbility?(:UNAWARE)
      end
    #---------------------------------------------------------------------------
    when "113" #todo
      score -= 100 if user.effects[PBEffects::Stockpile]==0
    #---------------------------------------------------------------------------
    when "114" #todo
      if user.effects[PBEffects::Stockpile]==0
        score -= 90
      elsif user.hp==user.totalhp
        score -= 90
      else
        mult = [0,25,50,100][user.effects[PBEffects::Stockpile]]
        score += mult
        score -= user.hp*mult*2/user.totalhp
      end
    #---------------------------------------------------------------------------
    when "115" #todo
      score += 50 if target.effects[PBEffects::HyperBeam]>0
      score -= 35 if target.hp<=target.totalhp/2   # If target is weak, no
      score -= 70 if target.hp<=target.totalhp/4   # need to risk this move
    #---------------------------------------------------------------------------
    when "116" #todo?
    #---------------------------------------------------------------------------
    when "117" #todo
      hasAlly = false
      user.eachAlly do |b|
        hasAlly = true
        break
      end
      score -= 90 if !hasAlly
    #---------------------------------------------------------------------------
    when "118" #todo
      if @battle.field.effects[PBEffects::Gravity]>0
        score -= 90
      end
      score -= 30
      score -= 20 if user.effects[PBEffects::SkyDrop]>=0
      score -= 20 if user.effects[PBEffects::MagnetRise]>0
      score -= 20 if user.effects[PBEffects::Telekinesis]>0
      score -= 20 if user.pbHasType?(:FLYING)
      score -= 20 if user.hasActiveAbility?(:LEVITATE)
      score -= 20 if user.hasActiveItem?(:AIRBALLOON)
      score += 20 if target.effects[PBEffects::SkyDrop]>=0
      score += 20 if target.effects[PBEffects::MagnetRise]>0
      score += 20 if target.effects[PBEffects::Telekinesis]>0
      score += 20 if target.inTwoTurnAttack?("0C9","0CC","0CE")   # Fly, Bounce, Sky Drop
      score += 20 if target.pbHasType?(:FLYING)
      score += 20 if target.hasActiveAbility?(:LEVITATE)
      score += 20 if target.hasActiveItem?(:AIRBALLOON)
    #---------------------------------------------------------------------------
    when "119" #todo
      if user.effects[PBEffects::MagnetRise]>0 ||
         user.effects[PBEffects::Ingrain] ||
         user.effects[PBEffects::SmackDown]
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "11A" #todo
      if target.effects[PBEffects::Telekinesis]>0 ||
         target.effects[PBEffects::Ingrain] ||
         target.effects[PBEffects::SmackDown]
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "11B" #todo
    #---------------------------------------------------------------------------
    when "11C" #todo
      score += 20 if target.effects[PBEffects::MagnetRise]>0
      score += 20 if target.effects[PBEffects::Telekinesis]>0
      score += 20 if target.inTwoTurnAttack?("0C9","0CC")   # Fly, Bounce
      score += 20 if target.pbHasType?(:FLYING)
      score += 20 if target.hasActiveAbility?(:LEVITATE)
      score += 20 if target.hasActiveItem?(:AIRBALLOON)
    #---------------------------------------------------------------------------
    when "11D" #todo
    #---------------------------------------------------------------------------
    when "11E" #todo
    #---------------------------------------------------------------------------
    when "11F" #todo
      score = 100 if !outspeedsopponent
      score = 0 if outspeedsopponent
      score = 0 if @battle.field.effects[PBEffects::TrickRoom] > 0
    #---------------------------------------------------------------------------
    when "120" #todo
    #---------------------------------------------------------------------------
    when "121" #todo
    #---------------------------------------------------------------------------
    when "122" #todo
    #---------------------------------------------------------------------------
    when "123" #todo
      if !target.pbHasType?(user.type1) &&
         !target.pbHasType?(user.type2)
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "124" #todo
    #---------------------------------------------------------------------------
    when "125" #todo
      hasThisMove = false; hasOtherMoves = false; hasUnusedMoves = false
      user.eachMove do |m|
        hasThisMove = true if m.id == @id
        hasOtherMoves = true if m.id != @id
        hasUnusedMoves = true if m.id != @id && !user.movesUsed.include?(m.id)
      end
      if !hasThisMove || !hasOtherMoves || hasUnusedMoves
        score = -100
      end
    #---------------------------------------------------------------------------
    when "126" #todo?
      score += 20   # Shadow moves are more preferable
    #---------------------------------------------------------------------------
    when "127" #todo?
      score += 20   # Shadow moves are more preferable
      if target.pbCanParalyze?(user,false)
        score += 30
        if skill>=PBTrainerAI.mediumSkill
           aspeed = pbRoughStat(user,:SPEED,skill)
           ospeed = pbRoughStat(target,:SPEED,skill)
          if aspeed<ospeed
            score += 30
          elsif aspeed>ospeed
            score -= 40
          end
        end
        if skill>=PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET])
        end
      end
    #---------------------------------------------------------------------------
    when "128" #todo?
      score += 20   # Shadow moves are more preferable
      if target.pbCanBurn?(user,false)
        score += 30
        if skill>=PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET,:FLAREBOOST])
        end
      end
    #---------------------------------------------------------------------------
    when "129" #todo?
      score += 20   # Shadow moves are more preferable
      if target.pbCanFreeze?(user,false)
        score += 30
        if skill>=PBTrainerAI.highSkill
          score -= 20 if target.hasActiveAbility?(:MARVELSCALE)
        end
      end
    #---------------------------------------------------------------------------
    when "12A" #todo?
      score += 20   # Shadow moves are more preferable
      if target.pbCanConfuse?(user,false)
        score += 30
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "12B" #todo?
      score += 20   # Shadow moves are more preferable
      if target.pbCanLowerStatStage?(:DEFENSE,user)
        score -= 90
      else
        score += 40 if user.turnCount==0
        score += target.stages[:DEFENSE]*20
      end
    #---------------------------------------------------------------------------
    when "12C" #todo?
      score += 20   # Shadow moves are more preferable
      if target.pbCanLowerStatStage?(:EVASION,user)
        score -= 90
      else
        score += target.stages[:EVASION]*15
      end
    #---------------------------------------------------------------------------
    when "12D" #todo?
      score += 20   # Shadow moves are more preferable
    #---------------------------------------------------------------------------
    when "12E" #todo?
      score += 20   # Shadow moves are more preferable
      score += 20 if target.hp>=target.totalhp/2
      score -= 20 if user.hp<user.hp/2
    #---------------------------------------------------------------------------
    when "12F" #todo?
      score += 20   # Shadow moves are more preferable
      score -= 110 if target.effects[PBEffects::MeanLook]>=0
    #---------------------------------------------------------------------------
    when "130" #todo?
      score += 20   # Shadow moves are more preferable
      score -= 40
    #---------------------------------------------------------------------------
    when "131" #todo?
      score += 20   # Shadow moves are more preferable
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.pbWeather == :ShadowSky
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "132" #todo?
      score += 20   # Shadow moves are more preferable
      if target.pbOwnSide.effects[PBEffects::AuroraVeil]>0 ||
         target.pbOwnSide.effects[PBEffects::Reflect]>0 ||
         target.pbOwnSide.effects[PBEffects::LightScreen]>0 ||
         target.pbOwnSide.effects[PBEffects::Safeguard]>0
        score += 30
        score -= 90 if user.pbOwnSide.effects[PBEffects::AuroraVeil]>0 ||
                       user.pbOwnSide.effects[PBEffects::Reflect]>0 ||
                       user.pbOwnSide.effects[PBEffects::LightScreen]>0 ||
                       user.pbOwnSide.effects[PBEffects::Safeguard]>0
      else
        score -= 110
      end
    #---------------------------------------------------------------------------
    when "137" #todo
      hasEffect = user.statStageAtMax?(:DEFENSE) &&
                  user.statStageAtMax?(:SPECIAL_DEFENSE)
      user.eachAlly do |b|
        next if b.statStageAtMax?(:DEFENSE) && b.statStageAtMax?(:SPECIAL_DEFENSE)
        hasEffect = true
        score -= b.stages[:DEFENSE]*10
        score -= b.stages[:SPECIAL_DEFENSE]*10
      end
      if hasEffect
        score -= user.stages[:DEFENSE]*10
        score -= user.stages[:SPECIAL_DEFENSE]*10
      else
        score -= 90
      end
      score = 0
    #---------------------------------------------------------------------------
    when "138" #todo
      if target.statStageAtMax?(:SPECIAL_DEFENSE)
        score -= 90
      else
        score -= target.stages[:SPECIAL_DEFENSE]*10
      end
    #---------------------------------------------------------------------------
    when "139"
      score = 0
      if target.pbCanLowerStatStage?(:ATTACK,user)
        statincrease = pbCynthiaGetStatIncrease(:ATTACK, -1, target)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = opposingPhysicalThreat * statincrease if damagethreshold < (userhp / [userThreat, opposingPhysicalThreat * statincrease].max.ceil).ceil
      else
        score = 0
      end
      score = 0 if user.hasActiveAbility?(:UNAWARE)
      score = 0 if target.hasActiveAbility?([:CONTRARY, :COMPETITIVE, :DEFIANT])
    #---------------------------------------------------------------------------
    when "13A"
      score = 0
      if target.pbCanLowerStatStage?(:ATTACK,user) || target.pbCanLowerStatStage?(:SPECIAL_ATTACK,user)
        statincrease = [pbCynthiaGetStatIncrease(:ATTACK, -1, target), pbCynthiaGetStatIncrease(:SPECIAL_ATTACK, -1, target)].max()
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = opposingThreat * statincrease if damagethreshold < (userhp / [userThreat, opposingThreat * statincrease].max.ceil).ceil
      else
        score = 0
      end
      score = 0 if user.hasActiveAbility?(:UNAWARE)
      score = 0 if target.hasActiveAbility?([:CONTRARY, :COMPETITIVE, :DEFIANT])
    #---------------------------------------------------------------------------
    when "13B"
      if user.hasActiveAbility?(:CONTRARY)
        if !user.statStageAtMax?(:DEFENSE)
          statincrease = pbCynthiaGetStatIncrease(:DEFENSE, -1, user).max()
          userhp = 100.0
          userhp = userhp - opposingThreat if !outspeedsopponent
          damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
          score = opposingPhysicalThreat * statincrease if damagethreshold < (userhp / ([userThreat, opposingPhysicalThreat / statincrease].max.ceil)).ceil
        else
          score = 0
        end
        user.eachOpposing do |opponent|
          score = 0 if opponent.hasActiveAbility?(:UNAWARE)
        end
      elsif user.hasActiveItem?(:WHITEHERB) && user.hasActiveAbility?(:UNBURDEN)
        score = 100
      else
        score = -32
      end
      score = -100 if !user.isSpecies?(:HOOPA) || user.form!=1
    #---------------------------------------------------------------------------
    when "13C"
      score = 0
      if target.pbCanLowerStatStage?(:SPECIAL_ATTACK,user)
        statincrease = pbCynthiaGetStatIncrease(:SPECIAL_ATTACK, -1, target)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = opposingSpecialThreat * statincrease if damagethreshold < (userhp / [userThreat, opposingSpecialThreat * statincrease].max.ceil).ceil
      else
        score = 0
      end
      score = 0 if user.hasActiveAbility?(:UNAWARE)
      score = 0 if target.hasActiveAbility?([:CONTRARY, :COMPETITIVE, :DEFIANT])
    #---------------------------------------------------------------------------
    when "13D"
      score = 0
      if target.pbCanLowerStatStage?(:SPECIAL_ATTACK,user)
        statincrease = pbCynthiaGetStatIncrease(:SPECIAL_ATTACK, -2, target)
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = opposingSpecialThreat * statincrease if damagethreshold < (userhp / [userThreat, opposingSpecialThreat * statincrease].max.ceil).ceil
      else
        score = 0
      end
      score = 0 if user.hasActiveAbility?(:UNAWARE)
      score = 0 if target.hasActiveAbility?([:CONTRARY, :COMPETITIVE, :DEFIANT])
    #---------------------------------------------------------------------------
    when "13E" #todo
      count = 0
      @battle.eachBattler do |b|
        if b.pbHasType?(:GRASS) && !b.airborne? &&
           (!b.statStageAtMax?(:ATTACK) || !b.statStageAtMax?(:SPECIAL_ATTACK))
          count += 1
          if user.opposes?(b)
            score -= 20
          else
            score -= user.stages[:ATTACK]*10
            score -= user.stages[:SPECIAL_ATTACK]*10
          end
        end
      end
      score -= 95 if count==0
    #---------------------------------------------------------------------------
    when "13F" #todo
      count = 0
      @battle.eachBattler do |b|
        if b.pbHasType?(:GRASS) && !b.statStageAtMax?(:DEFENSE)
          count += 1
          if user.opposes?(b)
            score -= 20
          else
            score -= user.stages[:DEFENSE]*10
          end
        end
      end
      score -= 95 if count==0
    #---------------------------------------------------------------------------
    when "140" #todo
      count=0
      @battle.eachBattler do |b|
        if b.poisoned? &&
           (!b.statStageAtMin?(:ATTACK) ||
           !b.statStageAtMin?(:SPECIAL_ATTACK) ||
           !b.statStageAtMin?(:SPEED))
          count += 1
          if user.opposes?(b)
            score += user.stages[:ATTACK]*10
            score += user.stages[:SPECIAL_ATTACK]*10
            score += user.stages[:SPEED]*10
          else
            score -= 20
          end
        end
      end
      score -= 95 if count==0
    #---------------------------------------------------------------------------
    when "141" #todo
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      else
        numpos = 0; numneg = 0
        GameData::Stat.each_battle do |s|
          numpos += target.stages[s.id] if target.stages[s.id] > 0
          numneg += target.stages[s.id] if target.stages[s.id] < 0
        end
        if numpos!=0 || numneg!=0
          score += (numpos-numneg)*10
        else
          score -= 95
        end
      end
    #---------------------------------------------------------------------------
    when "142" #todo
      score -= 90 if target.pbHasType?(:GHOST)
    #---------------------------------------------------------------------------
    when "143" #todo
      score -= 90 if target.pbHasType?(:GRASS)
    #---------------------------------------------------------------------------
    when "145" #todo
      aspeed = pbRoughStat(user,:SPEED,skill)
      ospeed = pbRoughStat(target,:SPEED,skill)
      score -= 90 if aspeed>ospeed
    #---------------------------------------------------------------------------
    when "146" #todo
    #---------------------------------------------------------------------------
    when "147" #todo
    #---------------------------------------------------------------------------
    when "148" #todo
      aspeed = pbRoughStat(user,:SPEED,skill)
      ospeed = pbRoughStat(target,:SPEED,skill)
      if aspeed>ospeed
        score -= 90
      else
        score += 30 if target.pbHasMoveType?(:FIRE)
      end
    #---------------------------------------------------------------------------
    when "149" #todo
      if user.turnCount==0
        score += 30
      else
        score = 0
      end
    #---------------------------------------------------------------------------
    when "14A" #todo
    #---------------------------------------------------------------------------
    when "14B", "14C" #todo
      if user.effects[PBEffects::ProtectRate]>1 ||
         target.effects[PBEffects::HyperBeam]>0
        score -= 90
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= user.effects[PBEffects::ProtectRate]*40
        end
        score += 50 if user.turnCount==0
        score += 30 if target.effects[PBEffects::TwoTurnAttack]
      end
    #---------------------------------------------------------------------------
    when "14D" #todo
    #---------------------------------------------------------------------------
    when "14E" #todo
      if user.statStageAtMax?(:SPECIAL_ATTACK) &&
         user.statStageAtMax?(:SPECIAL_DEFENSE) &&
         user.statStageAtMax?(:SPEED)
        score -= 90
      else
        score -= user.stages[:SPECIAL_ATTACK]*10   # Only *10 instead of *20
        score -= user.stages[:SPECIAL_DEFENSE]*10   # because two-turn attack
        score -= user.stages[:SPEED]*10
        hasSpecialAttack = false
        user.eachMove do |m|
          next if !m.specialMove?(m.type)
          hasSpecialAttack = true
          break
        end
        if hasSpecialAttack
          score += 20
        else
          score -= 90
        end
        aspeed = pbRoughStat(user,:SPEED,skill)
        ospeed = pbRoughStat(target,:SPEED,skill)
        score += 30 if aspeed<ospeed && aspeed*2>ospeed
      end
      score = 100 if user.hasActiveItem?(:POWERHERB)
    #---------------------------------------------------------------------------
    when "14F" #todo
      if skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:LIQUIDOOZE)
        score -= 80
      else
        score += 40 if user.hp<=user.totalhp/2
      end
    #---------------------------------------------------------------------------
    when "150" #todo
      score += 20 if !user.statStageAtMax?(:ATTACK) && target.hp<=target.totalhp/4
    #---------------------------------------------------------------------------
    when "151" #todo
      avg  = target.stages[:ATTACK]*10
      avg += target.stages[:SPECIAL_ATTACK]*10
      score += avg/2
    #---------------------------------------------------------------------------
    when "152" #todo
    #---------------------------------------------------------------------------
    when "153"
      score = 100
      score = 0 if user.pbOpposingSide.effects[PBEffects::StickyWeb]
    #---------------------------------------------------------------------------
    when "154"
      score *= 2 if user.hasActiveItem?(:TERRAINEXTENDER) || user.hasActiveItem?(:ELECTRICSEED)
      score *= 1.3 if user.pbHasType?(:ELECTRIC)
      score *= 2 if user.effects[PBEffects::Yawn]>0
      score *= 2 if user.hasActiveAbility?[:SURGESURFER, :QUARKDRIVE, :HADRONENGINE]
      score *= 2 if user.pbHasMove?(:RISINGVOLTAGE) || user.pbHasMove?(:TERRAINPULSE) || user.pbHasMove?(:PSYBLADE)
      score = 0 if @battle.field.terrain == :Electric
    #---------------------------------------------------------------------------
    when "155"
      score *= 2 if user.hasActiveItem?(:TERRAINEXTENDER) || user.hasActiveItem?(:GRASSYSEED)
      score *= 1.3 if user.pbHasType?(:GRASS)
      score *= 2 if user.pbHasMove?(:GRASSYGLIDE) || user.pbHasMove?(:TERRAINPULSE)
      score = 0 if @battle.field.terrain == :Grassy
    #---------------------------------------------------------------------------
    when "156"
      score *= 2 if user.hasActiveItem?(:TERRAINEXTENDER) || user.hasActiveItem?(:MISTYSEED)
      score *= 2 if user.effects[PBEffects::Yawn]>0
      score *= 2 if user.pbHasMove?(:MISTYEXPLOSION) || user.pbHasMove?(:TERRAINPULSE)
      score = 0 if @battle.field.terrain == :Misty
    #---------------------------------------------------------------------------
    when "158" #todo
      score -= 90 if !user.belched?
    #---------------------------------------------------------------------------
    when "159" #todo
      if target.pbCanLowerStatStage?(:SPEED,user)
        score = 100
        statincrease = pbCynthiaGetStatIncrease(:SPEED, -1, target)
        score = 0 if user.pbSpeed <= target.pbSpeed * statincrease
        score = 0 if target.hasActiveAbility?(:SPEEDBOOST)
      else
        score = 0
      end
      score = 0 if outspeedsopponent
      score = 0 if target.hasActiveAbility?([:CONTRARY, :COMPETITIVE, :DEFIANT])
      score += 32 if !(target.effects[PBEffects::Yawn]>0 || target.hasActiveAbility?([:GUTS,:MARVELSCALE,:TOXICBOOST,:QUICKFEET, :POISONHEAL, :MAGICGUARD]) || target.pbHasMoveFunction?("0D9") || !target.pbCanPoison?(user,false) || (target.hasActiveAbility?(:SYNCHRONIZE) && user.pbCanPoisonSynchronize?(target)))
    #---------------------------------------------------------------------------
    when "15A" #todo
      if target.opposes?(user)
        score -= 40 if target.status == :BURN
      else
        score += 40 if target.status == :BURN
      end
    #---------------------------------------------------------------------------
    when "15B" #todo
      if target.status == :NONE
        score -= 90
      elsif user.hp==user.totalhp && target.opposes?(user)
        score -= 90
      else
        score += (user.totalhp-user.hp)*50/user.totalhp
        score -= 30 if target.opposes?(user)
      end
    #---------------------------------------------------------------------------
    when "15C" #todo
      hasEffect = user.statStageAtMax?(:ATTACK) &&
                  user.statStageAtMax?(:SPECIAL_ATTACK)
      user.eachAlly do |b|
        next if b.statStageAtMax?(:ATTACK) && b.statStageAtMax?(:SPECIAL_ATTACK)
        hasEffect = true
        score -= b.stages[:ATTACK]*10
        score -= b.stages[:SPECIAL_ATTACK]*10
      end
      if hasEffect
        score -= user.stages[:ATTACK]*10
        score -= user.stages[:SPECIAL_ATTACK]*10
      else
        score -= 90
      end
      score = 0
    #---------------------------------------------------------------------------
    when "15D" #todo
      numStages = 0
      GameData::Stat.each_battle do |s|
        next if target.stages[s.id] <= 0
        numStages += target.stages[s.id]
      end
      score += numStages*20
    #---------------------------------------------------------------------------
    when "15E" #todo
      if user.effects[PBEffects::LaserFocus]>0
        score -= 90
      else
        score += 40
      end
      score = 0
    #---------------------------------------------------------------------------
    when "15F"
      if user.hasActiveAbility?(:CONTRARY)
        if !user.statStageAtMax?(:DEFENSE)
          statincrease = pbCynthiaGetStatIncrease(:DEFENSE, -1, user).max()
          userhp = 100.0
          userhp = userhp - opposingThreat if !outspeedsopponent
          damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
          score = opposingPhysicalThreat * statincrease if damagethreshold < (userhp / ([userThreat, opposingPhysicalThreat / statincrease].max.ceil)).ceil
        else
          score = 0
        end
        user.eachOpposing do |opponent|
          score = 0 if opponent.hasActiveAbility?(:UNAWARE)
        end
      elsif user.hasActiveItem?(:WHITEHERB) && user.hasActiveAbility?(:UNBURDEN)
        score = 100
      else
        score = -32
      end
    #---------------------------------------------------------------------------
    when "160" #todo
      if target.statStageAtMin?(:ATTACK)
        score -= 90
      else
        if target.pbCanLowerStatStage?(:ATTACK,user)
          score += target.stages[:ATTACK]*20
          hasPhysicalAttack = false
          target.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          if hasPhysicalAttack
            score += 20
          else
            score -= 90
          end
        end
        score += (user.totalhp-user.hp)*50/user.totalhp
      end
    #---------------------------------------------------------------------------
    when "161" #todo
      if user.speed>target.speed
        score += 50
      else
        score -= 70
      end
    #---------------------------------------------------------------------------
    when "162" #todo
      score -= 90 if !user.pbHasType?(:FIRE)
    #---------------------------------------------------------------------------
    when "163" #todo
    #---------------------------------------------------------------------------
    when "165"
      userSpeed   = pbRoughStat(user,:SPEED,skill)
      targetSpeed = pbRoughStat(target,:SPEED,skill)
      if userSpeed<targetSpeed
        score += 30
      end
    #---------------------------------------------------------------------------
    when "167" #todo
      score *= 2 if user.hasActiveItem?(:LIGHTCLAY)
      score *= 2 if outspeedsopponent
      score = 0 if user.pbOwnSide.effects[PBEffects::AuroraVeil]>0 || @battle.pbWeather != :Hail || @battle.pbWeather != :Snow
    #---------------------------------------------------------------------------
    when "168" #todo
      if user.effects[PBEffects::ProtectRate]>1 ||
         target.effects[PBEffects::HyperBeam]>0
        score -= 90
      else
        score -= user.effects[PBEffects::ProtectRate]*40
        score += 50 if user.turnCount==0
        score += 30 if target.effects[PBEffects::TwoTurnAttack]
        score += 20   # Because of possible poisoning
      end
    #---------------------------------------------------------------------------
    when "16A" #todo
      hasAlly = false
      target.eachAlly do |b|
        hasAlly = true
        break
      end
      score -= 90 if !hasAlly
    #---------------------------------------------------------------------------
    when "16B" #todo
      if !target.lastRegularMoveUsed ||
         !target.pbHasMove?(target.lastRegularMoveUsed) ||
         target.usingMultiTurnAttack?
        score -= 90
      else
        # Without lots of code here to determine good/bad moves and relative
        # speeds, using this move is likely to just be a waste of a turn
        score -= 50
      end
    #---------------------------------------------------------------------------
    when "16C" #todo
      if target.effects[PBEffects::ThroatChop]==0
        hasSoundMove = false
        user.eachMove do |m|
          next if !m.soundMove?
          hasSoundMove = true
          break
        end
        score += 40 if hasSoundMove
      end
    #---------------------------------------------------------------------------
    when "16D" #todo
      score *= 2 if opposingThreat < 66 && opposingThreat > 33 && user.hp <= user.totalhp * 3 / 4 && !outspeedsopponent
      score *= 2 if opposingThreat < 100 && user.hp <= user.totalhp / 2
      score *= 2 if opposingThreat < 100 && user.hp <= user.totalhp / 4
      score = 0 if !user.canHeal?
      score = 0 if user.hp >= user.totalhp * 3 / 4
    #---------------------------------------------------------------------------
    when "16E" #todo
      if target.hp==target.totalhp || (!target.canHeal?)
        score -= 90
      else
        score += 50
        score -= target.hp*100/target.totalhp
        score += 30 if @battle.field.terrain == :Grassy
      end
    #---------------------------------------------------------------------------
    when "16F" #todo
      if !target.opposes?(user)
        if target.hp==target.totalhp || !target.canHeal?
          score -= 90
        else
          score += 50
          score -= target.hp*100/target.totalhp
        end
      end
    #---------------------------------------------------------------------------
    when "170" #todo
      reserves = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if @battle.pbCheckGlobalAbility(:DAMP)
        score -= 100
      elsif reserves==0 && foes>0
        score -= 100   # don't want to lose
      elsif reserves==0 && foes==0
        score += 80   # want to draw
      else
        score -= (user.totalhp-user.hp)*75/user.totalhp
      end
    #---------------------------------------------------------------------------
    when "171"
      hasPhysicalAttack = false
      target.eachMove do |m|
        next if !m.physicalMove?(m.type)
        hasPhysicalAttack = true
        break
      end
      score -= 80 if !hasPhysicalAttack
    #---------------------------------------------------------------------------
    when "172" #todo
      score += 20   # Because of possible burning
    #---------------------------------------------------------------------------
    when "173"
      score *= 2 if user.hasActiveItem?(:TERRAINEXTENDER) || user.hasActiveItem?(:PSYCHICSEED)
      score *= 1.3 if user.pbHasType?(:PSYCHIC)
      score *= 2 if user.hasActiveAbility?[:SURGESURFER, :QUARKDRIVE, :HADRONENGINE]
      score *= 2 if user.pbHasMove?(:EXPANDINGFORCE) || user.pbHasMove?(:TERRAINPULSE)
      score = 0 if @battle.field.terrain == :Electric
    #---------------------------------------------------------------------------
    when "174" #todo
      score -= 90 if user.turnCount > 0
    #---------------------------------------------------------------------------
    when "175" #todo flinch
      score += 30 if target.effects[PBEffects::Minimize]
    #---------------------------------------------------------------------------
    when "176" #todo flinch
      if !user.statStageAtMax?(:SPEED)
        score = 100
        statincrease = pbCynthiaGetStatIncrease(:SPEED, 1, user)
        user.eachOpposing do |opponent|
          score = 0 if user.pbSpeed * statincrease <= opponent.pbSpeed
          score = 0 if opponent.hasActiveAbility?(:SPEEDBOOST)
        end
      else
        score = 0
      end
      score = 0 if outspeedsopponent
    #---------------------------------------------------------------------------
    when "180" #todo
    #---------------------------------------------------------------------------
    when "181"
      if !user.statStageAtMax?(:ATTACK) || !user.statStageAtMax?(:DEFENSE) || !user.statStageAtMax?(:SPEED) || !user.statStageAtMax?(:SPECIAL_ATTACK) || !user.statStageAtMax?(:SPECIAL_DEFENSE)
        speedstatincrease = pbCynthiaGetStatIncrease(:SPEED, 1, user)
        atkstatincrease = [pbCynthiaGetStatIncrease(:ATTACK, 1, user), pbCynthiaGetStatIncrease(:SPECIAL_ATTACK, 1, user)].max()
        defstatincrease = [pbCynthiaGetStatIncrease(:DEFENSE, 1, user), pbCynthiaGetStatIncrease(:SPECIAL_DEFENSE, 1, user)].max()
        userhp = ((100 * user.hp / user.totalhp) - 33) / (100 * user.hp / user.totalhp)
        if user.hasActiveItem?(:SITRUSBERRY)
          userhp = 100.0 * ((100 * user.hp / user.totalhp) + 25) / (100 * user.hp / user.totalhp)
        end
        speedscore = 100
        user.eachOpposing do |opponent|
          speedscore = 0 if user.pbSpeed * speedstatincrease <= opponent.pbSpeed
          speedscore = 0 if opponent.hasActiveAbility?(:SPEEDBOOST)
          atkstatincrease = 1 if opponent.hasActiveAbility?(:UNAWARE)
          defstatincrease = 1 if opponent.hasActiveAbility?(:UNAWARE)
        end
        speedscore = 0 if outspeedsopponent
        score = [score, speedscore].max()
        userhp = 100.0
        userhp = userhp - opposingThreat if !outspeedsopponent
        damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
        score = [score, opposingThreat * defstatincrease].max() if damagethreshold < (userhp / ([userThreat, opposingThreat / defstatincrease].max.ceil)).ceil
        score = [score, userThreat * atkstatincrease].max() if (userhp / [userThreat * atkstatincrease, opposingThreat].max.ceil).ceil < damagethreshold
      else
        score = 0
      end
    #---------------------------------------------------------------------------
    when "182" #todo
    #---------------------------------------------------------------------------
    when "183" #todo
      score = 1000000
    #---------------------------------------------------------------------------
    when "188" #todo
    #---------------------------------------------------------------------------
    when "193" #todo
    #---------------------------------------------------------------------------
    when "194" #todo
      if opposingThreat < (outspeedsopponent ? 49 : 32) || user.hasActiveItem?(:POWERHERB)
        if !user.statStageAtMax?(:SPECIAL_ATTACK)
          statincrease = pbCynthiaGetStatIncrease(:SPECIAL_ATTACK, 1, user)
          userhp = 100.0
          userhp = userhp - opposingThreat if !outspeedsopponent
          damagethreshold = (userhp / [userThreat, opposingThreat].max).ceil
          score = [score, userSpecialThreat * statincrease].max() if (userhp / [userSpecialThreat*statincrease, opposingThreat].max.ceil).ceil < damagethreshold
        else
          score = 0
        end
        user.eachOpposing do |opponent|
          score = 0 if opponent.hasActiveAbility?(:UNAWARE)
        end
      end
    #---------------------------------------------------------------------------
    end
    # A score of 0 here means it absolutely should not be used
    effectchance = 100
    effectchance = move.pbAdditionalEffectChance(user,target) if move.addlEffect > 0
    effectchance = pbRoughAccuracy(move,user,target,100) if move.statusMove?
    score = score * effectchance
    return score
  end

  def pbCynthiaCalcDamage(move,user,target)
    damagedictionary = {
      :minDamage => 0,
      :averageDamage => 0,
      :maxDamage => 0,
      :critDamage => 0,
    }
    switchin = false
    if user.index == 69
      switchin = user
    end
    if target.index == 69
      switchin = target
    end
    damagedictionary.each do |key,damage|
      originalkey = key
      baseDmg = move.baseDamage
      case move.function
      when "010"   # Stomp
        baseDmg *= 2 if target.effects[PBEffects::Minimize]
      # Sonic Boom, Dragon Rage, Super Fang, Night Shade, Endeavor
      when "06A", "06B", "06C", "06D", "06E"
        damage = move.pbFixedDamage(user,target)
      when "06F"   # Psywave
        case key
        when :minDamage
          damage = user.level/2.floor
        when :averageDamage
          damage = user.level
        else
          damage = user.level*3/2.floor
        end
      when "070"   # OHKO
        damage = target.hp
      when "071", "072", "073"   # Counter, Mirror Coat, Metal Burst
        damage = 0
      when "075", "076", "0D0", "12D"   # Surf, Earthquake, Whirlpool, Shadow Storm
        baseDmg = move.pbModifyDamage(baseDmg,user,target)
      # Gust, Twister, Venoshock, Smelling Salts, Wake-Up Slap, Facade, Hex, Brine,
      # Retaliate, Weather Ball, Return, Frustration, Eruption, Crush Grip,
      # Stored Power, Punishment, Hidden Power, Fury Cutter, Echoed Voice,
      # Trump Card, Flail, Electro Ball, Low Kick, Fling, Spit Up
      when "077", "078", "07B", "07C", "07D", "07E", "07F", "080", "085", "087",
           "089", "08A", "08B", "08C", "08E", "08F", "090", "091", "092", "097",
           "098", "099", "09A", "0F7", "113", "176", "188", "192"
        baseDmg = move.pbBaseDamage(baseDmg,user,target)
      when "086"   # Acrobatics
        baseDmg *= 2 if !user.item || user.hasActiveItem?(:FLYINGGEM)
      when "08D"   # Gyro Ball
        baseDmg = [[(25*target.pbSpeed/user.pbSpeed).floor,150].min,1].max
      when "094"   # Present
        baseDmg = 50
      when "095"   # Magnitude
        case key
        when :minDamage
          baseDmg = 10
        when :averageDamage
          baseDmg = 71
        else
          baseDmg = 150
        end
        baseDmg.each *= 2 if target.inTwoTurnAttack?("0CA")   # Dig
      when "096"   # Natural Gift
        baseDmg = move.pbNaturalGiftBaseDamage(user.item_id)
      when "09B"   # Heavy Slam
        baseDmg = move.pbBaseDamage(baseDmg,user,target)
        baseDmg *= 2 if target.effects[PBEffects::Minimize]
      when "0A0"  # Frost Breath
        originalkey = key
        key = :critDamage
      when "0BD", "0BE"   #Double Kick, Twineedle
        baseDmg *= 2
      when "0BF"   # Triple Kick
        case key
        when :minDamage
          baseDmg = 10
        when :averageDamage
          baseDmg = 47 #todo accuracy check
        else
          baseDmg *= 6   # Hits do x1, x2, x3 baseDmg in turn, for x6 in total
        end
      when "0C0", "176"   # Fury Attack
        if user.hasActiveAbility?(:SKILLLINK)
          baseDmg *= 5
        else
          if user.hasActiveItem?(:LOADEDDICE)
            case key
            when :minDamage
              baseDmg *= 4
            when :averageDamage
              baseDmg *= 4.5
            else
              baseDmg *= 5
            end
          else
            case key
            when :minDamage
              baseDmg *= 2
            when :averageDamage
              baseDmg = (baseDmg*19/6).floor
            else
              baseDmg *= 5
            end
          end
        end
      when "0C1"   # Beat Up
        mult = 0
        @battle.eachInTeamFromBattlerIndex(user.index) do |pkmn,_i|
          mult += 1 if pkmn && pkmn.able? && pkmn.status == :NONE
        end
        baseDmg *= mult
      when "0C4"   # Solar Beam
        baseDmg = move.pbBaseDamageMultiplier(baseDmg,user,target)
      when "0D3"   # Rollout
        baseDmg *= 2 if user.effects[PBEffects::DefenseCurl]
      when "0D4"   # Bide
        damage = 0
      when "0E1"   # Final Gambit
        damage = user.hp
      when "144"   # Flying Press
        if GameData::Type.exists?(:FLYING)
          targetTypes = target.pbTypes(true)
          mult = Effectiveness.calculate(:FLYING,
             targetTypes[0],targetTypes[1],targetTypes[2])
          baseDmg = (baseDmg.to_f*mult/Effectiveness::NORMAL_EFFECTIVE).round
        end
        baseDmg *= 2 if target.effects[PBEffects::Minimize]
      when "166"   # Stomping Tantrum
        baseDmg *= 2 if user.lastRoundMoveFailed
      when "175"   # Double Iron Bash
        baseDmg *= 2
        baseDmg *= 2 if target.effects[PBEffects::Minimize]
      when "044"
        baseDmg = (baseDmg / 2.0).round if move.id == :BULLDOZE && @battle.field.terrain == :Grassy
      when "081", "084"
        baseDmg *= 2 if target.pbSpeed > user.pbSpeed
      when "083"
        if [:maxDamage, :critDamage].include?(key)
          user.eachAlly do |b|
            baseDmg *= 1.5 if b.pbHasMove?(:ROUND) && b.pbSpeed > user.pbSpeed
          end
        end
      when "0F0"
        baseDmg *= 1.5 if target.item && !target.unlosableItem?(target.item)
      end
      
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      type = move.pbCalcType(user)
      typeMod = move.pbCalcTypeMod(type,user,target)
      atk, atkStage = move.pbGetAttackStats(user,target)
      if switchin == target && target.hasActiveAbility?([:INTIMIDATE, :SKULK]) && move.physicalMove?
        unless user.effects[PBEffects::Substitute]>0 || user.pbOwnSide.effects[PBEffects::Mist]>0 || user.hasActiveAbility?([:CLEARBODY, :WHITESMOKE, :HYPERCUTTER, :FULLMETALBODY]) || !user.pbCanLowerStatStage?(:ATTACK,target)
          if !target.hasActiveAbility?(:CONTRARY)
            atkStage -= 1
          else
            atkStage += 1
          end
        end
      end
      if switchin == user && user.hasActiveAbility?(:DOWNLOAD)
        oDef = oSpDef = 0
        @battle.eachOtherSideBattler(user.index) do |b|
          oDef   += b.defense
          oSpDef += b.spdef
        end
        stat = (oDef<oSpDef) ? move.physicalMove? : move.specialMove?
        atkStage += 1 if stat
      end
      if switchin == user && user.hasActiveAbility?(:CHARGEDEXPLOSIVE)
        atkStage += 1
      end
      if !target.hasActiveAbility?(:UNAWARE) || user.hasMoldBreaker?
        if key == :critDamage
          atkStage = 6 if atkStage<6
        end
        atk = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
      end
      defense, defStage = move.pbGetDefenseStats(user,target)
      if !user.hasActiveAbility?(:UNAWARE)
        if key == :critDamage
          defStage = 6 if defStage>6
        end
        defense = (defense.to_f*stageMul[defStage]/stageDiv[defStage]).floor
      end
      multipliers = {
        :base_damage_multiplier  => 1.0,
        :attack_multiplier       => 1.0,
        :defense_multiplier      => 1.0,
        :final_damage_multiplier => 1.0
      }

      if ((@battle.pbCheckGlobalAbility(:DARKAURA) || (switchin && switchin.ability == :DARKAURA)) && type == :DARK) ||
         ((@battle.pbCheckGlobalAbility(:FAIRYAURA) || (switchin && switchin.ability == :FAIRYAURA)) && type == :FAIRY)
        if @battle.pbCheckGlobalAbility(:AURABREAK) || (switchin && switchin.ability == :AURABREAK)
          multipliers[:base_damage_multiplier] *= 2 / 3.0
          multipliers[:base_damage_multiplier] *= 4 / 3.0
        else
        end
      end
      if user.abilityActive?
        if switchin == user && user.ability == :SLOWSTART
          multipliers[:attack_multiplier] /= 2 if move.physicalMove?
        end
        case user.ability
        when :AERILATE,:PIXILATE,:REFRIGERATE,:GALVANIZE,:ADAPTINGPIXELS,:PIXELATEDSANDS
          if type == :NORMAL
            multipliers[:base_damage_multiplier] *= 1.2
          end
        when :ANALYTIC
          if user.pbSpeed < target.pbSpeed
            multipliers[:base_damage_multiplier] *= 1.3
          end
        when :BLAZE
          if (user.hp <= user.totalhp / 3 || (target.pbSpeed > user.pbSpeed && user.hp - pbCynthiaAssessThreat(user, target, false) <= user.totalhp / 3)) && type == :FIRE
            mults[:attack_multiplier] *= 1.5
          end
        when :DEFEATIST
          if user.hp <= user.totalhp / 2 || (target.pbSpeed > user.pbSpeed && user.hp - pbCynthiaAssessThreat(user, target, false) <= user.totalhp / 2)
            mults[:attack_multiplier] /= 2
          end
        when :OVERGROW
          if (user.hp <= user.totalhp / 3 || (target.pbSpeed > user.pbSpeed && user.hp - pbCynthiaAssessThreat(user, target, false) <= user.totalhp / 3)) && type == :GRASS
            mults[:attack_multiplier] *= 1.5
          end
        when :SWARM
          if (user.hp <= user.totalhp / 3 || (target.pbSpeed > user.pbSpeed && user.hp - pbCynthiaAssessThreat(user, target, false) <= user.totalhp / 3)) && type == :BUG
            mults[:attack_multiplier] *= 1.5
          end
        when :TORRENT
          if (user.hp <= user.totalhp / 3 || (target.pbSpeed > user.pbSpeed && user.hp - pbCynthiaAssessThreat(user, target, false) <= user.totalhp / 3)) && type == :WATER
            mults[:attack_multiplier] *= 1.5
          end
        when :SNIPER, :SUPERSNIPER
          if key == :critDamage
            multipliers[:base_damage_multiplier] *= 1.5
          end
        when :TINTEDLENS
          multipliers[:final_damage_multiplier] *= 2 if Effectiveness.resistant?(typeMod)
        else
          BattleHandlers.triggerDamageCalcUserAbility(user.ability,
           user,target,move,multipliers,baseDmg,type)
        end
      end
      if !user.hasMoldBreaker?
        user.eachAlly do |b|
          next if !b.abilityActive?
          BattleHandlers.triggerDamageCalcUserAllyAbility(b.ability,
             user,target,move,multipliers,baseDmg,type)
        end
        if target.abilityActive?
          case user.ability
          when :FILTER,:SOLIDROCK
            if Effectiveness.super_effective?(typeMod)
              multipliers[:final_damage_multiplier] *= 0.75 if !user.hasMoldBreaker?
            end
          when :FLUFFY
            multipliers[:final_damage_multiplier] *= 2 if move.pbCalcType(user) == :FIRE && !user.hasMoldBreaker?
            multipliers[:final_damage_multiplier] /= 2 if move.contactMove? && !user.hasMoldBreaker?
          when :PRISMARMOR
            if Effectiveness.super_effective?(typeMod)
              mults[:final_damage_multiplier] *= 0.75
            end
          else
            BattleHandlers.triggerDamageCalcTargetAbility(target.ability,
               user,target,move,multipliers,baseDmg,type) if !user.hasMoldBreaker?
            BattleHandlers.triggerDamageCalcTargetAbilityNonIgnorable(target.ability,
               user,target,move,multipliers,baseDmg,type)
          end
        end
        target.eachAlly do |b|
          next if !b.abilityActive?
          BattleHandlers.triggerDamageCalcTargetAllyAbility(b.ability,
             user,target,move,multipliers,baseDmg,type)
        end
      end
      # Item effects that alter damage
      if user.itemActive?
        case user.item_id
        when :BUGGEM, :DARKGEM, :DRAGONGEM, :ELECTRICGEM, :FAIRYGEM, :FIGHTINGGEM, :FIREGEM, :FLYINGGEM, :GHOSTGEM, :GRASSGEM, :GROUNDGEM, :ICEGEM, :NORMALGEM, :POISONGEM, :PSYCHICGEM, :ROCKGEM, :SHARPBEAK, :STEELGEM, :WATERGEM
          if user.item_id == (type.to_s + "GEM").to_sym
            multipliers[:base_damage_multiplier] *= 1.5
          end
        when :EXPERTBELT
          if Effectiveness.super_effective?(typeMod)
            multipliers[:final_damage_multiplier] *= 1.2
          end
        else
          BattleHandlers.triggerDamageCalcUserItem(user.item,
           user,target,move,multipliers,baseDmg,type)
        end
      end
      if target.itemActive?
        case target.item_id
        when :BABIRIBERRY
          if move.calcType == :STEEL && !Effectiveness.resistant?(typeMod)
            multipliers[:final_damage_multiplier] /= 2
          end
        when :CHARTIBERRY
          if move.calcType == :ROCK && !Effectiveness.resistant?(typeMod)
            multipliers[:final_damage_multiplier] /= 2
          end
        when :CHILANBERRY
          if move.calcType == :NORMAL
            multipliers[:final_damage_multiplier] /= 2
          end
        when :CHOPLEBERRY
          if move.calcType == :FIGHTING && !Effectiveness.resistant?(typeMod)
            multipliers[:final_damage_multiplier] /= 2
          end
        when :COBABERRY
          if move.calcType == :FLYING && !Effectiveness.resistant?(typeMod)
            multipliers[:final_damage_multiplier] /= 2
          end
        when :COLBURBERRY
          if move.calcType == :DARK && !Effectiveness.resistant?(typeMod)
            multipliers[:final_damage_multiplier] /= 2
          end
        when :HABANBERRY
          if move.calcType == :DRAGON && !Effectiveness.resistant?(typeMod)
            multipliers[:final_damage_multiplier] /= 2
          end
        when :KASIBBERRY
          if move.calcType == :GHOST && !Effectiveness.resistant?(typeMod)
            multipliers[:final_damage_multiplier] /= 2
          end
        when :KEBIABERRY
          if move.calcType == :POISON && !Effectiveness.resistant?(typeMod)
            multipliers[:final_damage_multiplier] /= 2
          end
        when :OCCABERRY
          if move.calcType == :FIRE && !Effectiveness.resistant?(typeMod)
            multipliers[:final_damage_multiplier] /= 2
          end
        when :PASSHOBERRY
          if move.calcType == :WATER && !Effectiveness.resistant?(typeMod)
            multipliers[:final_damage_multiplier] /= 2
          end
        when :PAYAPABERRY
          if move.calcType == :PSYCHIC && !Effectiveness.resistant?(typeMod)
            multipliers[:final_damage_multiplier] /= 2
          end
        when :RINDOBERRY
          if move.calcType == :GRASS && !Effectiveness.resistant?(typeMod)
            multipliers[:final_damage_multiplier] /= 2
          end
        when :ROSELIBERRY
          if move.calcType == :FAIRY && !Effectiveness.resistant?(typeMod)
            multipliers[:final_damage_multiplier] /= 2
          end
        when :SHUCABERRY
          if move.calcType == :GROUND && !Effectiveness.resistant?(typeMod)
            multipliers[:final_damage_multiplier] /= 2
          end
        when :TANGABERRY
          if move.calcType == :BUG && !Effectiveness.resistant?(typeMod)
            multipliers[:final_damage_multiplier] /= 2
          end
        when :WACANBERRY
          if move.calcType == :ELECTRIC && !Effectiveness.resistant?(typeMod)
            multipliers[:final_damage_multiplier] /= 2
          end
        when :YACHEBERRY
          if move.calcType == :ICE && !Effectiveness.resistant?(typeMod)
            multipliers[:final_damage_multiplier] /= 2
          end
        else
          BattleHandlers.triggerDamageCalcTargetItem(target.item,
             user,target,move,multipliers,baseDmg,type)
        end
      end
      # Parental Bond's second attack
      if user.hasActiveAbility?(:PARENTALBOND)
        multipliers[:base_damage_multiplier] *= 5/4
      end
      # todo do helping hand calcs in a different part of the code
      # if user.effects[PBEffects::HelpingHand] && !move.is_a?(PokeBattle_Confusion)
      #   multipliers[:base_damage_multiplier] *= 1.5
      # end
      if user.effects[PBEffects::Charge]>0 && type == :ELECTRIC
        multipliers[:base_damage_multiplier] *= 2
      end
      # Mud Sport
      if type == :ELECTRIC
        @battle.eachBattler do |b|
          next if !b.effects[PBEffects::MudSport]
          multipliers[:base_damage_multiplier] /= 3
          break
        end
        if @battle.field.effects[PBEffects::MudSportField]>0
          multipliers[:base_damage_multiplier] /= 3
        end
      end
      # Water Sport
      if type == :FIRE
        @battle.eachBattler do |b|
          next if !b.effects[PBEffects::WaterSport]
          multipliers[:base_damage_multiplier] /= 3
          break
        end
        if @battle.field.effects[PBEffects::WaterSportField]>0
          multipliers[:base_damage_multiplier] /= 3
        end
      end
      # Terrain moves
      terrain = @battle.field.terrain
      if switchin
        case switchin.ability
        when :ELECTRICSURGE, :HADRONENGINE
          terrain = :Electric
        when :GRASSYSURGE
          terrain = :Grassy
        when :PSYCHICSURGE
          terrain = :Psychic
        when :MISTYSURGE
          terrain = :Misty
        end
      end
      case terrain
      when :Electric
        multipliers[:base_damage_multiplier] *= 1.5 if type == :ELECTRIC && user.affectedByTerrain?
      when :Grassy
        multipliers[:base_damage_multiplier] *= 1.5 if type == :GRASS && user.affectedByTerrain?
      when :Psychic
        multipliers[:base_damage_multiplier] *= 1.5 if type == :PSYCHIC && user.affectedByTerrain?
      when :Misty
        multipliers[:base_damage_multiplier] /= 2 if type == :DRAGON && target.affectedByTerrain?
      end
      if pbTargetsMultiple?(move,user)
        multipliers[:final_damage_multiplier] *= 0.75
      end
      # Weather
      weather = @battle.pbWeather
      if switchin && @battle.field.weather == weather
        case switchin.ability
        when :AIRLOCK, :CLOUDNINE
          weather = :None
        when :DELTASTREAM
          weather = :StrongWinds
        when :DROUGHT
          weather = :Sun unless [:StrongWinds, :HarshSun, :HeavyRain].include?(weather)
        when :DESOLATELAND
          weather = :HarshSun
        when :DRIZZLE
          weather = :Rain unless [:StrongWinds, :HarshSun, :HeavyRain].include?(weather)
        when :PRIMORDIALSEA
          weather = :HeavyRain
        when :SANDSTREAM, :ADAPTINGSANDS, :PIXELATEDSANDS
          weather = :Sandstorm unless [:StrongWinds, :HarshSun, :HeavyRain].include?(weather)
        when :SNOWWARNING
          weather = :Hail unless [:StrongWinds, :HarshSun, :HeavyRain].include?(weather)
        when :SNOWWWARNING
          weather = :Snow unless [:StrongWinds, :HarshSun, :HeavyRain].include?(weather)
        end
      end
      case weather
      when :Sun
        if type == :FIRE
          multipliers[:final_damage_multiplier] *= 1.5
        elsif type == :WATER
          multipliers[:final_damage_multiplier] /= 2
        end
      when :HarshSun
        if type == :FIRE
          multipliers[:final_damage_multiplier] *= 1.5
        elsif type == :WATER
          multipliers[:final_damage_multiplier] *= 0
        end
      when :Rain
        if type == :FIRE
          multipliers[:final_damage_multiplier] /= 2
        elsif type == :WATER
          multipliers[:final_damage_multiplier] *= 1.5
        end
      when :HeavyRain
        if type == :FIRE
          multipliers[:final_damage_multiplier] *= 0
        elsif type == :WATER
          multipliers[:final_damage_multiplier] *= 1.5
        end
      when :Sandstorm
        if (target.hasActiveAbility?(:ADAPTINGSANDS) || target.pbHasType?(:ROCK)) && move.specialMove? && move.function != "122"   # Psyshock
          multipliers[:defense_multiplier] *= 1.5
        end
      when :Snow
        if target.pbHasType?(:ICE) && move.physicalMove?
          multipliers[:defense_multiplier] *= 1.5
        end
      end
      if key == :critDamage
        if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
          multipliers[:final_damage_multiplier] *= 1.5
        else
          multipliers[:final_damage_multiplier] *= 2
        end
      end

      case key
      when :minDamage
        random = 85
      when :averageDamage
        random = 92.5
      else
        random = 100
      end
      multipliers[:final_damage_multiplier] *= random / 100.0
      # STAB
      if type && (user.pbHasType?(type) || (user.pbHasType?(:ICEFIREELECTRIC) && (type == :ELECTRIC || type == :FIRE || type == :ICE)))
        if user.hasActiveAbility?(:ADAPTABILITY) || user.hasActiveAbility?(:ADAPTINGPIXELS)
          multipliers[:final_damage_multiplier] *= 2
        else
          multipliers[:final_damage_multiplier] *= 1.5
        end
      end
      if user.unteraTypes != nil
        if user.unteraTypes.include?(:STELLAR)
          if user.stellarmoves == nil
            user.stellarmoves = []
          end
          if !user.stellarmoves.include?(GameData::Type.get(type).id)
            if type && user.unteraTypes.include?(GameData::Type.get(type).id)
              multipliers[:final_damage_multiplier] *= 1.5
            else
              multipliers[:final_damage_multiplier] *= 1.2
            end
          end
        else
          if type && user.unteraTypes.include?(GameData::Type.get(type).id)
            multipliers[:final_damage_multiplier] *= 1.5
          end
        end
      end
      # Type effectiveness
      multipliers[:final_damage_multiplier] *= typeMod.to_f / Effectiveness::NORMAL_EFFECTIVE
      # Burn
      if user.status == :BURN && move.physicalMove? && move.damageReducedByBurn? &&
         !user.hasActiveAbility?(:GUTS)
        multipliers[:final_damage_multiplier] /= 2
      end
      # Frostbite
      if user.status == :FROZEN && move.specialMove?
        multipliers[:final_damage_multiplier] /= 2
      end
      # Drowsy
      if target.status == :SLEEP && !(target.pbHasMove?(:SLEEPTALK) || target.pbHasMove?(:SNORE))
        multipliers[:final_damage_multiplier] *= 4/3
      end
      # Aurora Veil, Reflect, Light Screen
      if !move.ignoresReflect? && !(key == :critDamage)
         !(user.hasActiveAbility?(:INFILTRATOR) || user.hasActiveAbility?(:CHARGEDEXPLOSIVE))
        if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
          if @battle.pbSideBattlerCount(target)>1
            multipliers[:final_damage_multiplier] *= 2 / 3.0
          else
            multipliers[:final_damage_multiplier] /= 2
          end
        elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && move.physicalMove?
          if @battle.pbSideBattlerCount(target)>1
            multipliers[:final_damage_multiplier] *= 2 / 3.0
          else
            multipliers[:final_damage_multiplier] /= 2
          end
        elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && move.specialMove?
          if @battle.pbSideBattlerCount(target) > 1
            multipliers[:final_damage_multiplier] *= 2 / 3.0
          else
            multipliers[:final_damage_multiplier] /= 2
          end
        end
      end
      # Minimize
      if target.effects[PBEffects::Minimize] && move.tramplesMinimize?(2)
        multipliers[:final_damage_multiplier] *= 2
      end
      baseDmg = [(baseDmg * multipliers[:base_damage_multiplier]).round, 1].max
      atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
      defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
      damage  = (((2.0 * user.level / 5 + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
      damage  = [(damage  * multipliers[:final_damage_multiplier]).round, 1].max
      key = originalkey
      damagedictionary[key] = damage
    end
    return damagedictionary
  end
end