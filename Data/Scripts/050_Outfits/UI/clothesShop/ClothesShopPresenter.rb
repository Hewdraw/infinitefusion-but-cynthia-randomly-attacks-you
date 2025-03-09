class ClothesShopPresenter < PokemonMartScreen
  def pbChooseBuyItem

  end

  def initialize(scene, stock, adapter = nil, versions = false)
    super(scene, stock, adapter)
    @use_versions = versions
  end

  def putOnClothes(item)
    @adapter.putOnOutfit(item)
    @scene.pbEndBuyScene
  end


  def dyeClothes()
    original_color = $Trainer.clothes_color
    options = ["Shift up", "Shift down", "Reset", "Confirm", "Never Mind"]
    previous_input = 0
    ret = false
    while (true)
      choice = pbShowCommands(nil, options, options.length, previous_input,200)
      previous_input = choice
      case choice
      when 0 #NEXT
        pbSEPlay("GUI storage pick up", 80, 100)
        shiftClothesColor(10)
        ret = true
      when 1 #PREVIOUS
        pbSEPlay("GUI storage pick up", 80, 100)
        shiftClothesColor(-10)
        ret = true
      when 2 #Reset
        pbSEPlay("GUI storage pick up", 80, 100)
        $Trainer.clothes_color = 0
        ret = false
      when 3 #Confirm
        break
      else
        $Trainer.clothes_color = original_color
        ret = false
        break
      end
      @scene.updatePreviewWindow
    end
    return ret
  end


  # returns if should stay in the menu
  def playerClothesActionsMenu(item)
    cmd_wear = "Wear"
    cmd_dye = "Dye Kit"
    options = []
    options << cmd_wear
    options << cmd_dye  if $PokemonBag.pbHasItem?(:CLOTHESDYEKIT)
    options << "Cancel"
    choice = pbMessage("What would you like to do?", options, -1)

    if options[choice] == cmd_wear
      putOnClothes(item)
      $Trainer.clothes_color = @adapter.get_dye_color(item.id)
      return false
    elsif options[choice] == cmd_dye
      dyeClothes()
    end
    return true
  end

  def pbBuyScreen
    @scene.pbStartBuyScene(@stock, @adapter)
    @scene.select_specific_item(@adapter.worn_clothes) if !@adapter.isShop?
    item = nil
    loop do
      item = @scene.pbChooseBuyItem
      #break if !item
      if !item
        if pbConfirm(_INTL("Discard the changes to your outfit?"))
          break
        else
          item = @scene.pbChooseBuyItem
        end
      end


      if !@adapter.isShop?
        if @adapter.is_a?(ClothesMartAdapter)
          stay_in_menu = playerClothesActionsMenu(item)
          next if stay_in_menu
          return
        elsif @adapter.is_a?(HatsMartAdapter)
          stay_in_menu = playerHatActionsMenu(item)
          next if stay_in_menu
          return
        else
          if pbConfirm(_INTL("Would you like to put on the {1}?", item.name))
            putOnClothes(item)
            return
          end
          next
        end
        next
      end
      itemname = @adapter.getDisplayName(item)
      price = @adapter.getPrice(item)
      if !price.is_a?(Integer)
        pbDisplayPaused(_INTL("You already own this item!"))
        if pbConfirm(_INTL("Would you like to put on the {1}?", item.name))
          @adapter.putOnOutfit(item)
        end
        next
      end
      if @adapter.getMoney < price
        pbDisplayPaused(_INTL("You don't have enough money."))
        next
      end

      if !pbConfirm(_INTL("Certainly. You want {1}. That will be ${2}. OK?",
                          itemname, price.to_s_formatted))
        next
      end
      if @adapter.getMoney < price
        pbDisplayPaused(_INTL("You don't have enough money."))
        next
      end
      @adapter.setMoney(@adapter.getMoney - price)
      @stock.compact!
      pbDisplayPaused(_INTL("Here you are! Thank you!")) { pbSEPlay("Mart buy item") }
      @adapter.addItem(item)
      # break
    end
    @scene.pbEndBuyScene
  end

end