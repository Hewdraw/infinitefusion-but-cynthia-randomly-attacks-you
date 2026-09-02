def mcChest(opponent, badge_bonus=0)
    opponent_override = nil
    if opponent == "Miku"
        opponent = [:CREATOR_Minecraft, "Hatsune Miku"]
        opponent_override = [nil, nil]
    elsif opponent == "Miku2"
        opponent = [:CHAMPION_Sinnoh, "Cynthia"]
        opponent_override = ["Hatsune Miku", :CREATOR_Minecraft2]
    elsif opponent == "Cynthia"
        opponent = [:CHAMPION_Sinnoh, "Cynthia"]
        opponent_override = [nil, nil]
    elsif opponent == "Cynthia2"
        opponent = [:CHAMPION_Sinnoh, "Cynthia"]
        opponent_override = [nil, :CHAMPION_Sinnoh2]
    end
    pbEncounterCynthia(opponent, opponent_override, false, badge_bonus)
end

def enderChest()
    $PokemonBag.pbDeleteItem(:SINNOHCOIN, 10) if $PokemonGlobal.towervalues.nil?
    itemlist = getEnderChestItems() 
    raritylist = getEnderChestWeights()
    totalrarities = raritylist.sum
    exodiaitems = [:EXODIATHEFORBIDDENONE, :LEFTARMOFTHEFORBIDDENONE, :RIGHTARMOFTHEFORBIDDENONE, :LEFTLEGOFTHEFORBIDDENONE, :RIGHTLEGOFTHEFORBIDDENONE]
    for item in 1..10
        if item >= 9
            totalrarities -= raritylist[0]
            raritylist[0] = 0
        end
        randomrarity = rand(totalrarities)
        if item <= 5
            randomrarity = 0
        end
        raritylist.each_with_index do |rarity, i|
            if randomrarity < rarity
                randomrarity = i
                break
            else
                randomrarity -= rarity
            end
        end
        itemcolor = getEnderChestRarityColors()[randomrarity]
        randomitem = itemlist[randomrarity][rand(itemlist[randomrarity].length)]
        if randomitem[0] == :EMERA
            pbMessage("You got an \\C[#{itemcolor}]Emera\\C[0]!")
            grantRandomEmera
            next
        end
        itemname = (randomitem[1] > 1) ? GameData::Item.get(randomitem[0]).name_plural : GameData::Item.get(randomitem[0]).name
        if $PokemonBag.pbStoreItem(*randomitem) 
            $PokemonGlobal.chestitemspulled.push(randomitem[0]) if exodiaitems.include?(randomitem[0])
            pbMessage("You got #{randomitem[1]} \\C[#{itemcolor}]#{itemname}\\C[0]!")
        end
    end

    if rand(20) == 0 && $PokemonGlobal.towervalues.nil?
        $PokemonGlobal.enderchest = true
        eventlist = getEventList()
        randomevent = eventlist[rand(eventlist.length)]
        pbMessage("You got #{randomevent[1]} \\C[5]#{randomevent[0]}\\C[0]!")
        randomevent[2].call
        $PokemonGlobal.enderchest = nil
    end
end

def getEventList()
    return [
        ["Hatsune Miku", 1, lambda {pbEncounterCynthia(encounter_type = "Hatsune Miku")}],
        ["Cynthia", 2, lambda {pbEncounterCynthia(encounter_type = [:CHAMPION_Sinnoh, "Cynthia"], nil, false, 0, 2)}],
        ["Dennis", 2, lambda {pbDoubleTrainerBattle(:TEAMROCKET, "Dennis", 0, nil, :TEAMROCKET, "Dennis", 1)}],
        ["Creeper", 1, lambda {pbLegendaryBattle("Creeper")}],
        ["Thunder Stone and 1 Creeper", 1, lambda {pbLegendaryBattle("Charged Creeper")}],
        ["Max Repel", 1, lambda {pbRepel(:MAXREPEL, 250)}],
        ["Hewdraw", 1, lambda {pbTrainerBattle(:Non_Skeleton_Dev, "Hewdraw")}],
        ["Shadross", 1, lambda {pbTrainerBattle(:Skeleton_Dev, "Shadross")}],
        ["Hatsune Miku", 1, lambda {pbEncounterCynthia(encounter_type = [:CHAMPION_Sinnoh, "Cynthia"], [:CREATOR_Minecraft, "Hatsune Miku"], false, 1)}],
    ]
