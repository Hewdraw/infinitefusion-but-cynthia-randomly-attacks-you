#===============================================================================
#
#===============================================================================
class Window_PokemonLooplet < Window_DrawableCommand
  attr_reader :pocket
  attr_accessor :sorting

  def initialize(bag,x,y,width,height)
    @bag        = bag
    @sorting = false
    @adapter = PokemonMartAdapter.new
    super(x,y,width,height)
    @selarrow  = AnimatedBitmap.new("Graphics/Pictures/Bag/cursor")
    @swaparrow = AnimatedBitmap.new("Graphics/Pictures/Bag/cursor_swap")
    self.windowskin = nil
  end

  def dispose
    @swaparrow.dispose
    super
  end

  def page_row_max; return PokemonLooplet_Scene::ITEMSVISIBLE; end
  def page_item_max; return PokemonLooplet_Scene::ITEMSVISIBLE; end

  def item
    return nil if !@bag.emeras[self.index]
    item = @bag.emeras[self.index]
    return item
  end

  def itemCount
    return @bag.emeras.length+1
  end

  def itemRect(item)
    if item<0 || item>=@item_max || item<self.top_item-1 ||
       item>self.top_item+self.page_item_max
      return Rect.new(0,0,0,0)
    else
      cursor_width = (self.width-self.borderX-(@column_max-1)*@column_spacing) / @column_max
      x = item % @column_max * (cursor_width + @column_spacing)
      y = item / @column_max * @row_height - @virtualOy
      return Rect.new(x, y, cursor_width, @row_height)
    end
  end

  def drawCursor(index,rect)
    if self.index==index
      bmp = (@sorting) ? @swaparrow.bitmap : @selarrow.bitmap
      pbCopyBitmap(self.contents,bmp,rect.x,rect.y+2)
    end
  end

  def drawItem(index,_count,rect)
    textpos = []
    rect = Rect.new(rect.x+16,rect.y+16,rect.width-16,rect.height)
    thispocket = @bag.emeras
    if index==self.itemCount-1
      textpos.push([_INTL("CLOSE LOOPLET"),rect.x,rect.y-2,false,self.baseColor,self.shadowColor])
    else
      item = thispocket[index]
      baseColor   = self.baseColor
      shadowColor = self.shadowColor
      if @bag.activeemeras.include?(item)
        case EMERADICT[item][:rarity]
        # when :COMMON
        #   baseColor = Color.new(160,160,168)
        #   shadowColor = Color.new(208,208,216)
        when :UNCOMMON
          baseColor = Color.new(96,176,72)
          shadowColor = Color.new(176,208,144)
        when :RARE
          baseColor = Color.new(0,112,248)
          shadowColor = Color.new(120,184,232)
        when :LEGENDARY
          baseColor = Color.new(232,208,32)
          shadowColor = Color.new(248,232,136)
        end
      else
        baseColor = shadowColor
      end
      if @sorting && index==self.index
        baseColor   = Color.new(224,0,0)
        shadowColor = Color.new(248,144,144)
      end
      textpos.push(
         [EMERADICT[item][:name],rect.x,rect.y-2,false,baseColor,shadowColor]
      )
    end
    pbDrawTextPositions(self.contents,textpos)
  end

  def refresh
    @item_max = itemCount()
    self.update_cursor_rect
    dwidth  = self.width-self.borderX
    dheight = self.height-self.borderY
    self.contents = pbDoEnsureBitmap(self.contents,dwidth,dheight)
    self.contents.clear
    for i in 0...@item_max
      next if i<self.top_item-1 || i>self.top_item+self.page_item_max
      drawItem(i,@item_max,itemRect(i))
    end
    drawCursor(self.index,itemRect(self.index))
  end

  def update
    super
    @uparrow.visible   = false
    @downarrow.visible = false
  end
end

