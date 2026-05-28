class Pokemon
  #=============================================================================
  # Mega Evolution
  # NOTE: These are treated as form changes in Essentials.
  #=============================================================================
  def getMegaForm
    ret = 0
    GameData::Species.each do |data|
      next if data.species != @species || data.unmega_form != form_simple
      if data.mega_stone && hasItem?(data.mega_stone)
        ret = data.form
        break
      elsif data.mega_move && hasMove?(data.mega_move)
        ret = data.form
        break
      end
    end
    return ret   # form number, or 0 if no accessible Mega form
  end

  def getMegaList
    specieslist = [@species]
    ret = []
    if isFusion? && getDexNumberForSpecies(@species) < 1000000
      specieslist = [GameData::Species.get(getBodyID(@species)).species, GameData::Species.get(getHeadID(@species)).species]
    end

    GameData::Species.each do |data|
      next unless specieslist.include?(data.species)
      next if data.form == 0
      next if !data.mega_stone
      ret.push(data)
    end
    return ret   # form number, or 0 if no accessible Mega form
  end

  def getRegionalList
    specieslist = [@species]
    ret = []
    if isFusion? && getDexNumberForSpecies(@species) < 1000000
      specieslist = [GameData::Species.get(getBodyID(@species)).species, GameData::Species.get(getHeadID(@species)).species]
    end

    GameData::Species.each do |data|
      next unless specieslist.include?(data.species)
      next if data.form == 0
      next if data.mega_stone
      ret.push(data)
    end
    return ret   # form number, or 0 if no accessible Mega form
  end

  def getRegionalForm()
    setDefaultForms() if !@regionalform
    ret = [GameData::Species.get(getBodyID(@species)), GameData::Species.get(getHeadID(@species))]
    specieslist = [@species, @species]
    if isFusion? && getDexNumberForSpecies(@species) < 1000000
      specieslist = [GameData::Species.get(getBodyID(@species)).species, GameData::Species.get(getHeadID(@species)).species]
    end
    getMegaList.each do |mega|
      specieslist.each_with_index do |species, i|
        next unless species == mega.species
        next unless @regionalform[i] == mega.form
        ret[i] = mega
      end
    end
    return ret
  end

  def setDefaultForms(override = false)
    specieslist = [@species]
    ret = []
    if isFusion? && getDexNumberForSpecies(@species) < 1000000
      specieslist = [GameData::Species.get(getBodyID(@species)).species, GameData::Species.get(getHeadID(@species)).species]
    end
    megalist = [[], []]
    regionallist = [[], []]
    GameData::Species.each do |data|
      specieslist.each_with_index do |species, i|
        next unless species == data.species
        next if data.form == 0
        if data.mega_stone
          megalist[i].push(data.form)
        else
          regionallist[i].push(data.form)
        end
      end
    end
    if !@megaform || override
      @megaform = [0, 0]
      megalist.each_with_index do |mega, i|
        if mega.length == 0
          @megaform[i] = 0
          next
        end
        @megaform[i] = mega
        next
      end
    end
    if !@regionalform || override
      @regionalform = [0, 0]
      @regionalability = [nil, nil]
      regionallist.each_with_index do |regional, i|
        if regional.length == 0
          @regionalform[i] = 0
          next
        end
        @regionalform[i] = regional
        abilitylist = getRegionalList[i].abilities + getRegionalList[i].hidden_abilities
        @regionalability[i] = abilitylist[abilitylist.length]
      end
    end
  end

  def getMegaShardForm(megasource=nil)
    setDefaultForms() if !@megaform
    ret = [GameData::Species.get(getBodyID(@species)), GameData::Species.get(getHeadID(@species))]
    specieslist = [@species, @species]
    if isFusion? && getDexNumberForSpecies(@species) < 1000000
      specieslist = [GameData::Species.get(getBodyID(@species)).species, GameData::Species.get(getHeadID(@species)).species]
    end
    getMegaList.each do |mega|
      specieslist.each_with_index do |species, i|
        next if megasource == :EON && ![:LATIAS, :LATIOS].include?(species)
        next unless species == mega.species
        next unless @megaform[i] == mega.form
        ret[i] = mega
      end
    end
    return ret
  end

  def getUnmegaForm
    return (mega?) ? species_data.unmega_form : -1
  end

  def hasMegaForm?
    megaForm = self.getMegaForm
    return megaForm > 0 && megaForm != form_simple
  end

  def mega?
    return (species_data.mega_stone || species_data.mega_move) ? true : false
  end

  def makeMega
    self.form = 1
  end

  def makeUnmega
    unmegaForm = self.getUnmegaForm
    self.form = unmegaForm if unmegaForm >= 0
  end

  def megaName
    formName = species_data.form_name
    return (formName && !formName.empty?) ? formName : _INTL("Mega {1}", species_data.name)
  end

  def megaMessage   # 0=default message, 1=Rayquaza message
    megaForm = self.getMegaForm
    message_number = GameData::Species.get_species_form(@species, megaForm)&.mega_message
    return message_number || 0
  end

  #=============================================================================
  # Primal Reversion
  # NOTE: These are treated as form changes in Essentials.
  #=============================================================================
  def hasPrimalForm?
    v = MultipleForms.call("getPrimalForm", self)
    return !v.nil?
  end

  def primal?
    v = MultipleForms.call("getPrimalForm", self)
    return !v.nil? && v == @form
  end

  def makePrimal
    v = MultipleForms.call("getPrimalForm", self)
    self.form = v if !v.nil?
  end

  def makeUnprimal
    v = MultipleForms.call("getUnprimalForm", self)
    if !v.nil?;    self.form = v
    elsif primal?; self.form = 0
    end
  end
end