end

def getEnderChestRarityColors()
    return [
        7, #gray
        3, #green
        1, #blue
        6, #yellow
        2, #red
    ]
end

def getEnderChestWeights()
    return [
        70, #common
        80, #rare
        36, #super rare
        16, #secret rare
        1, #ultimate rare
    ]
end

def getEnderChestItems()
    return getTowerItems() if !$PokemonGlobal.towervalues.nil?
    chestitems = [
        [ #common
            [:NUGGET, 5],
            [:SLOWPOKETAIL, 5],
            [:RELICGOLD, 5],
            [:RELICSTATUE, 5],
            [:STARPIECE, 5],
            [:COMETSHARD, 5],
            [:HEARTSCALE, 5],
            [:AIRBALLOON, 5],
            [:BRIGHTPOWDER, 1],
            [:ROCKYHELMET, 1],
            [:EJECTBUTTON, 5],
            [:REDCARD, 5],
            [:SHEDSHELL, 1],
            [:SMOKEBALL, 1],
            [:LUCKYEGG, 1],
            [:CLEANSETAG, 1],
            [:GRIPCLAW, 1],
            [:BINDINGBAND, 1],
            [:BIGROOT, 1],
            [:SHELLBELL, 1],
            [:MENTALHERB, 5],
            [:WHITEHERB, 5],
            [:POWERHERB, 5],
            [:MUSCLEBAND, 1],
            [:WISEGLASSES, 1],
            [:RAZORCLAW, 1],
            [:SCOPELENS, 1],
            [:WIDELENS, 1],
            [:ZOOMLENS, 1],
            [:KINGSROCK, 1],
            [:RAZORFANG, 1],
            [:QUICKCLAW, 1],
            [:FOCUSBAND, 1],
            [:FOCUSSASH, 5],
            [:HYPERPOTION, 5],
            [:FULLHEAL, 5],
            [:REVIVE, 1],
            [:RAGECANDYBAR, 5],
            [:HPUP, 5],
            [:PROTEIN, 5],
            [:IRON, 5],
            [:CALCIUM, 5],
            [:ZINC, 5],
            [:CARBOS, 5],
            [:GREATBALL, 5],
            [:PREMIERBALL, 5],
            [:ULTRABALL, 5],
            [:DUSKBALL, 5],
            [:QUICKBALL, 5],
            [:LUMBERRY, 5],
            [:SITRUSBERRY, 5],
            [:MANKEYPAW, 1],
            [:ABILITYCAPSULE, 5],
            [:BERSERKGENE, 5],
            [:BANANA, 5],
            [:SAFETYGOGGLES, 1],
            [:PROTECTIVEPADS, 1],
            [:TERRAINEXTENDER, 1],
            [:ELECTRICSEED, 5],
            [:PSYCHICSEED, 5],
            [:MISTYSEED, 5],
            [:GRASSYSEED, 5],
            [:WEAKNESSPOLICY, 5],
            [:SINNOHCOIN, 2],
            [:GOLDENBOTTLECAP, 5],
            [:ABILITYPATCH, 5],
            [:HEALTHMOCHI, 5],
            [:MUSCLEMOCHI, 5],
            [:RESISTMOCHI, 5],
            [:GENIUSMOCHI, 5],
            [:CLEVERMOCHI, 5],
            [:SWIFTMOCHI, 5],
            [:REDCARD, 5],
            [:MASTERBALL, 1],
        ],
        [ #rare
            [:DIAMOND, 1],
            [:BIGNUGGET, 5],
            [:RELICCROWN, 5],
            [:PEARLSTRING, 5],
            [:EVIOLITE, 1],
            [:HEATROCK, 1],
            [:DAMPROCK, 1],
            [:SMOOTHROCK, 1],
            [:ICYROCK, 1],
            [:LIGHTCLAY, 1],
            [:BLACKSLUDGE, 1],
            [:EXPERTBELT, 1],
            [:METRONOME, 1],
            [:FLAMEORB, 1],
            [:TOXICORB, 1],
            [:FROSTORB, 1],
            [:SHOCKORB, 1],
            [:LIGHTBALL, 1],
            [:THICKCLUB, 1],
            [:STICK, 1],
            [:MAXPOTION, 5],
            [:FULLRESTORE, 5],
            [:MAXREVIVE, 1],
            [:REVIVALHERB, 1],
            [:PPMAX, 1],
            [:CHERISHBALL, 5],
            [:EJECTPACK, 5],
            [:BLUNDERPOLICY, 5],
            [:THROATSPRAY, 5],
            [:MISTSTONE, 1]
        ],
        [ #super rare
            [:CHOICEBAND, 1],
            [:CHOICESPECS, 1],
            [:CHOICESCARF, 1],
            [:LEFTOVERS, 1],
            [:LIFEORB, 1],
            [:ASSAULTVEST, 1],
            [:LOADEDDICE, 1],
            [:HEAVYDUTYBOOTS, 1],
        ],
        [ #secret rare
            [:BUNDLEOFBALLOONS, 1],
            [:TOTEMOFUNDYING, 1],
            [:ENDCRYSTAL, 1],
            [:MINECRAFTBALL, 1],
            [:ELYTRA, 1],
            [:ENDERPEARL, 1],
            [:DIAMONDCHESTPLATE, 1],
            [:GOLDENAPPLE, 1],
            [:ENCHANTINGTABLE, 1],
            [:WELLSPRINGMASK, 1],
            [:HEARTHFLAMEMASK, 1],
            [:CORNERSTONEMASK, 1],
        ],
        [ #ultimate rare
            [:SACREDASH, 1],
        ],
    ]
    exodiaitems = [:EXODIATHEFORBIDDENONE, :LEFTARMOFTHEFORBIDDENONE, :RIGHTARMOFTHEFORBIDDENONE, :LEFTLEGOFTHEFORBIDDENONE, :RIGHTLEGOFTHEFORBIDDENONE]
    $PokemonGlobal.chestitemspulled = [] if $PokemonGlobal.chestitemspulled.nil?
    exodiaitems.each do |exodia|
        chestitems[4].push([exodia]) if $PokemonGlobal.chestitemspulled.include?(exodia)
    end

    return chestitems