#===============================================================================
# Bag visuals
#===============================================================================
class PokemonLooplet_Scene
  ITEMLISTBASECOLOR     = Color.new(88,88,80)
  ITEMLISTSHADOWCOLOR   = Color.new(168,184,184)
  ITEMTEXTBASECOLOR     = Color.new(248,248,248)
  ITEMTEXTSHADOWCOLOR   = Color.new(0,0,0)
  POCKETNAMEBASECOLOR   = Color.new(88,88,80)
  POCKETNAMESHADOWCOLOR = Color.new(168,184,184)
  ITEMSVISIBLE          = 7

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(bag)
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @bag        = bag
    #pbRefreshFilter
    @sliderbitmap = AnimatedBitmap.new("Graphics/Pictures/Bag/icon_slider")
    @pocketbitmap = AnimatedBitmap.new("Graphics/Pictures/Bag/icon_pocket")
    @sprites = {}
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["bagsprite"] = IconSprite.new(30,20,@viewport)
    # @sprites["pocketicon"] = BitmapSprite.new(186,32,@viewport)
    # @sprites["pocketicon"].x = 0
    # @sprites["pocketicon"].y = 224
    # @sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow",8,40,28,2,@viewport)
    # @sprites["leftarrow"].x       = -4
    # @sprites["leftarrow"].y       = 76
    # @sprites["leftarrow"].visible = (!@choosing || numfilledpockets>1)
    # @sprites["leftarrow"].play
    # @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport)
    # @sprites["rightarrow"].x       = 150
    # @sprites["rightarrow"].y       = 76
    # @sprites["rightarrow"].visible = (!@choosing || numfilledpockets>1)
    # @sprites["rightarrow"].play
    @sprites["itemlist"] = Window_PokemonLooplet.new(@bag,168,-8,314,40+32+ITEMSVISIBLE*32)
    @sprites["itemlist"].viewport    = @viewport
    @sprites["itemlist"].index       = @bag.getChoice
    @sprites["itemlist"].baseColor   = ITEMLISTBASECOLOR
    @sprites["itemlist"].shadowColor = ITEMLISTSHADOWCOLOR
    @sprites["itemicon"] = ItemIconSprite.new(48,Graphics.height-48,nil,@viewport)
    @sprites["itemtext"] = Window_UnformattedTextPokemon.newWithSize("",
       72, 270, Graphics.width - 72 - 24, 128, @viewport)
    @sprites["itemtext"].baseColor   = ITEMTEXTBASECOLOR
    @sprites["itemtext"].shadowColor = ITEMTEXTSHADOWCOLOR
    @sprites["itemtext"].visible     = true
    @sprites["itemtext"].windowskin  = nil
    @sprites["helpwindow"] = Window_UnformattedTextPokemon.new("")
    @sprites["helpwindow"].visible  = false
    @sprites["helpwindow"].viewport = @viewport
    @sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible  = false
    @sprites["msgwindow"].viewport = @viewport
    pbBottomLeftLines(@sprites["helpwindow"],1)
    pbDeactivateWindows(@sprites)
    pbRefresh
    pbFadeInAndShow(@sprites)
  end

  def pbFadeOutScene
    @oldsprites = pbFadeOutAndHide(@sprites)
  end

  def pbFadeInScene
    pbFadeInAndShow(@sprites,@oldsprites)
    @oldsprites = nil
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) if !@oldsprites
    @oldsprites = nil
    pbDisposeSpriteHash(@sprites)
    @sliderbitmap.dispose
    @pocketbitmap.dispose
    @viewport.dispose
  end

  def pbDisplay(msg,brief=false)
    UIHelper.pbDisplay(@sprites["msgwindow"],msg,brief) { pbUpdate }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"],msg) { pbUpdate }
  end

  def pbChooseNumber(helptext,maximum,initnum=1)
    return UIHelper.pbChooseNumber(@sprites["helpwindow"],helptext,maximum,initnum) { pbUpdate }
  end

  def pbShowCommands(helptext,commands,index=0)
    return UIHelper.pbShowCommands(@sprites["helpwindow"],helptext,commands,index) { pbUpdate }
  end

  def pbRefresh
    # Set the background image
    @sprites["background"].setBitmap(sprintf("Graphics/Pictures/Bag/bg_1"))
    # Set the bag sprite
    @sprites["bagsprite"].setBitmap("Graphics/Pictures/Bag/Looplet_artwork_PSMD")
    @sprites["bagsprite"].zoom_x = 0.6
    @sprites["bagsprite"].zoom_y = 0.6
    @sprites["bagsprite"].y = 40

    # # Draw the pocket icons
    # @sprites["pocketicon"].bitmap.clear
    # if @choosing && @filterlist
    #   for i in 1...@bag.pockets.length
    #     if @filterlist[i].length==0
    #       @sprites["pocketicon"].bitmap.blt(6+(i-1)*22,6,
    #          @pocketbitmap.bitmap,Rect.new((i-1)*20,28,20,20))
    #     end
    #   end
    # end
    # @sprites["pocketicon"].bitmap.blt(2+(@sprites["itemlist"].pocket-1)*22,2,
    #    @pocketbitmap.bitmap,Rect.new((@sprites["itemlist"].pocket-1)*28,0,28,28))
    # Refresh the item window
    @sprites["itemlist"].refresh
    # Refresh more things
    pbRefreshIndexChanged
  end

  def pbRefreshIndexChanged
    itemlist = @sprites["itemlist"]
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    # Draw the pocket name
    pbDrawTextPositions(overlay,[
       [GameData::Item.get(getLoopletType).name,94,176,2,POCKETNAMEBASECOLOR,POCKETNAMESHADOWCOLOR]
    ])
    # Draw slider arrows
    # showslider = false
    # if itemlist.top_row>0
    #   overlay.blt(470,16,@sliderbitmap.bitmap,Rect.new(0,0,36,38))
    #   showslider = true
    # end
    # if itemlist.top_item+itemlist.page_item_max<itemlist.itemCount
    #   overlay.blt(470,228,@sliderbitmap.bitmap,Rect.new(0,38,36,38))
    #   showslider = true
    # end
    # # Draw slider box
    # if showslider
    #   sliderheight = 174
    #   boxheight = (sliderheight*itemlist.page_row_max/itemlist.row_max).floor
    #   boxheight += [(sliderheight-boxheight)/2,sliderheight/6].min
    #   boxheight = [boxheight.floor,38].max
    #   y = 54
    #   y += ((sliderheight-boxheight)*itemlist.top_row/(itemlist.row_max-itemlist.page_row_max)).floor
    #   overlay.blt(470,y,@sliderbitmap.bitmap,Rect.new(36,0,36,4))
    #   i = 0
    #   while i*16<boxheight-4-18
    #     height = [boxheight-4-18-i*16,16].min
    #     overlay.blt(470,y+4+i*16,@sliderbitmap.bitmap,Rect.new(36,4,36,height))
    #     i += 1
    #   end
    #   overlay.blt(470,y+boxheight-18,@sliderbitmap.bitmap,Rect.new(36,20,36,18))
    # end
    # Set the selected item's icon
    @sprites["itemicon"].item = itemlist.item #todo
    # Set the selected item's description
    @sprites["itemtext"].text =
       (itemlist.item) ? EMERADICT[itemlist.item][:description] : _INTL("Close Looplet.")
  end

  # def pbRefreshFilter
  #   @filterlist = nil
  #   return if !@choosing
  #   return if @filterproc==nil
  #   @filterlist = []
  #   for i in 1...@bag.pockets.length
  #     @filterlist[i] = []
  #     for j in 0...@bag.pockets[i].length
  #       @filterlist[i].push(j) if @filterproc.call(@bag.pockets[i][j][0])
  #     end
  #   end
  # end

  # def get_current_pocket
  #   itemwindow = @sprites["itemlist"]
  #   return @bag.pockets[itemwindow.pocket]
  # end

  # Called when the item screen wants an item to be chosen from the screen
  def pbChooseItem
    @sprites["helpwindow"].visible = false
    itemwindow = @sprites["itemlist"]
    thispocket = @bag.emeras
    swapinitialpos = -1
    pbActivateWindow(@sprites,"itemlist") {
      loop do
        oldindex = itemwindow.index
        Graphics.update
        Input.update
        pbUpdate
        if itemwindow.sorting && itemwindow.index>=thispocket.length
          itemwindow.index = (oldindex==thispocket.length-1) ? 0 : thispocket.length-1
        end
        if itemwindow.index!=oldindex
          # Move the item being switched
          if itemwindow.sorting
            thispocket.insert(itemwindow.index,thispocket.delete_at(oldindex))
          end
          # Update selected item for current pocket
          @bag.setChoice(itemwindow.index)
          pbRefresh
        end
        if itemwindow.sorting
          if Input.trigger?(Input::ACTION) ||
             Input.trigger?(Input::USE)
            itemwindow.sorting = false
            pbPlayDecisionSE
            pbRefresh
          elsif Input.trigger?(Input::BACK)
            thispocket.insert(swapinitialpos,thispocket.delete_at(itemwindow.index))
            itemwindow.index = swapinitialpos
            itemwindow.sorting = false
            pbPlayCancelSE
            pbRefresh
          end
        else
          if Input.trigger?(Input::ACTION)   # Start switching the selected item
            if thispocket.length>1 && itemwindow.index<thispocket.length &&
               !Settings::BAG_POCKET_AUTO_SORT[itemwindow.pocket]
              itemwindow.sorting = true
              swapinitialpos = itemwindow.index
              pbPlayDecisionSE
              pbRefresh
            end
          elsif Input.trigger?(Input::BACK)   # Cancel the item screen
            pbPlayCloseMenuSE
            return nil
          elsif Input.trigger?(Input::USE)   # Choose selected item
            (itemwindow.item) ? pbPlayDecisionSE : pbPlayCloseMenuSE
            return itemwindow.item
          end
        end
      end
    }
  end
