def Undertale()
  UndertaleShopSetup()
  scene = Undertale_Scene.new
  playingBGS = nil
  playingBGM = nil
  if $game_system && $game_system.is_a?(Game_System)
    playingBGS = $game_system.getPlayingBGS
    playingBGM = $game_system.getPlayingBGM
    $game_system.bgm_pause
    $game_system.bgs_pause
  end
  UndertaleCommand(scene)
  if $game_system && $game_system.is_a?(Game_System)
    $game_system.bgm_resume(playingBGM)
    $game_system.bgs_resume(playingBGS)
  end
  Input.update
end

def UndertaleCommand(scene)
  pbBGMPlay("Megalovania")
  loop do
    cmd = scene.UndertaleCommandMenu()
    pbSEPlay("MenuSelect")
    case cmd
    when 0    # Fight
      $PokemonGlobal.nextBattleBack = "Lava"
      $PokemonGlobal.nextBattleBGM = nil
      if !pbTrainerBattle(:Skeleton_Dev, "Shadross", nil, false, 1)
        $PokemonGlobal.battledepth = -1
        scene.pbEndBattle
        return
      end
    when 1    # Act
      scene.UndertaleActMenu()
    when 2    # Item
      scene.UndertaleItemMenu()
    when 3    # Mercy
      scene.pbEndBattle
      return
    end
  end
end

