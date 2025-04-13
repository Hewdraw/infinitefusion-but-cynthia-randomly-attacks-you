class PokeBattle_Battler
  #=============================================================================
  # Change HP
  #=============================================================================
  def pbReduceHP(amt,anim=true,registerDamage=true,anyAnim=true)
    amt = amt.round
    amt = @hp if amt>@hp
    amt = 1 if amt<1 && !fainted?
    oldHP = @hp
    self.hp -= amt
    PBDebug.log("[HP change] #{pbThis} lost #{amt} HP (#{oldHP}=>#{@hp})") if amt>0
    raise _INTL("HP less than 0") if @hp<0
    raise _INTL("HP greater than total HP") if @hp>adjustedTotalhp
    @battle.scene.pbHPChanged(self,oldHP,anim) if anyAnim && amt>0
    @tookDamage = true if amt>0 && registerDamage
    return amt
  end

  def pbRecoverHP(amt,anim=true,anyAnim=true)
    amt = amt.round
    amt = adjustedTotalhp-@hp if amt>adjustedTotalhp-@hp
    amt = 1 if amt<1 && @hp<adjustedTotalhp
    oldHP = @hp
    self.hp += amt
    PBDebug.log("[HP change] #{pbThis} gained #{amt} HP (#{oldHP}=>#{@hp})") if amt>0
    raise _INTL("HP less than 0") if @hp<0
    raise _INTL("HP greater than total HP") if @hp>adjustedTotalhp
    @battle.scene.pbHPChanged(self,oldHP,anim) if anyAnim && amt>0
    return amt
  end

  def pbRecoverHPFromDrain(amt,target,msg=nil)
    if target.hasActiveAbility?(:LIQUIDOOZE)
      @battle.pbShowAbilitySplash(target)
      pbReduceHP(amt)
      @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!",pbThis))
      @battle.pbHideAbilitySplash(target)
      pbItemHPHealCheck
    elsif target.hasActiveAbility?(:LEGENDARYPRESSURE) && target.pokemon.species == :TYRANTRUM_CARDBOARD
      @battle.pbShowAbilitySplash(target, false, true, "Liquid Ooze")
      pbReduceHP(amt)
      @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!",pbThis))
      @battle.pbHideAbilitySplash(target)
      pbItemHPHealCheck
    else
      msg = _INTL("{1} had its energy drained!",target.pbThis) if nil_or_empty?(msg)
      @battle.pbDisplay(msg)
      if canHeal?
        amt = (amt*1.3).floor if hasActiveItem?(:BIGROOT)
        pbRecoverHP(amt)
      end
    end
  end

  def pbFaint(showMessage=true)
    if @pokemon && @pokemon.phasetwo
      level = @level
      @species = @pokemon.phasetwo.species
      @pokemon.species = @pokemon.phasetwo.species
      @level = level
      @pokemon.item = @pokemon.phasetwo.item
      @item_id = @pokemon.phasetwo.item
      @pokemon.forget_all_moves
      @moves = []
      @pokemon.ability = @pokemon.phasetwo.ability
      @pokemon.phasetwo.moves.each { |move| @pokemon.learn_move_ignoremax(move.id) }
      @pokemon.moves.each { |move| @moves.push(PokeBattle_Move.from_pokemon_move(@battle,move))}
      @pokemon.iv = @pokemon.phasetwo.iv
      @pokemon.ev = @pokemon.phasetwo.ev
      @pokemon.nature = @pokemon.phasetwo.nature
      pbUpdate(true)
      @battle.pbCommonAnimation("UltraBurst2", self)
      @battle.scene.pbChangePokemon(self,@pokemon)
      pbBGMPlay("GalarBirds") if [:GARTICUNO, :GMOLTRES, :GZAPDOS].include?(@pokemon.species)
      hpbars = 1
      hpbars = @hpbars if @hpbars
      oldhp = @hp.to_f
      endhp = @totalhp * hpbars
      time = 64
      for i in 0..(time-1)
        if oldhp+((endhp-oldhp) * i/time).round >= @hp + 1
          @hp = oldhp+((endhp-oldhp) * i/time).round
        end
        @battle.scene.pbRefreshOne(@index)
        pbWait(1)
      end
      @hp = @totalhp * hpbars
      @battle.scene.pbRefreshOne(@index)
      @pokemon.hp = @hp
      @battle.scene.pbRefreshOne(@index)
      @pokemon.phasetwo = @pokemon.phasetwo.phasetwo
      @battle.pbCalculatePriority(false,[@index])
      # Trigger ability
      pbEffectsOnSwitchIn
      @battle.battleAI.pbDefaultChooseEnemyCommand(@index)
      return
    end
    if !fainted?
      PBDebug.log("!!!***Can't faint with HP greater than 0")
      return
    end
    return if @fainted   # Has already fainted properly
    @battle.pbDisplayBrief(_INTL("{1} fainted!",pbThis)) if showMessage
    updateSpirits()
    PBDebug.log("[Pokémon fainted] #{pbThis} (#{@index})") if !showMessage
    @battle.scene.pbFaintBattler(self)
    pbInitEffects(false)
    if self.hasActiveAbility?(:EXPLOSIVE, true) || self.hasActiveAbility?(:CHARGEDEXPLOSIVE, true)
      if !@battle.pbCheckGlobalAbility(:DAMP)
        @battle.pbShowAbilitySplash(self)
        @battle.pbPriority(true).each do |b|
          next if !b
          next if b == self
          if b.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
            @battle.scene.pbDamageAnimation(b)
            b.pbReduceHP(b.totalhp/4,false)
            @battle.pbDisplay(_INTL("{1} was caught in the aftermath!",b.pbThis))
          end
        end
      end
      @battle.pbHideAbilitySplash(self)
    end
    # Reset status
    self.status      = :NONE
    self.statusCount = 0
    # Lose happiness
    if @pokemon && @battle.internalBattle
      badLoss = false
      @battle.eachOtherSideBattler(@index) do |b|
        badLoss = true if b.level>=self.level+30
      end
      @pokemon.changeHappiness((badLoss) ? "faintbad" : "faint")
    end
    # Reset form
    @battle.peer.pbOnLeavingBattle(@battle,@pokemon,@battle.usedInBattle[idxOwnSide][@index/2])
    @pokemon.makeUnmega if mega?
    @pokemon.makeUnprimal if primal?
    # Do other things
    @battle.pbClearChoice(@index)   # Reset choice
    pbOwnSide.effects[PBEffects::LastRoundFainted] = @battle.turnCount
    # Check other battlers' abilities that trigger upon a battler fainting
    pbAbilitiesOnFainting
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
    if @battle.legendaryBattle? && @pokemon.raid
      @pokemon.ev = {}
      GameData::Stat.each_main do |s|
        @pokemon.ev[s.id] = 0
      end
      @pokemon.raid = nil
      @pokemon.hpbars = nil
      ability = @pokemon.getAbilityList[-1][0]
      @pokemon.ability_index = 2
      @pokemon.ability = GameData::Ability.get(ability).id
      @battle.pbThrowPokeBall(@index, :POKEBALL, catch_rate = 255, showPlayer = true)
    end
  end

  def updateSpirits()
    if $PokemonBag.pbQuantity(:ODDKEYSTONE)>=1 && @pokemon.hasType?(:GHOST)
      nbSpirits = pbGet(VAR_ODDKEYSTONE_NB)
      if nbSpirits < 108
        pbSet(VAR_ODDKEYSTONE_NB, nbSpirits+1)
      end
    end
  end

  #=============================================================================
  # Move PP
  #=============================================================================
  def pbSetPP(move,pp)
    move.pp = pp
    # No need to care about @effects[PBEffects::Mimic], since Mimic can't copy
    # Mimic
    if move.realMove && move.id==move.realMove.id && !@effects[PBEffects::Transform]
      move.realMove.pp = pp
    end
  end

  def pbReducePP(move)
    return true if usingMultiTurnAttack?
    return true if move.pp<0          # Don't reduce PP for special calls of moves
    return true if move.total_pp<=0   # Infinite PP, can always be used
    return false if move.pp==0        # Ran out of PP, couldn't reduce
    pbSetPP(move,move.pp-1) if move.pp>0
    return true
  end

  def pbReducePPOther(move)
    pbSetPP(move,move.pp-1) if move.pp>0
  end

  #=============================================================================
  # Change type
  #=============================================================================
  def pbChangeTypes(newType)
    if @unteraTypes != nil
      return false
    end
    if newType.is_a?(PokeBattle_Battler)
      newTypes = newType.pbTypes
      newTypes.push(:NORMAL) if newTypes.length == 0
      newType3 = newType.effects[PBEffects::Type3]
      newType3 = nil if newTypes.include?(newType3)
      @type1 = newTypes[0]
      @type2 = (newTypes.length == 1) ? newTypes[0] : newTypes[1]
      @effects[PBEffects::Type3] = newType3
    else
      newType = GameData::Type.get(newType).id
      @type1 = newType
      @type2 = newType
      @effects[PBEffects::Type3] = nil
    end
    @effects[PBEffects::BurnUp] = false
    @effects[PBEffects::Roost]  = false
  end

  #=============================================================================
  # Forms
  #=============================================================================
  def pbChangeForm(newForm,msg)
    return if fainted? || @effects[PBEffects::Transform] || @form==newForm
    oldForm = @form
    oldDmg = adjustedTotalhp-@hp
    self.form = newForm
    pbUpdate(true)
    @hp = adjustedTotalhp-oldDmg
    @effects[PBEffects::WeightChange] = 0 if Settings::MECHANICS_GENERATION >= 6
    @battle.scene.pbChangePokemon(self,@pokemon)
    @battle.scene.pbRefreshOne(@index)
    @battle.pbDisplay(msg) if msg && msg!=""
    PBDebug.log("[Form changed] #{pbThis} changed from form #{oldForm} to form #{newForm}")
    @battle.pbSetSeen(self)
  end

  def pbCheckFormOnStatusChange
    return if fainted? || @effects[PBEffects::Transform]
    # Shaymin - reverts if frozen
    if isSpecies?(:SHAYMIN) && frozen?
      pbChangeForm(0,_INTL("{1} transformed!",pbThis))
    end
  end

  def pbCheckFormOnMovesetChange
    return if fainted? || @effects[PBEffects::Transform]
    # Keldeo - knowing Secret Sword
    if isSpecies?(:KELDEO)
      newForm = 0
      newForm = 1 if pbHasMove?(:SECRETSWORD)
      pbChangeForm(newForm,_INTL("{1} transformed!",pbThis))
    end
  end

  def pbCheckFormOnWeatherChange
    return if fainted? || @effects[PBEffects::Transform]
    if hasActiveAbility?(:PROTOSYNTHESIS)
      if [:Sun, :HarshSun].include?(@battle.pbWeather) && !@effects[PBEffects::Protosynthesis]
        stageMul = [2, 2, 2, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8]
        stageDiv = [8, 7, 6, 5, 4, 3, 2, 2, 2, 2, 2, 2, 2]
        stats = [:ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED]
        stats2 = [@attack, @defense, @spatk, @spdef, @speed]
        stats.each_with_index do |stat,i|
          stage = @stages[stat]
          stat = stats2[i] * stageMul[stage] / stageDiv[stage]
        end
        stats.each_with_index do |stat,i|
          if stat >= stats.max
            @effects[PBEffects::Protosynthesis] = i + 1
            break
          end
        end
        @battle.pbShowAbilitySplash(battler)
        @battle.pbDisplay(_INTL("The harsh sunlight activated {1}'s Protosynthesis!", battler.pbThis))
        @battle.pbHideAbilitySplash(battler)
      end
      if ![:Sun, :HarshSun].include?(@battle.field.weather) && @effects[PBEffects::Protosynthesis] < 10
        @effects[PBEffects::Protosynthesis] = 0
      end
    end
    # Castform - Forecast
    if isSpecies?(:CASTFORM)
      if hasActiveAbility?(:FORECAST)
        newForm = 0
        case @battle.pbWeather
        when :Sun, :HarshSun   then newForm = 1
        when :Rain, :HeavyRain then newForm = 2
        when :Hail, :Snow             then newForm = 3
        end
        if @form!=newForm
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(newForm,_INTL("{1} transformed!",pbThis))
        end
      else
        pbChangeForm(0,_INTL("{1} transformed!",pbThis))
      end
    end
    # Cherrim - Flower Gift
    if isSpecies?(:CHERRIM)
      if hasActiveAbility?(:FLOWERGIFT)
        newForm = 0
        newForm = 1 if [:Sun, :HarshSun].include?(@battle.pbWeather)
        if @form!=newForm
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(newForm,_INTL("{1} transformed!",pbThis))
        end
      else
        pbChangeForm(0,_INTL("{1} transformed!",pbThis))
      end
    end
  end

  # Checks the Pokémon's form and updates it if necessary. Used for when a
  # Pokémon enters battle (endOfRound=false) and at the end of each round
  # (endOfRound=true).
  def pbCheckForm(endOfRound=false)
    return if fainted? || @effects[PBEffects::Transform]
    # Form changes upon entering battle and when the weather changes
    pbCheckFormOnWeatherChange if !endOfRound
    # Darmanitan - Zen Mode
    if isSpecies?(:DARMANITAN) && self.ability == :ZENMODE
      if @hp<=adjustedTotalhp/2
        if @form!=1
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(1,_INTL("{1} triggered!",abilityName))
        end
      elsif @form!=0
        @battle.pbShowAbilitySplash(self,true)
        @battle.pbHideAbilitySplash(self)
        pbChangeForm(0,_INTL("{1} triggered!",abilityName))
      end
    end
    # Minior - Shields Down
    if isSpecies?(:MINIOR) && self.ability == :SHIELDSDOWN
      if @hp>adjustedTotalhp/2   # Turn into Meteor form
        newForm = (@form>=7) ? @form-7 : @form
        if @form!=newForm
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(newForm,_INTL("{1} deactivated!",abilityName))
        elsif !endOfRound
          @battle.pbDisplay(_INTL("{1} deactivated!",abilityName))
        end
      elsif @form<7   # Turn into Core form
        @battle.pbShowAbilitySplash(self,true)
        @battle.pbHideAbilitySplash(self)
        pbChangeForm(@form+7,_INTL("{1} activated!",abilityName))
      end
    end
    # Wishiwashi - Schooling
    if isSpecies?(:WISHIWASHI) && self.ability == :SCHOOLING
      if @level>=20 && @hp>adjustedTotalhp/4
        if @form!=1
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(1,_INTL("{1} formed a school!",pbThis))
        end
      elsif @form!=0
        @battle.pbShowAbilitySplash(self,true)
        @battle.pbHideAbilitySplash(self)
        pbChangeForm(0,_INTL("{1} stopped schooling!",pbThis))
      end
    end
    # Zygarde - Power Construct
    if isSpecies?(:ZYGARDE) && self.ability == :POWERCONSTRUCT && endOfRound
      if @hp<=adjustedTotalhp/2 && @form<2   # Turn into Complete Forme
        newForm = @form+2
        @battle.pbDisplay(_INTL("You sense the presence of many!"))
        @battle.pbShowAbilitySplash(self,true)
        @battle.pbHideAbilitySplash(self)
        pbChangeForm(newForm,_INTL("{1} transformed into its Complete Forme!",pbThis))
      end
    end
  end

  def pbTransform(target)
    if target.is_a?(Integer)
      @battle.pbDisplay(_INTL("But it failed..."))
      return
    end
    oldAbil = @ability_id
    @effects[PBEffects::Transform]        = true
    @effects[PBEffects::TransformSpecies] = target.species
    pbChangeTypes(target)
    self.ability = target.ability
    self.ability2 = target.ability2 if target.ability2
    @attack  = target.attack
    @defense = target.defense
    @spatk   = target.spatk
    @spdef   = target.spdef
    @speed   = target.speed
    GameData::Stat.each_battle { |s| @stages[s.id] = target.stages[s.id] }
    if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
      @effects[PBEffects::FocusEnergy] = target.effects[PBEffects::FocusEnergy]
      @effects[PBEffects::LaserFocus]  = target.effects[PBEffects::LaserFocus]
    end
    @moves.clear
    target.moves.each_with_index do |m,i|
      @moves[i] = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(m.id))
      @moves[i].pp       = 5
      @moves[i].total_pp = 5
    end
    @effects[PBEffects::Disable]      = 0
    @effects[PBEffects::DisableMove]  = nil
    @effects[PBEffects::WeightChange] = target.effects[PBEffects::WeightChange]
    @battle.scene.pbRefreshOne(@index)
    @battle.pbDisplay(_INTL("{1} transformed into {2}!",pbThis,target.pbThis(true)))
    pbOnAbilityChanged(oldAbil)
  end

  def pbHyperMode; end
end
