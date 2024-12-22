class PokedexUtils
  # POSSIBLE_ALTS = ["", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q",
  #                  "r", "s", "t", "u", "v", "w", "x", "y", "z", "aa", "ab", "ac", "ad", "ae", "af", "ag", "ah",
  #                  "ai", "aj", "ak", "al", "am", "an", "ao", "ap", "aq", "ar", "as", "at", "au", "av", "aw", "ax",
  #                  "ay", "az"]

  def getAltLettersList()
    return ('a'..'z').to_a + ('aa'..'az').to_a
  end

  def getBaseSpritesAlts(dex_number)
    return $game_temp.base_sprites_list[dex_number]
  end

  def getFusionSpriteAlts(head_id, body_id)
    sprite_id = get_fusion_symbol(head_id,body_id)
    return $game_temp.custom_sprites_list[sprite_id]
    # available_alts = []
    # species_id = get_fusion_id(head_id,body_id).to_s
    # for pokemon_id in $game_temp.custom_sprites_list
    #   available_alts << pokemon_id if pokemon_id.to_s.start_with?(species_id)
    # end
    # echoln available_alts
    # return available_alts
  end

  def pbGetAvailableAlts(species, includeAutogens=false)
    dex_number = getDexNumberForSpecies(species)
    if isFusion(dex_number)
      body_id = getBodyID(dex_number)
      head_id = getHeadID(dex_number,body_id)
      available_alts = getFusionSpriteAlts(head_id,body_id)
    else
      available_alts= getBaseSpritesAlts(dex_number)
    end
    available_alts = [] if !available_alts
    available_alts << "autogen" if includeAutogens
    return available_alts


    # ret = []
    # return ret if !species
    # dexNum = getDexNumberForSpecies(species)
    # isFusion = dexNum > NB_POKEMON
    # if !isFusion
    #   altLetters = getAltLettersList()
    #   altLetters << ""
    #   altLetters.each { |alt_letter|
    #     altFilePath = Settings::CUSTOM_BASE_SPRITES_FOLDER + dexNum.to_s  + alt_letter + ".png"
    #     if pbResolveBitmap(altFilePath)
    #       ret << altFilePath
    #     end
    #   }
    #   return ret
    # end
    # body_id = getBodyID(species)
    # head_id = getHeadID(species, body_id)
    #
    # baseFilename = head_id.to_s + "." + body_id.to_s
    # baseFilePath = Settings::CUSTOM_BATTLERS_FOLDER_INDEXED + head_id.to_s + "/" + baseFilename + ".png"
    # if pbResolveBitmap(baseFilePath)
    #   ret << baseFilePath
    # end
    # getAltLettersList().each { |alt_letter|
    #   if alt_letter != "" #empty is included in alt letters because unfused sprites can be alts and not have a letter
    #     altFilePath = Settings::CUSTOM_BATTLERS_FOLDER_INDEXED + head_id.to_s + "/" + baseFilename + alt_letter + ".png"
    #     if pbResolveBitmap(altFilePath)
    #       ret << altFilePath
    #     end
    #   end
    # }
    # ret << Settings::BATTLERS_FOLDER + head_id.to_s + "/" + baseFilename + ".png"
    # return ret
  end

  #todo: return array for split evolution lines that have multiple final evos
  def getFinalEvolution(species)
    #ex: [[B3H4,Level 32],[B2H5, Level 35]]
    evolution_line = species.get_evolutions
    return species if evolution_line.empty?
    finalEvoId = evolution_line[0][0]
    return evolution_line[]
    for evolution in evolution_line
      evoSpecies = evolution[0]
      p GameData::Species.get(evoSpecies).get_evolutions
      isFinalEvo = GameData::Species.get(evoSpecies).get_evolutions.empty?
      return evoSpecies if isFinalEvo
    end
    return nil
  end

end
