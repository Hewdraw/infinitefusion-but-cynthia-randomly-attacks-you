def Undertale()
  scene = Undertale_Scene.new
  playingBGS = nil
  playingBGM = nil
  if $game_system && $game_system.is_a?(Game_System)
    playingBGS = $game_system.getPlayingBGS
    playingBGM = $game_system.getPlayingBGM
    $game_system.bgm_pause
    $game_system.bgs_pause
  end
  pbSceneStandby {
    UndertaleCommand(scene)
  }
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
      scene.UndertaleItemMenu
    when 3    # Mercy
      scene.pbEndBattle
      return
    end
  end
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
      if Input.trigger?(Input::BACK)                 # Confirm choice
        return
      end
    end
    return ret
  end

  def UndertaleItemMenu()
    cw = @sprites["itemWindow"]
    cw.visible = true
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
      if Input.trigger?(Input::BACK)                 # Confirm choice
        return
      end
    end
    return ret
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
  # NOTE: Button width is half the width of the graphic containing them all.
  BUTTON_HEIGHT = 46
  TEXT_BASE_COLOR   = PokeBattle_SceneConstants::MESSAGE_BASE_COLOR
  TEXT_SHADOW_COLOR = PokeBattle_SceneConstants::MESSAGE_SHADOW_COLOR

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
    # self.x = 0
    # self.y = Graphics.height-96
    # Create message box (shows "What will X do?")
    # @msgBox = Window_UnformattedTextPokemon.newWithSize("",
    #    self.x+16,self.y+2,220,Graphics.height-self.y,viewport)
    # @msgBox.baseColor   = TEXT_BASE_COLOR
    # @msgBox.shadowColor = TEXT_SHADOW_COLOR
    # @msgBox.windowskin  = nil
    # addSprite("msgBox",@msgBox)
    # Create background graphic
    # background = IconSprite.new(self.x,self.y,viewport)
    # background.setBitmap("Graphics/Pictures/Battle/overlay_command")
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
  # NOTE: Button width is half the width of the graphic containing them all.
  BUTTON_HEIGHT = 46
  TEXT_BASE_COLOR   = PokeBattle_SceneConstants::MESSAGE_BASE_COLOR
  TEXT_SHADOW_COLOR = PokeBattle_SceneConstants::MESSAGE_SHADOW_COLOR

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
  attr_reader   :mode
  # NOTE: Button width is half the width of the graphic containing them all.
  BUTTON_HEIGHT = 46
  TEXT_BASE_COLOR   = PokeBattle_SceneConstants::MESSAGE_BASE_COLOR
  TEXT_SHADOW_COLOR = PokeBattle_SceneConstants::MESSAGE_SHADOW_COLOR

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