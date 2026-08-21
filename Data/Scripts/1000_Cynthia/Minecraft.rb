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
      pbMessage("You got #{randomitem[1]} \\C[#{itemcolor}]#{itemname}\\C[0]!")
    end
  end

  if rand(10) == 0 && $PokemonGlobal.towervalues.nil?
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
    ["Hatsune Miku", 1, lambda {pbEncounterCynthia(encounter_type = "Hatsune Miku", nil, false, 1)}],
    ["Cynthia", 2, lambda {pbEncounterCynthia(encounter_type = [:CHAMPION_Sinnoh, "Cynthia"], nil, false, 0, 2)}],
    ["Dennis", 2, lambda {pbDoubleTrainerBattle(:TEAMROCKET, "Dennis", 0, nil, :TEAMROCKET, "Dennis")}],
    ["Creeper", 1, lambda {pbLegendaryBattle("Creeper")}],
    ["Thunder Stone and 1 Creeper", 1, lambda {pbLegendaryBattle("Charged Creeper")}],
    ["Max Repel", 1, lambda {pbRepel(:MAXREPEL, 250)}],
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
  return [
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
      [:MASTERBALL, 1],
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
      [:SACREDASH, 1],
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
      [:EXODIATHEFORBIDDENONE, 1],
      [:LEFTARMOFTHEFORBIDDENONE, 1],
      [:RIGHTARMOFTHEFORBIDDENONE, 1],
      [:LEFTLEGOFTHEFORBIDDENONE, 1],
      [:RIGHTLEGOFTHEFORBIDDENONE, 1],
    ],
  ]
end

def cactus()
  cactusarray = [11, 78, 79, 80]
  $PokemonGlobal.cactusheight = 3 if $PokemonGlobal.cactusheight == nil
  return if !pbWildBattle(:CACNEA, 5 + $PokemonGlobal.cactusheight)
  pbSetSelfSwitch(cactusarray[$PokemonGlobal.cactusheight], "A", true)
  $PokemonGlobal.cactusheight -= 1
end

def mcCrafting
    scene = MinecraftCraftingScene.new()
    loop do
        break if !scene.update
    end
end

CRAFTINGLIST = {
  :DIAMONDCHESTPLATE => [:ASSAULTVEST, :ENCHANTINGTABLE]
}

class MinecraftCraftingScene
    def update
        if Input.press?(Input::BACK)
            endScreen
            return false
        end
        Graphics.update
        Input.update
        return true
    end

    def initialize
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
        for i in 0..19
          craftableitem = Sprite.new(@viewport)
          craftableitem.bitmap = @craftablebitmap
          craftableitem.x = recipebooksprite.x + 12 + (craftableitem.width * (i % 5))
          craftableitem.y = recipebooksprite.y + 35 + (craftableitem.height * (i / 5))
          addSprite("craftable#{i}", craftableitem)
        end
        @cursorindex = 0
        @activepage = 0
        @maxpages = CRAFTINGLIST.keys().length() / 20

        pagecounter = Window_UnformattedTextPokemon.newWithSize("",
           recipebooksprite.x + 50, recipebooksprite.y + 120, recipebooksprite.width, recipebooksprite.height, @viewport)
        pagecounter.windowskin  = nil
        pagecounter.contents.font.name = MessageConfig.pbTryFonts("Minecraft Seven")
        pagecounter.contents.font.size = 14
        pagecounter.text = "#{@activepage+1}/#{@maxpages+1}"
    end

    def showPage()

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