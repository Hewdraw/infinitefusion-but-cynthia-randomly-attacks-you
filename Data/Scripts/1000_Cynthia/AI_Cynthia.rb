class PokeBattle_AI
  def pbCynthiaChooseEnemyCommand(idxBattler)
    user = @battle.battlers[idxBattler]
    @threattable[user] = {}
    choices = []
    if @battle.battlers[idxBattler].dynamax == nil || @battle.battlers[idxBattler].dynamax == true
      choices.push(*pbCynthiaItemScore(idxBattler))
      return if pbCynthiaShouldWithdraw(idxBattler)
      return if @battle.pbAutoFightMenu(idxBattler)
    end
    @battle.pbRegisterMegaEvolution(idxBattler) if pbEnemyShouldMegaEvolve?(idxBattler)
    pbCynthiaChooseMoves(idxBattler)
  end

  def pbCynthiaShouldWithdraw(idxBattler)
    return false if @battle.sideSizes[0]>=2 || @battle.sideSizes[1]>=2
    user = @battle.battlers[idxBattler]

    willswitch = false
    user.eachOpposing do |target|
      opposingThreat = pbCynthiaAssessThreat(user, target)
      userThreat = pbCynthiaAssessThreat(target, user, false)
      break if userThreat >= 100 && (opposingThreat < 100 || user.pbSpeed > target.pbSpeed)
      damagethreshold = (100.0/[userThreat, opposingThreat].max).ceil
      damagethreshold -= 1 if user.pbSpeed > target.pbSpeed
      damagethreshold = [damagethreshold, 1].max
      maxThreat = opposingThreat - (userThreat / damagethreshold)
      @battle.pbParty(idxBattler).each_with_index do |pokemon,i|
        next if pokemon.fainted?
        next if !@battle.pbCanSwitch?(idxBattler,i)
        battler = PokeBattle_Battler.new(@battle,69)
        battler.pbInitialize(pokemon,69)
        opposingThreat = pbCynthiaAssessThreat(battler, target)
        userThreat = pbCynthiaAssessThreat(target, battler, false)
        userhp = 100.0 - opposingThreat
        damagethreshold = (userhp/[userThreat, opposingThreat].max).ceil
        damagethreshold -= 1 if battler.pbSpeed <= target.pbSpeed
        damagethreshold = [damagethreshold, 1].max
        currentThreat = opposingThreat - (userThreat / damagethreshold)
        if currentThreat < maxThreat
          maxThreat = currentThreat
          @battle.pbRegisterSwitch(idxBattler,i)
          willswitch = true
        end
      end
    end
    return willswitch
  end

  def pbCynthiaSwitch(idxBattler,party)
    enemies = []
    party.each_with_index do |_p,i|
      enemies.push(i) if @battle.pbCanSwitchLax?(idxBattler,i)
    end
    return -1 if enemies.length==0
    best = -1
    maxThreat = 1000

    @battle.battlers[idxBattler].eachOpposing do |target|
      enemies.each do |i|
        battler = PokeBattle_Battler.new(@battle,69)
        battler.pbInitialize(party[i],69)
        opposingThreat = pbCynthiaAssessThreat(battler, target)
        userThreat = pbCynthiaAssessThreat(target, battler, false)
        damagethreshold = (100/[userThreat, opposingThreat].max).ceil
        damagethreshold -= 1 if battler.pbSpeed > target.pbSpeed
        damagethreshold = [damagethreshold, 1].max
        currentThreat = opposingThreat - (userThreat / damagethreshold)
        if best == -1 || currentThreat < maxThreat
          maxThreat = currentThreat
          best = i
        end
      end
    end
    return best
  end

  def pbCynthiaAssessThreat(user, target, max=true, detailed = false)
    key = :minDamage
    key = :maxDamage if max
    threattable = {
      :highestDamage => 0,
      :physicalDamage => 0,
      :specialDamage => 0,
      :statusCount => 0,
    }
    currentThreat = {}
    target.moves.each_with_index do |move,i|
      if move.callsAnotherMove?
        case move.function
        when "0AE"
        when "0AF"
          blacklist = ["002", "014", "158", "05C", "05D", "069", "071", "072", "073", "09C", "0AD", "0AA", "0AB", "0AC", "0E8", "149", "14A", "14B", "14C", "168", "0AE", "0AF", "0B0", "0B3", "0B4", "0B5", "0B6", "0B1", "0B2", "117", "16A", "0E6", "0E7", "0F1", "0F2", "0F3", "115", "171", "172", "133", "134"]
          currentThreat[move] = 0
          if target.pbSpeed >= user.pbSpeed && @battle.lastMoveUsed
            moveID = @battle.lastMoveUsed
            calledmove = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(moveID))
            if !blacklist.include?(calledmove.function)
              damage = pbCynthiaCalcDamage(calledmove,target,user)[key]
              currentThreat[move] = damage
              threattable[:highestDamage] = damage if damage > threattable[:highestDamage]
              threattable[:physicalDamage] = damage if damage > threattable[:physicalDamage] && calledmove.physicalMove?
              threattable[:specialDamage] = damage if damage > threattable[:specialDamage] && calledmove.specialMove?
            end
          end
          user.moves.each do |usermove|
            if !blacklist.include?(usermove.function)
              moveID = usermove.id
              calledmove = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(moveID))
              damage = pbCynthiaCalcDamage(calledmove,target,user)
              damage = damage[key]
              currentThreat[move] = damage if damage > currentThreat[move]
              threattable[:highestDamage] = damage if damage > threattable[:highestDamage]
              threattable[:physicalDamage] = damage if damage > threattable[:physicalDamage] && calledmove.physicalMove?
              threattable[:specialDamage] = damage if damage > threattable[:specialDamage] && calledmove.specialMove?
            end
          end
        when "0B0"
        when "0B3"
        when "0B4"
        when "0B5"
        when "0B6"
        end
      else
        currentThreat[move] = pbCynthiaCalcDamage(move,target,user)[key]
      end
    end
    currentThreat.each do |move,damage|
      if move.statusMove?
        threattable[:statusCount] += 1
        next
      end
      threattable[:highestDamage] = damage if damage > threattable[:highestDamage]
      threattable[:physicalDamage] = damage if damage > threattable[:physicalDamage] && move.physicalMove?
      threattable[:specialDamage] = damage if damage > threattable[:specialDamage] && move.specialMove?
    end
    if detailed
      threattable.each do |damagekey, value|
        threattable[damagekey] = [[100, value*100/user.totalhp].min, 1].max
      end
      return threattable
    end
    if currentThreat.length() == threattable[:statusCount]
      return 32
    end
    return [[100, threattable[:highestDamage]*100/user.totalhp].min, 1].max
  end

  def pbCynthiaItemScore(idxBattler)
    choices = []
    items = @battle.pbGetOwnerItems(idxBattler)
  end

  def pbCynthiaChooseMoves(idxBattler)
    user        = @battle.battlers[idxBattler]
    # Get scores and targets for each move
    # NOTE: A move is only added to the choices array if it has a non-zero
    #       score.
    choices     = []
    user.eachMoveWithIndex do |move,i|
      next if user.dynamax != nil && move.statusMove?
      next if !@battle.pbCanChooseMove?(idxBattler,i,false)
      if move.name == "The Skeleton Appears"
        choices = [[i,100,100]]
        break
      end
      pbCynthiaRegisterMove(user,i,choices)
    end
    # Figure out useful information about the choices
    maxScore   = 0
    choices.each do |c|
      maxScore = c[1] if maxScore<c[1]
    end
    # Log the available choices
    logMsg = "[AI] Move choices for #{user.pbThis(true)} (#{user.index}): "
    choices.each_with_index do |c,i|
      logMsg += "#{user.moves[c[0]].name}=#{c[1]}"
      logMsg += " (target #{c[2]})" if c[2]>=0
      logMsg += ", " if i<choices.length-1
    end
    #print(logMsg)
    # Find any preferred moves and just choose from them
    preferredMoves = []
    choices.each do |c|
      preferredMoves.push(c) if c[1]==maxScore
    end
    if preferredMoves.length>0
      m = preferredMoves[pbAIRandom(preferredMoves.length)]
      PBDebug.log("[AI] #{user.pbThis} (#{user.index}) prefers #{user.moves[m[0]].name}")
      @battle.pbRegisterMove(idxBattler,m[0],false)
      @battle.pbRegisterTarget(idxBattler,m[2]) if m[2]>=0
      return
    end
    # If there are no calculated choices, pick one at random
    PBDebug.log("[AI] #{user.pbThis} (#{user.index}) doesn't want to use any moves; picking one at random")
    user.eachMoveWithIndex do |_m,i|
      next if !@battle.pbCanChooseMove?(idxBattler,i,false)
      choices.push([i,100,-1])   # Move index, score, target
    end
    if choices.length==0   # No moves are physically possible to use; use Struggle
      @battle.pbAutoChooseMove(user.index)
    end
    # Log the result
    if @battle.choices[idxBattler][2]
      PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will use #{@battle.choices[idxBattler][2].name}")
    end
  end

  def pbCynthiaRegisterMove(user,idxMove,choices, returnscore=false)
    if idxMove.is_a?(Integer)
      move = user.moves[idxMove]
    else
      move = idxMove
    end
    target_data = move.pbTarget(user)
    if target_data.num_targets > 1
      # If move affects multiple battlers and you don't choose a particular one
      totalScore = 0
      @battle.eachBattler do |b|
        next if !@battle.pbMoveCanTarget?(user.index,b.index,target_data)
        score = pbCynthiaGetMoveScore(move,user,b)
        totalScore += ((user.opposes?(b)) ? score : -score)
      end
      return totalScore if returnscore
      choices.push([idxMove,totalScore,-1])
    elsif target_data.num_targets == 0
      # If move has no targets, affects the user, a side or the whole field
      score = pbCynthiaGetMoveScore(move,user,user)
      return score if returnscore
      choices.push([idxMove,score,-1])
    else
      # If move affects one battler and you have to choose which one
      scoresAndTargets = []
      @battle.eachBattler do |b|
        next if !@battle.pbMoveCanTarget?(user.index,b.index,target_data)
        next if target_data.targets_foe && !user.opposes?(b)
        score = pbCynthiaGetMoveScore(move,user,b)
        scoresAndTargets.push([score,b.index])
      end
      if scoresAndTargets.length>0
        # Get the one best target for the move
        scoresAndTargets.sort! { |a,b| b[0]<=>a[0] }
        return scoresAndTargets[0][0] if returnscore
        choices.push([idxMove,scoresAndTargets[0][0],scoresAndTargets[0][1]])
      end
    end
  end

  def pbCynthiaGetMoveScore(move,user,target)
    if move.damagingMove?
      score = pbCynthiaGetMoveScoreDamage(move,user,target)
      # Two-turn attacks waste 2 turns to deal one lot of damage
    else
      score = 0
    end
    score += pbCynthiaGetMoveScoreStatus(move,user,target)
    if move.chargingTurnMove? || move.function=="0C2"   # Hyper Beam
      if !user.hasActiveItem?(:POWERHERB)
        score *= 1/2
      else
        score - 1
      end
    end
    # Don't prefer attacking the target if they'd be semi-invulnerable
    if move.accuracy>0 &&
       (target.semiInvulnerable? || target.effects[PBEffects::SkyDrop]>=0)
      miss = true
      miss = false if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
      if miss && pbRoughStat(user,:SPEED,100)>pbRoughStat(target,:SPEED,100)
        # Knows what can get past semi-invulnerability
        if target.effects[PBEffects::SkyDrop]>=0
          miss = false if move.hitsFlyingTargets?
        else
          if target.inTwoTurnAttack?("0C9","0CC","0CE")   # Fly, Bounce, Sky Drop
            miss = false if move.hitsFlyingTargets?
          elsif target.inTwoTurnAttack?("0CA")          # Dig
            miss = false if move.hitsDiggingTargets?
          elsif target.inTwoTurnAttack?("0CB")          # Dive
            miss = false if move.hitsDivingTargets?
          end
        end
      end
      score -= 80 if miss
    end
    # Pick a good move for the Choice items
    if user.hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF]) && !(user.effects[PBEffects::Dynamax] > 0)
      if move.baseDamage>=60;     score += 60
      elsif move.damagingMove?;   score += 30
      elsif move.function=="0F2"; score += 70   # Trick
      else;                       score -= 60
      end
    end
    # If user is asleep, prefer moves that are usable while asleep
    if user.status == :SLEEP && !move.usableWhenAsleep?
      user.eachMove do |m|
        next unless m.usableWhenAsleep?
        score -= 33
        break
      end
    end
    # If user is frozen, prefer a move that can thaw the user
    if user.status == :FROZEN
      if move.thawsUser?
        score += 40
      else
        user.eachMove do |m|
          next unless m.thawsUser?
          score -= 60
          break
        end
      end
    end
    # If target is frozen, don't prefer moves that could thaw them
    if target.status == :FROZEN
      user.eachMove do |m|
        next if m.thawsUser?
        score -= 60
        break
      end
    end
    score = score.to_i
    score = 0 if score<0
    return score
  end

  def pbCynthiaGetMoveScoreDamage(move,user,target) #todo imposter
    # Don't prefer moves that are ineffective because of abilities or effects
    return 0 if pbCheckMoveImmunity(100,move,user,target,100)
    # Calculate how much damage the move will do (roughly)
    damagetable = pbCynthiaCalcDamage(move,user,target)
    damage = damagetable[:minDamage]
    # Account for accuracy of move
    accuracy = pbRoughAccuracy(move,user,target,100)
    damage *= accuracy/100.0
    # Convert damage to percentage of target's remaining HP
    damagePercentage = damage*100.0/target.hp
    # Adjust score
    damagePercentage = 100 if damage>=target.hp   # Treat all lethal moves the same
    return damagePercentage.to_i
  end
end