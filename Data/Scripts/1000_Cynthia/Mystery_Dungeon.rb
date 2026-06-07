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

    def initialize
        @sprites    = {}
        @visibility = {}
        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99999
        backgroundsprite = Sprite.new(@viewport)
        backgroundsprite.bitmap = Bitmap.new("Graphics/Battle animations/black_screen")
        addSprite("background", backgroundsprite)
        textbitmap = Bitmap.new("Graphics/Transitions/MysteryDungeonTitlecard")
        bitmapoffset = [[""]*10, "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
                        [""]*3, "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q",
                        "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
                        "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"].flatten
        bitmapxcount = 20
        textlayer = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
        dungeontext1 = "Temporal"
        dungeontext2 = "Tower"
        floortext = ($PokemonGlobal.towervalues[:floor] + 1).to_s + "F"
        textarray = [dungeontext1, dungeontext2, "", floortext]
        textyoffset = (Graphics.height / 2) - 50
        textarray.each_with_index do |text,j|
            textxoffset = (Graphics.width / 2) - (text.length * 10 / 2)
            text.split("").each do |char|
                xoffset = 0
                yoffset = 0
                bitmapoffset.each_with_index do |bitmapchar, i|
                    next if char != bitmapchar
                    xoffset = (i % bitmapxcount) * 25
                    yoffset = (i / bitmapxcount) * 25
                    break
                end
                textlayer.bitmap.blt(textxoffset, textyoffset, textbitmap, Rect.new(xoffset, yoffset, 25, 25))
                textxoffset += 10
                textxoffset += 5 if ["M", "m", "W", "w"].include?(char)
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