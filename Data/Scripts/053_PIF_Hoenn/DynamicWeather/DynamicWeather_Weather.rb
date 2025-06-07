# Dynamic weather system by Chardub, for Pokemon Infinite Fusion

if Settings::GAME_ID == :IF_HOENN
  SaveData.register(:weather) do
    ensure_class :GameWeather
    save_value { $game_weather }
    load_value { |value|
      if value.is_a?(GameWeather)
        $game_weather = value
      else
        $game_weather = GameWeather.new
      end
      $game_weather.update_neighbor_map     # reupdate the neighbors map to account for new maps added

      $game_weather.initialize_weather unless $game_weather.current_weather
    }
    new_game_value { GameWeather.new }
  end
end
class GameWeather
  attr_accessor :current_weather
  attr_accessor :last_update_time

  TIME_BETWEEN_WEATHER_UPDATES = 12000 # 180 seconds, only actually changes once the player changes map

  CHANCE_OF_NEW_WEATHER = 2 # /100    spontaneous new weather popping up somewhere
  CHANCE_OF_RAIN = 40 #/100
  CHANCE_OF_SUNNY = 30 #/100
  CHANCE_OF_WINDY = 30 #/100
  CHANCE_OF_FOG = 30 #/100    Only possible in the morning, otherwise, when rain and sun combine

  MAX_INTENSITY_ON_NEW_WEATHER = 4


  CHANCES_OF_INTENSITY_INCREASE = 30 # /100
  CHANCES_OF_INTENSITY_DECREASE = 20 # /100
  BASE_CHANCE_OF_WEATHER_SPREAD = 15
  BASE_CHANCES_OF_WEATHER_END = 10 #/100 - For a weather intensity of 10. Chances should increase the lower the intensity is
  BASE_CHANCES_OF_WEATHER_MOVE = 10
  DEBUG_PROPAGATION = false

  COLD_MAPS = [444] # Rain is snow on that map (shoal cave)
  SNOW_LIMITS = [965,951] # Route 121, Pacifidlog - Snow turns to rain if it reaches these maps


  SANDSTORM_MAPS = [555] # Always sandstorm, doesn't spread
  SOOT_MAPS = [] # Always soot, doesn't spread
  NO_WIND_MAPS = [989] # Sootopolis, Petalburg Forest

  def set_weather(map_id, weather_type, intensity)
    @current_weather[map_id] = [weather_type, intensity]
    update_overworld_weather($game_map.map_id)
  end

  def map_current_weather_type(map_id)
    map_weather = @current_weather[map_id]
    return map_weather[0] if map_weather
  end

  def initialize
    @last_update_time = pbGetTimeNow
    echoln @last_update_time
    # Similar to roaming legendaries: A hash of all the maps accessible from one map
    @neighbors_maps = generate_neighbor_map_from_town_map
    initialize_weather
  end

  def initialize_weather
    weather = {}
    @neighbors_maps.keys.each { |map_id|
      weather[map_id] = select_new_weather_spawn
    }
    @current_weather = weather
  end

  def set_map_weather(map_id,weather_type,intensity)
    @current_weather[map_id] = [weather_type,intensity]
  end

  def get_map_weather_type(map_id)
    if !@current_weather[map_id]
      @current_weather[map_id] = [:None,0]
    end
    return @current_weather[map_id][0]
  end

  def get_map_weather_intensity(map_id)
    if !@current_weather[map_id]
      @current_weather[map_id] = [:None,0]
    end
    return @current_weather[map_id][1]
  end

  #Legendary weather conditions can't dissapear, so they're treated as their full force counterpart for spreading
  def normalize_legendary_weather(type, intensity)
    case type
    when :HarshSun   then [:Sunny, 10]
    when :HeavyRain  then [:Rain, 10]
    when :StrongWinds then [:Wind, 10]
    else [type, intensity]
    end
  end



  def update_weather()
    return if !$game_weather
    new_weather = @current_weather.dup
    new_weather.each do |map_id, (type, intensity)|
      try_end_weather(map_id,type, get_map_weather_intensity(map_id))
      try_spawn_new_weather(map_id,type, intensity)
      try_propagate_weather_to_neighbors(map_id,type, intensity)
      echoln @current_weather[954] if @debug_you
      try_move_weather_to_neighbors(map_id,type, intensity)
      try_weather_intensity_decrease(map_id,type, intensity)
      try_weather_intensity_increase(map_id,type, intensity)
    end
    update_overworld_weather($game_map.map_id)
    @last_update_time = pbGetTimeNow
  end

  def try_propagate_weather_to_neighbors(map_id,propagating_map_weather_type,propagating_map_weather_intensity)
    propagating_map_neighbors = @neighbors_maps[map_id]

    return if propagating_map_weather_type == :None
    return unless can_weather_spread(propagating_map_weather_type)
    propagating_map_weather_type, propagating_map_weather_intensity = normalize_legendary_weather(propagating_map_weather_type, propagating_map_weather_intensity)
    propagating_map_neighbors.each do |neighbor_id|
      neighbor_weather_type = get_map_weather_type(neighbor_id)
      neighbor_weather_intensity = get_map_weather_intensity(neighbor_id)
      should_propagate = roll_for_weather_propagation(propagating_map_weather_type, propagating_map_weather_intensity, neighbor_weather_type, neighbor_weather_intensity)
      next if !should_propagate
      propagated_weather_type = resolve_weather_interaction(propagating_map_weather_type, neighbor_weather_type, propagating_map_weather_intensity, neighbor_weather_intensity)
      propagated_weather_intensity = [propagating_map_weather_intensity - 1, 1].max
      new_weather = get_updated_weather(propagated_weather_type, propagated_weather_intensity, neighbor_id)
      @current_weather[neighbor_id] = new_weather
    end
  end

  def try_spawn_new_weather(map_id,map_weather_type,weather_intensity)
    return if map_weather_type != :None
    new_weather = select_new_weather_spawn
    @current_weather[map_id] = adjust_weather_for_map(new_weather,map_id)
  end


  def try_move_weather_to_neighbors(map_id,map_weather_type,weather_intensity)
    map_neighbors = @neighbors_maps[map_id]
    return if map_weather_type == :None || weather_intensity <= 1
    return unless can_weather_spread(map_weather_type)
    map_weather_type, weather_intensity = normalize_legendary_weather(map_weather_type, weather_intensity)

    map_neighbors.each do |neighbor_id|
      neighbor_weather_type = get_map_weather_type(neighbor_id)
      neighbor_weather_intensity = get_map_weather_intensity(neighbor_id)

      should_move_weather = roll_for_weather_move(map_weather_type)
      next if !should_move_weather
      next if neighbor_weather_type == map_weather_type && neighbor_weather_intensity >= weather_intensity
      result_weather_type = resolve_weather_interaction(map_weather_type, neighbor_weather_type, weather_intensity, neighbor_weather_intensity)
      result_weather_intensity = weather_intensity
      new_weather = [result_weather_type,result_weather_intensity]
      @current_weather[neighbor_id] = adjust_weather_for_map(new_weather,map_id)
    end
  end

  def try_weather_intensity_decrease(map_id,map_weather_type,weather_intensity)
    return unless can_weather_decrease(map_weather_type)
    should_change_intensity = roll_for_weather_decrease(map_weather_type)
    return if !should_change_intensity
    new_weather = [map_weather_type,weather_intensity-1]
    @current_weather[map_id] = adjust_weather_for_map(new_weather,map_id)
  end

  def try_weather_intensity_increase(map_id,map_weather_type,weather_intensity)
    return unless can_weather_increase(map_weather_type)
    should_change_intensity = roll_for_weather_increase(map_weather_type)
    return if !should_change_intensity
    new_weather = [map_weather_type,weather_intensity+1]
    @current_weather[map_id] = adjust_weather_for_map(new_weather,map_id)
  end

  def try_end_weather(map_id,map_weather_type,weather_intensity)
    return unless can_weather_end(map_weather_type)

    should_weather_end = roll_for_weather_end(map_weather_type,weather_intensity)
    return if !should_weather_end
    if weather_intensity >1
      map_weather_type = :Rain if map_weather_type == :Storm
      new_weather = [map_weather_type,0]
    else
      new_weather = [:None,0]
    end
    @current_weather[map_id] = adjust_weather_for_map(new_weather,map_id)
  end


  def adjust_weather_for_map(map_current_weather,map_id)
    type = map_current_weather[0]
    intensity = map_current_weather[1]
    return get_updated_weather(type,intensity,map_id)
  end

  def get_updated_weather(type, intensity, map_id)
    if COLD_MAPS.include?(map_id)
      type = :Snow if type == :Rain
      type = :Blizzard if type == :Storm
      type = :None if type == :Sunny
    end
    if SNOW_LIMITS.include?(map_id)
      type = :Rain if type == :Snow
    end


    if SOOT_MAPS.include?(map_id)
      type = :SootRain if type == :Rain
    end
    if NO_WIND_MAPS.include?(map_id)
      type = :None if type == :Wind
    end
    if SANDSTORM_MAPS.include?(map_id)
      type = :Sandstorm
      intensity = 9
    end
    if (PBDayNight.isNight? || PBDayNight.isEvening?) && type == :Sunny
      type = :None
      intensity = 0
    end
    return [type, intensity]
  end

  def get_map_name(map_id)
    mapinfos = pbLoadMapInfos
    if mapinfos[map_id]
      neighbor_map_name = mapinfos[map_id].name
    else
      neighbor_map_name = "Map #{map_id}"
    end
    return neighbor_map_name
  end

  def resolve_weather_interaction(incoming, existing, incoming_intensity, existing_intensity)
    return existing unless can_weather_end(existing)
    return incoming if existing == :None
    return :Fog if incoming == :Rain && existing == :Sunny
    return :Fog if incoming == :Sunny && existing == :Rain

    if incoming == :Rain && existing == :Wind
      return :Storm  if incoming_intensity >= 5 || existing_intensity >= 5
    end
    return incoming
  end

  def print_current_weather()
    mapinfos = pbLoadMapInfos
    echoln "Current weather :"
    @current_weather.each do |map_id, value|
      game_map = mapinfos[map_id]
      if game_map
        map_name = mapinfos[map_id].name
      else
        map_name = map_id
      end
      echoln "  #{map_name} : #{value}"
    end

  end

  def can_weather_spread(type)
    return false if type == :Sandstorm
    return true
  end

  def can_weather_move(type)
    return false if type == :Sandstorm
    return false if type == :HeavyRain
    return false if type == :HarshSun
    return false if type == :StrongWinds
    return true
  end

  def can_weather_end(type)
    return false if type == :Sandstorm
    return false if type == :HeavyRain
    return false if type == :HarshSun
    return false if type == :StrongWinds
    # Sandstorm and special weathers for kyogre/groudon/rayquaza
    return true
  end

  def can_weather_decrease(type)
    return false if type == :Sandstorm
    return false if type == :HeavyRain
    return false if type == :HarshSun
    return false if type == :StrongWinds
    # Sandstorm and special weathers for kyogre/groudon/rayquaza
    return true
  end

  def can_weather_increase(type)
    return false if type == :Sandstorm
    return false if type == :HeavyRain
    return false if type == :HarshSun
    return false if type == :StrongWinds
    # Sandstorm and special weathers for kyogre/groudon/rayquaza
    return true
  end

  def roll_for_weather_propagation(propagating_map_weather_type, propagating_map_weather_intensity, destination_map_weather_type, destination_map_weather_intensity)
    if propagating_map_weather_type == destination_map_weather_type
      # same weather, use highest intensity
      intensity_diff = [propagating_map_weather_intensity,destination_map_weather_intensity].max
      propagation_chance = (intensity_diff * BASE_CHANCE_OF_WEATHER_SPREAD)
    else
      intensity_diff = propagating_map_weather_intensity - destination_map_weather_intensity
      if intensity_diff > 0
        propagation_chance = (intensity_diff * BASE_CHANCE_OF_WEATHER_SPREAD)
      else
        return false# Other map's weather is stronger
      end
    end
    return rand(100) < propagation_chance
  end

  def roll_for_weather_end(type, current_intensity)
    return false if !can_weather_end(type)
    chances = BASE_CHANCES_OF_WEATHER_END
    chances += (10 - current_intensity) * 5
    return rand(100) <= chances
  end

  def roll_for_weather_move(type)
    return false if !can_weather_spread(type)
    return rand(100) <= BASE_CHANCES_OF_WEATHER_MOVE
  end

  def roll_for_weather_increase(type)
    return false if !can_weather_decrease(type)
    return rand(100) <= CHANCES_OF_INTENSITY_INCREASE
  end

  def roll_for_weather_decrease(type)
    return false if !can_weather_decrease(type)
    return rand(100) <= CHANCES_OF_INTENSITY_DECREASE
  end

  def select_new_weather_spawn
    return [:None, 0] if rand(100) >= CHANCE_OF_NEW_WEATHER

    base_intensity = rand(MAX_INTENSITY_ON_NEW_WEATHER) + 1

    weights = []
    weights << [:Rain, CHANCE_OF_RAIN]
    weights << [:Sunny, CHANCE_OF_SUNNY]
    weights << [:Wind, CHANCE_OF_WINDY]
    weights << [:Fog, CHANCE_OF_FOG] if PBDayNight.isMorning?

    total = weights.sum { |w| w[1] }
    roll = rand(total)

    sum = 0
    weights.each do |type, chance|
      sum += chance
      if roll < sum
        intensity = (type == :Fog) ? base_intensity + 2 : base_intensity
        return [type, intensity]
      end
    end

    return [:None, 0]  # Fallback
  end




end