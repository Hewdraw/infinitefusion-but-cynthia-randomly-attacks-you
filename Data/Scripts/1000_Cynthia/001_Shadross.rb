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
    cmd = scene.pbCommandMenu()
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
      print(1)
    when 2    # Item
      print(2)
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
  # Window displays
  #=============================================================================
  def pbShowWindow(windowType)
    # NOTE: If you are not using fancy graphics for the command/fight menus, you
    #       will need to make "messageBox" also visible if the windowtype if
    #       COMMAND_BOX/FIGHT_BOX respectively.
    #@sprites["messageBox"].visible    = (windowType==MESSAGE_BOX)
    #@sprites["messageWindow"].visible = (windowType==MESSAGE_BOX)
    @sprites["commandWindow"].visible = (windowType==COMMAND_BOX)
  end


  #=============================================================================
  # Sprites
  #=============================================================================
  def pbAddSprite(id,x,y,filename,viewport)
    sprite = IconSprite.new(x,y,viewport)
    if filename
      sprite.setBitmap(filename) rescue nil

    end
    @sprites[id] = sprite
    return sprite
  end

  def pbDisposeSprites
    pbDisposeSpriteHash(@sprites)
  end

  #=============================================================================
  # Phases
  #=============================================================================
  def pbEndBattle()
    pbShowWindow(BLANK)
    # Fade out all sprites
    pbBGMFade(1.0)
    pbFadeOutAndHide(@sprites)
    pbDisposeSprites
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
  end

  def pbCommandMenu()
    pbShowWindow(COMMAND_BOX)
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
        pbPlayDecisionSE
        ret = cw.index
        break
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
    @cmdWindow.index = @index if @cmdWindow
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
    @cmdWindow.index = @index if @cmdWindow
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
    # Create bitmaps
    # @buttonBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_command"))
    # Create action buttons
    # @buttons = Array.new(4) do |i|   # 4 command options, therefore 4 buttons
    # end
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
      next button
    end
    @heartsprite = Sprite.new(viewport)
    @heartsprite.bitmap = Bitmap.new("Graphics/Undertale/PlayerHeart/Default/000")
    @heartsprite.tone = Tone.new(0,-255,-255)
    @heartsprite.angle -= 90
    addSprite("heartsprite", @heartsprite)
    # fightsprite = Sprite.new(viewport)
    # fightsprite.bitmap = Bitmap.new("Graphics/Undertale/UIFight/Default/000")
    # fightsprite.x = 0
    # fightsprite.y = Graphics.height - fightsprite.height
    # addSprite("button_0",fightsprite)
    # actsprite = Sprite.new(viewport)
    # actsprite.bitmap = Bitmap.new("Graphics/Undertale/UIAct/Default/000")
    # actsprite.x = (Graphics.width - actsprite.width) * 1/3
    # actsprite.y = Graphics.height - actsprite.height
    # addSprite("button_1",actsprite)
    # itemsprite = Sprite.new(viewport)
    # itemsprite.bitmap = Bitmap.new("Graphics/Undertale/UIItem/Default/000")
    # itemsprite.x = (Graphics.width - itemsprite.width) * 2/3
    # itemsprite.y = Graphics.height - itemsprite.height
    # addSprite("button_2",itemsprite)
    # mercysprite = Sprite.new(viewport)
    # mercysprite.bitmap = Bitmap.new("Graphics/Undertale/UIMercy/Default/000")
    # mercysprite.x = Graphics.width - mercysprite.width
    # mercysprite.y = Graphics.height - mercysprite.height
    # addSprite("button_3",mercysprite)
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
    @cmdWindow.z += 1 if @cmdWindow
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
  end

  def refresh
    # @msgBox.refresh
    @cmdWindow.refresh if @cmdWindow
    refreshButtons
  end
end