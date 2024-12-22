class PokeBattle_AI
  def pbCynthiaChooseEnemyCommand(idxBattler)
    user = @battle.battlers[idxBattler]
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
      userThreat = pbCynthiaAssessThreat(target, user, false), 1
      break if userThreat >= 100 && (opposingThreat < 100 || user.pbSpeed > target.pbSpeed)
      damagethreshold = (100/userThreat).ceil
      damagethreshold -= 1 if user.pbSpeed > target.pbSpeed
      opposingThreat *= damagethreshold
      maxThreat = opposingThreat + userThreat
      @battle.pbParty(idxBattler).each_with_index do |pokemon,i|
        next if !@battle.pbCanSwitch?(idxBattler,i)
        battler = PokeBattle_Battler.new(@battle,69)
        battler.pbInitialize(pokemon,69)
        opposingThreat = pbCynthiaAssessThreat(battler, target)
        userThreat = pbCynthiaAssessThreat(target, battler, false), 1
        damagethreshold = (100/userThreat).ceil
        damagethreshold += 1 if battler.pbSpeed <= target.pbSpeed
        opposingThreat *= damagethreshold
        currentThreat = opposingThreat + userThreat
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
        damagethreshold = (100/userThreat).ceil
        damagethreshold -= 1 if battler.pbSpeed > target.pbSpeed
        opposingThreat *= damagethreshold
        currentThreat = opposingThreat + userThreat
        if best == -1 || currentThreat < maxThreat
          maxThreat = currentThreat
          best = i
        end
      end
    end
    return best
  end

  def pbCynthiaAssessThreat(user, target, max=true)
    currentThreat = []
    target.moves.each_with_index do |move,i|
      currentThreat.push([move, pbCynthiaCalcDamage(move,target,user)])
    end
    maxdamage = 0
    statusMoves = []
    currentThreat.each do |move,damagetable|
      if move.statusMove?
        statusMoves.push(move)
        next
      end
      if max
        damage = damagetable[:maxDamage]
      else
        damage = damagetable[:minDamage]
      end
      if damage > maxdamage
        maxdamage = damage
      end
    end
    if currentThreat.length() == statusMoves.length()
      return 33
    end
    return [[100, maxdamage*100/user.totalhp].min, 1],max
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
      if move.name == "The Skeleton Appears" && move.pp > 0
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
    # Decide whether all choices are bad, and if so, try switching instead
    badMoves = false
    # if maxScore <= 33
    #   badMoves = true
    # end
    if badMoves && pbEnemyShouldWithdrawEx?(idxBattler,true)
      if $INTERNAL
        PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will switch due to terrible moves")
      end
      return
    end
    # Find any preferred moves and just choose from them
    preferredMoves = []
    choices.each do |c|
      preferredMoves.push(c) if c[1]==maxScore   # Doubly prefer the best move
    end
    if preferredMoves.length>0
      m = preferredMoves[pbAIRandom(preferredMoves.length)]
      PBDebug.log("[AI] #{user.pbThis} (#{user.index}) prefers #{user.moves[m[0]].name}")
      @battle.pbRegisterMove(idxBattler,m[0],false)
      @battle.pbRegisterTarget(idxBattler,m[2]) if m[2]>=0
      return
    end
    # If there are no calculated choices, pick one at random
    if choices.length==0
      PBDebug.log("[AI] #{user.pbThis} (#{user.index}) doesn't want to use any moves; picking one at random")
      user.eachMoveWithIndex do |_m,i|
        next if !@battle.pbCanChooseMove?(idxBattler,i,false)
        choices.push([i,100,-1])   # Move index, score, target
      end
      if choices.length==0   # No moves are physically possible to use; use Struggle
        @battle.pbAutoChooseMove(user.index)
      end
    end
    # Log the result
    if @battle.choices[idxBattler][2]
      PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will use #{@battle.choices[idxBattler][2].name}")
    end
  end


  def pbCynthiaRegisterMove(user,idxMove,choices)
    move = user.moves[idxMove]
    target_data = move.pbTarget(user)
    if target_data.num_targets > 1
      # If move affects multiple battlers and you don't choose a particular one
      totalScore = 0
      @battle.eachBattler do |b|
        next if !@battle.pbMoveCanTarget?(user.index,b.index,target_data)
        score = pbCynthiaGetMoveScore(move,user,b)
        totalScore += ((user.opposes?(b)) ? score : -score)
      end
      choices.push([idxMove,totalScore,-1]) if totalScore>0
    elsif target_data.num_targets == 0
      # If move has no targets, affects the user, a side or the whole field
      score = pbCynthiaGetMoveScore(move,user,user)
      choices.push([idxMove,score,-1]) if score>0
    else
      # If move affects one battler and you have to choose which one
      scoresAndTargets = []
      @battle.eachBattler do |b|
        next if !@battle.pbMoveCanTarget?(user.index,b.index,target_data)
        next if target_data.targets_foe && !user.opposes?(b)
        score = pbCynthiaGetMoveScore(move,user,b)
        scoresAndTargets.push([score,b.index]) if score>0
      end
      if scoresAndTargets.length>0
        # Get the one best target for the move
        scoresAndTargets.sort! { |a,b| b[0]<=>a[0] }
        choices.push([idxMove,scoresAndTargets[0][0],scoresAndTargets[0][1]])
      end
    end
  end

  def pbCynthiaGetMoveScore(move,user,target)
    score = 100
    score = pbGetMoveScoreFunctionCode(score,move,user,target,100)
    # A score of 0 here means it absolutely should not be used
    #return 0 if score<=0
    # Prefer damaging moves if AI has no more Pokémon or AI is less clever
    if @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
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
          score -= 60
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
    end
    # Adjust score based on how much damage it can deal
    if move.damagingMove?
      score = pbCynthiaGetMoveScoreDamage(move,user,target)
    else   # Status moves
      # Don't prefer attacks which don't deal damage
      score /= 2
      score -= 10
      # Account for accuracy of move
      accuracy = pbRoughAccuracy(move,user,target,100)
      score *= accuracy/100.0
      score = 0 if score<=10
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
    # Two-turn attacks waste 2 turns to deal one lot of damage
    if move.chargingTurnMove? || move.function=="0C2"   # Hyper Beam
      damage *= 2/3   # Not halved because semi-invulnerable during use or hits first turn
    end
    # Convert damage to percentage of target's remaining HP
    damagePercentage = damage*100.0/target.hp
    # Adjust score
    damagePercentage = 100 if damage>=target.hp   # Treat all lethal moves the same
    return damagePercentage.to_i
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
        baseDmg *= 2 if Settings::MECHANICS_GENERATION >= 7 &&
                        target.effects[PBEffects::Minimize]
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
      
      type = move.pbCalcType(user)
      typeMod = move.pbCalcTypeMod(type,user,target)

      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]

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
            mults[:final_damage_multiplier] *= 1.2
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