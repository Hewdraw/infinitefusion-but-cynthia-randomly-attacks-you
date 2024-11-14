class PokeBattle_AI
  def pbCynthiaChooseEnemyCommand(idxBattler)
    threat = pbCynthiaAssessThreat(idxBattler)
    choices = []
    if @battle.battlers[idxBattler].dynamax == nil
      choices.push(*pbCynthiaItemScore(idxBattler))
      return if pbEnemyShouldWithdraw?(idxBattler)
      return if @battle.pbAutoFightMenu(idxBattler)
    end
    @battle.pbRegisterMegaEvolution(idxBattler) if pbEnemyShouldMegaEvolve?(idxBattler)
    pbChooseMoves(idxBattler)
  end

  def pbCynthiaAssessThreat(idxBattler)
    user = @battle.battlers[idxBattler]
    threat = []
    user.eachOpposing do |b|
      currentThreat = []
      b.eachMoveWithIndex do |move,i|
        currentThreat.push([move.name, pbRoughDamage(move,b,user,100,pbMoveBaseDamage(move,b,user,100))])
      end
      currentThreat.each do |damage|
        damagePercentage = damage/user.hp
        maxDamagePercentage = damage/user.totalhp
        if user.dynamax != nil
          maxDamagePercentage /= 2
        end
        hitsTaken = 100 / damagePercentage
        maxHitsTaken = 100 / maxDamagePercentage
        if b.pbSpeed >= user.pbSpeed
          hitsTaken -= 1
          maxHitsTaken -= 1
        end
      end
    end
  end

  def pbCynthiaItemScore(idxBattler)
    choices = []
    items = @battle.pbGetOwnerItems(idxBattler)

  end
end