end

#===============================================================================
# Bag mechanics
#===============================================================================
class PokemonLoopletScreen
  def initialize(scene,bag)
    @bag   = bag
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene(@bag)
    item = nil
    loop do
      item = @scene.pbChooseItem
      break if !item
      cmdUse      = -1
      cmdToggle = -1
      cmdMisc = -1
      cmdSort     = -1
      commands = []
      # Generate command list

      commands[cmdUse = commands.length]    = _INTL("Tutor Move") if EMERADICT[item][:tutormove]
      commands[cmdMisc = commands.length]     = _INTL("Change Type") if item == :TERACRYSTAL
      commands[cmdToggle = commands.length]    = _INTL("Toggle off") if @bag.activeemeras.include?(item) && item != :STICKYKEY
      commands[cmdToggle = commands.length]    = _INTL("Toggle on") if !@bag.activeemeras.include?(item)
      commands[cmdSort = commands.length]        = _INTL("Sort bag")
      commands[commands.length]                 = _INTL("Cancel")
      # Show commands generated above
      itemname = EMERADICT[item][:name]
      command = @scene.pbShowCommands(_INTL("{1} is selected.",itemname),commands)
      if cmdUse>=0 && command==cmdUse   # Use item
        move = EMERADICT[item][:tutormove]
        movename = move.name
        if pbConfirmMessage(_INTL("Do you want to teach {1} to a Pokémon?", movename))
          pbFadeOutIn {
            annot = []
            $Trainer.party.each_with_index do |pkmn, i|
              if pkmn.egg?
                annot[i] = _INTL("NOT ABLE")
              elsif pkmn.hasMove?(move)
                annot[i] = _INTL("LEARNED")
              else
                species = pkmn.species
                if EMERADICT[item][:tutorcondition].call(pkmn)
                  annot[i] = _INTL("ABLE")
                else
                  annot[i] = _INTL("NOT ABLE")
                end
              end
            end
            scene = PokemonParty_Scene.new
            screen = PokemonPartyScreen.new(scene,$Trainer.party)
            screen.pbStartScene(_INTL("Teach which Pokémon?"),false,annot)
            loop do
              chosen = screen.pbChoosePokemon
              break if chosen<0
              pokemon = $Trainer.party[chosen]
              if pokemon.egg?
                pbMessage(_INTL("Eggs can't be taught any moves.")) { screen.pbUpdate }
              elsif pokemon.shadowPokemon?
                pbMessage(_INTL("Shadow Pokémon can't be taught any moves.")) { screen.pbUpdate }
              elsif !EMERADICT[item][:tutorcondition].call(pokemon)
                pbMessage(_INTL("{1} can't learn {2}.",pokemon.name,movename)) { screen.pbUpdate }
              else
                if pbLearnMove(pokemon,move,false,true) { screen.pbUpdate }
                  break
                end
              end
            end
            screen.pbEndScene
          }
        end
        @scene.pbRefresh
        next
      elsif cmdMisc >= 0 && command == cmdMisc
        scene = PokemonParty_Scene.new
        screen = PokemonPartyScreen.new(scene,$Trainer.party)
        screen.pbStartScene(_INTL("Which Pokémon?"),false)
        loop do
          chosen = screen.pbChoosePokemon
          break if chosen<0
          pokemon = $Trainer.party[chosen]
          types = []
          GameData::Type.each { |t| types.push(t.id) if !t.pseudo_type && ![:SHADOW].include?(t.id)}
          types.sort! { |a, b| GameData::Type.get(a).id_number <=> GameData::Type.get(b).id_number }
          typenames = []
          types.each do |type|
            typenames.push(GameData::Type.get(type).name)
          end
          type = types[Kernel.pbMessage("Select a Type", typenames)]
          pokemon.hiddenPowerType = type
        end
        screen.pbEndScene
      elsif cmdToggle >= 0 && command == cmdToggle
        if @bag.activeemeras.include?(item)
          @bag.activeemeras.delete(item)
        else
          @bag.activeemeras.push(item)
        end
        $Trainer.party.each do |mon|
          mon.calc_stats
        end
        @scene.pbRefresh
      elsif cmdSort >=0 && command == cmdSort # Sort bag
        command = @scene.pbShowCommands(_INTL("How to sort?",itemname),[
          _INTL("Alphabetically"),
          _INTL("Rarity"),
          _INTL("Cancel")
        ],0)
        case command
          ### Cancel ###
        when -1, 3
          next
        when 0
          @bag.sort_emera_alphabetically()
        when 1
          @bag.sort_emera_rarity()
        end
        @scene.pbRefresh
      end
    end
    @scene.pbEndScene
    return item
  end

  def pbDisplay(text)
    @scene.pbDisplay(text)
  end

  def pbConfirm(text)
    return @scene.pbConfirm(text)
  end
