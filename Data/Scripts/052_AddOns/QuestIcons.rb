def setDialogIconOff(eventId=nil)
  eventId = @event_id if !eventId
  event = $game_map.events[eventId]
  event.setDialogIconManualOffValue(true)
end

def setDialogIconOn(eventId=nil)
  eventId = @event_id if !eventId
  event = $game_map.events[eventId]
  event.setDialogIconManualOffValue(false)
end
class Game_Event < Game_Character
  #set from analyzing the event's content at load
  attr_accessor :show_quest_icon
  attr_accessor :show_dialog_icon

  #set manually from inside the event when triggered
  attr_accessor :quest_icon_manual_off
  attr_accessor :dialog_icon_manual_off

  QUEST_NPC_TRIGGER = "questNPC"
  MAPS_WITH_NO_ICONS = [] #Maps in which the game shouldn't try to look for quest icons(e.g. maps with a lot of events - mostly for possible performance issues)
  DIALOG_ICON_COMMENT_TRIGGER=["dialogIcon"]

  alias eventQuestIcon_init initialize
  def initialize(map_id, event, map=nil)
    eventQuestIcon_init(map_id, event, map)
    addQuestMarkersToSprite unless MAPS_WITH_NO_ICONS.include?($game_map.map_id)
  end

  def setDialogIconManualOffValue(value)
    @dialog_icon_manual_off=value
    @show_dialog_icon = !@dialog_icon_manual_off
  end
  def setQuestIconManualOffValue(value)
    @quest_icon_manual_off=value
    @show_quest_icon = !@quest_icon_manual_off
  end

  def addQuestMarkersToSprite()
    @show_quest_icon = detectQuestSwitch(self) && !@quest_icon_manual_off
    @show_dialog_icon = detectDialogueIcon(self) && !@dialog_icon_manual_off
  end

  def detectDialogueIcon(event)
    return nil if !validateEventIsCompatibleWithIcons(event)
    page = pbGetActiveEventPage(event)
    first_command = page.list[0]
    return nil if !(first_command.code == 108 || first_command.code == 408)
    comments = first_command.parameters
    return comments.any? { |str| DIALOG_ICON_COMMENT_TRIGGER.include?(str) }
  end

  def detectQuestSwitch(event)
    return nil if !validateEventIsCompatibleWithIcons(event)
    name = event.name.clone
    match = name.match(/#{Regexp.escape(QUEST_NPC_TRIGGER)}\(([^)]+)\)/)  # Capture anything inside parentheses
    return nil unless match
    quest_id = match[1]
    quest_id = quest_id.gsub(/^['"]|['"]$/, '')  # Remove quotes if they exist
    echoln "MATCH"
    echoln quest_id
    return nil if isQuestAlreadyAccepted?(quest_id)

    return quest_id
  end

  def validateEventIsCompatibleWithIcons(event)
    return false if event.is_a?(Game_Player)
    return false if event.erased
    page = pbGetActiveEventPage(event)
    return false unless page
    return false if page.graphic.character_name.empty?
    return true
  end

end



class Sprite_Character

  DIALOGUE_ICON_NAME = "Graphics/Pictures/Quests/dialogIcon"
  QUEST_ICON_NAME = "Graphics/Pictures/Quests/questIcon"
  attr_accessor :questIcon
  alias questIcon_init initialize
  def initialize(viewport, character = nil, is_follower=nil)
    questIcon_init(viewport,character)
    if character.is_a?(Game_Event) && character.show_dialog_icon
      addQuestMarkerToSprite(:DIALOG_ICON)
    end
    if character.is_a?(Game_Event) && character.show_quest_icon
      addQuestMarkerToSprite(:QUEST_ICON)
    end
    #addQuestMarkersToSprite(character) unless MAPS_WITH_NO_ICONS.include?($game_map.map_id)
  end



  # def addQuestMarkersToSprite(character)
  #   quest_id = detectQuestSwitch(character)
  #   if quest_id
  #     addQuestMarkerToSprite(:QUEST_ICON)
  #   else
  #     addQuestMarkerToSprite(:DIALOG_ICON) if detectDialogueIcon(character)
  #   end
  # end


  alias questIcon_update update
  def update
    questIcon_update
    updateGameEvent if @character.is_a?(Game_Event)
  end

  def updateGameEvent
    removeQuestIcon if !@character.show_dialog_icon && !@character.show_quest_icon
    positionQuestIndicator if @questIcon
  end

  alias questIcon_dispose dispose
  def dispose
    questIcon_dispose
    removeQuestIcon
  end




  # Event name must contain questNPC(x) for a quest icon to be displayed
  # Where x is the quest ID
  # if the quest has not already been accepted, the quest marker will be shown




  #type: :QUEST_ICON, :DIALOG_ICON
  def addQuestMarkerToSprite(iconType)
    removeQuestIcon if @questIcon
    @questIcon = Sprite.new(@viewport)
    case iconType
    when :QUEST_ICON
      iconPath = QUEST_ICON_NAME
    when :DIALOG_ICON
      iconPath = DIALOGUE_ICON_NAME
    end
    return if !iconPath
    @questIcon.bmp(iconPath)
    echoln @questIcon.bitmap
    positionQuestIndicator if @questIcon
  end

  def positionQuestIndicator()
    return if !@questIcon
    return if !@questIcon.bitmap

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
    @questIcon.dispose if @questIcon
    @questIcon = nil
  end

end
