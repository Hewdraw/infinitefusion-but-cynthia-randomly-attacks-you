
#Npc context an array of dialogues in order
# ex: ["NPC: hello, I'm an NPC"], ["Player: Hello!"]
def getRemoteNPCResponse(event_id)
  npc_event        = $game_map.events[event_id]
  npc_context      = get_npc_context(event_id)   # ["NPC: Hello...", "Player: ..."]
  npc_sprite_name  = npc_event.character_name
  current_location = Kernel.getMapName($game_map.map_id)

  # Build state params
  state_params = {
    context: npc_context,
    sprite: npc_sprite_name,
    location: current_location
  }

  # Convert into JSON-safe form (like battle code does)
  safe_params = convert_to_json_safe(state_params)
  json_data   = JSON.generate(safe_params)

  # Send to your remote dialogue server
  response = pbPostToString(Settings::REMOTE_NPC_DIALOG_SERVER_URL, { "npc_state" => json_data },10)
  response = clean_json_string(response)

  echoln "npc sprite name: #{npc_sprite_name}"
  echoln "current location: #{current_location}"
  echoln "[Remote NPC] Sent state: #{json_data}"
  echoln "[Remote NPC] Got response: #{response}"

  pbCallBub(2,event_id)
  pbMessage(response)
  return response
end