end

#===============================================================================
# The Bag object, which actually contains all the items
#===============================================================================
class PokemonLooplet
  attr_accessor :emeras
  attr_accessor :activeemeras
  attr_accessor :emeravariables

  def initialize
    @descending_sort=false
    @choice    = 0
    @emeras = []
    @activeemeras = []
    @emeravariables = {}
  end

  def sort_emera_alphabetically
    sorted = @emeras.sort_by do |item|
      EMERADICT[item][:name]
    end
    sorted.reverse! if @descending_sort

    @descending_sort = !@descending_sort
    @emeras = sorted
  end

  def sort_emera_rarity
    sorted = @emeras.sort_by do |item|
      EMERADICT[item][:rarity]
    end
    sorted.reverse! if @descending_sort

    @descending_sort = !@descending_sort
    @emeras = sorted
  end

  def getMaxActiveEmeras
    return -1
  end

  # Gets the index of the current selected item in the pocket
  def getChoice
    return @choice || 0
  end

  # Sets the index of the current selected item in the pocket
  def setChoice(value)
    @choice = value if value <= @emeras.length
  end

  def pbHasEmera?(item)
    return @activeemeras.include?(item)
  end

  def pbStoreEmera(item)
    @emeras.push(item)
    @activeemeras.push(item) #todo
  end

  def pbRandomEmera(rarity=nil)
    list = []
    @emeras.each do |emera|
      next if rarity && EMERADICT[emera][:rarity] != rarity
      list.push(emera)
    end
    return list.sample
  end

  def pbRemoveEmera(item)
    @emeras.delete(item)
    @activeemeras.delete(item)
  end
end

LOOPLETLIST = [:UNLIMITEDLOOPLET, :PLATINUMLOOPLET, :PEARLLOOPLET, :DIAMONDLOOPLET, :EMERALDLOOPLET, :SAPHIRELOOPLET, :RUBYLOOPLET, :CRYSTALLOOPLET, :GOLDLOOPLET, :SILVERLOOPLET]

def getLoopletType
  LOOPLETLIST.each do |looplet|
    return looplet if $PokemonBag.pbHasItem?(looplet)
  end
  return nil
end

def getLooplet
  return $PokemonGlobal.towervalues[:looplet] if !$PokemonGlobal.towervalues.nil?
  return nil if !getLoopletType
  $PokemonGlobal.looplet = PokemonLooplet.new if !$PokemonGlobal.looplet
  return $PokemonGlobal.looplet
end