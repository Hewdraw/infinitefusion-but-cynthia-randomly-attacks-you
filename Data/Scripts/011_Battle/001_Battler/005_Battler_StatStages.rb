class PokeBattle_Battler
  #=============================================================================
  # Increase stat stages
  #=============================================================================
  def statStageAtMax?(stat)
    return @stages[stat]>=6
  end

  def pbCanRaiseStatStage?(stat,user=nil,move=nil,showFailMsg=false,ignoreContrary=false)
    return false if fainted?
    # Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbCanLowerStatStage?(stat,user,move,showFailMsg,true)
    end
    # Check the stat stage
    if statStageAtMax?(stat)
      @battle.pbDisplay(_INTL("{1}'s {2} won't go any higher!",
         pbThis, GameData::Stat.get(stat).name)) if showFailMsg
      return false
    end
    return true
  end

  def pbRaiseStatStageBasic(stat,increment,ignoreContrary=false)
    if !@battle.moldBreaker
      # Contrary
      if hasActiveAbility?(:CONTRARY) && !ignoreContrary
        return pbLowerStatStageBasic(stat,increment,true)
      end
      # Simple
      increment *= 2 if hasActiveAbility?(:SIMPLE)
    end
    # Change the stat stage
    increment = [increment,6-@stages[stat]].min
    if increment>0
      stat_name = GameData::Stat.get(stat).name
      new = @stages[stat]+increment
      PBDebug.log("[Stat change] #{pbThis}'s #{stat_name}: #{@stages[stat]} -> #{new} (+#{increment})")
      @stages[stat] += increment
    end
    if stat == :EVASION && @stages[stat] >= 1
      @stages[stat] = 1
      @effects[PBEffects::Obscured] = 4
    end
    return increment
  end

  def pbRaiseStatStage(stat,increment,user,showAnim=true,ignoreContrary=false)
    # Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbLowerStatStage(stat,increment,user,showAnim,true)
    end
    # Perform the stat stage change
    increment = pbRaiseStatStageBasic(stat,increment,ignoreContrary)
    return false if increment<=0
    # Stat up animation and message
    @battle.pbCommonAnimation("StatUp",self) if showAnim
    arrStatTexts = [
       _INTL("{1}'s {2} rose!",pbThis,GameData::Stat.get(stat).name),
       _INTL("{1}'s {2} rose sharply!",pbThis,GameData::Stat.get(stat).name),
       _INTL("{1}'s {2} rose drastically!",pbThis,GameData::Stat.get(stat).name)]
    if stat == :EVASION && @stages[stat] >= 1
      @battle.pbDisplay(_INTL("{1} becomes obscured!",pbThis))
    else
      @battle.pbDisplay(arrStatTexts[[increment-1,2].min])
    end
    # Trigger abilities upon stat gain
    if abilityActive?
      BattleHandlers.triggerAbilityOnStatGain(self.ability,self,stat,user)
    end
    return true
  end

  def pbRaiseStatStageByCause(stat,increment,user,cause,showAnim=true,ignoreContrary=false)
    # Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbLowerStatStageByCause(stat,increment,user,cause,showAnim,true)
    end
    # Perform the stat stage change
    increment = pbRaiseStatStageBasic(stat,increment,ignoreContrary)
    return false if increment<=0
    # Stat up animation and message
    @battle.pbCommonAnimation("StatUp",self) if showAnim
    if user.index==@index
      arrStatTexts = [
         _INTL("{1}'s {2} raised its {3}!",pbThis,cause,GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} sharply raised its {3}!",pbThis,cause,GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} drastically raised its {3}!",pbThis,cause,GameData::Stat.get(stat).name)]
    else
      arrStatTexts = [
         _INTL("{1}'s {2} raised {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} sharply raised {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} drastically raised {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name)]
    end
    if stat == :EVASION && @stages[stat] >= 1
      @battle.pbDisplay(_INTL("{1} becomes obscured by it's {2}!",pbThis,cause))
    else
      @battle.pbDisplay(arrStatTexts[[increment-1,2].min])
    end
    # Trigger abilities upon stat gain
    if abilityActive?
      BattleHandlers.triggerAbilityOnStatGain(self.ability,self,stat,user)
    end
    return true
  end

  def pbRaiseStatStageByAbility(stat,increment,user,splashAnim=true, abilityName=nil)
    return false if fainted?
    ret = false
    @battle.pbShowAbilitySplash(user,false,true,abilityName) #if splashAnim
    if pbCanRaiseStatStage?(stat,user,nil,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        ret = pbRaiseStatStage(stat,increment,user)
      else
        ret = pbRaiseStatStageByCause(stat,increment,user,user.abilityName)
      end
    end
    @battle.pbHideAbilitySplash(user) if splashAnim
    return ret
  end

  #=============================================================================
  # Decrease stat stages
  #=============================================================================
  def statStageAtMin?(stat)
    return @stages[stat]<=-6
  end

  def pbCanLowerStatStage?(stat,user=nil,move=nil,showFailMsg=false,ignoreContrary=false)
    return false if fainted?
    # Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbCanRaiseStatStage?(stat,user,move,showFailMsg,true)
    end
    if !user || user.index!=@index   # Not self-inflicted
      if (@effects[PBEffects::Substitute]>0 || @effects[PBEffects::RedstoneCube]>0) && !(move && move.ignoresSubstitute?(user))
        @battle.pbDisplay(_INTL("{1} is protected by its substitute!",pbThis)) if showFailMsg
        return false
      end
      if pbOwnSide.effects[PBEffects::Mist]>0 &&
         !(user && (user.hasActiveAbility?(:INFILTRATOR) || user.hasActiveAbility?(:CHARGEDEXPLOSIVE)))
        @battle.pbDisplay(_INTL("{1} is protected by Mist!",pbThis)) if showFailMsg
        return false
      end
      if abilityActive?
        return false if BattleHandlers.triggerStatLossImmunityAbility(
           self.ability,self,stat,@battle,showFailMsg) if !@battle.moldBreaker
        return false if BattleHandlers.triggerStatLossImmunityAbilityNonIgnorable(
           self.ability,self,stat,@battle,showFailMsg)
      end
      if !@battle.moldBreaker
        eachAlly do |b|
          next if !b.abilityActive?
          return false if BattleHandlers.triggerStatLossImmunityAllyAbility(
             b.ability,b,self,stat,@battle,showFailMsg)
        end
      end
    end
    # Check the stat stage
    if statStageAtMin?(stat)
      @battle.pbDisplay(_INTL("{1}'s {2} won't go any lower!",
         pbThis, GameData::Stat.get(stat).name)) if showFailMsg
      return false
    end
    return true
  end

  def pbLowerStatStageBasic(stat,increment,ignoreContrary=false)
    if !@battle.moldBreaker
      # Contrary
      if hasActiveAbility?(:CONTRARY) && !ignoreContrary
        return pbRaiseStatStageBasic(stat,increment,true)
      end
      # Simple
      increment *= 2 if hasActiveAbility?(:SIMPLE)
    end
    # Change the stat stage
    increment = [increment,6+@stages[stat]].min
    if increment>0
      if stat == :EVASION && @stages[stat] >= 0
        @effects[PBEffects::Obscured] = 0
      end
      stat_name = GameData::Stat.get(stat).name
      new = @stages[stat]-increment
      PBDebug.log("[Stat change] #{pbThis}'s #{stat_name}: #{@stages[stat]} -> #{new} (-#{increment})")
      @stages[stat] -= increment
    end
    return increment
  end

  def pbLowerStatStage(stat,increment,user,showAnim=true,ignoreContrary=false)
    # Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbRaiseStatStage(stat,increment,user,showAnim,true)
    end
    obscured = false
    if stat == :EVASION && @effects[PBEffects::Obscured] > 0
      obscured = true
    end
    # Perform the stat stage change
    increment = pbLowerStatStageBasic(stat,increment,ignoreContrary)
    return false if increment<=0
    # Stat down animation and message
    @battle.pbCommonAnimation("StatDown",self) if showAnim
    arrStatTexts = [
       _INTL("{1}'s {2} fell!",pbThis,GameData::Stat.get(stat).name),
       _INTL("{1}'s {2} harshly fell!",pbThis,GameData::Stat.get(stat).name),
       _INTL("{1}'s {2} severely fell!",pbThis,GameData::Stat.get(stat).name)]
    if obscured
      @battle.pbDisplay(_INTL("{1} is no longer obscured!",pbThis))
    else
      @battle.pbDisplay(arrStatTexts[[increment-1,2].min])
    end
    # Trigger abilities upon stat loss
    if abilityActive?
      BattleHandlers.triggerAbilityOnStatLoss(self.ability,self,stat,user)
    end
    if hasActiveItem?(:EJECTPACK) && @battle.pbCanSwitch?(self.index,-1,false) && @battle.pbAbleCount(self.index) > 1
      itemname = self.item.name
      @battle.pbCommonAnimation("UseItem",self,nil); pbConsumeItem(false,true)
      @battle.pbDisplay(_INTL("{1} is switched out with the {2}!",pbThis,itemname))
      newPkmn = @battle.pbGetReplacementPokemonIndex(self.index)   # Owner chooses
      @battle.pbRecallAndReplace(self.index,newPkmn)
      @battle.pbClearChoice(self.index)   # Replacement Pokémon does nothing this round
      self.pbEffectsOnSwitchIn(true)
    end
    return true
  end

  def pbLowerStatStageByCause(stat,increment,user,cause,showAnim=true,ignoreContrary=false)
    # Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbRaiseStatStageByCause(stat,increment,user,cause,showAnim,true)
    end
    obscured = false
    if stat == :EVASION && @effects[PBEffects::Obscured] > 0
      obscured = true
    end
    # Perform the stat stage change
    increment = pbLowerStatStageBasic(stat,increment,ignoreContrary)
    return false if increment<=0
    # Stat down animation and message
    @battle.pbCommonAnimation("StatDown",self) if showAnim
    if user.index==@index
      arrStatTexts = [
         _INTL("{1}'s {2} lowered its {3}!",pbThis,cause,GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} harshly lowered its {3}!",pbThis,cause,GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} severely lowered its {3}!",pbThis,cause,GameData::Stat.get(stat).name)]
    else
      arrStatTexts = [
         _INTL("{1}'s {2} lowered {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} harshly lowered {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} severely lowered {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name)]
    end
    if obscured
      @battle.pbDisplay(_INTL("{1} is no longer obscured!",pbThis))
    else
      @battle.pbDisplay(arrStatTexts[[increment-1,2].min])
    end
    # Trigger abilities upon stat loss
    if abilityActive?
      BattleHandlers.triggerAbilityOnStatLoss(self.ability,self,stat,user)
    end
    if hasActiveItem?(:EJECTPACK) && @battle.pbCanSwitch?(self.index,-1,false) && @battle.pbAbleCount(self.index) > 1
      itemname = self.itemName
      @battle.pbCommonAnimation("UseItem",self,nil); pbConsumeItem(false,true)
      @battle.pbDisplay(_INTL("{1} is switched out with the {2}!",pbThis,itemname))
      newPkmn = @battle.pbGetReplacementPokemonIndex(self.index)   # Owner chooses
      @battle.pbRecallAndReplace(self.index,newPkmn)
      @battle.pbClearChoice(self.index)   # Replacement Pokémon does nothing this round
      user.pbEffectsOnSwitchIn(true)
    end
    return true
  end

  def pbLowerStatStageByAbility(stat,increment,user,splashAnim=true,checkContact=false,ability_name=nil)
    ret = false
    @battle.pbShowAbilitySplash(user,false ,false ,ability_name) if splashAnim
    if pbCanLowerStatStage?(stat,user,nil,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       (!checkContact || affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH))
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        ret = pbLowerStatStage(stat,increment,user)
      else
        ret = pbLowerStatStageByCause(stat,increment,user,user.abilityName)
      end
    end
    @battle.pbHideAbilitySplash(user) if splashAnim
    return ret
  end

  def pbLowerAttackStatStageIntimidate(user, stat=:ATTACK)
    return false if fainted?
    # NOTE: Substitute intentially blocks Intimidate even if self has Contrary.
    if @effects[PBEffects::Substitute]>0 || @effects[PBEffects::RedstoneCube]>0
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} is protected by its substitute!",pbThis))
      else
        @battle.pbDisplay(_INTL("{1}'s substitute protected it from {2}'s {3}!",
           pbThis,user.pbThis(true),user.abilityName))
      end
      return false
    end
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      return pbLowerStatStageByAbility(stat,1,user,false,false ,user.abilityName)
    end
    # NOTE: These checks exist to ensure appropriate messages are shown if
    #       Intimidate is blocked somehow (i.e. the messages should mention the
    #       Intimidate ability by name).
    if !hasActiveAbility?(:CONTRARY)
      if pbOwnSide.effects[PBEffects::Mist]>0
        @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by Mist!",
           pbThis,user.pbThis(true),user.abilityName))
        return false
      end
      if abilityActive?
        if BattleHandlers.triggerStatLossImmunityAbility(self.ability,self,stat,@battle,false) ||
           BattleHandlers.triggerStatLossImmunityAbilityNonIgnorable(self.ability,self,stat,@battle,false)
          @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
             pbThis,abilityName,user.pbThis(true),user.abilityName))
          return false
        end
      end
      eachAlly do |b|
        next if !b.abilityActive?
        if BattleHandlers.triggerStatLossImmunityAllyAbility(b.ability,b,self,stat,@battle,false)
          @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by {4}'s {5}!",
             pbThis,user.pbThis(true),user.abilityName,b.pbThis(true),b.abilityName))
          return false
        end
      end
    end
    return false if !pbCanLowerStatStage?(stat,user)
    return pbLowerStatStageByCause(stat,1,user,user.abilityName)
  end

  #=============================================================================
  # Reset stat stages
  #=============================================================================
  def hasAlteredStatStages?
    GameData::Stat.each_battle { |s| return true if @stages[s.id] != 0 }
    return false
  end

  def hasRaisedStatStages?
    GameData::Stat.each_battle { |s| return true if @stages[s.id] > 0 }
    return false
  end

  def hasLoweredStatStages?
    GameData::Stat.each_battle { |s| return true if @stages[s.id] < 0 }
    return false
  end

  def pbResetStatStages
    GameData::Stat.each_battle { |s| @stages[s.id] = 0 }
  end
end
