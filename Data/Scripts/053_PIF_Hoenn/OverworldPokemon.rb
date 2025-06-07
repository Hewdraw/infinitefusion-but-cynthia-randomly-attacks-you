
def player_near_event?(map_id, event_id, radius)
  return false if map_id != $game_map.map_id
  event = $game_map.events[event_id]
  return false if event.nil?
  dx = $game_player.x - event.x
  dy = $game_player.y - event.y
  distance = Math.sqrt(dx * dx + dy * dy)
  return distance <= radius
end

def checkOverworldPokemonFlee(radius=4)
  event = $game_map.event[@event_id]
  return player_near_event?($game_map.map_id, event.id, radius)
end