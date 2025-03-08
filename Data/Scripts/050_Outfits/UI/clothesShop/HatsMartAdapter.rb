class HatsMartAdapter < OutfitsMartAdapter
  attr_accessor :worn_clothes
  attr_accessor :worn_clothes2

  DEFAULT_NAME = "[unknown]"
  DEFAULT_DESCRIPTION = "A headgear that trainers can wear."

  def initialize(stock = nil, isShop = nil, isSecondaryHat = false)
    super(stock,isShop,isSecondaryHat)
    @worn_clothes =  $Trainer.hat(false)
    @worn_clothes2 =  $Trainer.hat(true)
  end

  def toggleEvent(item)
    if !@isShop
      $Trainer.set_hat(nil,@is_secondary_hat)
      @worn_clothes = nil

      hat1_name = get_hat_by_id($Trainer.hat) ? get_hat_by_id($Trainer.hat).name : "(Empty)"
      hat2_name = get_hat_by_id($Trainer.hat2) ? get_hat_by_id($Trainer.hat2).name : "(Empty)"

      cmd_remove_hat1 = "Remove #{hat1_name}"
      cmd_remove_hat2 = "Remove #{hat2_name}"
      options = [cmd_remove_hat1,cmd_remove_hat2, "Cancel"]
      choice = optionsMenu(options)
      if options[choice] == cmd_remove_hat1
        $Trainer.set_hat(nil,false)
        @worn_clothes = nil
      elsif options[choice] == cmd_remove_hat2
        $Trainer.set_hat(nil,true)
        @worn_clothes = nil
      end
    end
  end

  def set_secondary_hat(value)
    @is_secondary_hat = value
  end

  def is_wearing_clothes(outfit_id)
    return outfit_id == @worn_clothes || outfit_id == @worn_clothes2
  end

  def toggleText()
    return
    # return if @isShop
    # toggleKey = "D"#getMappedKeyFor(Input::SPECIAL)
    # return "Remove hat: #{toggleKey}"
  end

  def switchVersion(item,delta=1)
    @is_secondary_hat = !@is_secondary_hat
  end

  def getName(item)
    return item.id
  end

  def getDescription(item)
    return DEFAULT_DESCRIPTION if !item.description
    return item.description
  end

  def getItemIcon(item)
    return Settings::BACK_ITEM_ICON_PATH if !item
    return getOverworldHatFilename(item.id)
  end

  def updateTrainerPreview(item, previewWindow)
    if item.is_a?(Outfit)
      previewWindow.set_hat(item.id,@is_secondary_hat)
      $Trainer.set_hat(item.id,@is_secondary_hat)# unless $Trainer.hat==nil
      set_dye_color(item,previewWindow)
    else
      $Trainer.set_hat(nil,@is_secondary_hat)
      previewWindow.set_hat(nil,@is_secondary_hat)
    end


    pbRefreshSceneMap
    previewWindow.updatePreview()
  end
  
  def get_dye_color(item)
    return 0 if isShop?
    $Trainer.dyed_hats= {} if ! $Trainer.dyed_hats
    if $Trainer.dyed_hats.include?(item.id)
      return $Trainer.dyed_hats[item.id]
    end
    return 0
  end
  
  
  def set_dye_color(item,previewWindow)
    if !isShop?
      $Trainer.dyed_hats= {} if !$Trainer.dyed_hats
      if $Trainer.dyed_hats.include?(item.id)
        dye_color = $Trainer.dyed_hats[item.id]
        $Trainer.set_hat_color(dye_color,@is_secondary_hat)
        previewWindow.hat_color = dye_color
      else
        $Trainer.set_hat_color(0,@is_secondary_hat)
        previewWindow.hat_color=0
      end
      #echoln $Trainer.dyed_hats
    else
      $Trainer.set_hat_color(0,@is_secondary_hat)
      previewWindow.hat_color=0
    end
  end


  def addItem(item)
    return unless item.is_a?(Outfit)
    changed_clothes = obtainHat(item.id,@is_secondary_hat)
    if changed_clothes
      @worn_clothes = item.id
    end
  end

  def get_current_clothes()
    return $Trainer.hat(@is_secondary_hat)
  end

  def putOnOutfit(item)
    return unless item.is_a?(Outfit)
    putOnHat(item.id,false,@is_secondary_hat)
    @worn_clothes = item.id
  end

  def reset_player_clothes()
    $Trainer.set_hat(@worn_clothes,@is_secondary_hat)
    $Trainer.set_hat_color($Trainer.dyed_hats[@worn_clothes],@is_secondary_hat) if  $Trainer.dyed_hats && $Trainer.dyed_hats[@worn_clothes]
  end

  def get_unlocked_items_list()
    return $Trainer.unlocked_hats
  end

  def getSpecialItemCaption(specialType)
    case specialType
    when :REMOVE_HAT
      return "Remove hat"
    end
    return nil
  end

  def getSpecialItemBaseColor(specialType)
    case specialType
    when :REMOVE_HAT
      return MessageConfig::BLUE_TEXT_MAIN_COLOR
    end
    return nil
  end

  def getSpecialItemShadowColor(specialType)
    case specialType
    when :REMOVE_HAT
      return MessageConfig::BLUE_TEXT_SHADOW_COLOR
    end
    return nil
  end

  def getSpecialItemDescription(specialType)
    echoln $Trainer.hair
    hair_situation = !$Trainer.hair || getSimplifiedHairIdFromFullID($Trainer.hair) == HAIR_BALD ? "bald head" : "fabulous hair"
    return "Go without a hat and show off your #{hair_situation}!"
  end

  def doSpecialItemAction(specialType,item=nil)
    toggleEvent(item)
  end
end
