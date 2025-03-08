class ClothesShopPresenter < PokemonMartScreen

  def removeHat(item)
    if item.id == @adapter.worn_clothes
      $Trainer.set_hat(nil,false)
      @adapter.worn_clothes = nil
    elsif item.id == @adapter.worn_clothes2
      $Trainer.set_hat(nil,true)
      @adapter.worn_clothes2 = nil
    end
  end

  def wearAsHat1(item)
    @adapter.set_secondary_hat(false)
    putOnClothes(item)
    $Trainer.set_hat_color(@adapter.get_dye_color(item),false)
  end
  def wearAsHat2(item)
    @adapter.set_secondary_hat(true)
    putOnClothes(item)
    $Trainer.set_hat_color(@adapter.get_dye_color(item),true)
  end

  def removeDye(item)
    if pbConfirm(_INTL("Are you sure you want to remove the dye from the {1}?", item.name))
      $Trainer.set_hat_color(0,@adapter.is_secondary_hat)
    end
  end

  def swapHats()
    hat1 = $Trainer.hat
    hat2 = $Trainer.hat2
    hat1_color = $Trainer.hat_color
    hat2_color = $Trainer.hat2_color

    $Trainer.hat = hat2
    $Trainer.hat2 = hat1
    $Trainer.hat_color = hat1_color
    $Trainer.hat2_color = hat2_color
    pbSEPlay("GUI naming tab swap start")


    new_selected_hat = @adapter.is_secondary_hat ? $Trainer.hat2 : $Trainer.hat
    @scene.select_specific_item(new_selected_hat)
  end


  def build_options_menu(cmd_confirm,cmd_remove,cmd_remove_dye,cmd_swap,cmd_cancel)
    options = []
    options << cmd_confirm
    options << cmd_remove

    options << cmd_swap
    remove_dye_option_available = $Trainer.hat_color(@adapter.is_secondary_hat) != 0
    options << cmd_remove_dye if remove_dye_option_available
    options << cmd_cancel
  end

  def build_wear_options(cmd_wear_hat1,cmd_wear_hat2,cmd_replace_hat1,cmd_replace_hat2)
    options = []
    primary_hat, secondary_hat = @adapter.worn_clothes, @adapter.worn_clothes2
    primary_cmds = primary_hat ? cmd_replace_hat1 : cmd_wear_hat1
    secondary_cmds = secondary_hat ? cmd_replace_hat2 : cmd_wear_hat2

    if @adapter.is_secondary_hat
      options << secondary_cmds
      options << primary_cmds
    else
      options << primary_cmds
      options << secondary_cmds
    end
    return options
  end


  def putOnHats()
    putOnHat($Trainer.hat,true,false)
    putOnHat($Trainer.hat2,true,true)
    @worn_clothes = $Trainer.hat
    @worn_clothes2 = $Trainer.hat2

    playOutfitChangeAnimation()
    pbMessage(_INTL("You put on the hat(s)!\\wtnp[30]"))
    @scene.pbEndBuyScene
  end
  def playerHatActionsMenu(item)
    cmd_confirm = "Confirm"

    cmd_remove = "Remove hat"
    cmd_cancel = "Cancel"
    cmd_remove_dye = "Remove dye"
    cmd_swap = "Swap hats positions"

    options = build_options_menu(cmd_confirm,cmd_remove,cmd_remove_dye,cmd_swap,cmd_cancel)

    choice = pbMessage("What would you like to do?", options, -1,nil,0)
    if options[choice] == cmd_remove
      removeHat(item)
      return true
    elsif options[choice] == cmd_confirm
      putOnHats()
      $Trainer.hat_color = @adapter.get_dye_color($Trainer.hat)
      $Trainer.hat2_color = @adapter.get_dye_color($Trainer.hat2)

      return false
    elsif options[choice] == cmd_remove_dye
      removeDye(item)
      return true
    elsif options[choice] == cmd_swap
      swapHats()
      return true
    end
    end
end
