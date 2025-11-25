class PokeBattle_AI
  def pbCynthiaCompareSpeed(user, target)
    outspeedsopponent = user.pbSpeed > target.pbSpeed
    outspeedsopponent = user.pbSpeed < target.pbSpeed if @battle.field.effects[PBEffects::TrickRoom]>0
    return outspeedsopponent
  end

  def pbCynthiaGetStatIncrease(stat, change, target)
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    originalstages = target.stages[stat] + 6
    stages =  originalstages + change
    stages = [0, stages].max
    stages = [12, stages].min
    stateffect = (stageMul[stages].to_f / stageDiv[stages].to_f) / (stageMul[originalstages].to_f / stageDiv[originalstages].to_f)
    #stateffect = (stateffect + (-1 * (originalstages - 6))) / (1 + (-1 * (originalstages - 6))) if change < 0 && originalstages < 6
    return stateffect
  end

  def pbCynthiaCalculateStatScore(statarray,user,target,recursion=false)
    score = 0
    statarray.each do |stat|
      stat[1] *= -1 if target.hasActiveAbility?(:CONTRARY)
      stat[1] *= 2 if target.hasActiveAbility?(:SIMPLE)
      if target.hasActiveAbility?(:UNBURDEN) && target.hasActiveItem?(:WHITEHERB) && stat[1] < 0
        score = pbCynthiaCalculateStatScore([[:SPEED, 2]],user,target,true)
        break
      end
      next if stat[1] < 0 && target.hasActiveItem?(:WHITEHERB)
      stateffect = pbCynthiaGetStatIncrease(stat[0], stat[1], target)
      next if stateffect == 0
      score += stat[1]
      score += stat[1] * 5 if user.pbHasMove?(:STOREDPOWER) && stat[1] > 0
      if stat[0] == :SPEED #todo trick room
        tempscore = [0.0, 0]
        target.eachOpposing do |opponent|
          if target.pbSpeed < opponent.pbSpeed && opponent.pbSpeed < target.pbSpeed * stateffect
            tempscore[0] += 99
          end
          if target.pbSpeed * stateffect < opponent.pbSpeed && opponent.pbSpeed < target.pbSpeed
            tempscore[0] -= 99
          end
          tempscore[1] += 1
        end
        score += tempscore[0] / tempscore[1]
        next
      end
      damagekey = [:specialDamage, :physicalDamage]
      damagekey = [:physicalDamage, :specialDamage] if [:ATTACK, :DEFENSE].include?(stat[0])
      maxdamage = 0
      boostdamage = 0
      target.eachOpposing do |opponent|
        next if opponent.hasActiveAbility?(:UNAWARE)
        next if opponent.pbHasMove?(:FREEZYFROST) || opponent.pbHasMove?(:HAZE)
        damagearray = [target, opponent]
        damagearray = [opponent, target] if [:ATTACK, :SPECIAL_ATTACK].include?(stat[0])
        maxdamage = [pbCynthiaGetThreat(*damagearray)[:highestDamage], maxdamage].max
        boostdamage = [pbCynthiaGetThreat(*damagearray)[damagekey[0]] * stateffect, pbCynthiaGetThreat(*damagearray)[damagekey[1]], boostdamage].max
      end
      score += (boostdamage - maxdamage) * pbCynthiaGetDamageInfo(user)[:info][:damagethreshold]
    end
    if user.opposes?(target)
      score *= -0.75
      if !recursion
        score += pbCynthiaCalculateStatScore([[:ATTACK, 2]],user,target,true) if target.hasActiveAbility?(:DEFIANT)
        score += pbCynthiaCalculateStatScore([[:SPECIAL_ATTACK, 2]],user,target,true) if target.hasActiveAbility?(:COMPETITIVE)
      end
    end
    return score
  end

  def pbCynthiaGetDamageInfo(user, target=nil)
    @damageinfo[user] = {} if !@damageinfo[user]
    if target && !@damageinfo[user][target]
      @damageinfo[user][target] = {}
      @damageinfo[user][target][:targetMaxThreattable] = pbCynthiaGetThreat(user, target)
      @damageinfo[user][target][:targetMaxThreat] = @damageinfo[user][target][:targetMaxThreattable][:highestDamage]
      @damageinfo[user][target][:targetMaxPhysicalThreat] = @damageinfo[user][target][:targetMaxThreattable][:physicalDamage]
      @damageinfo[user][target][:targetMaxSpecialThreat] = @damageinfo[user][target][:targetMaxThreattable][:specialDamage]
      @damageinfo[user][target][:targetThreattable] = pbCynthiaGetThreat(user, target, false)
      @damageinfo[user][target][:targetThreat] = @damageinfo[user][target][:targetThreattable][:highestDamage]
      @damageinfo[user][target][:targetPhysicalThreat] = @damageinfo[user][target][:targetThreattable][:physicalDamage]
      @damageinfo[user][target][:targetSpecialThreat] = @damageinfo[user][target][:targetThreattable][:specialDamage]
      @damageinfo[user][target][:outspeedstarget] = pbCynthiaCompareSpeed(user, target)
    end
    return @damageinfo[user] if @damageinfo[user][:info]
    @damageinfo[user][:info] = {}
    @damageinfo[user][:info][:userMaxThreat] = 0
    @damageinfo[user][:info][:userMaxPhysicalThreat] = 0
    @damageinfo[user][:info][:userMaxSpecialThreat] = 0
    @damageinfo[user][:info][:userThreat] = 0
    @damageinfo[user][:info][:userPhysicalThreat] = 0
    @damageinfo[user][:info][:userSpecialThreat] = 0
    @damageinfo[user][:info][:opposingMaxThreat] = 0
    @damageinfo[user][:info][:opposingMaxPhysicalThreat] = 0
    @damageinfo[user][:info][:opposingMaxSpecialThreat] = 0
    @damageinfo[user][:info][:opposingThreat] = 0
    @damageinfo[user][:info][:opposingPhysicalThreat] = 0
    @damageinfo[user][:info][:opposingSpecialThreat] = 0
    @damageinfo[user][:info][:outspeedsopponent] = true
    user.eachOpposing do |opponent|
      userMaxThreattable = pbCynthiaGetThreat(opponent, user)
      @damageinfo[user][:info][:userMaxThreat] = [userMaxThreattable[:highestDamage], @damageinfo[user][:info][:userMaxThreat]].max
      @damageinfo[user][:info][:userMaxPhysicalThreat] = [userMaxThreattable[:physicalDamage], @damageinfo[user][:info][:userMaxPhysicalThreat]].max
      @damageinfo[user][:info][:userMaxSpecialThreat] = [userMaxThreattable[:specialDamage], @damageinfo[user][:info][:userMaxSpecialThreat]].max
      userThreattable = pbCynthiaGetThreat(opponent, user, false)
      @damageinfo[user][:info][:userThreat] = [userThreattable[:highestDamage], @damageinfo[user][:info][:userThreat]].max
      @damageinfo[user][:info][:userPhysicalThreat] = [userThreattable[:physicalDamage], @damageinfo[user][:info][:userPhysicalThreat]].max
      @damageinfo[user][:info][:userSpecialThreat] = [userThreattable[:specialDamage], @damageinfo[user][:info][:userSpecialThreat]].max
      opponentMaxThreattable = pbCynthiaGetThreat(user, opponent)
      @damageinfo[user][:info][:opposingMaxThreat] += opponentMaxThreattable[:highestDamage]
      @damageinfo[user][:info][:opposingMaxPhysicalThreat] += opponentMaxThreattable[:physicalDamage]
      @damageinfo[user][:info][:opposingMaxSpecialThreat] += opponentMaxThreattable[:specialDamage]
      opponentThreattable = pbCynthiaGetThreat(user, opponent, false)
      @damageinfo[user][:info][:opposingThreat] += opponentThreattable[:highestDamage]
      @damageinfo[user][:info][:opposingPhysicalThreat] += opponentThreattable[:physicalDamage]
      @damageinfo[user][:info][:opposingSpecialThreat] += opponentThreattable[:specialDamage]
      @damageinfo[user][:info][:outspeedsopponent] = pbCynthiaCompareSpeed(user, opponent) if @damageinfo[user][:info][:outspeedsopponent]
    end
    userhp = 100.0 * user.adjustedTotalhp / user.totalhp
    userhp = userhp - @damageinfo[user][:info][:opposingThreat] if !@damageinfo[user][:info][:outspeedsopponent]
    @damageinfo[user][:info][:userdamagethreshold] = (userhp / @damageinfo[user][:info][:opposingThreat]).ceil - 1
    @damageinfo[user][:info][:opposingdamagethreshold] = (100.0 / @damageinfo[user][:info][:userThreat]).ceil - 1
    @damageinfo[user][:info][:damagethreshold] = [@damageinfo[user][:info][:userdamagethreshold], @damageinfo[user][:info][:opposingdamagethreshold]].min
    return @damageinfo[user]
  end

  def pbCynthiaGetMoveScoreStatus(move,user,target)
    skill = 100 #temporary
    damageinfo = pbCynthiaGetDamageInfo(user, target)
    score = [100.0 * [user.hp, user.totalhp].max / user.totalhp / 2 - damageinfo[:info][:opposingThreat], 1.0].max
    # movedamage = 0
    # movedamage = pbCynthiaGetThreat(user, target, false)[:moves][move][:minDamage] if target != user
    movefunction = move.function
    if movefunction == "188"
      movefunction += move.type.to_s
    end
    case movefunction
    #---------------------------------------------------------------------------
    when "000", "001", "002", "017", "048", "06A", "06B", "06C", "06D", "06E", "06F", "075", "076", "077", "079", "07A", "07B", "07E", "07F", "080", "085", "086", "087", "088", "089", "08A", "08B", "08C", "08D", "08E", "08F", "090", "091", "094", "095", "096", "097", "098", "099", "09A", "09B", "09F", "0A0", "0A4", "0A5", "0A9", "0BD", "0BF", "0C0", "0C1", "0C3", "0EE", "106", "107", "108", "109", "122", "133", "134", "144", "157", "164", "166", "169", "177", "178", "185", "192" ,"195", "207"  # No extra effect
      score = 0
    #---------------------------------------------------------------------------
    when "003", "004" #sleep
      sleepturns = [damageinfo[:info][:damagethreshold], 4].min
      score = sleepturns * damageinfo[:info][:userThreat] / 3.0
      score += 100 * sleepturns / 3.0
      score += 100 * sleepturns / 3.0 if [:Snow, :Hail].include?(@battle.pbWeather)
      score += 100 * sleepturns / 8.0 if user.hasActiveAbility?(:BADDREAMS)
      score = 0 if target.effects[PBEffects::Yawn]>0
      score = 0 if target.hasActiveAbility?([:GUTS, :QUICKFEET])
      score = 0 if target.hasActiveAbility?(:MARVELSCALE) && damageinfo[:info][:userPhysicalThreat] > damageinfo[:info][:userSpecialThreat]
      score = 0 if target.pbHasMoveFunction?("011","0B4", "0D9", "191")
      score = 0 if !target.pbCanSleep?(user,false)
    # #---------------------------------------------------------------------------
    when "005", "006", "0BE", "159" #poison
      score = 100 * [damageinfo[:info][:damagethreshold], 1].max / 8.0
      score = 100 * (0..[damageinfo[:info][:damagethreshold], 1].max).sum / 16.0 if movefunction == 006 || @battle.pbWeather == :Sandstorm
      score = 0 if target.effects[PBEffects::Yawn]>0 
      score = 0 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:TOXICBOOST,:QUICKFEET, :POISONHEAL, :MAGICGUARD])
      score = 0 if target.pbHasMoveFunction?("0D9", "191")
      score = 0 if !target.pbCanPoison?(user,false)
      score = 0 if target.hasActiveAbility?(:SYNCHRONIZE) && user.pbCanPoisonSynchronize?(target)
      score = 0 if target.pbHasType?(:POISON) || target.pbHasType?(:STEEL)
      score += pbCynthiaCalculateStatScore([[:SPEED, -1]], user, target) if movefunction == "159"
    #---------------------------------------------------------------------------
    when "007", "008", "009", "0C5", "0FD" #paralyze
      score = 100 * damageinfo[:info][:damagethreshold] / 4.0
      score += damageinfo[target][:targetThreat] if !damageinfo[:info][:outspeedstarget] && target.pbSpeed / 4 < user.pbSpeed
      score = 0 if target.effects[PBEffects::Yawn]>0
      score = 0 if !target.pbCanParalyze?(user,false)
      score = 0 if move.id == :THUNDERWAVE && Effectiveness.ineffective?(pbCalcTypeMod(move.type,user,target))
      score = 0 if target.hasActiveAbility?([:QUICKFEET, :MARVELSCALE, :GUTS])
      score = 0 if target.pbHasMoveFunction?("0D9", "191")
      score = 0 if target.hasActiveAbility?(:SYNCHRONIZE) && user.pbCanParalyzeSynchronize?(target)
      score = 0 if @battle.field.effects[PBEffects::TrickRoom]
    #---------------------------------------------------------------------------
    when "00A", "00B", "0C6", "201", "204", "218" #burn todo better damage calcs
      score = 100 * [damageinfo[:info][:damagethreshold], 1].max / 16.0
      score = 0 if target.hasActiveAbility?(:MAGICGUARD)
      score += (damageinfo[target][:targetPhysicalThreat] - [damageinfo[target][:targetPhysicalThreat] / 2.0, damageinfo[target][:targetSpecialThreat]].max) * damageinfo[:info][:damagethreshold]
      if movefunction == "218"
        raisedstat = false
        GameData::Stat.each_battle { |s| raisedstat = true if target.stages[s.id] > 0 }
        score = 0 if !raisedstat
      end
      score = 0 if target.effects[PBEffects::Yawn]>0
      score = 0 if !target.pbCanBurn?(user,false)
      score = 0 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET,:FLAREBOOST, :WILDFIRE])
      score = 0 if target.pbHasMoveFunction?("0D9", "191")
      score = 0 if (target.hasActiveAbility?(:SYNCHRONIZE) && user.pbCanBurnSynchronize?(target))
      score = 0 if target.pbHasType?(:FIRE)
    #---------------------------------------------------------------------------
    when "00C", "00D", "00E", "135", "187", "224" #frostbite todo better damage calcs
      score = 100 * [damageinfo[:info][:damagethreshold], 1].max / 16.0
      score = 0 if target.hasActiveAbility?(:MAGICGUARD)
      score += (damageinfo[target][:targetSpecialThreat] - [damageinfo[target][:targetSpecialThreat] / 2.0, damageinfo[target][:targetPhysicalThreat]].max) * damageinfo[:info][:damagethreshold]
      score = 0 if target.effects[PBEffects::Yawn]>0
      score = 0 if !target.pbCanFreeze?(user,false)
      score = 0 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET, :ICEBODY])
      score = 0 if target.pbHasMoveFunction?("0D9")
      score = 0 if target.pbHasType?(:ICE)
    #---------------------------------------------------------------------------
    when "00F", "010", "011"
      score = 0
      score += damageinfo[target][:targetThreat] if damageinfo[:info][:outspeedstarget]
      score = 0 if target.hasActiveAbility?([:INNERFOCUS, :STEADFAST])
      score = 0 if (target.effects[PBEffects::Substitute] || target.effects[PBEffects::RedstoneCube]) && !move.ignoresSubstitute?(user)
    #---------------------------------------------------------------------------
    when "012"
      score = damageinfo[target][:targetThreat]
      score = 0 if target.hasActiveAbility?([:INNERFOCUS, :STEADFAST])
      score = 0 if (target.effects[PBEffects::Substitute] || target.effects[PBEffects::RedstoneCube]) && !move.ignoresSubstitute?(user)
      score = -100 if !(user.turnCount==0)
    #---------------------------------------------------------------------------
    when "013", "014", "015", "040", "041", "217"
      score = 100 * [damageinfo[:info][:damagethreshold], 2].min / 3.0
      if movefunction == "217"
        raisedstat = false
        GameData::Stat.each_battle { |s| raisedstat = true if target.stages[s.id] > 0 }
        score = 0 if !raisedstat
      end
      score = 0 if !target.pbCanConfuse?(user,false,move)
    #---------------------------------------------------------------------------
    when "016"
      score = 100 * damageinfo[:info][:damagethreshold] / 2.0
      score = 0 if !target.pbCanAttract?(user,false)
      score = 0 if target.hasActiveItem?(:DESTINYKNOT) && user.pbCanAttract?(target,false)
    #---------------------------------------------------------------------------
    when "018" #todo
      score = 0 if ![:POISON, :BURN, :PARALYSIS].include?(user.status)
    #---------------------------------------------------------------------------
    when "019", "191" #todo
      score = 0
      @battle.pbParty(user.index).each do |pkmn|
        score += 20 if pkmn && pkmn.status != :NONE
      end
    #---------------------------------------------------------------------------
    when "01A" #todo
      score = 0 if user.pbOwnSide.effects[PBEffects::Safeguard]>0
      score = 0 if user.status != :NONE
    #---------------------------------------------------------------------------
    when "01B" #todo
      score *= 1.5
      score = 0 if user.status == :NONE
      score = 0 if !target.pbCanInflictStatus?(user.status, user, false, move)
    #---------------------------------------------------------------------------
    when "01C", "029", "188FIGHTING"
      score = pbCynthiaCalculateStatScore([[:ATTACK, 1]], user, user)
      if user.pbHasMove?(:POPULATIONBOMB) && user.stages[:ACCURACY] == 0
        score += 100
      end
    #---------------------------------------------------------------------------
    when "01D", "01E", "0C8", "188STEEL"
      score = pbCynthiaCalculateStatScore([[:DEFENSE, 1]], user, user)
    #---------------------------------------------------------------------------
    when "01F", "188FLYING"
      score = pbCynthiaCalculateStatScore([[:SPEED, 1]], user, user)
    #---------------------------------------------------------------------------
    when "020", "188POISON"
      score = pbCynthiaCalculateStatScore([[:SPECIAL_ATTACK, 1]], user, user)
    #---------------------------------------------------------------------------
    when "021", "188GROUND"
      score = pbCynthiaCalculateStatScore([[:SPECIAL_DEFENSE, 1]], user, user)
      #todo charge
    #---------------------------------------------------------------------------
    when "022"
      score = [score, 66 - damageinfo[:info][:opposingThreat]].max()
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
      score = [score, 100 - damageinfo[:info][:opposingThreat]].max()
      score *= 0.5 if !damageinfo[:info][:outspeedsopponent]
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
      score = pbCynthiaCalculateStatScore([[:ATTACK, 1], [:DEFENSE, 1]], user, user)
    #---------------------------------------------------------------------------
    when "026"
      score = pbCynthiaCalculateStatScore([[:ATTACK, 1], [:SPEED, 1]], user, user)
    #---------------------------------------------------------------------------
    when "027", "028"
      score = pbCynthiaCalculateStatScore([[:ATTACK, 1], [:SPECIAL_ATTACK, 1]], user, user)
    #---------------------------------------------------------------------------
    when "02A"
      score = pbCynthiaCalculateStatScore([[:DEFENSE, 1], [:SPECIAL_DEFENSE, 1]], user, user)
    #---------------------------------------------------------------------------
    when "02B"
      score = pbCynthiaCalculateStatScore([[:SPEED, 1], [:SPECIAL_ATTACK, 1], [:SPECIAL_DEFENSE, 1]], user, user)
    #---------------------------------------------------------------------------
    when "02C"
      score = pbCynthiaCalculateStatScore([[:SPECIAL_ATTACK, 1], [:SPECIAL_DEFENSE, 1]], user, user)
    #---------------------------------------------------------------------------
    when "02D"
      score = [score, 100 - damageinfo[:info][:opposingThreat]].max()
    #---------------------------------------------------------------------------
    when "02E"
      score = pbCynthiaCalculateStatScore([[:ATTACK, 2]], user, user)
    #---------------------------------------------------------------------------
    when "02F", "136"
      score = pbCynthiaCalculateStatScore([[:DEFENSE, 2]], user, user)
    #---------------------------------------------------------------------------
    when "030", "031"
      score = pbCynthiaCalculateStatScore([[:SPEED, 2]], user, user)
    #---------------------------------------------------------------------------
    when "032"
      score = pbCynthiaCalculateStatScore([[:SPECIAL_ATTACK, 2]], user, user)
    #---------------------------------------------------------------------------
    when "033"
      score = pbCynthiaCalculateStatScore([[:SPECIAL_DEFENSE, 2]], user, user)
    #---------------------------------------------------------------------------
    when "034"
      score = [score, 66 - damageinfo[:info][:opposingThreat]].max()
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
      score = pbCynthiaCalculateStatScore([[:ATTACK, 2], [:DEFENSE, -1], [:SPEED, 2], [:SPECIAL_ATTACK, 2], [:SPECIAL_DEFENSE, -1]], user, user)
    #---------------------------------------------------------------------------
    when "036"
      score = pbCynthiaCalculateStatScore([[:ATTACK, 1], [:SPEED, 2]], user, user)
    #---------------------------------------------------------------------------
    when "037"
      statscore = 0
      statamount = 0.0
      [[:ATTACK, 2], [:DEFENSE, 2], [:SPEED, 2], [:SPECIAL_ATTACK, 2], [:SPECIAL_DEFENSE, 2]].each do |stat|
        currentstat = pbCynthiaCalculateStatScore([stat], user, user)
        next if currentstat == 0
        statscore += currentstat
        statamount += 1
      end #todo evasion/accuracy
      score = statscore / statamount
    #---------------------------------------------------------------------------
    when "038"
      score = pbCynthiaCalculateStatScore([[:DEFENSE, 3]], user, user)
    #---------------------------------------------------------------------------
    when "039"
      score = pbCynthiaCalculateStatScore([[:SPECIAL_ATTACK, 3]], user, user)
    #---------------------------------------------------------------------------
    when "03A"
      score = pbCynthiaCalculateStatScore([[:ATTACK, 12]], user, user)
      score -= 50
    #---------------------------------------------------------------------------
    when "03B"
      score = pbCynthiaCalculateStatScore([[:ATTACK, -1], [:DEFENSE, -1]], user, user)
    #---------------------------------------------------------------------------
    when "03C"
      score = pbCynthiaCalculateStatScore([[:DEFENSE, -1], [:SPECIAL_DEFENSE, -1]], user, user)
    #---------------------------------------------------------------------------
    when "03D"
      score = pbCynthiaCalculateStatScore([[:DEFENSE, -1], [:SPEED, -1], [:SPECIAL_DEFENSE, -1]], user, user)
    #---------------------------------------------------------------------------
    when "03E"
      score = pbCynthiaCalculateStatScore([[:SPEED, -1]], user, user)
    #---------------------------------------------------------------------------
    when "03F"
      score = pbCynthiaCalculateStatScore([[:SPECIAL_ATTACK, -2]], user, user)
      score = 0 if user.effects[PBEffects::FocusEnergy]>= 2 && user.hasActiveItem?(:SCOPELENS)
    #---------------------------------------------------------------------------
    when "042", "188DRAGON"
      score = pbCynthiaCalculateStatScore([[:ATTACK, -1]], user, target)
    #---------------------------------------------------------------------------
    when "043", "188GHOST", "216", "221"
      score = pbCynthiaCalculateStatScore([[:DEFENSE, -1]], user, target)
    #---------------------------------------------------------------------------
    when "044", "188NORMAL"
      score = pbCynthiaCalculateStatScore([[:SPEED, -1]], user, target)
    #---------------------------------------------------------------------------
    when "045", "188BUG"
      score = pbCynthiaCalculateStatScore([[:SPECIAL_ATTACK, -1]], user, target)
    #---------------------------------------------------------------------------
    when "046", "188DARK"
      score = pbCynthiaCalculateStatScore([[:SPECIAL_DEFENSE, -1]], user, target)
    #---------------------------------------------------------------------------
    when "047"
      score *= (6 - target.stages[:ACCURACY]) / 6.0
      score *= 0.5
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
      score = pbCynthiaCalculateStatScore([[:ATTACK, -1], [:DEFENSE, -1]], user, target)
    #---------------------------------------------------------------------------
    when "04B"
      score = pbCynthiaCalculateStatScore([[:ATTACK, -2]], user, target)
    #---------------------------------------------------------------------------
    when "04C"
      score = pbCynthiaCalculateStatScore([[:DEFENSE, -2]], user, target)
    #---------------------------------------------------------------------------
    when "04D"
      score = pbCynthiaCalculateStatScore([[:SPEED, -2]], user, target)
    #---------------------------------------------------------------------------
    when "04E"
      score = pbCynthiaCalculateStatScore([[:SPECIAL_ATTACK, -2]], user, target)
    #---------------------------------------------------------------------------
    when "04F"
      score = pbCynthiaCalculateStatScore([[:SPECIAL_DEFENSE, -2]], user, target)
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
      score = 0
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
      score = 0 if user.hp>=(user.hp+target.hp)/2
      score = 0 if target.effects[PBEffects::Substitute]>0
    #---------------------------------------------------------------------------
    when "05B"
      score = 100 if @battle.sideSizes[0]>=2 || @battle.sideSizes[1]>=2
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
      if target.unstoppableAbility? || [:TRUANT, :SIMPLE].include?(target.ability_id)
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
      if target.ability_id == :TRUANT && user.opposes?(target)
        score -= 90
      elsif target.ability_id == :SLOWSTART && user.opposes?(target)
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "066" #todo
      score = 0 if !user.hasActiveAbility?([:TRUANT, :SLOWSTART])
      score = 100 if user.pbHasType?(:GHOST) && user.hasActiveAbility?(:NORMALIZE) && damageinfo[:info][:outspeedsopponent]
      score = 0 if target.effects[PBEffects::Substitute]>0
      score = 0 if !user.ability || user.ability==target.ability ||
        [:MULTITYPE, :RKSSYSTEM, :TRUANT].include?(target.ability_id) ||
        [:FLOWERGIFT, :FORECAST, :ILLUSION, :IMPOSTER, :MULTITYPE, :RKSSYSTEM,
         :TRACE, :ZENMODE].include?(user.ability_id)
    #---------------------------------------------------------------------------
    when "067" #todo
      score -= 40   # don't prefer this move
      if (!user.ability && !target.ability) ||
         user.ability==target.ability ||
         [:ILLUSION, :MULTITYPE, :RKSSYSTEM, :WONDERGUARD].include?(user.ability_id) ||
         [:ILLUSION, :MULTITYPE, :RKSSYSTEM, :WONDERGUARD].include?(target.ability_id)
        score -= 90
      end
      if target.ability_id == :TRUANT && user.opposes?(target)
        score -= 90
      elsif target.ability_id == :SLOWSTART && user.opposes?(target)
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
      score = 0
      score = 100 if user.hasActiveAbility?(:NOGUARD)
      score = 100 if target.hasActiveAbility?(:NOGUARD)
      score = -100 if target.hasActiveAbility?(:STURDY)
      score = -100 if target.level>user.level
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
    when "092"
      score = [50 - damageinfo[:info][:opposingThreat], 0].min
    #---------------------------------------------------------------------------
    when "093" #todo
      score += 25 if user.effects[PBEffects::Rage]
    #---------------------------------------------------------------------------
    when "09C"
      score = 0
      user.eachAlly do |b|
        score = [score, pbCynthiaGetThreat(b, b)[:highestDamage] * 0.3].max
        score *= 2 if pbCynthiaCompareSpeed(b, user)
        break
      end
    #---------------------------------------------------------------------------
    when "0A1"
      score = 0 if user.pbOwnSide.effects[PBEffects::LuckyChant]>0
    #---------------------------------------------------------------------------
    when "0A2", "190" #TODO
      score *= 2 if user.hasActiveItem?(:LIGHTCLAY)
      score *= 2 if damageinfo[:info][:opposingMaxThreat] == damageinfo[:info][:opposingMaxPhysicalThreat]
      user.eachOpposing do |b|
        score = 0 if b.pbHasMove?(:BRICKBREAK) || b.pbHasMove?(:PSYCHICFANGS) || b.pbHasMove?(:DEFOG)
      end
      score = 0 if user.pbOwnSide.effects[PBEffects::Reflect]>0
    #---------------------------------------------------------------------------
    when "0A3", "189" #TODO
      score *= 2 if user.hasActiveItem?(:LIGHTCLAY)
      score *= 2 if damageinfo[:info][:opposingMaxThreat] == damageinfo[:info][:opposingMaxSpecialThreat]
      user.eachOpposing do |b|
        score = 0 if b.pbHasMove?(:BRICKBREAK) || b.pbHasMove?(:PSYCHICFANGS) || b.pbHasMove?(:DEFOG)
      end
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
      lastmovescore = 0
      moveID = @battle.lastMoveUsed
      if moveID
        calledmove = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(moveID))
        if !blacklist.include?(calledmove.function)
          lastmovescore = pbCynthiaRegisterMove(user, calledmove, nil, true)
        end
      end
      if damageinfo[:info][:outspeedsopponent]
        score = lastmovescore
      else
        user.eachOpposing do |opponent|
          opponent.moves.each do |opponentmove|
            if !blacklist.include?(opponentmove.function)
              moveID = opponentmove.id
              calledmove = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(moveID))
              score = [score, pbCynthiaRegisterMove(user, calledmove, nil, true)].max
            end
          end
        end
      end
      score -= 1
      score = 0 if lastmovescore == 0
    #---------------------------------------------------------------------------
    when "0B0" #todo
    #---------------------------------------------------------------------------
    when "0B1" #todo
    #---------------------------------------------------------------------------
    when "0B2" #todo
    #---------------------------------------------------------------------------
    when "0B3" #todo?
    #---------------------------------------------------------------------------
    when "0B4", "210" #todo
      if user.asleep?
        score += 100   # Because it can only be used while asleep
      else
        score -= 90
      end
      score += 10 if movefunction == "210"
    #---------------------------------------------------------------------------
    when "0B5" #todo
    #---------------------------------------------------------------------------
    when "0B6"
      score = rand(50)
    #---------------------------------------------------------------------------
    when "0B7" #todo
      score -= 90 if target.effects[PBEffects::Torment]
    #---------------------------------------------------------------------------
    when "0B8"
      score = 0
      user.eachOpposing do |opponent|
        totalthreat = 0
        opponentmoves = pbCynthiaGetThreat(user, opponent, false)[:moves]
        opponentmoves.each do |opponentmove, damagetable|
          totalthreat += damagetable[:maxDamage]
        end
        opponentmoves.each do |opponentmove, damagetable|
          score += 10 + (100.0 * damagetable[:maxDamage] / totalthreat) if user.pbHasMove?(opponentmove.id)
        end
      end
      score = 0 if user.effects[PBEffects::Imprison]
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
      score = 1 #todo
      score = 1 if !damageinfo[:info][:outspeedsopponent]
      score = 0 if target.effects[PBEffects::Encore]>0
      score = 0 if !target.lastRegularMoveUsed
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
    when "0CF", "0D0" #todo 
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
    when "0D5", "0D6", "16D", "0D8"
      healamount = 50.0
      healamount = 66.6 if [:Sandstorm].include?(@battle.pbWeather) && movefunction == "16D"
      if movefunction == "0D8"
        healamount = 25.0
        healamount = 50.0 if [:None, :StrongWinds].include?(@battle.pbWeather)
        healamount = 66.6 if [:Sun, :HarshSun].include?(@battle.pbWeather)
      end
      healamount -= 5
      missinghp = 100.0 * (user.adjustedTotalhp - user.hp) / user.adjustedTotalhp
      missinghp += damageinfo[:info][:opposingMaxThreat] if !damageinfo[:info][:outspeedsopponent]
      score = (2 - (damageinfo[:info][:opposingMaxThreat] / [healamount, missinghp].min)) ** 2 * [healamount, missinghp].min
      score = 1 if damageinfo[:info][:opposingMaxThreat] > healamount
      score = 1 if [healamount, missinghp].min < healamount / 1.5
      score = 1 if user.hp > user.adjustedTotalhp * 3 / 4.0
      score = 0 if !user.canHeal?
      score = 0 if user.hp == user.adjustedTotalhp
    #---------------------------------------------------------------------------
    when "0D7"
      healamount = 45.0
      missinghp = 100.0 * (user.adjustedTotalhp - user.hp) / user.adjustedTotalhp
      missinghp += damageinfo[:info][:opposingMaxThreat] if !damageinfo[:info][:outspeedsopponent]
      score = (2 - (damageinfo[:info][:opposingMaxThreat] / [healamount, missinghp].min)) ** 2 * [healamount, missinghp].min
      score = 1 if damageinfo[:info][:opposingMaxThreat] > healamount
      score = 1 if [healamount, missinghp].min < healamount / 2.0
      score = 1 if missinghp + damageinfo[:info][:opposingMaxThreat] > user.adjustedTotalhp && !(user.pbHasMove?(:PROTECT) || user.pbHasMove?(:DETECT))
      score = 0 if !user.canHeal?
      score = 0 if user.hp == user.adjustedTotalhp
      score = 0 if @battle.positions[user.index].effects[PBEffects::Wish]>0
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
    when "0DA"
      score = 100 * damageinfo[:info][:damagethreshold] / 16.0
      score *= 1.3 if user.hasActiveItem?(:BIGROOT)
      score = 0 if user.effects[PBEffects::HealBlock]
      score = 0 if user.effects[PBEffects::AquaRing]
    #---------------------------------------------------------------------------
    when "0DB" #todo switch move check
      score = 100 * damageinfo[:info][:damagethreshold] / 16.0
      score *= 1.3 if user.hasActiveItem?(:BIGROOT)
      score = 0 if user.effects[PBEffects::HealBlock]
      score = 0 if user.effects[PBEffects::Ingrain]
    #---------------------------------------------------------------------------
    when "0DC", "184" #todo more properly
      score = 100 * ([damageinfo[:info][:damagethreshold], 1].max + 1) / 2.5
      if !target.hasActiveAbility?(:LIQUIDOOZE)
        score *= 1.15 if user.hasActiveItem?(:BIGROOT) && !user.effects[PBEffects::HealBlock]
        score /= 2.0 if user.effects[PBEffects::HealBlock]
      else
        score /= 1.15 if user.hasActiveItem?(:BIGROOT)
        score /= 4.0
      end
      score /= [damageinfo[:info][:damagethreshold], 1].max / 2.0 if target.pbHasMove?(:RAPIDSPIN)
      score = 0 if target.hasActiveAbility?(:MAGICGUARD)
      score = 0 if target.pbHasType?(:GRASS)
      score = 0 if target.effects[PBEffects::LeechSeed] > -1
    #---------------------------------------------------------------------------
    when "0DD" #todo
      score = 0
      score = 10 if user.hp < user.adjustedTotalhp
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
      score = damageinfo[:info][:opposingThreat]
      score = -(damageinfo[:info][:userThreat] - 1) if (damageinfo[:info][:opposingThreat] < 100 && damageinfo[:info][:outspeedsopponent]) || (damageinfo[:info][:opposingThreat] < 50 && !damageinfo[:info][:outspeedsopponent])
    #---------------------------------------------------------------------------
    when "0E1" #todo
      score = damageinfo[:info][:opposingThreat]
      score = -(damageinfo[:info][:userThreat] - 1) if (damageinfo[:info][:opposingThreat] < 100 && damageinfo[:info][:outspeedsopponent]) || (damageinfo[:info][:opposingThreat] < 50 && !damageinfo[:info][:outspeedsopponent])
    #---------------------------------------------------------------------------
    when "0E2" #todo
      score = damageinfo[:info][:opposingThreat]
      score = -(damageinfo[:info][:userThreat] - 1) if (damageinfo[:info][:opposingThreat] < 100 && damageinfo[:info][:outspeedsopponent]) || (damageinfo[:info][:opposingThreat] < 50 && !damageinfo[:info][:outspeedsopponent])
    #---------------------------------------------------------------------------
    when "0E3", "0E4"
      score = damageinfo[:info][:opposingThreat]
      score = -(damageinfo[:info][:userThreat] - 1) if (damageinfo[:info][:opposingThreat] < 100 && damageinfo[:info][:outspeedsopponent]) || (damageinfo[:info][:opposingThreat] < 50 && !damageinfo[:info][:outspeedsopponent])
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
      score = 0 if (damageinfo[:info][:opposingThreat] < 100 && damageinfo[:info][:outspeedsopponent]) || (damageinfo[:info][:opposingThreat] < 50 && !damageinfo[:info][:outspeedsopponent])
    #---------------------------------------------------------------------------
    when "0E8" #todo
      score = 1
      score = 0 if damageinfo[:info][:opposingThreat] < 100
      user.eachAlly do |ally|
        score = 201 if ally.hasActiveAbility?([:EXPLOSIVE, :CHARGEDEXPLOSIVE])
      end
      score = 1 if user.effects[PBEffects::ProtectRate]>1
      score = 0 if target.effects[PBEffects::HyperBeam]>0
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
      score = 1
    #---------------------------------------------------------------------------
    when "0EB" #todo
      score = damageinfo[:info][:opposingThreat] / 3
      score += 10 if target.pbOwnSide.effects[PBEffects::Spikes]>0
      score += 10 if target.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
      score += 10 if target.pbOwnSide.effects[PBEffects::StealthRock]
      score = 0 if target.effects[PBEffects::Ingrain] || target.hasActiveAbility?(:SUCTIONCUPS)
      ch = 0
      @battle.pbParty(target.index).each_with_index do |pkmn,i|
        ch += 1 if @battle.pbCanSwitchLax?(target.index,i)
      end
      score = 0 if ch==0
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
    when "0F0", "202" #todo
      score *= 3 if target.hasActiveItem?([:LIGHTBALL, :THICKCLUB, :PYRITE, :EVIOLITE, :REAPERCLOTH])
      score *= 2 if target.hasActiveItem?([:LEFTOVER, :CHOICEBAND, :CHOICESPECS, :LIFEORB, :ASSAULTVEST, :METRONOME])
      score = 1 if target.hasActiveItem?([:POWERHERB, :ENDCRYSTAL]) #todo add more consumables
      score = 1 if target.hasActiveAbility?([:UNBURDEN])
      score = 0 if !target.item
      score = 0 if target.unlosableItem?(target.item)
      score = 0 if target.hasActiveAbility?(:STICKYHOLD) && !user.hasMoldBreaker?
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
    when "0FE" #todo
      score -= 30
      if target.pbCanBurn?(user,false)
        score += 30
        score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET,:FLAREBOOST])
      end
    #---------------------------------------------------------------------------
    when "0FF", "188FIRE", "09D" #todo
      score *= 2 if user.hasActiveItem?(:HEATROCK)
      party = @battle.pbParty(user.index)
      party.each do |pkmn|
        next if !pkmn || !pkmn.fainted?
        score *= 2 if pkmn.hasAbility?([:CHLOROPHYLL, :HARVEST, :FLOWERGIFT, :FORECAST, :LEAFGUARD, :SOLARPOWER, :PROTOSYNTHESIS, :ORICHALCUMPULSE])
        score *= 1.5 if pkmn.hasType?(:FIRE)
        score *= 1.5 if pkmn.hasMove?(:SOLARBEAM) || pkmn.hasMove?(:SOLARBLADE) || pkmn.hasMove?(:GROWTH) || pkmn.hasMove?(:WEATHERBALL) || pkmn.hasMove?(:MOONLIGHT) || pkmn.hasMove?(:SYNTHESIS) || pkmn.hasMove?(:MORNINGSUN)
      end
      score *= 2 if @battle.pbWeather == :Rain
      user.eachOpposing do |opponent|
        score *= 2 if opponent.pbHasType?(:WATER) && damageinfo[:info][:outspeedsopponent]
      end
      score = 0 if @battle.pbCheckGlobalAbility(:AIRLOCK) || @battle.pbCheckGlobalAbility(:CLOUDNINE) || @battle.pbWeather == :Sun || @battle.pbWeather == :HarshSun
    #---------------------------------------------------------------------------
    when "100", "188WATER", "09E" #todo
      score *= 2 if user.hasActiveItem?(:DAMPROCK)
      party = @battle.pbParty(user.index)
      party.each do |pkmn|
        next if !pkmn || !pkmn.fainted?
        score *= 2 if pkmn.hasAbility?([:SWIFTSWIM, :DRYSKIN, :FORECAST, :HYDRATION, :RAINDISH])
        score *= 1.5 if pkmn.hasType?(:WATER)
        score *= 1.5 if pkmn.hasMove?(:THUNDER) || pkmn.hasMove?(:HURRICANE) || pkmn.hasMove?(:BLEAKWINDSTORM) || pkmn.hasMove?(:WILDBOLTSTORM) || pkmn.hasMove?(:SANDSEARSTORM) || pkmn.hasMove?(:WEATHERBALL) || pkmn.hasMove?(:ELECTROSHOT)
      end
      score *= 2 if @battle.pbWeather == :Sun
      score = 0 if @battle.pbCheckGlobalAbility(:AIRLOCK) || @battle.pbCheckGlobalAbility(:CLOUDNINE) || @battle.pbWeather == :Rain || @battle.pbWeather == :HeavyRain
    #---------------------------------------------------------------------------
    when "101", "188ROCK" #todo
      score *= 2 if user.hasActiveItem?(:SMOOTHROCK)
      party = @battle.pbParty(user.index)
      party.each do |pkmn|
        next if !pkmn || !pkmn.fainted?
        score *= 2 if pkmn.hasAbility?([:SANDRUSH, :SANDFORCE, :SANDVEIL])
        score *= 1.5 if pkmn.hasType?(:ROCK)
        score *= 1.5 if pkmn.hasMove?(:WEATHERBALL) || pkmn.hasMove?(:SHOREUP)
      end
      score = 0 if @battle.pbCheckGlobalAbility(:AIRLOCK) || @battle.pbCheckGlobalAbility(:CLOUDNINE) || @battle.pbWeather == :Sandstorm
    #---------------------------------------------------------------------------
    when "102", "179", "188ICE", "196"
      score *= 2 if user.hasActiveItem?(:ICYROCK)
      party = @battle.pbParty(user.index)
      party.each do |pkmn|
        next if !pkmn || !pkmn.fainted?
        score *= 2 if pkmn.hasAbility?([:SLUSHRUSH, :ICEBODY, :SNOWCLOAK, :FORECAST, :ICEFACE])
        score *= 1.5 if pkmn.hasType?(:ICE)
        score *= 1.5 if pkmn.hasMove?(:WEATHERBALL) || pkmn.hasMove?(:BLIZZARD) || pkmn.hasMove?(:AURORAVEIL)
      end
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
      canChoose = false
      user.eachOpposing do |b|
        next if !@battle.pbCanChooseNonActive?(b.index)
        canChoose = true
        break
      end
      score = 10*@battle.pbAbleNonActiveCount(user.idxOpposingSide)
      score = 0 if !canChoose
      score = 0 if user.pbOpposingSide.effects[PBEffects::StealthRock]
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
      score = 100 if damageinfo[:info][:opposingMaxThreat] < 25
      user.eachOpposing do |b|
        score = 0 if b.hasActiveAbility?(:INFILTRATOR)
      end
      score = 0 if user.hp <= user.totalhp/4
      score = 0 if damageinfo[:info][:opposingMaxThreat] >= 25 || user.effects[PBEffects::Substitute]>0
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
        score = pbCynthiaCalculateStatScore([[:ATTACK, 1], [:DEFENSE, 1], [:SPEED, -1]], user, user)
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
      score = 0
      score += 30 if user.effects[PBEffects::Trapping]>0
      score += 30 if user.effects[PBEffects::LeechSeed]>=0
      if @battle.pbAbleNonActiveCount(user.idxOwnSide)>0
        score += 80 if user.pbOwnSide.effects[PBEffects::Spikes]>0
        score += 80 if user.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
        score += 80 if user.pbOwnSide.effects[PBEffects::StealthRock]
      end
    #---------------------------------------------------------------------------
    when "111" #todo
      score = -16
      if @battle.positions[target.index].effects[PBEffects::FutureSightCounter]>0
        score -= 100
      elsif @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
        # Future Sight tends to be wasteful if down to last Pokemon
        score -= 70
      end
    #---------------------------------------------------------------------------
    when "112"
      score = pbCynthiaCalculateStatScore([[:DEFENSE, 1], [:SPECIAL_DEFENSE, 1]], user, user)
      score = 0 if user.effects[PBEffects::Stockpile]>=3
    #---------------------------------------------------------------------------
    when "113" #todo
      score = -100 if user.effects[PBEffects::Stockpile]==0
    #---------------------------------------------------------------------------
    when "114" #todo
      score = -100 if user.effects[PBEffects::Stockpile]==0
      if user.hp==user.totalhp
        score -= 90
      else
        mult = [0,25,50,100][user.effects[PBEffects::Stockpile]]
        score += mult
        score -= user.hp*mult*2/user.totalhp
      end
    #---------------------------------------------------------------------------
    when "115" #todo
      score = -100
      score = 0 if user.effects[PBEffects::Substitute] || user.effects[PBEffects::RedstoneCube]
      score = 0 if damageinfo[:info][:opposingThreat] == 0
    #---------------------------------------------------------------------------
    when "116" #todo?
      score = 0
    #---------------------------------------------------------------------------
    when "117" #todo
      ally = nil
      user.eachAlly do |b|
        ally = b
        break
      end
      allythreat = 0
      if ally && !ally.fainted?
        user.eachOpposing do |b|
          allythreat += pbCynthiaGetThreat(ally, b)[:highestDamage]
        end
        if allythreat > damageinfo[:info][:opposingMaxThreat] * 2
          score = allythreat
        end
      else
        score = 0
      end
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
      score = 101 if !damageinfo[:info][:outspeedsopponent]
      user.eachAlly do |b|
        score = 0 if b.pbHasMove?(:TRICKROOM) && pbCynthiaGetThreat(b, b)[:highestDamage] > damageinfo[:info][:userMaxThreat]
      end
      score = 0 if damageinfo[:info][:outspeedsopponent]
      score = 0 if @battle.field.effects[PBEffects::TrickRoom] > 0
    #---------------------------------------------------------------------------
    when "120" #todo
    #---------------------------------------------------------------------------
    when "121" #todo
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
      score = pbCynthiaCalculateStatScore([[:SPECIAL_DEFENSE, 1]], user, target)
    #---------------------------------------------------------------------------
    when "139"
      score = pbCynthiaCalculateStatScore([[:ATTACK, -1]], user, target)
    #---------------------------------------------------------------------------
    when "13A"
      score = pbCynthiaCalculateStatScore([[:ATTACK, -1], [:SPECIAL_ATTACK, -1]], user, target)
    #---------------------------------------------------------------------------
    when "13B"
      score = pbCynthiaCalculateStatScore([[:DEFENSE, -1]], user, user)
    #---------------------------------------------------------------------------
    when "13C"
      score = pbCynthiaCalculateStatScore([[:SPECIAL_ATTACK, -1]], user, target)
    #---------------------------------------------------------------------------
    when "13D"
      score = pbCynthiaCalculateStatScore([[:SPECIAL_ATTACK, -2]], user, target)
    #---------------------------------------------------------------------------
    when "13E"
      score = 0
      @battle.eachBattler do |b|
        if b.pbHasType?(:GRASS) && !b.airborne?
          score += pbCynthiaCalculateStatScore([[:ATTACK, 1], [:SPECIAL_ATTACK, 1]], user, b)
        end
      end
    #---------------------------------------------------------------------------
    when "13F" #todo
      score = 0
      @battle.eachBattler do |b|
        if b.pbHasType?(:GRASS)
          score = pbCynthiaCalculateStatScore([[:DEFENSE, 1]], user, b)
        end
      end
    #---------------------------------------------------------------------------
    when "140" #todo
      score = 0
      @battle.eachBattler do |b|
        if b.poisoned?
          score = pbCynthiaCalculateStatScore([[:ATTACK, -1], [:SPEED, -1], [:SPECIAL_ATTACK, -1]], user, b)
        end
      end
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
    when "14E"
      score = pbCynthiaCalculateStatScore([[:SPEED, 2], [:SPECIAL_ATTACK, 2], [:SPECIAL_DEFENSE, 2]], user, user)
      score /= 2.0 if !user.hasActiveItem?(:POWERHERB)
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
    when "154", "188ELECTRIC"
      score *= 2 if user.hasActiveItem?(:TERRAINEXTENDER)
      party = @battle.pbParty(user.index)
      party.each do |pkmn|
        next if !pkmn || !pkmn.fainted?
        score *= 1.3 if pkmn.hasType?(:ELECTRIC)
        score *= 1.5 if pkmn.hasItem?(:ELECTRICSEED)
        score *= 2 if pkmn.hasAbility?([:SURGESURFER, :QUARKDRIVE, :HADRONENGINE])
        score *= 1.5 if pkmn.hasMove?(:RISINGVOLTAGE) || pkmn.hasMove?(:TERRAINPULSE) || pkmn.hasMove?(:PSYBLADE)
      end
      score *= 2 if user.effects[PBEffects::Yawn]>0
      score = 0 if @battle.field.terrain == :Electric
    #---------------------------------------------------------------------------
    when "155", "188GRASS"
      score *= 2 if user.hasActiveItem?(:TERRAINEXTENDER)
      party = @battle.pbParty(user.index)
      party.each do |pkmn|
        next if !pkmn || !pkmn.fainted?
        score *= 1.3 if pkmn.hasType?(:GRASS)
        score *= 1.5 if pkmn.hasItem?(:GRASSYSEED)
        score *= 1.5 if pkmn.hasMove?(:GRASSYGLIDE) || pkmn.hasMove?(:TERRAINPULSE)
      end
      score = 0 if @battle.field.terrain == :Grassy
    #---------------------------------------------------------------------------
    when "156", "188FAIRY"
      score *= 2 if user.hasActiveItem?(:TERRAINEXTENDER)
      party = @battle.pbParty(user.index)
      party.each do |pkmn|
        next if !pkmn || !pkmn.fainted?
        score *= 1.5 if pkmn.hasItem?(:MISTYSEED)
        score *= 1.5 if pkmn.hasMove?(:MISTYEXPLOSION) || pkmn.hasMove?(:TERRAINPULSE)
      end
      score *= 2 if user.effects[PBEffects::Yawn]>0
      score = 0 if @battle.field.terrain == :Misty
    #---------------------------------------------------------------------------
    when "158" #todo
      score -= 90 if !user.belched?
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
      score = pbCynthiaCalculateStatScore([[:DEFENSE, -1]], user, user)
    #---------------------------------------------------------------------------
    when "160" #todo
      score = pbCynthiaCalculateStatScore([[:ATTACK, -1]], user, target)
      if score > 0
        score *= 2
        #todo healing
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
      score *= 4
      score *= 2 if user.hasActiveItem?(:LIGHTCLAY)
      score *= 2 if damageinfo[:info][:outspeedsopponent]
      user.eachOpposing do |b|
        score = 0 if b.pbHasMove?(:BRICKBREAK) || b.pbHasMove?(:PSYCHICFANGS) || b.pbHasMove?(:DEFOG)
      end
      score = 0 if user.pbOwnSide.effects[PBEffects::AuroraVeil]>0
      score = 0 if @battle.pbWeather != :Hail && @battle.pbWeather != :Snow
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
      score = 0
      if target.effects[PBEffects::ThroatChop]==0
        user.eachOpposing do |opponent|
          opponent.eachMove do |m|
            next if !m.soundMove?
            score += 25
          end
        end
      end
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
        score -= (user.totalhp-user.hp)*75/user.totalhp if !user.hasActiveAbility?(:MAGICGUARD)
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
    when "173", "188PSYCHIC", "214"
      score *= 2 if user.hasActiveItem?(:TERRAINEXTENDER)
      party = @battle.pbParty(user.index)
      party.each do |pkmn|
        next if !pkmn || !pkmn.fainted?
        score *= 1.5 if pkmn.hasItem?(:PSYCHICSEED)
        score *= 1.3 if pkmn.hasType?(:PSYCHIC)
        score *= 1.5 if pkmn.hasMove?(:EXPANDINGFORCE) || pkmn.hasMove?(:TERRAINPULSE)
      end
      score = 0 if @battle.field.terrain == :Psychic
    #---------------------------------------------------------------------------
    when "174" #todo
      score = -100 if user.turnCount > 0
    #---------------------------------------------------------------------------
    when "175" #todo flinch
      score += 30 if target.effects[PBEffects::Minimize]
    #---------------------------------------------------------------------------
    when "176" #todo flinch
      score = pbCynthiaCalculateStatScore([[:DEFENSE, -1], [:SPEED, 1]], user, user)
    #---------------------------------------------------------------------------
    when "180"
      score = 0
      score = -100 if user.lastRegularMoveUsed == move.id
    #---------------------------------------------------------------------------
    when "181"
      score = pbCynthiaCalculateStatScore([[:ATTACK, 1], [:DEFENSE, 1], [:SPEED, 1], [:SPECIAL_ATTACK, 1], [:SPECIAL_DEFENSE, 1]], user, user)
      score -= 33
    #---------------------------------------------------------------------------
    when "182" #todo
    #---------------------------------------------------------------------------
    when "183" #todo
      score = 1000000
    #---------------------------------------------------------------------------
    when "188" #todo
    #---------------------------------------------------------------------------
    when "193"
      score = 0
      score = -100 if !target.item
    #---------------------------------------------------------------------------
    when "194" #todo
      score = pbCynthiaCalculateStatScore([[:SPECIAL_ATTACK, 1]], user, user)
      score /= 2.0 if !user.hasActiveItem?(:POWERHERB)
    #---------------------------------------------------------------------------
    when "197" #todo
      score = 200
      faintedlist = []
      party = @battle.pbParty(user.index)
      party.each do |pkmn|
        next if !pkmn || !pkmn.fainted?
        faintedlist.append(pkmn)
      end
      #print(faintedlist)
      score = 0 if faintedlist.length == 0
    #---------------------------------------------------------------------------
    when "198" #todo
      score *= 2 if target.pbHasType?(:WATER) || target.pbHasType?(:STEEL)
      score = 0 if target.effects[PBEffects::SaltCure] > 0
    #---------------------------------------------------------------------------
    when "199" #todo
      score *= 2 if user.pbSpeed > target.pbSpeed
    #---------------------------------------------------------------------------
    when "203"
      score = 99 if target.pbSpeed > user.pbSpeed && target.pbSpeed / 4 < user.pbSpeed
      score = 0 if target.effects[PBEffects::Yawn]>0
      score = 0 if !target.pbCanParalyze?(user,false)
      score = 0 if move.id == :THUNDERWAVE && Effectiveness.ineffective?(pbCalcTypeMod(move.type,user,target))
      score = 0 if target.hasActiveAbility?([:QUICKFEET, :MARVELSCALE, :GUTS])
      score = 0 if target.pbHasMoveFunction?("0D9")
      score = 0 if target.hasActiveAbility?(:SYNCHRONIZE) && user.pbCanParalyzeSynchronize?(target)
      score = 0 if @battle.field.effects[PBEffects::TrickRoom]>0
      score = -100 if user.lastRegularMoveUsed == move.id
    #---------------------------------------------------------------------------
    when "205"
      score = pbCynthiaCalculateStatScore([[:ATTACK, 1, :SPEED, 1, :SPECIAL_ATTACK, 1]], user, user)
      score += 50 #todo healing
      score /= 2.0 if !user.hasActiveItem?(:POWERHERB)
    #---------------------------------------------------------------------------
    when "206"
      score *= 2 if user.effects[PBEffects::FocusEnergy] < 3
      score *= 3 if target.hasActiveItem?([:LIGHTBALL, :THICKCLUB, :PYRITE, :EVIOLITE, :REAPERCLOTH])
      score *= 2 if target.hasActiveItem?([:LEFTOVER, :CHOICEBAND, :CHOICESPECS, :LIFEORB, :ASSAULTVEST, :METRONOME])
      score /= 2 if (!target.item) || target.unlosableItem?(target.item)
    #---------------------------------------------------------------------------
    when "208", "209", "211" #todo
      score = 99
    #---------------------------------------------------------------------------
    when "212" #todo
      score *= 3
    #---------------------------------------------------------------------------
    when "215" 
      score = 10 + rand(50) + rand(50)
    #---------------------------------------------------------------------------
    when "223"
      score = 15 + rand(50) + rand(50) + rand(50)
    end
    effectchance = 100
    if move.addlEffect > 0
      effectchance = move.addlEffect
      effectchance = 10 if ["009", "00B", "00E"].include?(movefunction)
      effectchance = 50 if ["216"].include?(movefunction)
      effectchance = move.pbAdditionalEffectChance(user,target, effectchance)
    end
    effectchance = effectchance * [pbRoughAccuracy(move,user,target,100), 100].min / 100.0 if !move.statusMove? && !user.hasActiveAbility?(:NOGUARD) && !target.hasActiveAbility?(:NOGUARD)
    score = score * effectchance / 100.0 if score > 0
    return score
  end

    
  def pbCynthiaCalcDamage(move,user,target,tera=nil)
    damagedictionary = {
      :minDamage => 0,
      #:averageDamage => 0,
      :maxDamage => 0,
      #:critDamage => 0,
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
      key = :critDamage if user.hasActiveItem?(:LEEK) || user.hasActiveItem?(:STICK)
      baseDmg = move.baseDamage
      case move.function
      when "010"   # Stomp
        baseDmg *= 2 if target.effects[PBEffects::Minimize]
      # Sonic Boom, Dragon Rage, Super Fang, Night Shade, Endeavor
      when "06A", "06B", "06C", "06D", "06E"
        damagedictionary[originalkey] = move.pbFixedDamage(user,target)
        next
      when "06F"   # Psywave
        case originalkey
        when :minDamage
          damagedictionary[originalkey] = user.level/2.floor
          next
        when :averageDamage
          damagedictionary[originalkey] = user.level
          next
        else
          damagedictionary[originalkey] = user.level*3/2.floor
          next
        end
      when "070"   # OHKO
        damagedictionary[originalkey] = target.hp
        next
      when "071", "072", "073"   # Counter, Mirror Coat, Metal Burst
        damagedictionary[originalkey] = 5
        next
      when "075", "076", "0D0", "12D"   # Surf, Earthquake, Whirlpool, Shadow Storm
        baseDmg = move.pbModifyDamage(baseDmg,user,target)
      # Gust, Twister, Venoshock, Smelling Salts, Wake-Up Slap, Facade, Hex, Brine,
      # Retaliate, Weather Ball, Return, Frustration, Eruption, Crush Grip,
      # Stored Power, Punishment, Hidden Power, Fury Cutter, Echoed Voice,
      # Trump Card, Flail, Electro Ball, Low Kick, Fling, Spit Up
      when "077", "078", "07B", "07C", "07D", "07E", "07F", "080", "085", "087",
           "089", "08A", "08B", "08C", "08E", "08F", "090", "091", "092", "097",
           "098", "099", "09A", "0F7", "113", "176", "188", "192", "195", "219",
           "220", "222", "224"
        baseDmg = move.pbBaseDamage(baseDmg,user,target)
      when "086"   # Acrobatics
        baseDmg *= 2 if !user.item || user.hasActiveItem?(:FLYINGGEM)
      when "08D"   # Gyro Ball
        baseDmg = [[(25*target.pbSpeed/user.pbSpeed).floor,150].min,1].max
      when "094"   # Present
        baseDmg = 50
      when "095"   # Magnitude
        case originalkey
        when :minDamage
          baseDmg = 50 #assume you dont hit 4 or 5
        when :averageDamage
          baseDmg = 71
        else
          baseDmg = 90 #assume they dont hit 9 or 10
        end
        baseDmg.each *= 2 if target.inTwoTurnAttack?("0CA")   # Dig
      when "096"   # Natural Gift
        baseDmg = move.pbNaturalGiftBaseDamage(user.item_id)
      when "09B"   # Heavy Slam
        baseDmg = move.pbBaseDamage(baseDmg,user,target)
        baseDmg *= 2 if target.effects[PBEffects::Minimize]
      when "0A0"  # Frost Breath
        key = :critDamage
      when "0BD", "0BE", "204"   #Double Kick, Twineedle
        baseDmg *= 2
      when "0BF"   # Triple Kick
        case originalkey
        when :minDamage
          baseDmg *= 3
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
            case originalkey
            when :minDamage
              baseDmg *= 4
            when :averageDamage
              baseDmg *= 4.5
            else
              baseDmg *= 5
            end
          else
            case originalkey
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
        mult = rand(5) + 1 #todo
        baseDmg *= mult
      when "0C4"   # Solar Beam
        baseDmg = move.pbBaseDamageMultiplier(baseDmg,user,target)
      when "0D3"   # Rollout
        baseDmg *= 2 if user.effects[PBEffects::DefenseCurl]
      when "0D4"   # Bide
        damagedictionary[originalkey] = 0
        next
      when "0E1"   # Final Gambit
        damagedictionary[originalkey] = user.hp
        next
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
        user.eachAlly do |b|
          baseDmg *= 1.5 if b.pbHasMove?(:ROUND) && b.pbSpeed > user.pbSpeed #todo
        end
      when "0F0"
        baseDmg *= 1.5 if target.item && !target.unlosableItem?(target.item)
      when "213"
        baseDmg *= move.pbNumHits(user, target)
      when "225"
        if user.stages[:ACCURACY] > 0
          baseDmg *= 10
        else
          case originalkey
          when :minDamage
            baseDmg *= 4
          when :averageDamage
            baseDmg *= 6 #todo accuracy check
          else
            baseDmg *= 10   # Hits do x1, x2, x3 baseDmg in turn, for x6 in total
          end
        end
      end
      
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      type = move.pbCalcType(user)
      if tera == user && move.function == "177"
        type = user.tera
      end
      typeMod = move.pbCalcTypeMod(type,user,target,tera)
      atk, atkStage = move.pbGetAttackStats(user,target)
      if switchin == target && target.hasActiveAbility?([:INTIMIDATE, :SKULK]) && move.physicalMove? #todo menace
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

      if ((@battle.pbCheckGlobalAbility(:DARKAURA) || (switchin && switchin.ability_id == :DARKAURA)) && type == :DARK) ||
         ((@battle.pbCheckGlobalAbility(:FAIRYAURA) || (switchin && switchin.ability_id == :FAIRYAURA)) && type == :FAIRY)
        if @battle.pbCheckGlobalAbility(:AURABREAK) || (switchin && switchin.ability_id == :AURABREAK)
          multipliers[:base_damage_multiplier] *= 2 / 3.0
          multipliers[:base_damage_multiplier] *= 4 / 3.0
        else
        end
      end
      if user.abilityActive?
        if switchin == user && user.ability_id == :SLOWSTART
          multipliers[:attack_multiplier] /= 2 if move.physicalMove?
        end
        case user.ability_id
        when :ROUGHSKIN
        when :AERILATE,:PIXILATE,:REFRIGERATE,:GALVANIZE,:ADAPTINGPIXELS,:PIXELATEDSANDS,:PIXELTAG,:PIXELBOUNCE
          if type == :NORMAL
            multipliers[:base_damage_multiplier] *= 1.2
          end
        when :ANALYTIC
          if user.pbSpeed < target.pbSpeed
            multipliers[:base_damage_multiplier] *= 1.3
          end
        when :BLAZE
          if (user.hp <= user.adjustedTotalhp / 3 || (target.pbSpeed > user.pbSpeed && user.hp / (100 / pbCynthiaGetThreat(user, target, false)[:highestDamage]) <= user.adjustedTotalhp / 3)) && type == :FIRE
            multipliers[:attack_multiplier] *= 1.5
          end
        when :DEFEATIST
          if user.hp <= user.adjustedTotalhp / 2 || (target.pbSpeed > user.pbSpeed && user.hp / (100 / pbCynthiaGetThreat(user, target, false)[:highestDamage]) <= user.adjustedTotalhp / 2)
            multipliers[:attack_multiplier] /= 2
          end
        when :OVERGROW
          if (user.hp <= user.adjustedTotalhp / 3 || (target.pbSpeed > user.pbSpeed && user.hp / (100 / pbCynthiaGetThreat(user, target, false)[:highestDamage]) <= user.adjustedTotalhp / 3)) && type == :GRASS
            multipliers[:attack_multiplier] *= 1.5
          end
        when :SWARM
          if (user.hp <= user.adjustedTotalhp / 3 || (target.pbSpeed > user.pbSpeed && user.hp / (100 / pbCynthiaGetThreat(user, target, false)[:highestDamage]) <= user.adjustedTotalhp / 3)) && type == :BUG
            multipliers[:attack_multiplier] *= 1.5
          end
        when :TORRENT
          if (user.hp <= user.adjustedTotalhp / 3 || (target.pbSpeed > user.pbSpeed && user.hp / (100 / pbCynthiaGetThreat(user, target, false)[:highestDamage]) <= user.adjustedTotalhp / 3)) && type == :WATER
            multipliers[:attack_multiplier] *= 1.5
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
             b,user,target,move,multipliers,baseDmg,type)
        end
        if target.abilityActive?
          case user.ability_id
          when :FILTER,:SOLIDROCK
            if Effectiveness.super_effective?(typeMod)
              multipliers[:final_damage_multiplier] *= 0.75 if !user.hasMoldBreaker?
            end
          when :FLUFFY
            multipliers[:final_damage_multiplier] *= 2 if move.pbCalcType(user) == :FIRE && !user.hasMoldBreaker?
            multipliers[:final_damage_multiplier] /= 2 if move.contactMove? && !user.hasMoldBreaker?
          when :PRISMARMOR
            if Effectiveness.super_effective?(typeMod)
              multipliers[:final_damage_multiplier] *= 0.75
            end
          else
            BattleHandlers.triggerDamageCalcTargetAbility(target.ability,
               target,user,move,multipliers,baseDmg,type) if !user.hasMoldBreaker?
            BattleHandlers.triggerDamageCalcTargetAbilityNonIgnorable(target.ability,
               target,user,move,multipliers,baseDmg,type)
          end
        end
        target.eachAlly do |b|
          next if !b.abilityActive?
          BattleHandlers.triggerDamageCalcTargetAllyAbility(b.ability,
             b,user,target,move,multipliers,baseDmg,type)
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
        case switchin.ability_id
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
        case switchin.ability_id
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
        if type == :FIRE || move.id == :HYDROSTEAM
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
        if (target.hasActiveAbility?(:ADAPTINGSANDS) || target.pbHasType?(:ROCK) || (target == tera && target.tera == :ROCK)) && move.specialMove? && move.function != "122"   # Psyshock
          multipliers[:defense_multiplier] *= 1.5
        end
      when :Snow
        if (target.pbHasType?(:ICE) || (target == tera && target.tera == :ICE)) && move.physicalMove? && move.function != "202"
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

      case originalkey
      when :minDamage
        random = 85
      when :averageDamage
        random = 92.5
      else
        random = 100
      end
      multipliers[:final_damage_multiplier] *= random / 100.0
      # STAB
      if user == tera
        if type && user.tera == type
          if user.hasActiveAbility?([:ADAPTABILITY, :ADAPTINGPIXELS, :ADAPTIVETECHNICIAN])
            multipliers[:final_damage_multiplier] *= 2
          else
            multipliers[:final_damage_multiplier] *= 1.5
          end
        end
        if type && user.pbHasType?(type)
          multipliers[:final_damage_multiplier] *= 1.5
        end
      else
        if type && user.pbHasType?(type)
          if user.hasActiveAbility?([:ADAPTABILITY, :ADAPTINGPIXELS, :ADAPTIVETECHNICIAN])
            multipliers[:final_damage_multiplier] *= 2
          else
            multipliers[:final_damage_multiplier] *= 1.5
          end
        end
        if user.pokemon.unteraTypes != nil
          if user.pokemon.unteraTypes.include?(:STELLAR)
            if user.stellarmoves == nil
              user.stellarmoves = []
            end
            if !user.stellarmoves.include?(GameData::Type.get(type).id)
              if type && user.pokemon.unteraTypes.include?(GameData::Type.get(type).id)
                multipliers[:final_damage_multiplier] *= 1.5
              else
                multipliers[:final_damage_multiplier] *= 1.2
              end
            end
          else
            if type && user.pokemon.unteraTypes.include?(GameData::Type.get(type).id)
              multipliers[:final_damage_multiplier] *= 1.5
            end
          end
        end
      end
      # Type effectiveness
      multipliers[:final_damage_multiplier] *= typeMod.to_f / Effectiveness::NORMAL_EFFECTIVE
      # Burn
      if user.status == :BURN && move.physicalMove? && move.damageReducedByBurn? &&
         !user.hasActiveAbility?([:GUTS, :WILDFIRE])
        multipliers[:final_damage_multiplier] /= 2
      end
      # Frostbite
      if user.status == :FROZEN && move.specialMove? && !user.hasActiveAbility?(:ICEBODY)
        multipliers[:final_damage_multiplier] /= 2
      end
      # Drowsy
      if target.status == :SLEEP && !(target.pbHasMove?(:SLEEPTALK) || target.pbHasMove?(:SNORE))
        multipliers[:final_damage_multiplier] *= 4/3.0
      end
      # Aurora Veil, Reflect, Light Screen
      if !move.ignoresReflect? && !(key == :critDamage)
         !(user.hasActiveAbility?(:INFILTRATOR) || user.hasActiveAbility?(:CHARGEDEXPLOSIVE) || ["201", "213"].include?(move.function))
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