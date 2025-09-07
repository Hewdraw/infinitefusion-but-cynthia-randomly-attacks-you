class PokeBattle_AI
  def pbCynthiaChooseEnemyCommand(idxBattler)
    user = @battle.battlers[idxBattler]
    @threattable = {}
    @damagetable = {}
    choices = []
    if @battle.battlers[idxBattler].dynamax == nil || @battle.battlers[idxBattler].dynamax == true
      choices.push(*pbCynthiaItemScore(idxBattler))
      return if pbCynthiaShouldWithdraw(idxBattler)
    end
    @battle.pbRegisterMegaEvolution(idxBattler) if pbEnemyShouldMegaEvolve?(idxBattler)
    pbCynthiaChooseMoves(idxBattler)
    if @battle.choices[idxBattler][0]==:UseMove && user.tera && user.unteraTypes == nil
      if user.tera == :STELLAR || user.hasActiveAbility?(:WONDERGUARD) || user.hasActiveAbility?(:NORMALIZE)
        user.willtera = true
      else
        user.willtera = pbCynthiaShouldTera(idxBattler)
      end
    end
  end

  def pbCynthiaShouldTera(idxBattler)
    user = @battle.battlers[idxBattler]
    userThreat = 1
    opposingThreat = 1
    teraUserThreat = 1
    teraOpposingThreat = 1
    user.eachOpposing do |target|
      next if target.fainted?
      opposingThreat += pbCynthiaGetThreat(user, target)[:highestDamage]
      threat = pbCynthiaGetThreat(target, user, false)[:highestDamage]
      userThreat = [threat, userThreat].max
      teraOpposingThreat += pbCynthiaGetThreat(user, target, true, user)[:highestDamage]
      threat = pbCynthiaGetThreat(target, user, false, user)[:highestDamage]
      teraUserThreat = [threat, teraUserThreat].max
    end

    if teraUserThreat > userThreat || teraOpposingThreat < opposingThreat
      return true
    end

    return nil
  end

  def pbCynthiaShouldWithdraw(idxBattler)
    user = @battle.battlers[idxBattler]
    return false if user.ace || user.level == 1

    willswitch = false
    bestSwitchValue = 0
    @battle.pbParty(idxBattler).each_with_index do |pokemon,i|
      next if pokemon.fainted?
      next if !@battle.pbCanSwitch?(idxBattler,i,nil, pbCynthiaChooseMoves(idxBattler, true))
      next if pokemon.ace
      switchValue = pbCynthiaGetSwitchValue(user, pokemon)
      if switchValue > bestSwitchValue
        next unless pbCynthiaChooseMoves(idxBattler, true) || @battle.pbRegisterSwitch(idxBattler,i)
        bestSwitchValue = switchValue
        willswitch = true 
      end
    end
    return willswitch
  end

  def pbCynthiaSwitch(idxBattler,party)
    @threattable = {}
    enemies = []
    party.each_with_index do |_p,i|
      enemies.push(i) if @battle.pbCanSwitchLax?(idxBattler,i)
    end
    return -1 if enemies.length==0
    best = -1
    bestSwitchValue = 0

    enemies.each do |i|
      next if party[i].ace && enemies.length > 1
      switchValue = pbCynthiaGetSwitchValue(@battle.battlers[idxBattler], party[i])
      if best == -1 || switchValue > bestSwitchValue
        bestSwitchValue = switchValue
        best = i
      end
    end
    return best
  end

  def pbCynthiaGetSwitchValue(user, switch)
    activeUserThreat = 1
    activeOpposingThreat = 1
    activeUserOutspeeds = true
    battler = PokeBattle_Battler.new(@battle,69)
    battler.pbInitialize(switch,69)
    switchThreat = 1
    opposingThreat = 1
    opposingMaxThreat = 0
    switchOutspeeds = true
    user.eachOpposing do |target|
      next if target.fainted?
      opposingThreat += pbCynthiaGetThreat(battler, target)[:highestDamage]
      opposingMaxThreat += pbCynthiaGetThreat(battler, target, false)[:highestDamage]
      threat = pbCynthiaGetThreat(target, battler, false)[:highestDamage]
      switchThreat = [threat, switchThreat].max
      switchOutspeeds = false if target.pbSpeed >= battler.pbSpeed
      if user.fainted?
        activeUserThreat = 1
        activeOpposingThreat = 100
        activeUserOutspeeds = false
        next
      end
      activeUserOutspeeds = false if target.pbSpeed >= user.pbSpeed
      activeOpposingThreat += pbCynthiaGetThreat(user, target)[:highestDamage]
      threat = pbCynthiaGetThreat(target, user, false)[:highestDamage]
      activeUserThreat = [threat, activeUserThreat].max
    end

    opposingThreat = [opposingThreat, 100].min
    activeOpposingThreat = [activeOpposingThreat, 100].min

    damagethreshold = ((100.0-opposingThreat)/opposingThreat).ceil #todo hazards
    damagethreshold = (100.0/opposingThreat).ceil if user.fainted? #todo hazards
    damagethreshold += 1 if switchOutspeeds
    activeDamagethreshold = (100.0/activeOpposingThreat).ceil
    activeDamagethreshold = (200.0/activeOpposingThreat).ceil if user.effects[PBEffects::Dynamax] > 0
    activeDamagethreshold += 1 if activeUserOutspeeds
    hitsDifferential = (1+(100.0/switchThreat).floor) / (100.0/activeUserThreat).floor
    switchScore = damagethreshold - (activeDamagethreshold * hitsDifferential)
    #print(user.name, " ", switch.name, " ", switchScore)
    switchScore += pbCynthiaGetSwitchBonus(battler, opposingThreat, damagethreshold)
    switchScore += pbCynthiaGetSwitchBonus(user, activeOpposingThreat, activeDamagethreshold) if !user.fainted?
    #print(user.name, " ", switch.name, " ", switchScore) 
    switchScore += (damagethreshold - activeDamagethreshold)
    switchScore -= 3
    switchScore -= 10 if opposingMaxThreat >= 100

    #print(switch.name, " ", switchScore, " ", hitsDifferential, " ", damagethreshold - (activeDamagethreshold * hitsDifferential), " ", opposingThreat, " ", switchThreat, " ", activeUserThreat, " ", activeOpposingThreat)

    #todo check when in turn order switch happens
    return switchScore
  end

  def pbCynthiaGetSwitchBonus(user, threat, damagethreshold)
    switchScore = 0
    switchInScore = 0
    switchOutScore = 0
    activeScore = 0

    switchScore += 2 if user.hasActiveAbility?([:SNOWWARNING, :SNOWWWARNING]) && @battle.pbWeather != :Snow && @battle.pbWeather != :Hail
    switchScore += 2 if user.hasActiveAbility?(:DROUGHT) && @battle.pbWeather != :Sun
    switchScore += 2 if user.hasActiveAbility?([:SANDSTREAM, :ADAPTINGSANDS, :PIXELATEDSANDS]) && @battle.pbWeather != :Sandstorm
    switchScore += 2 if user.hasActiveAbility?(:DRIZZLE) && @battle.pbWeather != :Rain
    switchScore += 2 if user.hasActiveAbility?(:PSYCHICSURGE) && @battle.field.terrain != :Psychic
    switchScore += 2 if user.hasActiveAbility?(:ELECTRICSURGE) && @battle.field.terrain != :Electric
    switchScore += 2 if user.hasActiveAbility?(:GRASSYSURGE) && @battle.field.terrain != :Grassy
    switchScore += 1 if user.hasActiveAbility?(:MISTYSURGE) && @battle.field.terrain != :Misty
    switchScore += 1 if user.hasActiveAbility?(:REGENERATOR)
    user.eachOpposing do |target|
      switchScore += 1 if user.hasActiveAbility?(:INTIMIDATE) && target.effects[PBEffects::Substitute] == 0 && !target.hasActiveAbility?([:DEFIANT, :COMPETITIVE, :FULLMETALBODY, :CLEARBODY, :HYPERCUTTER, :WHITESMOKE])
    end
    switchScore += 1 if user.pbHasMove?(:FAKEOUT) && !(user.turnCount == 0 && user.index != 69)

    switchInScore += 1 if user.hasActiveAbility?(:REGENERATOR) && threat <= 33 && 100.0 * user.hp / user.totalhp > threat
    switchInScore += 1 if user.hasActiveAbility?(:REGENERATOR) && threat <= 16 && 100.0 * user.hp / user.totalhp > threat
    user.eachOpposing do |target|
      switchInScore -= 3 if user.hasActiveAbility?(:INTIMIDATE) && target.effects[PBEffects::Substitute] == 0 && target.hasActiveAbility?([:DEFIANT, :COMPETITIVE])
    end

    switchOutScore += 1 if user.hasActiveAbility?(:REGENERATOR) && threat >= 100.0 * user.hp / user.totalhp
    switchOutScore -= 5 if user.hasActiveAbility?(:REGENERATOR) && threat <= 66 && 100.0 * user.hp / user.totalhp > 66
    switchOutScore += 2 if user.hasActiveAbility?(:REGENERATOR) && user.index != 69 &&  @battle.positions[user.index].effects[PBEffects::Wish]>0
    switchOutScore += 1 if user.effects[PBEffects::LeechSeed] >= 0 && !user.hasActiveAbility?(:MAGICGUARD)
    switchOutScore += 5 if user.effects[PBEffects::PerishSong]==1
    switchOutScore += [0, user.statusCount - 2].max if user.status == :POISON && !user.hasActiveAbility?([:POISONHEAL, :MAGICGUARD])
    switchOutScore -= 10 if user.effects[PBEffects::Substitute]>0 || user.effects[PBEffects::RedstoneCube]>0
    switchOutScore += 3 if user.effects[PBEffects::Curse] && !user.hasActiveAbility?(:MAGICGUARD)
    switchOutScore += 2 if user.effects[PBEffects::Nightmare] && !user.hasActiveAbility?(:MAGICGUARD)
    switchOutScore -= 1 if user.turnCount == 0 && @battle.turnCount != 0
    switchOutScore += 1 if user.pbHasMove?(:UTURN) || user.pbHasMove?(:VOLTSWITCH) || user.pbHasMove?(:FLIPTURN) || user.pbHasMove?(:PARTINGSHOT)
    switchOutScore -= 1 if user.effects[PBEffects::Protosynthesis] > 0
    switchOutScore -= 1 if user.effects[PBEffects::Protosynthesis] > 10
    switchOutScore -= 1 if user.effects[PBEffects::QuarkDrive] > 0
    switchOutScore -= 1 if user.effects[PBEffects::QuarkDrive] > 10
    switchOutScore += 1 if user.effects[PBEffects::Yawn]
    switchOutScore -= 3 if user.effects[PBEffects::Dynamax] > 0
    switchOutScore -= 5 if user.pbHasMove?(:EXPLOSION) || user.pbHasMove?(:SELFDESTRUCT) || user.pbHasMove?(:MEMENTO) || user.pbHasMove?(:HEALINGWISH)
    user.eachOpposing do |target|
      switchOutScore -= 1 if target.pbHasMove?(:CALMMIND) || target.pbHasMove?(:BULKUP)
      switchOutScore -= 2 if target.pbHasMove?(:NASTYPLOT) || target.pbHasMove?(:SWORDSDANCE) || target.pbHasMove?(:DRAGONDANCE) || target.pbHasMove?(:QUIVERDANCE)
      switchOutScore -= 2 if target.pbHasMove?(:WHIRLWIND) || target.pbHasMove?(:ROAR) || target.pbHasMove?(:DRAGONTAIL)
      switchOutScore -= 3 if target.pbHasMove?(:BELLYDRUM) || target.pbHasMove?(:SHELLSMASH)
    end
    switchOutScore -= 1 if user.hasActiveAbility?(:NATURALCURE) && user.pbHasMove?(:REST) && !user.status
    switchOutScore += 1 if user.hasActiveAbility?(:NATURALCURE) && user.status
    switchOutScore -= 3 if (user.hasActiveAbility?(:STURDY) || user.hasActiveItem?(:FOCUSSASH)) && user.hp == user.totalhp && threat > 90
    GameData::Stat.each_battle { |s| switchOutScore -= user.stages[s.id] }

    if threat < 33
      activeScore += [(@battle.pbAbleTeamCounts(0)[0]-1), damagethreshold-1].min if user.pbHasMove?(:STEALTHROCK) && user.pbOpposingSide.effects[PBEffects::StealthRock] == false
      activeScore += [(@battle.pbAbleTeamCounts(0)[0]-1), damagethreshold-1].min if user.pbHasMove?(:SPIKES) && user.pbOpposingSide.effects[PBEffects::Spikes] < 3
      opponenthaspoison = false
      @battle.pbParty(0).each_with_index do |pkmn,i|
        if pkmn.pbHasType?(:POISON)# && !pkmn.airborne? todo
          opponenthaspoison = true
          break
        end
      end
      activeScore += [(@battle.pbAbleTeamCounts(0)[0]-1), damagethreshold-1].min if user.pbHasMove?(:TOXICSPIKES) && user.pbOpposingSide.effects[PBEffects::ToxicSpikes] < 1 && !opponenthaspoison
      activeScore += [(@battle.pbAbleTeamCounts(0)[0]-1), damagethreshold-1].min*2 if user.pbHasMove?(:STICKYWEB) && user.pbOpposingSide.effects[PBEffects::StickyWeb] == 0
    end
    activeScore += 1 if (user.pbHasMove?(:REFLECT) || user.pbHasMove?(:BADDYBAD)) && user.pbOwnSide.effects[PBEffects::Reflect] == 0
    activeScore += 1 if (user.pbHasMove?(:LIGHTSCREEN) || user.pbHasMove?(:GLITZYGLOW)) && user.pbOwnSide.effects[PBEffects::LightScreen] == 0
    activeScore += 1 if user.pbHasMove?(:AURORAVEIL) && (@battle.pbWeather == :Snow || @battle.pbWeather == :Hail || (user.hasActiveAbility?([:SNOWWARNING, :SNOWWWARNING] && user.index == 69)))
    activeScore += 3 if user.pbHasMove?(:TAILWIND) && user.pbOwnSide.effects[PBEffects::Tailwind] == 0 && @battle.sideSizes[1] >= 2
    activeScore += 5 if user.pbHasMove?(:TRICKROOM) && @battle.field.effects[PBEffects::TrickRoom] == 0
    user.eachOpposing do |target|
      activeScore -= 3 if target.pbHasMove?(:WILLOWISP) && pbCynthiaGetThreat(target, user)[:specialDamage] == 0
    end

    activeScore *= 2 if @battle.turnCount == 0 && user.index != 69  

    switchScore += switchInScore if user.index == 69
    switchScore += switchOutScore if user.index != 69
    switchScore += activeScore if user.index == 69
    switchScore -= activeScore if user.index != 69
    #todo wish logic
    #print(user.name, " ", threat, " ", damagethreshold, " ", switchScore, " ", switchInScore, " ", switchOutScore, " ", activeScore)
    return switchScore
  end

  def pbCynthiaGetThreat(user, target, percentagetotal = true, tera = nil)
    return {
      :highestDamage => 0,
      :physicalDamage => 0,
      :specialDamage => 0,
      :statusCount => 0,
      :moves => {}
    } if !user
    newtable = {}
    if user != target
      threattable = pbCynthiaAssessThreat(user, target, tera)
    else
      maxthreat = 0
      user.eachOpposing do |opponent|
        threat = pbCynthiaAssessThreat(opponent, user, tera)
        if threat[:highestDamage] >= maxthreat
          threattable = threat
        end
      end
    end
    maxhp = user.adjustedTotalhp
    maxhp = user.hp if !percentagetotal
    for key, threat in threattable
      newtable[key] = threat
      next if key == :moves
      newtable[key] = [[100, threat*100.0/maxhp].min, 1].max
    end
    #print(user.name, " ", target.name, " ", newtable)
    return newtable
  end

  def pbCynthiaAssessThreat(user, target, tera = nil)
    @threattable[target] = {} if !@threattable[target]
    if !tera
      return @threattable[target][user] if @threattable[target][user]
    end
    threattable = {
      :highestDamage => 0,
      :physicalDamage => 0,
      :specialDamage => 0,
      :statusCount => 0,
      :moves => {}
    }

    key = :minDamage
    key = :maxDamage if target.pbOwnedByPlayer?

    target.moves.each_with_index do |move,i|
      next if move.pp==0 && move.total_pp>0
      next if !target.pbCanChooseMove?(move,true,false,false)
      next if target.pbEncoredMoveIndex != i && target.pbEncoredMoveIndex >= 0
      next if pbCheckMoveImmunity(100,move,target,user,100)
      threattable[:moves][move] = pbCynthiaAssessMoveThreat(user, target, move, tera)
      if threattable[:moves][move][:category] == :status
        threattable[:statusCount] += 1
        next
      end
      damage = threattable[:moves][move][key]
      threattable[:highestDamage] = damage if damage > threattable[:highestDamage]
      threattable[:physicalDamage] = damage if damage > threattable[:physicalDamage] && threattable[:moves][move][:category] == :physical
      threattable[:specialDamage] = damage if damage > threattable[:specialDamage] && threattable[:moves][move][:category] == :special
    end

    if !tera
      @threattable[target][user] = threattable
    end

    return threattable
  end

  def pbCynthiaAssessMoveThreat(user, target, move, tera=nil)
      if move.callsAnotherMove?
        case move.function
        when "0AE" #todo
        when "0AF"
          blacklist = ["002", "014", "158", "05C", "05D", "069", "071", "072", "073", "09C", "0AD", "0AA", "0AB", "0AC", "0E8", "149", "14A", "14B", "14C", "168", "0AE", "0AF", "0B0", "0B3", "0B4", "0B5", "0B6", "0B1", "0B2", "117", "16A", "0E6", "0E7", "0F1", "0F2", "0F3", "115", "171", "172", "133", "134"]
          if @battle.lastMoveUsed
            moveID = @battle.lastMoveUsed
            calledmove = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(moveID))
            if !blacklist.include?(calledmove.function)
              return pbCynthiaAssessMoveThreat(user,target,calledmove,tera)
            end
          end
        when "0B0" #todo
        when "0B3" #todo
        when "0B4" #todo
        when "0B5" #todo
        when "0B6" #todo
        end
      end
      damagetable = pbCynthiaCalcDamage(move,target,user,tera)
      damagetable[:category] = :status
      damagetable[:category] = :physical if move.physicalMove?
      damagetable[:category] = :special if move.specialMove?
      damagetable[:name] = move.name
      return damagetable

  end

  def pbCynthiaItemScore(idxBattler)
    choices = []
    items = @battle.pbGetOwnerItems(idxBattler)
  end

  def pbCynthiaChooseMoves(idxBattler, switch=false)
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
      next if switch && ![:UTURN,:VOLTSWITCH,:FLIPTURN,:TELEPORT,:PARTINGSHOT,:BATONPASS,:CHILLYRECEPTION,:SHEDTAIL].include?(move.id)
      pbCynthiaRegisterMove(user,i,choices)
    end
    if user.zmove > 0
      @battle.pbGetZMoves(user).each do |move|
        pbCynthiaRegisterMove(user,move,choices)
      end
    end
    # Figure out useful information about the choices
    maxScore   = 0
    choices.each do |c|
      maxScore = c[1] if maxScore<c[1]
    end
    # Log the available choices
    logMsg = "[AI] Move choices for #{user.pbThis(true)} (#{user.index}): "
    # choices.each_with_index do |c,i|
    #   logMsg += "#{user.moves[c[0]].name}=#{c[1]}"
    #   logMsg += " (target #{c[2]})" if c[2]>=0
    #   logMsg += ", " if i<choices.length-1
    # end
    #print(logMsg)
    # Find any preferred moves and just choose from them
    preferredMoves = []
    choices.each do |c|
      preferredMoves.push(c) if c[1]==maxScore
    end
    if preferredMoves.length>0
      m = preferredMoves[pbAIRandom(preferredMoves.length)]
      #PBDebug.log("[AI] #{user.pbThis} (#{user.index}) prefers #{user.moves[m[0]].name}")
      @battle.pbRegisterMove(idxBattler,m[0],false)
      @battle.pbRegisterTarget(idxBattler,m[2]) if m[2]>=0
      return true
    end
    return false if switch
    # If there are no calculated choices, pick one at random
    PBDebug.log("[AI] #{user.pbThis} (#{user.index}) doesn't want to use any moves; picking one at random")
    user.eachMoveWithIndex do |_m,i|
      next if !@battle.pbCanChooseMove?(idxBattler,i,false)
      choices.push([i,100,-1])   # Move index, score, target
    end
    if choices.length==0  # No moves are physically possible to use; use Struggle
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
    if user.hasActiveAbility?(:GENESIS) && move.id == :PSYCHIC && user.zmove > 0
      move = PokeBattle_Move.from_pokemon_move(@battle,Pokemon::Move.new(:GENESISSUPERNOVA))
      return
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
    score *= 2 if score >= 100
    if score > 0 || move.statusMove?
      score += pbCynthiaGetMoveScoreStatus(move,user,target)
    end
    score *= [pbRoughAccuracy(move,user,target,100), 100].min / 100.0 if !user.hasActiveAbility?(:NOGUARD) && !target.hasActiveAbility?(:NOGUARD)
    if move.statusMove?
      return 0 if user.hasActiveAbility?(:PRANKSTER) && target.pbHasType?(:DARK) && target != user
    end
    return 0 if move.powderMove? && (target.pbHasType?(:GRASS) || target.hasActiveAbility?(:OVERCOAT) || target.hasActiveItem?(:SAFETYGOGGLES)) && target != user
    #print(move.name, " ", user.name, " ", target.name, " ", score)
    if move.chargingTurnMove? || move.function=="0C2"   # Hyper Beam
      if !user.hasActiveItem?(:POWERHERB)
        score *= 0.5
      else
        score -= 1
      end
    end
    # Don't prefer attacking the target if they'd be semi-invulnerable
    if move.accuracy>0 &&
       (target.semiInvulnerable? || target.effects[PBEffects::SkyDrop]>=0)
      miss = true
      miss = false if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
      if miss && user.pbSpeed>target.pbSpeed
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
    # if user.hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF]) && !(user.effects[PBEffects::Dynamax] > 0)
    #   if move.baseDamage>=60;     score += 60
    #   elsif move.damagingMove?;   score += 30
    #   elsif move.function=="0F2"; score += 70   # Trick
    #   else;                       score -= 60
    #   end
    # end
    # If user is asleep, prefer moves that are usable while asleep
    if user.status == :SLEEP && !move.usableWhenAsleep?
      user.eachMove do |m|
        next unless m.usableWhenAsleep?
        score -= 33
        break
      end
    end
    if user.status != :SLEEP && move.usableWhenAsleep?
      score = 0
    end
    # If user is frozen, prefer a move that can thaw the user
    # if user.status == :FROZEN
    #   if move.thawsUser?
    #     score += 40
    #   else
    #     user.eachMove do |m|
    #       next unless m.thawsUser?
    #       score -= 60
    #       break
    #     end
    #   end
    # end
    # If target is frozen, don't prefer moves that could thaw them
    # if target.status == :FROZEN
    #   user.eachMove do |m|
    #     next if m.thawsUser?
    #     score -= 60
    #     break
    #   end
    # end
    score = score.to_i
    score = 0 if score<0
    return score
  end

  def pbCynthiaGetMoveScoreDamage(move,user,target)
    # Don't prefer moves that are ineffective because of abilities or effects
    return 0 if pbCheckMoveImmunity(100,move,user,target,100)
    # Calculate how much damage the move will do (roughly)
    damagetable = pbCynthiaCalcDamage(move,user,target)
    damage = damagetable[:minDamage]
    # Convert damage to percentage of target's remaining HP
    damagePercentage = damage*100.0/target.hp
    # Adjust score
    damagePercentage = 100 if damage>=target.hp   # Treat all lethal moves the same
    return damagePercentage.to_i
  end
end