def UndertaleShopSetup()
  if $PokemonGlobal.cynthiabadgetier && $Trainer.numbadges > $PokemonGlobal.cynthiabadgetier
    $PokemonBag.pbDeleteItem(:SINNOHCOIN, 999)
    if !$PokemonGlobal.pcItemStorage
      $PokemonGlobal.pcItemStorage = PCItemStorage.new
    end
    $PokemonGlobal.pcItemStorage.pbDeleteItem(:SINNOHCOIN,999)
    $PokemonGlobal.cynthiaupgradechance = 0
    $PokemonGlobal.cynthiabadgetier = $Trainer.numbadges
    $PokemonGlobal.cynthiachance = 1000
  end
  $PokemonGlobal.shadrossstock = {
    :ULTRANECROZIUMZ => {
      "badges" => 0,
      "cost" => 48,
      "amount" => 1,
    },
    :BERRYJUICE => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 1,
    },
    :RAGECANDYBAR => {
      "badges" => 0,
      "cost" => 1,
      "amount" => 30,
    },
    :RUSTYBOTTLECAP => {
      "badges" => 0,
      "cost" => 1,
      "amount" => 6,
    },
    :BOTTLECAP => {
      "badges" => 0,
      "cost" => 3,
      "amount" => 6,
    },
    :GOLDENBOTTLECAP => {
      "badges" => 0,
      "cost" => 3,
      "amount" => 1,
    },
    :FRESHSTARTMOCHI => {
      "badges" => 0,
      "cost" => 1,
      "amount" => 50,
    },
    :ABILITYCAPSULE => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 1,
    },
    :RARECANDY => {
      "badges" => 0,
      "cost" => 3,
      "amount" => 5,
    },
    :AMULETCOIN => {
      "badges" => 0,
      "cost" => 3,
      "amount" => 1,
    },
    :SMOKEBALL => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 1,
    },
    :WIDELENS => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 1,
    },
    :LONELYMINT => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 2,
    },
    :ADAMANTMINT => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 2,
    },
    :NAUGHTYMINT => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 2,
    },
    :BRAVEMINT => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 2,
    },
    :BOLDMINT => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 2,
    },
    :IMPISHMINT => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 2,
    },
    :LAXMINT => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 2,
    },
    :RELAXEDMINT => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 2,
    },
    :MODESTMINT => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 2,
    },
    :MILDMINT => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 2,
    },
    :RASHMINT => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 2,
    },
    :QUIETMINT => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 2,
    },
    :CALMMINT => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 2,
    },
    :GENTLEMINT => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 2,
    },
    :CAREFULMINT => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 2,
    },
    :SASSYMINT => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 2,
    },
    :TIMIDMINT => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 2,
    },
    :HASTYMINT => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 2,
    },
    :JOLLYMINT => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 2,
    },
    :NAIVEMINT => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 2,
    },
    :SERIOUSMINT => {
      "badges" => 0,
      "cost" => 2,
      "amount" => 2,
    },
    :LUXURYBALL => {
      "badges" => 1,
      "cost" => 16,
      "amount" => 25,
    },
    :FOCUSSASH => {
      "badges" => 1,
      "cost" => 6,
      "amount" => 1,
    },
    :AIRBALLOON => {
      "badges" => 1,
      "cost" => 4,
      "amount" => 2,
    },
    :BLUNDERPOLICY => {
      "badges" => 1,
      "cost" => 4,
      "amount" => 2,
    },
    :ROCKYHELMET => {
      "badges" => 1,
      "cost" => 6,
      "amount" => 1,
    },
    :QUICKCLAW => {
      "badges" => 1,
      "cost" => 4,
      "amount" => 1,
    },
    :FOCUSBAND => {
      "badges" => 1,
      "cost" => 4,
      "amount" => 1,
    },
    :WEAKNESSPOLICY => {
      "badges" => 1,
      "cost" => 4,
      "amount" => 1,
    },
    :TERRAINEXTENDER => {
      "badges" => 1,
      "cost" => 6,
      "amount" => 1,
    },
    :PPMAX => {
      "badges" => 2,
      "cost" => 6,
      "amount" => 4,
    },
    :EXPERTBELT => {
      "badges" => 2,
      "cost" => 4,
      "amount" => 1,
    },
    :SHELLBELL => {
      "badges" => 2,
      "cost" => 6,
      "amount" => 1,
    },
    :FLAMEORB => {
      "badges" => 2,
      "cost" => 6,
      "amount" => 1,
    },
    :TOXICORB => {
      "badges" => 2,
      "cost" => 6,
      "amount" => 1,
    },
    :FROSTORB => {
      "badges" => 2,
      "cost" => 6,
      "amount" => 1,
    },
    :MUSCLEBAND => {
      "badges" => 2,
      "cost" => 4,
      "amount" => 1,
    },
    :WISEGLASSES => {
      "badges" => 2,
      "cost" => 4,
      "amount" => 1,
    },
    :ABILITYPATCH => {
      "badges" => 3,
      "cost" => 14,
      "amount" => 1,
    },
    :BLACKSLUDGE => {
      "badges" => 3,
      "cost" => 9,
      "amount" => 1,
    },
    :LUCKYPUNCH => {
      "badges" => 3,
      "cost" => 9,
      "amount" => 1,
    },
    :LEEK => {
      "badges" => 3,
      "cost" => 9,
      "amount" => 1,
    },
    :THICKCLUB => {
      "badges" => 3,
      "cost" => 9,
      "amount" => 1,
    },
    :LIGHTBALL => {
      "badges" => 3,
      "cost" => 9,
      "amount" => 1,
    },
    :CHOICESCARF => {
      "badges" => 4,
      "cost" => 12,
      "amount" => 1,
    },
    :HEALTHMOCHI => {
      "badges" => 5,
      "cost" => 10,
      "amount" => 52,
    },
    :MUSCLEMOCHI => {
      "badges" => 5,
      "cost" => 10,
      "amount" => 52,
    },
    :RESISTMOCHI => {
      "badges" => 5,
      "cost" => 10,
      "amount" => 52,
    },
    :GENIUSMOCHI => {
      "badges" => 5,
      "cost" => 10,
      "amount" => 52,
    },
    :CLEVERMOCHI => {
      "badges" => 5,
      "cost" => 10,
      "amount" => 52,
    },
    :SWIFTMOCHI => {
      "badges" => 5,
      "cost" => 10,
      "amount" => 52,
    },
    :EVIOLITE => {
      "badges" => 6,
      "cost" => 12,
      "amount" => 1,
    },
    :ASSAULTVEST => {
      "badges" => 6,
      "cost" => 12,
      "amount" => 1,
    },
    :LIFEORB => {
      "badges" => 7,
      "cost" => 14,
      "amount" => 1,
    },
    :LEFTOVERS => {
      "badges" => 7,
      "cost" => 14,
      "amount" => 1,
    },
    :CHOICEBAND => {
      "badges" => 8,
      "cost" => 16,
      "amount" => 1,
    },
    :CHOICESPECS => {
      "badges" => 8,
      "cost" => 16,
      "amount" => 1,
    },
    :THROATSPRAY => {
      "badges" => 8,
      "cost" => 16,
      "amount" => 3,
    },
    :KARMAKUT => {
      "badges" => 8,
      "cost" => 8,
      "amount" => 5,
    },
    :KARMAKLEAN => {
      "badges" => 8,
      "cost" => 16,
      "amount" => 5,
    },
    :KARMAKLIMB => {
      "badges" => 8,
      "cost" => 8,
      "amount" => 5,
    },
    :HPUP => {
      "badges" => 9,
      "cost" => 4,
      "amount" => 30,
    },
    :PROTEIN => {
      "badges" => 9,
      "cost" => 4,
      "amount" => 30,
    },
    :IRON => {
      "badges" => 9,
      "cost" => 4,
      "amount" => 30,
    },
    :CALCIUM => {
      "badges" => 9,
      "cost" => 2,
      "amount" => 30,
    },
    :ZINC => {
      "badges" => 9,
      "cost" => 4,
      "amount" => 30,
    },
    :CARBOS => {
      "badges" => 9,
      "cost" => 4,
      "amount" => 30,
    },
    :BERSERKGENE => {
      "badges" => 10,
      "cost" => 30,
      "amount" => 5,
    },
  }
