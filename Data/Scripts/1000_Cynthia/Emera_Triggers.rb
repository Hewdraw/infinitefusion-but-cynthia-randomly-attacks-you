BattleHandlers::AbilityOnBattlerFainting.add(:EMERA,
  proc { |ability,battler,fainted,battle|
    if fainted.hasActiveEmera?(:STUNSEED) && (fainted.isFusionOf(:SLUGMA) || fainted.isFusionOf(:GULPIN) || fainted.isFusionOf(:SWELLOW) || fainted.isFusionOf(:RHYDON))
      fainted.tempability = EMERADICT[:STUNSEED][:name]
      battle.pbShowAbilitySplash(fainted)
      Kernel.pbMessage("Deez Nuts")
      fainted.eachOpposing do |opponent|
        opponent.pbParalyze if opponent.pbCanParalyze?(fainted, true)
      end
      battle.pbHideAbilitySplash(fainted)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:EMERA,
  proc { |ability,battler,battle|
    if battler.hasActiveEmera?(:FLASHLIGHT) && battler.hasActiveAbility?(:ILLUMINATE)
      battler.tempability = EMERADICT[:FLASHLIGHT][:name]
      battle.pbShowAbilitySplash(battler)
      battle.eachOtherSideBattler(battler.index) do |b|
        next if !b.near?(battler)
        b.pbLowerAttackStatStageIntimidate(battler, :ACCURACY)
        b.pbItemOnIntimidatedCheck
      end
      battle.pbHideAbilitySplash(battler)
    end
    if battler.hasActiveEmera?(:LINGERINGPOTIONOFTURTLEMASTER)
      battler.tempability = EMERADICT[:LINGERINGPOTIONOFTURTLEMASTER][:name]
      battle.pbShowAbilitySplash(battler)
      battler.pbRaiseStatStage(:DEFENSE,2,battler) if battler.pbCanRaiseStatStage?(:DEFENSE)
      battler.pbRaiseStatStage(:SPECIAL_DEFENSE,2,battler) if battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE)
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::CriticalCalcUserAbility.add(:EMERA,
  proc { |ability,user,target,c|
    c += 1 if user.hasActiveEmera?(:SPINNINGLEEK)
    if user.hasActiveEmera?(:CHOICERIBBON) && user.effects[PBEffects::ChoiceRibbon] == true
      c += 1
    end
    next c
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:EMERA,
  proc { |ability,target,user,move,mults,baseDmg,type|
    if target.hasActiveEmera?(:COSMICFLUTE)
      mults[:defense_multiplier] *= 1.1
    end
    if target.hasActiveEmera?(:MILOTICSCALE) && target.pbHasAnyStatus?
      mults[:defense_multiplier] *= 1.1
    end
    if target.hasActiveEmera?(:MOONHEART) && target.hp == target.adjustedTotalhp
      mults[:final_damage_multiplier] *= 0.8
    end
    if target.hasActiveEmera?(:RUSTEDSHIELD) && move.physicalMove?
      mults[:defense_multiplier] *= 1.2
    end
    if target.hasActiveEmera?(:HEAVYCORE)
      mults[:defense_multiplier] *= 1.1
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:EMERA,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.hasActiveEmera?(:BRAINPRISM) && Effectiveness.super_effective?(target.damageState.typeMod)
      mults[:final_damage_multiplier] *= 1.5
    end
    if user.hasActiveEmera?(:RUSTEDSWORD) && move.physicalMove?
      mults[:final_damage_multiplier] *= 1.2
    end
    if user.hasActiveEmera?(:SUNHEART) && target.hp == target.adjustedTotalhp
      mults[:final_damage_multiplier] *= 1.2
    end
    if user.hasActiveEmera?(:HEAVYCORE)
      mults[:final_damage_multiplier] *= 1.2
    end
  }
)

BattleHandlers::SpeedCalcAbility.add(:EMERA,
  proc { |ability,battler,mult|
    if battler.hasActiveEmera?(:POTIONOFSWIFTNESS) && battler.battle.turnCount == 0
      mult *= 2
    end
    if battler.hasActiveEmera?(:HEAVYCORE)
      mult *= 0.5
    end
    next mult
  }
)

BattleHandlers::TargetAbilityOnHit.add(:EMERA,
  proc { |ability,target,user,move,battle|
    if target.hasActiveEmera?(:ENIGMASTONE) && Effectiveness.super_effective?(target.damageState.typeMod) && !target.fainted? && target.canHeal?
      target.tempability = EMERADICT[:ENIGMASTONE][:name]
      battle.pbShowAbilitySplash(target)
      target.pbRecoverHP(target.totalhp / 4)
      battle.pbDisplay(_INTL("{1}'s HP was restored.",target.pbThis))
      battle.pbHideAbilitySplash(target)
    end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:EMERA,
  proc { |ability,user,targets,move,battle|
    next if user.fainted?
    if user.hasActiveEmera?(:ABSORPTIONEMERA) && user.canHeal?
      targets.each do |b|
        next if !b.damageState.fainted
        user.tempability = EMERADICT[:ABSORPTIONEMERA][:name]
        battle.pbShowAbilitySplash(user)
        user.pbRecoverHP(user.totalhp / 4)
        battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
        battle.pbHideAbilitySplash(user)
      end
    end
    if user.hasActiveEmera?(:GOLDENBELL) && user.canHeal?
      totalDamage = 0
      targets.each { |b| totalDamage += b.damageState.totalHPLost }
      if totalDamage > 0
        user.tempability = EMERADICT[:GOLDENBELL][:name]
        battle.pbShowAbilitySplash(user)
        user.pbRecoverHP(totalDamage/8)
        battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
        battle.pbHideAbilitySplash(user)
      end
    end

    if user.hasActiveEmera?(:SCULKSHRIEKER) && move.soundMove?
      opposingmon = []
      user.eachOpposing.each do |mon|
        next if mon.hasActiveAbility?([:SOUNDPROOF, :VOCALOID])
        next if mon.fainted?
        opposingmon.push(mon)
      end
      if opposingmon.length > 0
        opposingmon = opposingmon.sample
        user.tempability = EMERADICT[:SCULKSHRIEKER][:name]
        pbShowAbilitySplash(user)
        battle.pbDisplay(_INTL("The {1} Shrieks.", EMERADICT[:SCULKSHRIEKER][:name]))
        opposingmon.pbLowerStatStage(:DEFENSE,2,user) if opposingmon.pbCanLowerStatStage?(:DEFENSE, user)
        opposingmon.pbLowerStatStage(:ACCURACY,1,user) if opposingmon.pbCanLowerStatStage?(:ACCURACY, user)
        if !$PokemonGlobal.towervalues.nil?
          $PokemonGlobal.towervalues.eventvariables[:sculkshrieker] = 0 if $PokemonGlobal.towervalues.eventvariables[:sculkshrieker].nil?
          $PokemonGlobal.towervalues.eventvariables[:sculkshrieker] += 1
          case $PokemonGlobal.towervalues.eventvariables[:sculkshrieker]
          when 1
            battle.pbDisplay("Warden approaches.")
          when 2
            battle.pbDisplay("Warden advances.")
          else
            battle.pbDisplay("Warden draws close.")
            #$PokemonGlobal.towervalues[:unknownlist].push("Warden")
          end
        end
        pbHideAbilitySplash(user)
      end
    end
  }
)


class PokeBattle_Battle
  def pbStartEmeras
    playerside = []
    opponentside = []
    idxBattler = -1
    loop do
      idxBattler += 1
      break if idxBattler>=@battlers.length
      battler = @battlers[idxBattler]
      next if !battler
      playerside.push(battler) if battler.idxOwnSide == 0
      opponentside.push(battler) if battler.idxOpposingSide == 0
    end
    if hasEmera?(:POTIONOFREGENERATION)
      playerside[0].tempability = EMERADICT[:POTIONOFREGENERATION][:name]
      pbShowAbilitySplash(playerside[0])
      pbDisplay(_INTL("Your Pokemon are surrounded by a veil of water!"))
      playerside.each do |battler|
        battler.effects[PBEffects::AquaRing] = true
      end
      pbHideAbilitySplash(playerside[0])
    end
    if hasEmera?(:SPLASPOTIONOFHARMING)
      playerside[0].tempability = EMERADICT[:SPLASPOTIONOFHARMING][:name]
      pbShowAbilitySplash(playerside[0])
      pbDisplay(_INTL("A {1} hits the opposing Pokemon!", EMERADICT[:SPLASPOTIONOFHARMING][:name]))
      opponentside.each do |battler|
        battler.pbReduceHP(battler.totalhp / 4,false)
      end
      pbHideAbilitySplash(playerside[0])
    end
    if hasEmera?(:SPLASHPOTIONOFPOISON)
      playerside[0].tempability = EMERADICT[:SPLASHPOTIONOFPOISON][:name]
      pbShowAbilitySplash(playerside[0])
      pbDisplay(_INTL("A {1} hits the opposing Pokemon!", EMERADICT[:SPLASHPOTIONOFPOISON][:name]))
      opponentside.each do |battler|
        battler.pbPoison if battler.pbCanPoison?(battler, true)
      end
      pbHideAbilitySplash(playerside[0])
    end
    if hasEmera?(:SPLASHPOTIONOFSLOWNESS)
      playerside[0].tempability = EMERADICT[:SPLASHPOTIONOFSLOWNESS][:name]
      pbShowAbilitySplash(playerside[0])
      pbDisplay(_INTL("A {1} hits the opposing Pokemon!", EMERADICT[:SPLASHPOTIONOFSLOWNESS][:name]))
      opponentside.each do |battler|
        battler.pbLowerStatStage(:SPEED,1,battler) if battler.pbCanLowerStatStage?(:SPEED)
      end
      pbHideAbilitySplash(playerside[0])
    end
    if hasEmera?(:SPLASHPOTIONOFWEAKNESS)
      playerside[0].tempability = EMERADICT[:SPLASHPOTIONOFWEAKNESS][:name]
      pbShowAbilitySplash(playerside[0])
      pbDisplay(_INTL("A {1} hits the opposing Pokemon!", EMERADICT[:SPLASHPOTIONOFWEAKNESS][:name]))
      opponentside.each do |battler|
        battler.pbLowerStatStage(:ATTACK,1,battler) if battler.pbCanLowerStatStage?(:ATTACK)
      end
      pbHideAbilitySplash(playerside[0])
    end
    if hasEmera?(:TOTEMSTICKER)
      pbDisplay("Your Pokemons Totem aura flared to life!")
      playerside[0].tempability = EMERADICT[:TOTEMSTICKER][:name]
      pbShowAbilitySplash(playerside[0])
      playerside.each do |battler|
        userStats = battler.plainStats
        lowestStatValue = 0
        userStats.each_value { |value| lowestStatValue = value if lowestStatValue < value }
        GameData::Stat.each_main_battle do |s|
          next if userStats[s.id] > lowestStatValue
          if battler.pbCanRaiseStatStage?(s.id, battler)
            battler.pbRaiseStatStage(s.id, 1, battler)
          end
          break
        end
      end
      pbHideAbilitySplash(playerside[0])
    end

    if $PokemonGlobal.towervalues[:activeevent] == "Legendary" && legendaryBattle?
      getLooplet.emeras.each do |emera|
        next if !EMERADICT[emera][:Legendary]
        next if !EMERADICT[emera][:Legendary].include?($PokemonGlobal.towervalues[:activevariable])
        playerside[0].tempability = EMERADICT[emera][:name]
        pbShowAbilitySplash(playerside[0])
        pbDisplay(_INTL("Your {1} shines brightly", EMERADICT[emera][:name]))
        playerside.each do |battler|
          GameData::Stat.each_main_battle do |s|
            if battler.pbCanRaiseStatStage?(s.id, battler)
              battler.pbRaiseStatStage(s.id, 1, battler)
            end
          end
        end
        pbHideAbilitySplash(playerside[0])
        break
      end
    end
  end
end