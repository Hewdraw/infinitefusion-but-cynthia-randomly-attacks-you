
BattleHandlers::DamageCalcTargetAbility.add(:EMERA,
  proc { |ability,target,user,move,mults,baseDmg,type|
    if target.hasActiveEmera?(:MILOTICSCALE) && target.pbHasAnyStatus?
      mults[:defense_multiplier] *= 1.1
    end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:EMERA,
  proc { |ability,user,targets,move,battle|
    next if user.fainted?
    if user.hasActiveEmera?(:ABSORPTIONEMERA)
      targets.each do |b|
        next if !b.damageState.fainted
        user.tempability = EMERADICT[:ABSORPTIONEMERA][:name]
        battle.pbShowAbilitySplash(user)
        user.pbRecoverHP(user.totalhp / 4)
        @battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
        battle.pbHideAbilitySplash(user)
      end
    end
    if user.hasActiveEmera?(:GOLDENBELL)
      next if !user.canHeal?
      totalDamage = 0
      targets.each { |b| totalDamage += b.damageState.totalHPLost }
      next if totalDamage<=0
      user.tempability = EMERADICT[:GOLDENBELL][:name]
      battle.pbShowAbilitySplash(user)
      user.pbRecoverHP(totalDamage/8)
      @battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
      battle.pbHideAbilitySplash(user)
    end
  }
)
