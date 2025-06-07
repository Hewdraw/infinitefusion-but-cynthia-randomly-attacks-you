# frozen_string_literal: true
SURF_SPLASH_ANIMATION_ID = 30

class Game_Temp
  attr_accessor :surf_patches

  def initializeSurfPatches
    @surf_patches = []
  end

  def clearSurfSplashPatches
    return unless $game_temp.surf_patches
    $game_temp.surf_patches.clear
  end
end

class Spriteset_Map
  alias surf_patch_update update
  def update
    surf_patch_update
    return unless $scene.is_a?(Scene_Map)
    return unless Settings::GAME_ID == :IF_HOENN
    return unless $PokemonGlobal.surfing
    return if Graphics.frame_count % 32 != 0
    animate_surf_water_splashes
  end
end


class SurfPatch
  MAX_NUMBER_SURF_SPLASHES = 6

  attr_accessor :shape      #Array of tiles coordinates (ex: [[10,20],[1,5]])

  def initialize(patch_size)
    x, y = getRandomPositionOnPerimeter(8, 6, $game_player.x, $game_player.y, 2)
    variance = rand(5..8)
    @shape =getRandomSplashPatch(patch_size,x,y,variance)
  end

  def getRandomSplashPatch(tile_count, center_x, center_y, variance = rand(4))
    return [] if tile_count <= 0

    center_pos = getRandomPositionOnPerimeter(tile_count, tile_count, center_x, center_y, variance)
    area = [center_pos]
    visited = { center_pos => true }
    queue = [center_pos]

    directions = [[1, 0], [-1, 0], [0, 1], [0, -1],
                  [1, 1], [-1, -1], [1, -1], [-1, 1]] # 8 directions

    while area.length < tile_count && !queue.empty?
      current = queue.sample
      queue.delete(current)
      cx, cy = current

      # Randomize how many directions to try (1 to 4)
      directions.shuffle.take(rand(1..4)).each do |dx, dy|
        nx, ny = cx + dx, cy + dy
        new_pos = [nx, ny]
        next if visited[new_pos]

        visited[new_pos] = true
        area << new_pos
        queue << new_pos

        break if area.length >= tile_count
      end
    end

    # Filter to keep only water tiles
    map_id = $game_map.map_id
    area.select! do |pos|
      x, y = pos
      terrain = $MapFactory.getTerrainTag(map_id, x, y, false)
      next false unless terrain&.can_surf  # Only water/surfable tiles
      $game_map.playerPassable?(x, y, 2)  # Direction 2 (down) or any direction for checking passability
    end
    return area
  end


end


def animate_surf_water_splashes
  animation_frequency = 16 #in frames
  return unless $game_temp.surf_patches
  return unless Graphics.frame_count % animation_frequency == 0
  $game_temp.surf_patches.each do |patch|
    next if patch.nil? || patch.shape.empty?
    patch.shape.each do |splash_tile|
      x_position= splash_tile[0]
      y_position = splash_tile[1]
      $scene.spriteset.addUserAnimation(SURF_SPLASH_ANIMATION_ID, x_position, y_position, true, 0)
    end
  end
end

def try_spawn_surf_water_splashes
  water_splash_chance = 0.1 #Chance each step 10%
  steps_interval = 5  # Only check once every 5 steps
  return if $PokemonGlobal.stepcount % steps_interval != 0
  return unless rand < water_splash_chance
  spawnSurfSplashPatch
end




Events.onStepTaken += proc { |sender, e|
  water_encounter_chance = 25

  next unless $scene.is_a?(Scene_Map)
  next unless Settings::GAME_ID == :IF_HOENN
  next unless $PokemonGlobal.surfing

  player_x = $game_player.x
  player_y = $game_player.y
  if $game_temp.surf_patches
    $game_temp.surf_patches.each_with_index do |patch,index|
      next unless patch && patch.shape
      if patch.shape.include?([player_x, player_y])
        next if rand(100) > water_encounter_chance
        $game_temp.surf_patches.delete_at(index)
        echoln "surf patch encounter!"
        wild_pokemon = $PokemonEncounters.choose_wild_pokemon(:Water)
        species = wild_pokemon[0]
        level = wild_pokemon[1]
        pbWildBattle(species, level)
        break
      end
    end
  end

  try_spawn_surf_water_splashes
}



def spawnSurfSplashPatch
  $game_temp.initializeSurfPatches unless $game_temp.surf_patches

  patch_size = [3,4,5,6].sample
  splash_patch = SurfPatch.new(patch_size)
  $game_temp.surf_patches << splash_patch
  $game_temp.surf_patches.shift if $game_temp.surf_patches.length >=  SurfPatch::MAX_NUMBER_SURF_SPLASHES
  echoln $game_temp.surf_patches
end