end

def cactus()
    cactusarray = [11, 78, 79, 80]
    $PokemonGlobal.cactusheight = 3 if $PokemonGlobal.cactusheight == nil
    return if !pbWildBattle(:CACNEA, 5 + $PokemonGlobal.cactusheight)
    pbSetSelfSwitch(cactusarray[$PokemonGlobal.cactusheight], "A", true)
    $PokemonGlobal.cactusheight -= 1
end


def mcCrafting
    if !$PokemonBag.pbHasItem?(:RECIPEBOOK)
        Kernel.pbMessage("A Crafting Table!")
        Kernel.pbMessage("Unfortunately you don't know any recipes.")
        return
    end
    playingBGM = $game_system.getPlayingBGM
    scene = MinecraftCraftingScene.new()
    loop do
        break if !scene.update
    end
    pbBGMPlay(playingBGM)
end

CRAFTINGLIST = {
    :DIAMONDCHESTPLATE => [:DIAMOND, nil, :DIAMOND, :DIAMOND, :DIAMOND, :DIAMOND, :DIAMOND, :DIAMOND, :DIAMOND],
    :DIAMONDCHESTPLATE => [:ASSAULTVEST, :ENCHANTINGTABLE],
    :BUNDLEOFBALLOONS => [:AIRBALLOON, :AIRBALLOON, :LEFTOVERS],
    :ENCHANTEDGOLDENAPPLE => [:ENCHANTINGTABLE, :GOLDENAPPLE],
    :ENCHANTEDELYTRA => [:ELYTRA, :ENCHANTINGTABLE],
    :GOLDENBOTTLECAP => [:BOTTLECAP, :BOTTLECAP, :BOTTLECAP],
    :NETHERITECHESTPLATE => [:ASSAULTVEST, :DIAMONDCHESTPLATE],
    :FOCUSEDBANDANA => [:FOCUSBAND, :FOCUSSASH],
    :DETOXBOOTS => [:HEAVYDUTYBOOTS, :TOXICORB],
    :LOADEDDICESET => [:LOADEDDICE, :LOADEDDICE],
    :EVIOLYTE => [:EVIOLITE, :CHOICESCARF],
    :EVIOMITE => [:EVIOLITE, :CHOICEBAND, :CHOICESPECS],
    :EVERSTONEPLUS => [:EVIOLITE, :EVIOLYTE, :EVIOMITE],
    :GOLDENAPPLE => [:SITRUSBERRY, :BIGNUGGET, :BIGNUGGET],
    :LIFEBELL => [:LIFEORB, :SHELLBELL],
    :SAGE => [:POWERHERB, :WHITEHERB, :MENTALHERB],
    :METRONAGA => [:METRONOME, :METRONOME, :METRONOME],
    :LIGHTTABLE => [:LIGHTCLAY, :ENCHANTINGTABLE],
    :SHUDDERORB => [:TOXICORB, :SHOCKORB],
    :WINCINGORB => [:FLAMEORB, :FROSTORB],
    :WEIRDORB => [:WINCINGORB, :SHUDDERORB, :LIFEORB],
    :BIGNUGGET => [:NUGGET, :NUGGET],
    :TOXBOOTS => [:DETOXBOOTS, :ENCHANTINGTABLE],
    :HOTBOOTS => [:TOXBOOTS, :FLAMEORB],
    :COLDBOOTS => [:HOTBOOTS, :ENCHANTINGTABLE],
    :SHOCKBOOTS => [:COLDBOOTS, :SHOCKORB],
    :MEDIUMNUGGET => [:BIGNUGGET, :NUGGET],
    :CHICKENNUGGET => [:NUGGET, :MEDIUMNUGGET, :BIGNUGGET],
    :GOLDENCHICKENNUGGET => [:CHICKENNUGGET, :BIGNUGGET],
    :GOLDENCHICKEN => [:GOLDENCHICKENNUGGET, :ELYTRA, :LOADEDDICE],
    :SITRUSPAW => [:MANKEYPAW, :SITRUSBERRY],
    :PRIMALROCK => [:HEATROCK, :DAMPROCK],
    :DESERTEDROCK => [:SMOOTHROCK, :ICYROCK],
    #:SHADOWEDROCK => [:DESERTEDROCK, :PRIMALROCK],
    :MISTYSOWER => [:MISTYSEED, :ENCHANTINGTABLE, :TERRAINEXTENDER],
    :ELECTRICSOWER => [:ELECTRICSEED, :ENCHANTINGTABLE, :TERRAINEXTENDER],
    :PSYCHICSOWER => [:PSYCHICSEED, :ENCHANTINGTABLE, :TERRAINEXTENDER],
    :GRASSYSOWER => [:GRASSYSEED, :ENCHANTINGTABLE, :TERRAINEXTENDER],
    :BEEGSUCK => [:BIGROOT, :SHELLBELL, :LEFTOVERS],
    :MANKEYSCARF => [:MANKEYPAW, :CHOICESCARF, :QUICKCLAW],
    :THELENS => [:SCOPELENS, :WIDELENS, :ZOOMLENS],
    :SHADES => [:THELENS, :THELENS, :BLACKGLASSES],
    :HEAVYDUTYPANTS => [:HEAVYDUTYBOOTS, :ENCHANTINGTABLE],
    :HEAVYSUIT => [:HEAVYDUTYPANTS, :NETHERITECHESTPLATE],
    :FLIGHTLESSWINGSUIT => [:HEAVYSUIT, :ENCHANTEDELYTRA],
    :SCROLL => [:FOCUSEDBANDANA, :EXPERTBELT, :CHOICESCARF],
    :BERSERKBERRY => [:BERSERKGENE, :LUMBERRY],
    :ENCHANTINGTABLE => [:DIAMOND, :DIAMOND],
    :REAPERCLOTH => [:EVIOLITE, :DUSKSTONE],
    :BIGROOT => [:GRASSYSEED, :FRESHWATER],
    :SHADOWGEM => [:NORMALGEM, :DARKGEM, :GHOSTGEM],
    :LIVEORB => [:LIFEORB, :ENCHANTINGTABLE],
    :ASSAULTHELMET => [:LIFEORB, :ASSAULTVEST, :ROCKYHELMET],
    :FLINTANDSTEEL => [:FLAMEORB, :IRON],
    :FLINTNTANDSTEELNT => [:FLINTANDSTEEL, :FROSTORB],
    :THUNDERBALL => [:MISTSTONE, :LIGHTBALL],
    :HYPERGENE => [:BERSERKGENE, :PSYCHICGEM],
    :MAXREVIVE => [:REVIVE, :FULLRESTORE],
    :MISTSTONE => [:RARECANDY, :RAGECANDYBAR, :EVERSTONE],
    :BADAPPLE => [:LEFTOVERS, :ENCHANTINGTABLE, :LEPPABERRY],
    :MILLENNIUMANKH => [nil, :EXODIATHEFORBIDDENONE, nil, :RIGHTARMOFTHEFORBIDDENONE, nil, :LEFTARMOFTHEFORBIDDENONE, :RIGHTLEGOFTHEFORBIDDENONE, nil, :LEFTLEGOFTHEFORBIDDENONE]
}