end

class Undertale_Scene
  attr_reader   :viewport
  attr_reader   :sprites

  BLANK       = 0
  MESSAGE_BOX = 1
  COMMAND_BOX = 2

  MESSAGE_PAUSE_TIME = (Graphics.frame_rate*0.25).floor   # 1 second

  #=============================================================================
  # Updating and refreshing
  #=============================================================================
  def pbUpdate(cw=nil)
    pbGraphicsUpdate
    Input.update
    cw.update if cw
  end

  def pbGraphicsUpdate
    # Update lineup animations
    if @animations.length>0
      shouldCompact = false
      @animations.each_with_index do |a,i|
        a.update
        if a.animDone?
          a.dispose
          @animations[i] = nil
          shouldCompact = true
        end
      end
      @animations.compact! if shouldCompact
    end
    # Update other graphics
    Graphics.update
    @frameCounter += 1
    @frameCounter = @frameCounter%(Graphics.frame_rate*12/20)
  end
  #=============================================================================
  # Phases
  #=============================================================================
  def pbEndBattle()
    # Fade out all sprites
    pbBGMFade(1.0)
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
  end

  #=============================================================================
  # Create the battle scene and its elements
  #=============================================================================
  def initialize
    @animations = []
    @frameCounter = 0
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    # Create command window
    @sprites["commandWindow"] = UndertaleMenu.new(@viewport, 200)
    @sprites["actWindow"] = UndertaleActMenu.new(@viewport, 300)
    @sprites["actWindow"].visible = false
    @sprites["itemWindow"] = UndertaleItemMenu.new(@viewport, 300)
    @sprites["itemWindow"].visible = false
  end

  def UndertaleCommandMenu()
    cw = @sprites["commandWindow"]
    ret = -1
    loop do
      oldIndex = cw.index
      pbUpdate(cw)
      # Update selected command
      if Input.trigger?(Input::LEFT)
        cw.index = 3-((3 - cw.index + 1) % 4)
      elsif Input.trigger?(Input::RIGHT)
        cw.index = (cw.index + 1) % 4
      end
      pbSEPlay("MenuCursor") if cw.index!=oldIndex
      # Actions
      if Input.trigger?(Input::USE)                 # Confirm choice
        ret = cw.index
        break
      end
    end
    return ret
  end

  def UndertaleActMenu()
    cw = @sprites["actWindow"]
    cw.visible = true
    ret = -1
    loop do
      break
    end
    return ret
  end

  def UndertaleItemMenu()
    cw = @sprites["itemWindow"]
    msgBox = @sprites["commandWindow"].sprites["msgBox"]
    msgBox.text = ""
    cw.visible = true
    cw.visible = false
    cw.visible = true
    ret = -1
    loop do
      oldIndex = cw.index
      olditemindex = cw.itemindex
      pbUpdate(cw)
      # Update selected command
      if Input.trigger?(Input::UP)
        cw.index = cw.index - 1
      elsif Input.trigger?(Input::DOWN)
        cw.index = cw.index + 1
      elsif Input.trigger?(Input::RIGHT) 
        cw.index = cw.index + 1
        cw.index = cw.index + 1
        cw.index = cw.index + 1
        cw.index = cw.index + 1
        cw.index = cw.index + 1
      elsif Input.trigger?(Input::LEFT)
        cw.index = cw.index - 1
        cw.index = cw.index - 1
        cw.index = cw.index - 1
        cw.index = cw.index - 1
        cw.index = cw.index - 1
      end
      pbSEPlay("MenuCursor") if cw.index != oldIndex || cw.itemindex != olditemindex
      # Actions
      if Input.trigger?(Input::USE)                 # Confirm choice
        item = $PokemonGlobal.shadrossstock.keys[cw.itemindex + cw.index]
        if !item
          break
        end
        if $Trainer.numbadges < $PokemonGlobal.shadrossstock[item]["badges"]
          text = "Weak ass."
        elsif pbQuantity(:SINNOHCOIN) < $PokemonGlobal.shadrossstock[item]["cost"]
          text = "Broke ass."
        else
          text = "Bought #{$PokemonGlobal.shadrossstock[item]["amount"]} #{$PokemonGlobal.shadrossstock[item]["amount"] == 1 ? GameData::Item.get(item).name : GameData::Item.get(item).name_plural}."
          $PokemonBag.pbDeleteItem(:SINNOHCOIN, $PokemonGlobal.shadrossstock[item]["cost"])
          $PokemonBag.pbStoreItem(item, $PokemonGlobal.shadrossstock[item]["amount"])
        end
        cw.visible = false
        msgBox.text = ""
        pbWait(1)
        for i in 0..text.length()
          msgBox.text = text[0..i]
          pbSEPlay("BattleText")
          pbWait(1)
        end
        pbWait(40)
        cw.visible = true
      end
      if Input.trigger?(Input::BACK)
        break
      end
    end
    cw.visible = false
    pbWait(1)
    text = "You feel like you're going to have a bad time."
    for i in 0..text.length()
      msgBox.text = text[0..i]
      pbSEPlay("BattleText")
      pbWait(1)
    end
    return
  end
