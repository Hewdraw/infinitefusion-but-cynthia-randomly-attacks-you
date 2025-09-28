def isOutdoor()
  current_map = $game_map.map_id
  map_metadata = GameData::MapMetadata.try_get(current_map)
  return map_metadata && map_metadata.outdoor_map
end
