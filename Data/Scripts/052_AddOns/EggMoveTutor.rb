def pbRelearnEggMoveScreen(pkmn)
  retval = true
  pbFadeOutIn {
    scene = MoveRelearner_Scene.new
    screen = MoveRelearnerScreen.new(scene)
    retval = screen.pbStartScreenEgg(pkmn)
  }
  return retval
end

class MoveRelearnerScreen
  def pbStartScreenEgg(pkmn)
    moves = []
    pbCreatePreEvolutionTree(pkmn.species).each do |species|
      moves.push(pbGetSpeciesEggMoves(species))
    end
    moves = moves.flatten

    @scene.pbStartScene(pkmn, moves)
    loop do
      move = @scene.pbChooseMove
      if move
        if @scene.pbConfirm(_INTL("Teach {1}?", GameData::Move.get(move).name))
          if pbLearnMove(pkmn, move)
            @scene.pbEndScene
            return true
          end
        end
      elsif @scene.pbConfirm(_INTL("Give up trying to teach a new move to {1}?", pkmn.name))
        @scene.pbEndScene
        return false
      end
    end
  end

  def pbCreatePreEvolutionTree(species)
    array = []
    if pbGetPreviousForm(species)
      array = pbCreatePreEvolutionTree(pbGetPreviousForm(species))
    end
    array.push(species)
    return array
  end
end