end

#===============================================================================
# Command menu (Fight/Pokémon/Bag/Run)
#===============================================================================
class UndertaleMenu

  attr_accessor :x
  attr_accessor :y
  attr_reader   :z
  attr_reader   :visible
  attr_reader   :color
  attr_reader   :index
  attr_reader   :mode
  attr_reader   :sprites
  TEST = 10

  def disposed?; return @disposed; end

  def visible=(value)
    @visible = value
    for i in @sprites
      i[1].visible = (value && @visibility[i[0]]) if !i[1].disposed?
    end
  end

  def color=(value)
    @color = value
    for i in @sprites
      i[1].color = value if !i[1].disposed?
    end
  end

  def index=(value)
    oldValue = @index
    @index = value
    refresh if @index!=oldValue
  end

  def mode=(value)
    oldValue = @mode
    @mode = value
    refresh if @mode!=oldValue
  end

  def addSprite(key,sprite)
    @sprites[key]    = sprite
    @visibility[key] = true
  end

  def setIndexAndMode(index,mode)
    oldIndex = @index
    oldMode  = @mode
    @index = index
    @mode  = mode
    refresh if @index!=oldIndex || @mode!=oldMode
  end

  def refresh; end

  def update
    pbUpdateSpriteHash(@sprites)
  end
  # Lists of which button graphics to use in different situations/types of battle.

  def initialize(viewport,z)
    @x          = 0
    @y          = 0
    @z          = 0
    @visible    = false
    @color      = Color.new(0,0,0,0)
    @index      = 0
    @mode       = 0
    @disposed   = false
    @sprites    = {}
    @visibility = {}
    backgroundsprite = Sprite.new(viewport)
    backgroundsprite.bitmap = Bitmap.new("Graphics/Battle animations/black_screen")
    addSprite("background",backgroundsprite)
    pbSEPlay("appearboost")
    pbWait(3)
    @heartsprite = Sprite.new(viewport)
    @heartsprite.bitmap = Bitmap.new("Graphics/Undertale/PlayerHeart/Default/000")
    @heartsprite.tone = Tone.new(0, -255, -255)
    @heartsprite.angle -= 90
    @heartsprite.x = Graphics.width / 2 + @heartsprite.width / 2
    @heartsprite.y = Graphics.height / 2 - @heartsprite.height
    addSprite("heartsprite", @heartsprite)
    @buttonmaps = [
      [
        Bitmap.new("Graphics/Undertale/UIFight/Default/000"),
        Bitmap.new("Graphics/Undertale/UIFight/Highlight/000")
      ],
      [
        Bitmap.new("Graphics/Undertale/UIAct/Default/000"),
        Bitmap.new("Graphics/Undertale/UIAct/Highlight/000")
      ],
      [
        Bitmap.new("Graphics/Undertale/UIItem/Default/000"),
        Bitmap.new("Graphics/Undertale/UIItem/Highlight/000")
      ],
      [
        Bitmap.new("Graphics/Undertale/UIMercy/Default/000"),
        Bitmap.new("Graphics/Undertale/UIMercy/Highlight/000")
      ]
    ]
    @buttons = Array.new(4) do |i|
      button = Sprite.new(viewport)
      button.bitmap = @buttonmaps[i][0]
      button.x      = (Graphics.width - button.width) * i/3
      button.y      = Graphics.height - button.height
      addSprite("button_#{i}",button)
      button.visible = false
      next button
    end
    pbWait(3)
    @heartsprite.visible = false
    pbWait(3)
    @heartsprite.visible = true
    pbWait(3)
    @heartsprite.visible = false
    pbWait(3)
    @heartsprite.visible = true
    @heartsprite.z = z + 4
    heartspritecoords = [@heartsprite.x, @heartsprite.y]
    targetcoords = [@buttons[0].x + 24, @buttons[0].y + 13]
    movecoords = [(targetcoords[0] - heartspritecoords[0]), (targetcoords[1] - heartspritecoords[1])]
    for i in 0...21
      @heartsprite.x = heartspritecoords[0] + (movecoords[0] * i / 20)
      @heartsprite.y = heartspritecoords[1] + (movecoords[1] * i / 20)
      pbWait(1)
    end
    for i in 0...@buttons.length
      button = @buttons[i]
      button.bitmap = @buttonmaps[i][i==@index? 1 : 0]
      button.visible = true
    end
    @skeleton = Sprite.new(viewport)
    @skeleton.bitmap = Bitmap.new("Graphics/Undertale/Skeleton")
    @skeleton.x = Graphics.width / 2 - @skeleton.width / 2
    @skeleton.y = Graphics.height / 4 - @skeleton.height / 2
    addSprite("skeleton", @skeleton)
    messageboxborder = Graphics.width / 100
    @messagebox = Sprite.new(viewport)
    @messagebox.bitmap = Bitmap.new("Graphics/Battle animations/black_screen")
    @messagebox.src_rect.height = Graphics.height / 3
    @messagebox.y = Graphics.height / 2
    @messagebox.tone = Tone.new(255, 255, 255)
    addSprite("messagebox", @messagebox)
    @messageboxinner = Sprite.new(viewport)
    @messageboxinner.bitmap = Bitmap.new("Graphics/Battle animations/black_screen")
    @messageboxinner.src_rect.height = @messagebox.src_rect.height - (messageboxborder * 2)
    @messageboxinner.src_rect.width = Graphics.width - (messageboxborder * 2)
    @messageboxinner.y = @messagebox.y + messageboxborder
    @messageboxinner.x = messageboxborder
    addSprite("messageboxinner", @messageboxinner)
    @msgBoxStar = Window_UnformattedTextPokemon.newWithSize("",
       @messagebox.x, @messagebox.y, Graphics.width / 10, @messagebox.height, viewport)
    @msgBoxStar.baseColor   = Color.new(255, 255, 255)
    @msgBoxStar.shadowColor = nil
    @msgBoxStar.windowskin  = nil
    @msgBoxStar.contents.font.name = MessageConfig.pbTryFonts("Determination Mono")
    @msgBoxStar.contents.font.size = 25
    @msgBoxStar.text = "*"
    addSprite("msgBoxStar",@msgBoxStar)
    @msgBox = Window_UnformattedTextPokemon.newWithSize("",
       @messagebox.x + Graphics.width / 20, @messagebox.y, @messagebox.width - Graphics.width / 20, @messagebox.height, viewport)
    @msgBox.baseColor   = Color.new(255, 255, 255)
    @msgBox.shadowColor = nil
    @msgBox.windowskin  = nil
    @msgBox.contents.font.name = MessageConfig.pbTryFonts("Determination Mono")
    @msgBox.contents.font.size = 25
    text = "You feel like you're going to have a bad time."
    for i in 0..text.length()
      @msgBox.text = text[0..i]
      pbSEPlay("BattleText")
      pbWait(1)
    end
    addSprite("msgBox",@msgBox)

    self.z = z
    refresh
  end

  def dispose
    return if disposed?
    pbDisposeSpriteHash(@sprites)
    @disposed = true
    @buttonBitmap.dispose if @buttonBitmap
  end

  def z=(value)
    @z = value
    for i in @sprites
      i[1].z = value if !i[1].disposed?
    end
    # @msgBox.z    += 1
  end

  def refreshButtons
    for i in 0...@buttons.length
      button = @buttons[i]
      button.bitmap = @buttonmaps[i][i==@index? 1 : 0]
      button.z          = self.z + ((i==@index) ? 3 : 2)
      if i==@index
        @heartsprite.x = button.x+24
        @heartsprite.y = button.y+13
        @heartsprite.z = self.z + 4
      end
    end
    @skeleton.z = self.z+1
    @messagebox.z = self.z+1
    @messageboxinner.z = self.z+2
    @msgBoxStar.z = self.z+4
    @msgBox.z = self.z+3
  end

  def refresh
    @msgBox.refresh
    @msgBoxStar.refresh
    refreshButtons
  end
