class PokeBattle_Battle
    def applyEffect(user, target, effect, duration = true, recursion = false)
        return false if target.effects.nil?
        case effect
        when :AuroraVeil
            pbDisplay(_INTL("{1}'s Defense and Special Defense is raised bye the effect of Aurora Veil!", user.pbTeam(true)))
            if user.hasActiveItem?(:LIGHTCLAY) && duration.is_a?(Integer)
                duration += 3
                duration += 3 if user.hasActiveAbility?(:HOLD)
            end
        when :LightScreen
            pbDisplay(_INTL("{1}'s Special Defense is raised by the Light Screen!", user.pbTeam(true)))
            if !recursion && user.hasActiveItem?(:LIGHTTABLE)
                applyEffect(user, target, :Reflect, duration, true)
            end
            if user.hasActiveItem?(:LIGHTCLAY) && duration.is_a?(Integer)
                duration += 3
                duration += 3 if user.hasActiveAbility?(:HOLD)
            end
        when :Reflect
            pbDisplay(_INTL("{1}'s Defense is raised by the Reflect!", user.pbTeam(true)))
            if !recursion && user.hasActiveItem?(:LIGHTTABLE)
                applyEffect(user, target, :LightScreen, duration, true)
            end
            if user.hasActiveItem?(:LIGHTCLAY) && duration.is_a?(Integer)
                duration += 3
                duration += 3 if user.hasActiveAbility?(:HOLD)
            end
        end
        duration += 1 if duration.is_a?(Integer) && user.hasActiveEmera?(:HEAVYCLAY) && [:AuroraVeil, :LightScreen, :LuckyChant, :Mist, :Rainbow, :Reflect, :Safeguard, :SeaOfFire, :Swamp, :Tailwind, :GmaxWildFire, :FairyLock, :Gravity, :MagicRoom, :TrickRoom, :WonderRoom, :InverseRoom]
        target.effects[PBEffects.const_get(effect)] = duration
    end
end