def generateMysteryDungeon
    $game_temp.player_new_map_id = 38
    $game_temp.player_new_x = 2
    $game_temp.player_new_y = 2
    $game_temp.player_new_direction = 2
    $scene.transfer_player
    $game_map.autoplay
    $game_map.refresh
    maparray = [[0]*52]*28
    maparray.each_with_index do |list, i|
        list.each_with_index do |tile, j|
            $game_map.data[j+2,i+2,0] = 22+384
        end
    end
    x = 3#+rand(52)
    y = 3#+rand(28)
    testevent = RPG::Event.new(x,y)
    key_id = ($game_map.events.keys.max || -1) + 1
    testevent.id = key_id
    testevent.x = x
    testevent.y = y
    testevent.pages[0].graphic.character_name = "BW126"
    event = Game_Event.new(38, testevent)
    event.id = key_id
    event.moveto(3,3)
    event.character_name = "BW126"
    $game_map.events[key_id] = event
end