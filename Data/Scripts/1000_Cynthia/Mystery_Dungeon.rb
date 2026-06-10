class FloorDisplay
    def visible=(value)
        @visible = value
        for i in @sprites
            i[1].visible = (value && @visibility[i[0]]) if !i[1].disposed?
        end
    end

    def addSprite(key,sprite)
        @sprites[key]    = sprite
        @visibility[key] = true
    end

    def initialize(event=nil)
        @sprites    = {}
        @visibility = {}
        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99999
        backgroundsprite = Sprite.new(@viewport)
        backgroundsprite.bitmap = Bitmap.new("Graphics/Battle animations/black_screen")
        addSprite("background", backgroundsprite)
        textbitmap = Bitmap.new("Graphics/Transitions/MysteryDungeonTitlecard")
        bitmapoffset = [[" ", 10], ["", 0], ["", 0], ["", 0], ["", 0], ["", 0], ["", 0], ["", 0], ["", 0], ["", 0], ["0", 13], ["1", 6], ["2", 11], ["3", 12], ["4", 13], ["5", 12], ["6", 13], ["7", 11], ["8", 13], ["9", 12],
                        ["", 0], ["", 0], ["", 0],  ["A", 13], ["B", 12], ["C", 11], ["D", 11], ["E", 11], ["F", 10], ["G", 14], ["H", 11], ["I", 4], ["J", 10], ["K", 11], ["L", 9], ["M", 14], ["N", 11], ["O", 12], ["P", 11], ["Q", 12],
                        ["R", 12], ["S", 12], ["T", 11], ["U", 10], ["V", 11], ["W", 15], ["X", 10], ["Y", 13], ["Z", 12], ["a", 10], ["b", 9], ["c", 9], ["d", 10], ["e", 9], ["f", 9], ["g", 9], ["h", 9], ["i", 3], ["j", 6], ["k", 8],
                        ["l", 3], ["m", 14], ["n", 9], ["o", 10], ["p", 9], ["q", 12], ["r", 8], ["s", 10], ["t", 10], ["u", 9], ["v", 9], ["w", 12], ["x", 9], ["y", 10], ["z", 9]]
        bitmapxcount = 20
        textlayer = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
        dungeontext1 = "Temporal"
        dungeontext2 = "Tower"
        if TOWER_EVENTS[$PokemonGlobal.towervalues[:activevariable]]
            dungeontext1 = TOWER_EVENTS[$PokemonGlobal.towervalues[:activevariable]][:location]
            dungeontext2 = ""
            dungeontext2 = TOWER_EVENTS[$PokemonGlobal.towervalues[:activevariable]][:location2] if TOWER_EVENTS[$PokemonGlobal.towervalues[:activevariable]][:location2]
        end
        floortext = ($PokemonGlobal.towervalues[:floor] + 1).to_s + "F"
        textarray = [dungeontext1, dungeontext2, "", floortext]
        displayarray = [[], [], [], []]
        textyoffset = (Graphics.height / 2) - 50
        textarray.each_with_index do |text,j|
            textxoffset = (Graphics.width / 2) - (text.length * 10 / 2)
            text.split("").each do |char|
                xoffset = 0
                yoffset = 0
                bitmapoffset.each_with_index do |bitmapchar, i|
                    next if char != bitmapchar[0]
                    displayarray[j].push([bitmapchar, i].flatten)
                    break
                end
            end
        end
        displayarray.each do |text|
            textlenght = 0
            text.each do |array|
                textlenght += array[1]
            end
            textxoffset = (Graphics.width / 2) - (textlenght / 2)
            text.each do |array|
                xoffset = (array[2] % bitmapxcount) * 25
                yoffset = (array[2] / bitmapxcount) * 25
                textlayer.bitmap.blt(textxoffset, textyoffset, textbitmap, Rect.new(xoffset, yoffset, 25, 25))
                textxoffset += array[1]
            end
            textyoffset += 25
            textyoffset -= 15 if text == ""
        end
        textlayer.zoom_x = 2
        textlayer.zoom_y = 2
        textlayer.x -= Graphics.width / 2
        textlayer.y -= Graphics.height / 1.9
        addSprite("text", textlayer)

    end

    def endScreen()
        # Fade out all sprites
        pbFadeOutAndHide(@sprites)
        pbDisposeSpriteHash(@sprites)
    end
end

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
end