end

class UndertaleActMenu

  attr_accessor :x
  attr_accessor :y
  attr_reader   :z
  attr_reader   :visible
  attr_reader   :color
  attr_reader   :index
  attr_reader   :mode

  def disposed?; return @disposed; end

  def visible=(value)
    @visible = value
    for i in @sprites
      i[1].visible = (value && @visibility[i[0]]) if !i[1].disposed?
    end
  end

  def color=(value)
    @color = value
    for i in @sprites
      i[1].color = value if !i[1].disposed?
    end
  end

  def index=(value)
    oldValue = @index
    @index = value
    refresh if @index!=oldValue
  end

  def mode=(value)
    oldValue = @mode
    @mode = value
    refresh if @mode!=oldValue
  end

  def addSprite(key,sprite)
    @sprites[key]    = sprite
    @visibility[key] = true
  end

  def setIndexAndMode(index,mode)
    oldIndex = @index
    oldMode  = @mode
    @index = index
    @mode  = mode
    refresh if @index!=oldIndex || @mode!=oldMode
  end

  def refresh; end

  def update
    pbUpdateSpriteHash(@sprites)
  end
  # Lists of which button graphics to use in different situations/types of battle.

  def initialize(viewport,z)
    @x          = 0
    @y          = 0
    @z          = 0
    @visible    = false
    @color      = Color.new(0,0,0,0)
    @index      = 0
    @mode       = 0
    @disposed   = false
    @sprites    = {}
    @visibility = {}
    self.z = z
    refresh
  end

  def dispose
    return if disposed?
    pbDisposeSpriteHash(@sprites)
    @disposed = true
    @buttonBitmap.dispose if @buttonBitmap
  end

  def z=(value)
    @z = value
    for i in @sprites
      i[1].z = value if !i[1].disposed?
    end
    # @msgBox.z    += 1
  end

  def refreshButtons
  end

  def refresh
    # @msgBox.refresh
    refreshButtons
  end
