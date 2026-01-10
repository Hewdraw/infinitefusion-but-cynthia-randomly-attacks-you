class BetterRegionMap
  DEBUG_WEATHER = $DEBUG
  def update_weather_icon(location)
    return
    return nil if !location
    map_id = location[4]
    return nil if !map_id

    weather_at_location = $game_weather.current_weather[map_id]
    return nil if weather_at_location.nil?

    weather_type = weather_at_location[0]
    weather_intensity = weather_at_location[1]

    icon = get_weather_icon(weather_type,weather_intensity)
    return nil if icon.nil?
    icon_path = "Graphics/Pictures/Weather/Cursor/" + icon

    # @sprites["weather"].visible=true
    @sprites["cursor"].bmp(icon_path)
    @sprites["cursor"].src_rect.width = @sprites["cursor"].bmp.height
    return weather_type

  end


  def draw_all_weather
    processed_locations =[]
    n=0
    for x in 0...(@window["map"].bmp.width / TileWidth)
      for y in 0...(@window["map"].bmp.height / TileHeight)

        for location in @data[2]
          if location[0] == x && location[1] == y

            map_id = location[4]

            next if !map_id
            next if processed_locations.include?(map_id)

            weather_at_location = $game_weather.current_weather[map_id]
            next if weather_at_location.nil?

            weather_type = weather_at_location[0]
            weather_intensity = weather_at_location[1]

            weather_icon = get_full_weather_icon_name(weather_type,weather_intensity)
            next if weather_icon.nil?
            weather_icon_path = "Graphics/Pictures/Weather/" + weather_icon
            @weatherIcons["weather#{n}"] = Sprite.new(@mapvp)
            @weatherIcons["weather#{n}"].bmp(weather_icon_path)
            @weatherIcons["weather#{n}"].src_rect.width = @weatherIcons["weather#{n}"].bmp.height
            @weatherIcons["weather#{n}"].x = TileWidth * x + (TileWidth / 2)
            @weatherIcons["weather#{n}"].y = TileHeight * y + (TileHeight / 2)
            @weatherIcons["weather#{n}"].oy = @weatherIcons["weather#{n}"].bmp.height / 2.0
            @weatherIcons["weather#{n}"].ox = @weatherIcons["weather#{n}"].oy

            processed_locations << map_id
            n= n+1
          end
        end
      end
    end
  end


  def new_weather_cycle
    return if !$game_weather
    @weatherIcons.dispose
    @weatherIcons = SpriteHash.new
    $game_weather.update_weather
    draw_all_weather
  end

end
def get_current_map_weather_icon
  return if !$game_weather
  current_weather= $game_weather.current_weather[$game_map.map_id]
  return if !current_weather
  weather_type = current_weather[0]
  weather_intensity = current_weather[1]
  icon = get_full_weather_icon_name(weather_type,weather_intensity)
  return "Graphics/Pictures/Weather/" +icon if icon
  return nil
end

def get_weather_icon(weather_type,intensity)
  case weather_type
  when :Sunny #&& !PBDayNight.isNight?
    icon_name = "mapSun"
  when :Rain
    icon_name = "mapRain"
  when :Fog
    icon_name = "mapFog"
  when :Wind
    icon_name = "mapWind"
  when :Storm
    icon_name = "mapStorm"
  when :Sandstorm
    icon_name = "mapSand"
  when :Snow
    icon_name = "mapSnow"
  when :HeavyRain
    icon_name = "mapHeavyRain"
  when :StrongWinds
    icon_name = "mapStrongWinds"
  when :HarshSun
    icon_name = "mapHarshSun"
  else
    icon_name = nil
  end
  return icon_name
end
def get_full_weather_icon_name(weather_type,intensity)
  return nil if !weather_type
  return nil if !intensity
  same_intensity_weather_types = [:Sandstorm,:Snow,:StrongWinds,:HeavyRain,:HarshSun]

  base_weather_icon_name = get_weather_icon(weather_type,intensity)
  icon_name = base_weather_icon_name
  return nil if !icon_name
  return icon_name if same_intensity_weather_types.include?(weather_type)
  if intensity <= 2
    icon_name += "_light"
  elsif intensity <=4
    icon_name += "_medium"
  else
    icon_name += "_heavy"
  end
  return icon_name
end

