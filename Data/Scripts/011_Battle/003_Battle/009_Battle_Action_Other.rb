class PokeBattle_Battle
  #=============================================================================
  # Shifting a battler to another position in a battle larger than double
  #=============================================================================
  def pbCanShift?(idxBattler)
    return false if pbSideSize(0)<=2 && pbSideSize(1)<=2   # Double battle or smaller
    idxOther = -1
    case pbSideSize(idxBattler)
    when 1
      return false   # Only one battler on that side
    when 2
      idxOther = (idxBattler+2)%4
    when 3
      return false if idxBattler==2 || idxBattler==3   # In middle spot already
      idxOther = ((idxBattler%2)==0) ? 2 : 3
    end
    return false if pbGetOwnerIndexFromBattlerIndex(idxBattler)!=pbGetOwnerIndexFromBattlerIndex(idxOther)
    return true
  end

  def pbRegisterShift(idxBattler)
    @choices[idxBattler][0] = :Shift
    @choices[idxBattler][1] = 0
    @choices[idxBattler][2] = nil
    return true
  end

  #=============================================================================
  # Calling at a battler
  #=============================================================================
  def pbRegisterCall(idxBattler)
    @choices[idxBattler][0] = :Call
    @choices[idxBattler][1] = 0
    @choices[idxBattler][2] = nil
    return true
  end

  def pbCall(idxBattler)
    battler = @battlers[idxBattler]
    trainerName = pbGetOwnerName(idxBattler)
    pbDisplay(_INTL("{1} called {2}!",trainerName,battler.pbThis(true)))
    pbDisplay(_INTL("{1}!",battler.name))
    if battler.shadowPokemon?
      if battler.inHyperMode?
        battler.pokemon.hyper_mode = false
        battler.pokemon.adjustHeart(-300)
        pbDisplay(_INTL("{1} came to its senses from the Trainer's call!",battler.pbThis))
      else
        pbDisplay(_INTL("But nothing happened!"))
      end
    elsif battler.status == :SLEEP
      battler.pbCureStatus
    elsif battler.pbCanRaiseStatStage?(:ACCURACY,battler)
      battler.pbRaiseStatStage(:ACCURACY,1,battler)
    else
      pbDisplay(_INTL("But nothing happened!"))
    end
  end

  #=============================================================================
  # Choosing to Mega Evolve a battler
  #=============================================================================
  def pbHasMegaRing?(idxBattler)
    return true if !pbOwnedByPlayer?(idxBattler)   # Assume AI trainer have a ring
    Settings::MEGA_RINGS.each { |item| return true if $PokemonBag.pbHasItem?(item) }
    return false
  end

  def pbGetMegaRingName(idxBattler)
    if pbOwnedByPlayer?(idxBattler)
      Settings::MEGA_RINGS.each do |item|
        return GameData::Item.get(item).name if $PokemonBag.pbHasItem?(item)
      end
    end
    # NOTE: Add your own Mega objects for particular NPC trainers here.
