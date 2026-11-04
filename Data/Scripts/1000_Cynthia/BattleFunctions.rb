class PokeBattle_Battle
    def applyEffect(user, target, effect, duration = true, args = {})
        return false if target.effects.nil?
        if !args[:override]
            if target.effects[PBEffects.const_get(effect)].is_a?(Integer)
                return false if target.effects[PBEffects.const_get(effect)] > 0
            else
                return false if target.effects[PBEffects.const_get(effect)]
            end
        end
        case effect
        when :AquaRing
            pbDisplay(_INTL("{1} surrounded itself with a veil of water!",user.pbThis)) if !args[:nomessage]
        when :AuroraVeil
            pbDisplay(_INTL("{1}'s Defense and Special Defense is raised by the effect of Aurora Veil!", user.pbTeam))
            if user.hasActiveItem?(:LIGHTCLAY) && duration.is_a?(Integer)
                duration += 3
                duration += 3 if user.hasActiveAbility?(:HOLD)
            end
        when :Curse
            pbDisplay(_INTL("{1} laid a curse on {2}!", user.pbThis, target.pbThis(true))) if !args[:nomessage]
        when :GastoAcid
            return false if target.unstoppableAbility?
            target.effects[PBEffects::GastroAcid] = true
            target.effects[PBEffects::Truant] = false
            battle.pbDisplay(_INTL("{1}'s Ability was suppressed!", target.pbThis))
            target.pbOnAbilityChanged(target.ability)
            return true
        when :Gravity
            pbDisplay(_INTL("Gravity intensified!"))
            eachBattler do |b|
                showMessage = false
                if b.inTwoTurnAttack?("0C9", "0CC", "0CE") # Fly/Bounce/Sky Drop
                    b.effects[PBEffects::TwoTurnAttack] = nil
                    pbClearChoice(b.index) if !b.movedThisRound?
                    showMessage = true
                end
                if b.effects[PBEffects::MagnetRise] > 0 || b.effects[PBEffects::Telekinesis] > 0 || b.effects[PBEffects::SkyDrop] >= 0
                    b.effects[PBEffects::MagnetRise] = 0
                    b.effects[PBEffects::Telekinesis] = 0
                    b.effects[PBEffects::SkyDrop] = -1
                    showMessage = true
                end
                pbDisplay(_INTL("{1} couldn't stay airborne because of gravity!", b.pbThis)) if showMessage
            end
        when :LightScreen
            pbDisplay(_INTL("{1}'s Special Defense is raised by the Light Screen!", user.pbTeam))
            if !args[:recursion] && user.hasActiveItem?(:LIGHTTABLE)
                args[:recursion] = true
                applyEffect(user, target, :Reflect, duration, args)
            end
            if user.hasActiveItem?(:LIGHTCLAY) && duration.is_a?(Integer)
                duration += 3
                duration += 3 if user.hasActiveAbility?(:HOLD)
            end
        when :LuckyChant
            pbDisplay(_INTL("The Lucky Chant shielded {1} from critical hits!",user.pbTeam(true)))
        when :Mist
            pbDisplay(_INTL("{1} became shrouded in mist!", user.pbTeam))
        when :Reflect
            pbDisplay(_INTL("{1}'s Defense is raised by the Reflect!", user.pbTeam))
            if !args[:recursion] && user.hasActiveItem?(:LIGHTTABLE)
                args[:recursion] = true
                applyEffect(user, target, :LightScreen, duration, args)
            end
            if user.hasActiveItem?(:LIGHTCLAY) && duration.is_a?(Integer)
                duration += 3
                duration += 3 if user.hasActiveAbility?(:HOLD)
            end
        when :Yawn
            pbDisplay(_INTL("{1} made {2} drowsy!", user.pbThis, target.pbThis(true)))
        end
        duration += 1 if duration.is_a?(Integer) && user.hasActiveEmera?(:HEAVYCLAY) && [:AuroraVeil, :LightScreen, :LuckyChant, :Mist, :Rainbow, :Reflect, :Safeguard, :SeaOfFire, :Swamp, :Tailwind, :GmaxWildFire, :FairyLock, :Gravity, :MagicRoom, :TrickRoom, :WonderRoom, :InverseRoom]
        target.effects[PBEffects.const_get(effect)] = duration
        return true
    end
end