end


class UndertaleItemMenu

  attr_accessor :x
  attr_accessor :y
  attr_reader   :z
  attr_reader   :visible
  attr_reader   :color
  attr_reader   :index
  attr_reader   :itemindex
  attr_reader   :mode

  def disposed?; return @disposed; end

  def visible=(value)
    @visible = value
    for i in @sprites
      i[1].visible = (value && @visibility[i[0]]) if !i[1].disposed?
    end
  end

  def color=(value)
    @color = value
    for i in @sprites
      i[1].color = value if !i[1].disposed?
    end
  end

  def index=(value)
    if value < 0
      value = 0
    end
    if value > 4
      value = 4
    end
    if !((@itemindex==0 && value <= 2) || (@itemindex==($PokemonGlobal.shadrossstock.length-4) && value >= 2))
      @itemindex += value - @index
      @index = 2
      refresh
    else
      oldValue = @index
      @index = value
      refresh if @index!=oldValue
    end
  end

  def mode=(value)
    oldValue = @mode
    @mode = value
    refresh if @mode!=oldValue
  end

  def addSprite(key,sprite)
    @sprites[key]    = sprite
    @visibility[key] = true
  end

  def setIndexAndMode(index,mode)
    oldIndex = @index
    oldMode  = @mode
    @index = index
    @mode  = mode
    refresh if @index!=oldIndex || @mode!=oldMode
  end

  def refresh; end

  def update
    pbUpdateSpriteHash(@sprites)
  end
  # Lists of which button graphics to use in different situations/types of battle.

  def initialize(viewport,z)
    @x          = 0
    @y          = 0
    @z          = 0
    @visible    = false
    @color      = Color.new(0,0,0,0)
    @index      = 0
    @itemindex  = 0
    @mode       = 0
    @disposed   = false
    @sprites    = {}
    @visibility = {}
    shopboxborder = Graphics.width / 100
    @shopbox = Sprite.new(viewport)
    @shopbox.bitmap = Bitmap.new("Graphics/Battle animations/black_screen")
    @shopbox.src_rect.height = Graphics.height / 2
    @shopbox.y = Graphics.height / 2
    @shopbox.tone = Tone.new(255, 255, 255)
    addSprite("shopbox", @shopbox)
    @shopboxinner = Sprite.new(viewport)
    @shopboxinner.bitmap = Bitmap.new("Graphics/Battle animations/black_screen")
    @shopboxinner.src_rect.height = @shopbox.src_rect.height - (shopboxborder * 2)
    @shopboxinner.src_rect.width = Graphics.width - (shopboxborder * 2)
    @shopboxinner.y = @shopbox.y + shopboxborder
    @shopboxinner.x = shopboxborder
    addSprite("shopboxinner", @shopboxinner)
    @shoplistings = Array.new(5) do |i|
      item = $PokemonGlobal.shadrossstock.keys[@itemindex+i]
      item = GameData::Item.get(item) if item
      itemtext = Window_UnformattedTextPokemon.newWithSize("",
         @shopbox.x + Graphics.width / 10 + Graphics.width / 20, @shopbox.y + (i*30), @shopbox.width - Graphics.width / 10 - Graphics.width / 20, @shopbox.height, viewport)
      itemtext.baseColor   = Color.new(255, 255, 255)
      itemtext.shadowColor = nil
      itemtext.windowskin  = nil
      itemtext.contents.font.name = MessageConfig.pbTryFonts("Determination Mono")
      itemtext.contents.font.size = 25
      itemtext.text = item.name if item
      itemtext.text = "Exit" if !item
      addSprite("itemtext_#{i}",itemtext)
      next itemtext
    end
    @shopamount = Array.new(5) do |i|
      item = $PokemonGlobal.shadrossstock.keys[@itemindex+i]
      itemtext = Window_UnformattedTextPokemon.newWithSize("",
         @shopbox.x + Graphics.width / 20, @shopbox.y + (i*30), @shopbox.width - Graphics.width / 20, @shopbox.height, viewport)
      itemtext.baseColor   = Color.new(255, 255, 255)
      itemtext.shadowColor = nil
      itemtext.windowskin  = nil
      itemtext.contents.font.name = MessageConfig.pbTryFonts("Determination Mono")
      itemtext.contents.font.size = 25
      itemtext.text = $PokemonGlobal.shadrossstock[item]["amount"].to_s if item
      itemtext.text = "" if !item
      addSprite("itemamount_#{i}",itemtext)
      next itemtext
    end
    @shopprices = Array.new(5) do |i|
      item = $PokemonGlobal.shadrossstock.keys[@itemindex+i]
      itemcost = $PokemonGlobal.shadrossstock[item]["cost"] if item
      itembadges = $PokemonGlobal.shadrossstock[item]["badges"] if item
      itemtext = Window_UnformattedTextPokemon.newWithSize("",
         @shopbox.x + Graphics.width / 10 + Graphics.width / 20 + Graphics.width * 1 / 2, @shopbox.y + (i*30), @shopbox.width - Graphics.width / 10 - Graphics.width / 20 - Graphics.width * 1 / 2, @shopbox.height, viewport)
      itemtext.baseColor   = Color.new(255, 255, 255)
      itemtext.shadowColor = nil
      itemtext.windowskin  = nil
      itemtext.contents.font.name = MessageConfig.pbTryFonts("Determination Mono")
      itemtext.contents.font.size = 25
      itemtext.text = "#{itembadges} Badges" if item
      itemtext.text = "#{itembadges} Badge" if item && itembadges == 1
      itemtext.text = "#{itemcost} Coins" if item && itembadges <= $Trainer.numbadges
      itemtext.text = "1 Coin" if item && itembadges <= $Trainer.numbadges && itemcost == 1
      itemtext.text = "" if !item
      addSprite("itemprice_#{i}",itemtext)
      next itemtext
    end
    @heartsprite = Sprite.new(viewport)
    @heartsprite.bitmap = Bitmap.new("Graphics/Undertale/PlayerHeart/Default/000")
    @heartsprite.tone = Tone.new(0, -255, -255)
    @heartsprite.angle -= 90
    @heartsprite.x = @shopboxinner.x + @heartsprite.width * 1.5
    @heartsprite.y = @shoplistings[@index].y + Graphics.width / 20 + 1
    addSprite("heartsprite",@heartsprite)
    self.z = z
    refresh
  end

  def dispose
    return if disposed?
    pbDisposeSpriteHash(@sprites)
    @disposed = true
    @buttonBitmap.dispose if @buttonBitmap
  end

  def z=(value)
    @z = value
    for i in @sprites
      i[1].z = value if !i[1].disposed?
    end
    # @msgBox.z    += 1
  end

  def refreshButtons
    @shopbox.z = self.z + 1
    @shopboxinner.z = self.z + 2
    for i in 0...@shoplistings.length
      itemtext = @shoplistings[i]
      item = $PokemonGlobal.shadrossstock.keys[@itemindex+i]
      item = GameData::Item.get(item) if item
      itemtext.text = item.name if item
      itemtext.text = "Exit" if !item
      itemtext.z = self.z + 3
      if i==@index
        @heartsprite.y = itemtext.y + Graphics.width / 20 + 1
        @heartsprite.z = self.z+5
      end
    end
    for i in 0...@shopamount.length
      item = $PokemonGlobal.shadrossstock.keys[@itemindex+i]
      itemtext = @shopamount[i]
      itemtext.text = $PokemonGlobal.shadrossstock[item]["amount"].to_s if item
      itemtext.text = "" if !item
      itemtext.z = self.z + 4
    end
    for i in 0...@shopprices.length
      item = $PokemonGlobal.shadrossstock.keys[@itemindex+i]
      itemcost = $PokemonGlobal.shadrossstock[item]["cost"] if item
      itembadges = $PokemonGlobal.shadrossstock[item]["badges"] if item
      itemtext = @shopprices[i]
      itemtext.text = "#{itembadges} Badges" if item
      itemtext.text = "#{itemcost} Coins" if item && itembadges <= $Trainer.numbadges
      itemtext.text = "1 Coin" if item && itembadges <= $Trainer.numbadges && itemcost == 1
      itemtext.text = "" if !item
      itemtext.z = self.z + 4
    end
  end

  def refresh
    # @msgBox.refresh
    refreshButtons
  end
end