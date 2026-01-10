def splitSpriteCredits(name, bitmap, max_width)
  name_full_width = bitmap.text_size(name).width
  # use original name if can fit on one line
  return [ name ] if name_full_width <= max_width

  temp_string = name
  name_split = []

  # split name by collab separator " & " nearest to max width
  start_pos = temp_string.index(' & ')
  temp_pos = nil
  while start_pos && (bitmap.text_size(temp_string).width > max_width)
    substring_width = bitmap.text_size(temp_string[0, start_pos]).width
    if substring_width > max_width
      name_split << temp_string[0, temp_pos].strip
      temp_string = temp_string[(temp_pos + 1)..].strip
      start_pos = temp_string.index(' & ')
      temp_pos = nil
      next
    end

    temp_pos = start_pos
    start_pos = temp_string.index(' & ', start_pos + 1)
  end

  # append remainder of " & " split if within max width
  if temp_pos != nil
    name_split << temp_string[0, temp_pos].strip
    temp_string = temp_string[(temp_pos + 1)..].strip
  end

  # split remaining string by space
  temp_pos = nil
  if (bitmap.text_size(temp_string).width > max_width) && (start_pos = temp_string.index(' '))
    while start_pos && (bitmap.text_size(temp_string).width > max_width)
      substring_width = bitmap.text_size(temp_string[0, start_pos]).width
      if substring_width > max_width
        name_split << temp_string[0, temp_pos].strip
        temp_string = temp_string[(temp_pos + 1)..].strip
        start_pos = temp_string.index(' ')
        temp_pos = nil
        next
      end

      temp_pos = start_pos
      start_pos = temp_string.index(' ', start_pos + 1)
    end
  end

  # append remaining text, even if too long for screen
  name_split << temp_string if temp_string != ''

  return name_split
end

def pbLoadPokemonBitmapSpecies(pokemon, species, back = false, scale = POKEMONSPRITESCALE)
  ret = nil
  pokemon = pokemon.pokemon if pokemon.respond_to?(:pokemon)
  if pokemon.isEgg?
    bitmapFileName = getEggBitmapPath(pokemon)
    bitmapFileName = pbResolveBitmap(bitmapFileName)
  elsif pokemon.species >= ZAPMOLCUNO_NB #zapmolcuno
    bitmapFileName = getSpecialSpriteName(pokemon.species) #sprintf("Graphics/Battlers/special/144.145.146")
    bitmapFileName = pbResolveBitmap(bitmapFileName)
  else
    #edited here
    isFusion = species > NB_POKEMON
    if isFusion
      poke1 = getBodyID(species)
      poke2 = getHeadID(species, poke1)
    else
      poke1 = species
      poke2 = species
    end
    bitmapFileName = GetSpritePath(poke1, poke2, isFusion)
    # Alter bitmap if supported
    alterBitmap = (MultipleForms.getFunction(species, "alterBitmap") rescue nil)
  end
  if bitmapFileName && alterBitmap
    animatedBitmap = AnimatedBitmap.new(bitmapFileName)
    copiedBitmap = animatedBitmap.copy
    animatedBitmap.dispose
    copiedBitmap.each { |bitmap| alterBitmap.call(pokemon, bitmap) }
    ret = copiedBitmap
  elsif bitmapFileName
    ret = AnimatedBitmap.new(bitmapFileName)
  end
  return ret
end

def pbPokemonBitmapFile(species)
  # Used by the Pokédex
  # Load normal bitmap
  #get body and head num
  isFused = species > NB_POKEMON
  if isFused
    if species >= ZAPMOLCUNO_NB
      path = getSpecialSpriteName(species) + ".png"
    else
      poke1 = getBodyID(species) #getBasePokemonID(species,true)
      poke2 = getHeadID(species, poke1) #getBasePokemonID(species,false)
      path = GetSpritePath(poke1, poke2, isFused)
    end
  else
    path = GetSpritePath(species, species, false)
  end
  ret = sprintf(path) rescue nil
  if !pbResolveBitmap(ret)
    ret = "Graphics/Battlers/000.png"
  end
  return ret
end


def pbLoadPokemonBitmap(pokemon, species, back = false)
  #species est utilisé par elitebattle mais ca sert a rien
  return pbLoadPokemonBitmapSpecies(pokemon, pokemon.species, back)
end

def getEggBitmapPath(pokemon)
  return "Graphics/Battlers/Eggs/000" if $PokemonSystem.hide_custom_eggs
  bitmapFileName = sprintf("Graphics/Battlers/Eggs/%s", getConstantName(PBSpecies, pokemon.species)) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    if pokemon.species >= NUM_ZAPMOLCUNO
      bitmapFileName = "Graphics/Battlers/Eggs/egg_base"
    else
      bitmapFileName = sprintf("Graphics/Battlers/Eggs/%03d", pokemon.species)
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName = sprintf("Graphics/Battlers/Eggs/000")
      end
    end
  end
  return bitmapFileName
end

def GetSpritePath(poke1, poke2, isFused)
  #Check if custom exists
  spritename = GetSpriteName(poke1, poke2, isFused)
  pathCustom = sprintf("Graphics/%s/indexed/%s/%s.png", DOSSIERCUSTOMSPRITES,poke2, spritename)
  pathReg = sprintf("Graphics/%s/%s/%s.png", BATTLERSPATH, poke2, spritename)
  path = pbResolveBitmap(pathCustom) && $game_variables[196] == 0 ? pathCustom : pathReg
  return path
end


def GetSpritePathForced(poke1, poke2, isFused)
  #Check if custom exists
  spritename = GetSpriteName(poke1, poke2, isFused)
  pathCustom = sprintf("Graphics/%s/indexed/%s/%s.png", DOSSIERCUSTOMSPRITES, poke2, spritename)
  pathReg = sprintf("Graphics/%s/%s/%s.png", BATTLERSPATH, poke2, spritename)
  path = pbResolveBitmap(pathCustom) ? pathCustom : pathReg
  return path
end


def GetSpriteName(poke1, poke2, isFused)
  ret = isFused ? sprintf("%d.%d", poke2, poke1) : sprintf("%d", poke2) rescue nil
  return ret
end