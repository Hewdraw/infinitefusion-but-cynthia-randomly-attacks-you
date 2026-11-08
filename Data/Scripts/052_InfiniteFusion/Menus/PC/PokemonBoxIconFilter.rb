# frozen_string_literal: true
COMMAND_SELECT_POKEMON = 3

class PokemonBoxIcon
  def refresh()
    return if !@pokemon
    setPokemonBitmap(@pokemon)
    if self.src_rect
      self.zoom_x = 1 / (self.src_rect.width / 64.0)
      self.zoom_y = 1 / (self.src_rect.height / 64.0)
    end

    # if useRegularIcon(@pokemon.species) || @pokemon.egg?
    #   self.setBitmap(GameData::Species.icon_filename_from_pokemon(@pokemon))
    # else
    #   self.setBitmapDirectly(createFusionIcon(@pokemon.species, @pokemon.spriteform_head, @pokemon.spriteform_body, @pokemon.bodyShiny?, @pokemon.headShiny?))
    # end
    # self.src_rect = Rect.new(0, 0, self.bitmap.height, self.bitmap.height)
  end

  def apply_filter(filterProc = nil)
    if filterProc && @pokemon
      if filterProc.call(@pokemon)
        self.opacity = 255
        @enabled = true
      else
        self.opacity = 80
        @enabled = false
      end
    else
      self.opacity = 255
      @enabled = true
    end
  end
end