#    if pbGetOwnerFromBattlerIndex(idxBattler).trainer_type == :BUGCATCHER
#      return _INTL("Mega Net")
#    end
    return _INTL("Mega Ring")
  end

  def pbCanMegaEvolve?(idxBattler)
    return false if pbOwnedByPlayer?(idxBattler)
    # return false if $game_switches[Settings::NO_MEGA_EVOLUTION]
    return false if !@battlers[idxBattler].hasMega?
    return false if wildBattle? && opposes?(idxBattler)
    # return true if $DEBUG && Input.press?(Input::CTRL)
    # return false if @battlers[idxBattler].effects[PBEffects::SkyDrop]>=0
    return false if !pbHasMegaRing?(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @megaEvolution[side][owner]==-1
  end

  def pbRegisterMegaEvolution(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @megaEvolution[side][owner] = idxBattler
  end

  def pbUnregisterMegaEvolution(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @megaEvolution[side][owner] = -1 if @megaEvolution[side][owner]==idxBattler
  end

  def pbToggleRegisteredMegaEvolution(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    if @megaEvolution[side][owner]==idxBattler
      @megaEvolution[side][owner] = -1
    else
      @megaEvolution[side][owner] = idxBattler
    end
  end

  def pbRegisteredMegaEvolution?(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @megaEvolution[side][owner]==idxBattler
  end

  #=============================================================================
  # Mega Evolving a battler
  #=============================================================================
  def pbMegaEvolve(idxBattler, force=false)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    if !force
      return if !battler.hasMega? || battler.mega?
    end
    trainerName = pbGetOwnerName(idxBattler)
    # Break Illusion
    if battler.hasActiveAbility?(:ILLUSION)
      BattleHandlers.triggerTargetAbilityOnHit(battler.ability,nil,battler,nil,self)
    end
    # Mega Evolve
    if !force
      case battler.pokemon.species
      when :RAYQUAZA   # Rayquaza
        pbDisplay(_INTL("{1}'s fervent wish has reached {2}!",trainerName,battler.pbThis))
      when :CREEPER
        pbDisplay(_INTL("{1} got charged by its {2}!",
           battler.pbThis,battler.itemName))
      else
        pbDisplay(_INTL("{1}'s {2} is reacting to {3}'s {4}!",
           battler.pbThis,battler.itemName,trainerName,pbGetMegaRingName(idxBattler)))
      end
      pbCommonAnimation("MegaEvolution",battler)
    end
    tempspecies = ("MEGA" + battler.pokemon.species.to_s).to_sym
    level = battler.level
    battler.pokemon.species = tempspecies
    battler.species = tempspecies
    battler.level = level
    battler.pbUpdate(true)
    @scene.pbChangePokemon(battler,battler.pokemon)
    @scene.pbRefreshOne(idxBattler)
    pbCommonAnimation("MegaEvolution2",battler)
    megaName = battler.pokemon.megaName
    if !force
      megaName = _INTL("Mega {1}", battler.pokemon.speciesName) if nil_or_empty?(megaName)
      pbDisplay(_INTL("{1} has Mega Evolved into {2}!",battler.pbThis,megaName))
    end
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @megaEvolution[side][owner] = -2
    if battler.isSpecies?(:GENGAR) && battler.mega?
      battler.effects[PBEffects::Telekinesis] = 0
    end
    pbCalculatePriority(false,[idxBattler]) if Settings::RECALCULATE_TURN_ORDER_AFTER_MEGA_EVOLUTION
    # Trigger ability
    battler.pbEffectsOnSwitchIn
    @battleAI.pbDefaultChooseEnemyCommand(idxBattler)
  end

  def pbTerastallize(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if battler.unteraTypes != nil
    trainerName = pbGetOwnerName(idxBattler)
    # Break Illusion
    if battler.hasActiveAbility?(:ILLUSION)
      BattleHandlers.triggerTargetAbilityOnHit(battler.ability,nil,battler,nil,self)
    end
    #pbDisplay(_INTL("{1} is Terastallizing into the {2}-Type!", battler.pbThis, battler.pokemon.tera))
    #pbCommonAnimation("MegaEvolution",battler)
    tempspecies = (battler.pokemon.species.to_s + battler.pokemon.tera.to_s).to_sym
    level = battler.level
    ability = battler.ability
    types = [battler.pokemon.type1, battler.pokemon.type2]
    if battler.pokemon.tera == :STELLAR
      types = [battler.pokemon.tera]
    end
    battler.pokemon.species = tempspecies
    battler.species = tempspecies
    battler.level = level
    battler.unteraTypes = types
    battler.pbUpdate(true)
    battler.ability = ability
    @scene.pbChangePokemon(battler,battler.pokemon)
    @scene.pbRefreshOne(idxBattler)
    pbCommonAnimation("MegaEvolution2",battler)
    @battleAI.pbDefaultChooseEnemyCommand(idxBattler)
    pbDisplay(_INTL("{1} has Terastallized into the {2}-Type!",battler.pbThis, battler.pokemon.tera))
    pbCalculatePriority(false,[idxBattler]) if Settings::RECALCULATE_TURN_ORDER_AFTER_MEGA_EVOLUTION
  end

  def pbDynamax(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if battler.pokemon.dynamax != true
    trainerName = pbGetOwnerName(idxBattler)
    sprite = @scene.sprites["pokemon_" + idxBattler.to_s]
    @scene.pbRefreshOne(idxBattler)
    battler.effects[PBEffects::Dynamax] = 3
    battler.effects[PBEffects::Encore] = 0
    battler.effects[PBEffects::Torment] = 0
    if battler.pokemon.gigantamax
      tempspecies = ("GMAX" + battler.pokemon.species.to_s).to_sym
      level = battler.level
      battler.pokemon.species = tempspecies
      battler.species = tempspecies
      battler.level = level
      battler.pbUpdate(true)
      @scene.pbChangePokemon(battler,battler.pokemon)
      @scene.pbRefreshOne(idxBattler)
      pbCommonAnimation("MegaEvolution2",battler)
    end
    pbCommonAnimation("StatUp",battler)
    pbSEPlay(pbStringToAudioFile("dynamaxbig"))
    oldhp = battler.hp.to_f
    time = 64
    for i in 0..(time-1)
      sprite.zoom_x += 0.03125
      sprite.zoom_y += 0.03125
      sprite.y += 2
      if oldhp+(oldhp * i/time).round >= battler.hp + 1
        battler.hp = oldhp+(oldhp * i/time).round
      end
      @scene.pbRefreshOne(idxBattler)
      pbWait(1)
    end
    battler.pokemon.dynamax = 3
    battler.hp = endhp
    sprite.zoom_x -= 2
    sprite.zoom_y -= 2
    sprite.y -= 128
    sprite.setPokemonBitmap(battler.pokemon)
    @scene.pbRefreshOne(idxBattler)
    battler.undynamoves = battler.pokemon.moves.clone
    battler.pokemon.forget_all_moves
    battler.moves = []
    maxmoves = {
      :NORMAL => :MAXSTRIKE,
      :FIGHTING => :MAXKNUCKLE,
      :FLYING => :MAXAIRSTREAM,
      :POISON => :MAXOOZE,
      :GROUND => :MAXQUAKE,
      :ROCK => :MAXROCKFALL,
      :BUG => :MAXFLUTTERBY,
      :GHOST => :MAXPHANTASM,
      :STEEL => :MAXSTEELSPIKE,
      :FIRE => :MAXFLARE,
      :WATER => :MAXGEYSER,
      :GRASS => :MAXOVERGROWTH,
      :ELECTRIC => :MAXLIGHTNING,
      :PSYCHIC => :MAXMINDSTORM,
      :ICE => :MAXHAILSTORM,
      :DRAGON => :MAXWYRMWIND,
      :DARK => :MAXDARKNESS,
      :FAIRY => :MAXSTARFALL
    }
    battler.undynamoves.each_with_index do |move,i|
      if !(move.category == 2)
        move = Pokemon::Move.new(maxmoves[move.type])
      else
        move = Pokemon::Move.new(:MAXGUARD)
      end
      battler.moves[i] = PokeBattle_Move.from_pokemon_move(self,move)
      battler.moves[i].category = battler.undynamoves[i].category
    end
    @battleAI.pbDefaultChooseEnemyCommand(idxBattler)
    pbDisplay(_INTL("{1} has Dynamaxed?!",battler.pbThis))
    pbCalculatePriority(false,[idxBattler]) if Settings::RECALCULATE_TURN_ORDER_AFTER_MEGA_EVOLUTION
  end

  def pbUnDynamax(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if (battler.pokemon.dynamax == nil) || battler.pokemon.dynamax == true
    trainerName = pbGetOwnerName(idxBattler)
    sprite = @scene.sprites["pokemon_" + idxBattler.to_s]
    @scene.pbRefreshOne(idxBattler)
    battler.effects[PBEffects::Dynamax] = 0
    if battler.pokemon.gigantamax
      tempspecies = (battler.pokemon.species.to_s[4..-1]).to_sym
      level = battler.level
      battler.pokemon.species = tempspecies
      battler.species = tempspecies
      battler.level = level
      battler.pbUpdate(true)
      @scene.pbChangePokemon(battler,battler.pokemon)
      @scene.pbRefreshOne(idxBattler)
      pbCommonAnimation("MegaEvolution2",battler)
    end
    pbCommonAnimation("StatDown",battler)
    pbSEPlay(pbStringToAudioFile("dynamaxsmall"))
    oldhp = battler.hp.to_f
    endhp = (battler.hp / 2).round
    time = 40
    for i in 0..(time-1)
      sprite.zoom_x -= 0.0165
      sprite.zoom_y -= 0.0165
      sprite.y -= 3.2
      if oldhp-(oldhp * i/time/2).round <= battler.hp - 1
        battler.hp = oldhp-(oldhp * i/time/2).round
      end
      @scene.pbRefreshOne(idxBattler)
      pbWait(1)
    end
    battler.pokemon.dynamax = nil
    battler.hp = endhp
    if battler.hp > battler.totalhp
      battler.hp = battler.totalhp
    end
    sprite.zoom_x += 0.64
    sprite.zoom_y += 0.64
    sprite.y += 32
    sprite.setPokemonBitmap(battler.pokemon)
    @scene.pbRefreshOne(idxBattler)
    battler.pokemon.moves = battler.undynamoves
    battler.moves = []
    battler.pokemon.moves.each_with_index do |move,i|
      battler.moves[i] = PokeBattle_Move.from_pokemon_move(self,move)
    end
    #pbDisplay(_INTL("{1} has Dynamaxed?!",battler.pbThis))
    pbCalculatePriority(false,[idxBattler]) if Settings::RECALCULATE_TURN_ORDER_AFTER_MEGA_EVOLUTION
  end

  #=============================================================================
  # Primal Reverting a battler
  #=============================================================================
  def pbPrimalReversion(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasPrimal? || battler.primal?
    if battler.isSpecies?(:KYOGRE)
      pbCommonAnimation("PrimalKyogre",battler)
    elsif battler.isSpecies?(:GROUDON)
      pbCommonAnimation("PrimalGroudon",battler)
    end
    battler.pokemon.makePrimal
    battler.form = battler.pokemon.form
    battler.pbUpdate(true)
    @scene.pbChangePokemon(battler,battler.pokemon)
    @scene.pbRefreshOne(idxBattler)
    if battler.isSpecies?(:KYOGRE)
      pbCommonAnimation("PrimalKyogre2",battler)
    elsif battler.isSpecies?(:GROUDON)
      pbCommonAnimation("PrimalGroudon2",battler)
    end
    pbDisplay(_INTL("{1}'s Primal Reversion!\nIt reverted to its primal form!",battler.pbThis))
  end
end
