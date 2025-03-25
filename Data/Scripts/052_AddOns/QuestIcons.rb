class Sprite_Character
  QUEST_NPC_TRIGGER = "questNPC"

  QUEST_ICON_FOLDER = "Graphics/Pictures/Quests/"
  QUEST_ICON_NAME = "Graphics/Pictures/Quests/questIcon"

  attr_accessor :questIcon

  alias questIcon_init initialize
  def initialize(viewport, character = nil, is_follower=nil)
    questIcon_init(viewport,character)
    quest_id = detectQuestSwitch(character)
    addQuestMarkerToSprite if quest_id
  end

  alias questIcon_update update
  def update
    questIcon_update
    positionQuestIndicator if @questIcon
    #removeQuestIcon if @questIcon && isQuestAlreadyAccepted?(@quest_switch)
  end

  alias questIcon_dispose dispose
  def dispose
    questIcon_dispose
    removeQuestIcon
  end
  # Event name must contain questNPC(x) for a quest icon to be displayed
  # Where x is the quest ID
  # if the quest has not already been accepted, the quest marker will be shown
  def detectQuestSwitch(event)
    return nil if event.is_a?(Game_Player)
    return nil if event.erased
    return nil unless pbGetActiveEventPage(event)
    name = event.name.clone
    match = name.match(/#{Regexp.escape(QUEST_NPC_TRIGGER)}\(([^)]+)\)/)  # Capture anything inside parentheses
    return nil unless match
    quest_id = match[1]
    quest_id = quest_id.gsub(/^['"]|['"]$/, '')  # Remove quotes if they exist
    return nil if isQuestAlreadyAccepted?(quest_id)
    return quest_id
  end


  def addQuestMarkerToSprite()
    removeQuestIcon if @questIcon
    @questIcon = Sprite.new(@viewport)
    @questIcon.bmp(QUEST_ICON_NAME)
    positionQuestIndicator
  end

  def positionQuestIndicator()
    y_offset =-70

    @questIcon.ox = @questIcon.bitmap.width / 2.0
    @questIcon.oy = @questIcon.bitmap.height / 2.0

    x_position = @character.screen_x
    y_position = @character.screen_y + y_offset
    @questIcon.x =  x_position
    @questIcon.y =  y_position
    @questIcon.z =  999
  end

  def removeQuestIcon()
    echoln "REMOVAL for #{self}"
    @questIcon.dispose if @questIcon
    @questIcon = nil
  end

end