class MinecraftCraftingScene
    def update
        return if @ending
        if Input.trigger?(Input::UP) && @cursorindex >= 0
            pbSEPlay("MenuCursor")
            loop do
                @cursorindex -= 5
                break if @cursorindex >= 0 && @cursorindex <= 19 && @sprites["craftable#{@cursorindex}"].visible
                break if @cursorindex < 0
            end
        end
        if Input.trigger?(Input::DOWN) && @cursorindex <= 19
            pbSEPlay("MenuCursor")
            loop do
                @cursorindex += 5
                break if @cursorindex >= 0 && @cursorindex <= 19 && @sprites["craftable#{@cursorindex}"].visible
                break if @cursorindex > 19
            end
        end
        if Input.trigger?(Input::LEFT) && @cursorindex >= 0
            pbSEPlay("MenuCursor")
            if @cursorindex <= 19
                loop do
                    if @cursorindex % 5 == 0
                        @cursorindex += 5
                    end
                    @cursorindex -= 1
                    break if @cursorindex >= 0 && @cursorindex <= 19 && @sprites["craftable#{@cursorindex}"].visible
                end
            elsif @cursorindex > 21
                @cursorindex = 21
            else
                @cursorindex = 23
            end

        end
        if Input.trigger?(Input::RIGHT) && @cursorindex >= 0
            pbSEPlay("MenuCursor")
            if @cursorindex <= 19
                loop do
                    @cursorindex += 1
                    if @cursorindex % 5 == 0
                        @cursorindex -= 5
                    end
                    break if @cursorindex >= 0 && @cursorindex <= 19 && @sprites["craftable#{@cursorindex}"].visible
                end
            elsif @cursorindex > 21
                @cursorindex = 21
            else
                @cursorindex = 23
            end
        end
        itemindex = @cursorindex + @activepage * 20
        itemtable = (@filtermode == 0) ? CRAFTINGLIST.keys : @craftablelist
        item = itemtable[itemindex]
        if Input.trigger?(Input::USE)
            pbSEPlay("MenuSelect")
            if @cursorindex < 0
                @filtermode = (@filtermode + 1) % 2
                itemtable = (@filtermode == 0) ? CRAFTINGLIST.keys : @craftablelist
                @cursorindex = -5
                @maxpages = itemtable.length() / 20
                @activepage = 0
                @sprites["filter"].bitmap = (@filtermode == 0) ? Bitmap.new("Graphics/Minecraft/filter_disabled") : Bitmap.new("Graphics/Minecraft/filter_enabled")
            elsif @cursorindex <= 19
                if @craftablelist.include?(item)
                    CRAFTINGLIST[item].each do |material|
                        $PokemonBag.pbDeleteItem(material, 1) if material
                    end
                    $PokemonBag.pbStoreItem(item)
                    Kernel.pbMessage("You crafted a #{GameData::Item.get(item).name}")
                    calculateCraftables
                    @cursorindex -= 1 unless @sprites["craftable#{@cursorindex}"].visible
                end
            elsif @cursorindex > 21
                changepage(@activepage + 1)
            else
                changepage(@activepage - 1)
            end
        end
        if Input.trigger?(Input::BACK)
            @ending = true
            endScreen
            return false
        end

        if @cursorindex >= 0 && @cursorindex <= 19
            @sprites["heart"].x = @sprites["craftable#{@cursorindex}"].x + @sprites["craftable0"].width / 2
            @sprites["heart"].y = @sprites["craftable#{@cursorindex}"].y + @sprites["craftable0"].height / 2
        elsif @cursorindex < 0
            @sprites["heart"].x = @sprites["filter"].x + @sprites["filter"].width / 2
            @sprites["heart"].y = @sprites["filter"].y + @sprites["filter"].height / 2
        elsif @cursorindex > 21
            @sprites["heart"].x = @sprites["rightarrow"].x
            @sprites["heart"].y = @sprites["rightarrow"].y + @sprites["rightarrow"].height / 2
        else
            @sprites["heart"].x = @sprites["leftarrow"].x
            @sprites["heart"].y = @sprites["leftarrow"].y + @sprites["leftarrow"].height / 2
        end
        for i in 0..19
            craftableitem = @sprites["craftable#{i}"]
            itemsprite = @sprites["itemicon#{i}"]
            itemindex = i + @activepage * 20
            itemslot = nil
            itemslot = itemtable[itemindex] if i < itemtable.length
            if !itemslot
                craftableitem.visible = false
                itemsprite.visible = false
                next
            end
            craftableitem.visible = true
            itemsprite.visible = true
            craftableitem.bitmap = (@craftablelist.include?(itemslot)) ? @craftablebitmap : @uncraftablebitmap
            itemsprite.item = itemslot
        end
        if item && @craftablelist.include?(item)
            @sprites["resulticon"].item = item
            @sprites["resulticon"].visible = true
        else
            @sprites["resulticon"].visible = false
        end
        for i in 0..8
            materialsprite = @sprites["materialicon#{i}"]
            materiallist = CRAFTINGLIST[item]
            if @cursorindex < 0 || @cursorindex > 19 || !item || !materiallist || i >= materiallist.length || !materiallist[i]
                materialsprite.visible = false
                for j in 0..2
                    @sprites["countshadow#{j}digit#{i}"].visible = false
                    @sprites["materialcount#{j}digit#{i}"].visible = false
                end
                next
            end
            materialsprite.visible = true
            materialsprite.item = materiallist[i]
            next if !materiallist[i]
            quantity = [$PokemonBag.pbQuantity(materiallist[i]), 999].min
            quantitydigits = quantity.to_s.split("")
            for j in 0..2
                countshadow = @sprites["countshadow#{j}digit#{i}"]
                countsprite = @sprites["materialcount#{j}digit#{i}"]
                if j >= quantitydigits.length
                    countshadow.visible = false
                    countsprite.visible = false
                    next
                end
                countshadow.visible = true
                countshadow.bitmap = @numbersbitmaps[quantitydigits[j].to_i]
                countsprite.visible = true
                countsprite.bitmap = @numbersbitmaps[quantitydigits[j].to_i]
            end
        end

        @sprites["activepageshadow"].bitmap = @numbersbitmaps[@activepage + 1]
        @sprites["activepagecount"].bitmap = @numbersbitmaps[@activepage + 1]
        @sprites["maxpageshadow"].bitmap = @numbersbitmaps[@maxpages + 1]
        @sprites["maxpagecount"].bitmap = @numbersbitmaps[@maxpages + 1]

        Graphics.update
        Input.update
        return true
    end

    def initialize
        @ending = false
        @sprites = {}
        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 999
        
        backgroundsprite = Sprite.new(@viewport)
        backgroundsprite.bitmap = Bitmap.new("Graphics/Battle animations/black_screen")
        backgroundsprite.opacity = 50
        addSprite("background", backgroundsprite)
        recipebooksprite = Sprite.new(@viewport)
        recipebooksprite.bitmap = Bitmap.new("Graphics/Minecraft/recipe_book")
        recipebooksprite.y = (Graphics.height / 2) - (recipebooksprite.height / 2)
        craftingtablesprite = Sprite.new(@viewport)
        craftingtablesprite.bitmap = Bitmap.new("Graphics/Minecraft/crafting_table")
        craftingtablesprite.y = (Graphics.height / 2) - (craftingtablesprite.height / 2)
        totalwidth = recipebooksprite.width + craftingtablesprite.width + 1
        recipebooksprite.x = (Graphics.width / 2) - (totalwidth / 2)
        craftingtablesprite.x = (Graphics.width / 2) - (totalwidth / 2) + recipebooksprite.width + 1
        addSprite("craftingtable", craftingtablesprite)
        addSprite("recipebook", recipebooksprite)
        @craftablebitmap = Bitmap.new("Graphics/Minecraft/slot_craftable")
        @uncraftablebitmap = Bitmap.new("Graphics/Minecraft/slot_uncraftable")
        @numbersbitmaps = [
            Bitmap.new("Graphics/Minecraft/0"),
            Bitmap.new("Graphics/Minecraft/1"),
            Bitmap.new("Graphics/Minecraft/2"),
            Bitmap.new("Graphics/Minecraft/3"),
            Bitmap.new("Graphics/Minecraft/4"),
            Bitmap.new("Graphics/Minecraft/5"),
            Bitmap.new("Graphics/Minecraft/6"),
            Bitmap.new("Graphics/Minecraft/7"),
            Bitmap.new("Graphics/Minecraft/8"),
            Bitmap.new("Graphics/Minecraft/9"),
        ]
        for i in 0..19
            craftableitem = Sprite.new(@viewport)
            craftableitem.bitmap = @craftablebitmap
            craftableitem.x = recipebooksprite.x + 12 + (craftableitem.width * (i % 5))
            craftableitem.y = recipebooksprite.y + 35 + (craftableitem.height * (i / 5))
            addSprite("craftable#{i}", craftableitem)
            itemsprite = ItemIconSprite.new(craftableitem.x + craftableitem.width / 2,craftableitem.y + craftableitem.height / 2,nil,@viewport)
            itemsprite.ox = itemsprite.width / 2
            itemsprite.oy = itemsprite.height / 2
            itemsprite.zoom_x = 0.5
            itemsprite.zoom_y = 0.5
            @sprites["itemicon#{i}"] = itemsprite
        end
        for i in 0..8
            materialsprite = ItemIconSprite.new(craftingtablesprite.x + 38 + (i % 3) * 18,craftingtablesprite.y + 25 + (i / 3) * 18,nil,@viewport)
            materialsprite.ox = materialsprite.width / 2
            materialsprite.oy = materialsprite.height / 2
            materialsprite.zoom_x = 0.35
            materialsprite.zoom_y = 0.35
            @sprites["materialicon#{i}"] = materialsprite
            for j in 0..2
                countshadow = Sprite.new(@viewport)
                countshadow.bitmap = @numbersbitmaps[0]
                countshadow.x = craftingtablesprite.x + 31 + (i % 3) * 18 + (6 * j)
                countshadow.y = craftingtablesprite.y + 26 + (i / 3) * 18
                countshadow.tone = Tone.new(-200, -200, -200)
                addSprite("countshadow#{j}digit#{i}", countshadow)
                materialcount = Sprite.new(@viewport)
                materialcount.bitmap = @numbersbitmaps[0]
                materialcount.x = craftingtablesprite.x + 30 + (i % 3) * 18 + (6 * j)
                materialcount.y = craftingtablesprite.y + 25 + (i / 3) * 18
                addSprite("materialcount#{j}digit#{i}", materialcount)
            end
        end
        resultsprite = ItemIconSprite.new(craftingtablesprite.x + 132,craftingtablesprite.y + 43,:MISTSTONE,@viewport)
        resultsprite.ox = resultsprite.width / 2
        resultsprite.oy = resultsprite.height / 2
        resultsprite.zoom_x = 0.5
        resultsprite.zoom_y = 0.5
        @sprites["resulticon"] = resultsprite

        @cursorindex = 0
        @activepage = 0
        @maxpages = CRAFTINGLIST.keys().length() / 20
        @filtermode = 0
        filtersprite = Sprite.new(@viewport)
        filtersprite.bitmap = Bitmap.new("Graphics/Minecraft/filter_disabled")
        filtersprite.x = @sprites["craftable4"].x
        filtersprite.y = recipebooksprite.y + 10
        addSprite("filter", filtersprite)
        rightarrowsprite = Sprite.new(@viewport)
        rightarrowsprite.bitmap = Bitmap.new("Graphics/Minecraft/page_forward")
        rightarrowsprite.ox = rightarrowsprite.width / 2
        rightarrowsprite.x = @sprites["craftable3"].x + @sprites["craftable3"].width / 2
        rightarrowsprite.y = recipebooksprite.y + recipebooksprite.height - 10 - rightarrowsprite.height
        addSprite("rightarrow", rightarrowsprite)
        leftarrowsprite = Sprite.new(@viewport)
        leftarrowsprite.bitmap = Bitmap.new("Graphics/Minecraft/page_backward")
        leftarrowsprite.ox = leftarrowsprite.width / 2
        leftarrowsprite.x = @sprites["craftable1"].x + @sprites["craftable1"].width / 2
        leftarrowsprite.y = recipebooksprite.y + recipebooksprite.height - 10 - leftarrowsprite.height
        addSprite("leftarrow", leftarrowsprite)

        heartsprite = Sprite.new(@viewport)
        if $PokemonGlobal.towervalues.nil?
            heartsprite.bitmap = Bitmap.new("Graphics/Undertale/PlayerHeart/Default/000")
            heartsprite.tone = Tone.new(0, -255, -255)
            heartsprite.angle -= 90
            heartsprite.ox = heartsprite.width / 2
            heartsprite.oy = heartsprite.height / 2
        else
            heartsprite.bitmap = Bitmap.new("Graphics/Minecraft/hardcore_full")
            heartsprite.zoom_x = 2
            heartsprite.zoom_y = 2
            heartsprite.ox = heartsprite.width / 2 + 5
            heartsprite.oy = heartsprite.height / 2
        end
        addSprite("heart", heartsprite)

        slashshadow = Sprite.new(@viewport)
        slashshadow.bitmap = Bitmap.new("Graphics/Minecraft/slash")
        slashshadow.x = recipebooksprite.x + recipebooksprite.width / 2 + 1
        slashshadow.ox = slashshadow.width / 2
        slashshadow.y = recipebooksprite.y + recipebooksprite.height - 14 - slashshadow.height
        slashshadow.tone = Tone.new(-200, -200, -200)
        addSprite("slashshadow", slashshadow)
        slash = Sprite.new(@viewport)
        slash.bitmap = Bitmap.new("Graphics/Minecraft/slash")
        slash.x = recipebooksprite.x + recipebooksprite.width / 2
        slash.ox = slash.width / 2
        slash.y = recipebooksprite.y + recipebooksprite.height - 15 - slash.height
        addSprite("slash", slash)

        activepageshadow = Sprite.new(@viewport)
        activepageshadow.bitmap = @numbersbitmaps[@activepage + 1]
        activepageshadow.x = recipebooksprite.x + recipebooksprite.width / 2 - slash.width + 1
        activepageshadow.ox = activepageshadow.width
        activepageshadow.y = recipebooksprite.y + recipebooksprite.height - 14 - activepageshadow.height
        activepageshadow.tone = Tone.new(-200, -200, -200)
        addSprite("activepageshadow", activepageshadow)
        activepagecount = Sprite.new(@viewport)
        activepagecount.bitmap = @numbersbitmaps[@activepage + 1]
        activepagecount.x = recipebooksprite.x + recipebooksprite.width / 2 - slash.width
        activepagecount.ox = activepagecount.width
        activepagecount.y = recipebooksprite.y + recipebooksprite.height - 15 - activepagecount.height
        addSprite("activepagecount", activepagecount)

        maxpageshadow = Sprite.new(@viewport)
        maxpageshadow.bitmap = @numbersbitmaps[@maxpages + 1]
        maxpageshadow.x = recipebooksprite.x + recipebooksprite.width / 2 + slash.width + 1
        maxpageshadow.y = recipebooksprite.y + recipebooksprite.height - 14 - maxpageshadow.height
        maxpageshadow.tone = Tone.new(-200, -200, -200)
        addSprite("maxpageshadow", maxpageshadow)
        maxpagecount = Sprite.new(@viewport)
        maxpagecount.bitmap = @numbersbitmaps[@maxpages + 1]
        maxpagecount.x = recipebooksprite.x + recipebooksprite.width / 2 + slash.width
        maxpagecount.y = recipebooksprite.y + recipebooksprite.height - 15 - maxpagecount.height
        addSprite("maxpagecount", maxpagecount)

        calculateCraftables
        update
    end

    def numberToImage(number)
        image = BitmapSprite.new(@sprites["craftingtable"].width,@sprites["craftingtable"].height,@viewport)
        number.to_s.split("").each_with_index do |value, i|
            image.bitmap.blt(0, i*8, @textbitmap, Rect.new(value.to_i * 8, 8, 8, 8))
        end
        return image
    end


    def changepage(page)
        if page > @maxpages
            @activepage = 0
            return
        end
        if page < 0
            @activepage = @maxpages
            return
        end
        @activepage = page
    end

    def calculateCraftables()
        @craftablelist = []
        CRAFTINGLIST.each do |item, materials|
            materialcount = {}
            materials.each do |material|
                next if !material
                materialcount[material] = 0 if materialcount[material].nil?
                materialcount[material] += 1
            end
            craftable = true
            materialcount.each do |material,value|
                craftable = false if $PokemonBag.pbQuantity(material) < value
            end
            @craftablelist.push(item) if craftable
        end
    end

    def addSprite(key,sprite)
        @sprites[key]    = sprite
    end

    def endScreen()
        # Fade out all sprites
        pbBGMFade(1.0)
        pbFadeOutAndHide(@sprites)
        pbDisposeSpriteHash(@sprites)
    end
end