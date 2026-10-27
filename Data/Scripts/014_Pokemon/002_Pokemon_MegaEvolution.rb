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

  def getFormList(filter)
    specieslist = [@species, @species]
    ret = [[], []]
    if isFusion? && getDexNumberForSpecies(@species) < 1000000
      specieslist = [GameData::Species.get(getBodyID(@species)).species, GameData::Species.get(getHeadID(@species)).species]
    end

    GameData::Species.each do |data|
      case filter
      when "Rotom"
        next unless data.species == :ROTOM
      else
        next unless specieslist.include?(data.species)
      end
      next if data.form == 0
      specieslist.each_with_index do |species, i|
        case filter
        when "Paradox"
          next unless data.species == species
          next unless data.form_name[0..6] == "Paradox" || data.form_name == "Stereo"
        when "Mega"
          next unless data.species == species
          next if !(data.mega_stone || data.mega_move)
        when "Regional"
          next unless data.species == species
          next if data.mega_stone || data.mega_move
          next if data.form_name && data.form_name[0..6] == "Paradox"
          next if [:ROTOM].include?(data.species)
        when "Rotom"
          next unless [:ROTOM, :WASHROTOM, :HEATROTOM, :FROSTROTOM, :FANROTOM, :MOWROTOM, :STEREOROTOM, :DRONEROTOM, :BIKEROTOM, :PHONEROTOM].include?(species)
          next if data.form > 5 && pbGetRotomCount() < 3
          next if data.mega_stone || data.mega_move
        end
        ret[i].push(data)
      end
    end
    return ret
  end

  def getParadoxForm
    setDefaultForms() if !@paradoxform
    ret = [GameData::Species.get(getBodyIDNormalized(@species)), GameData::Species.get(getHeadIDNormalized(@species))]
    specieslist = [@species, @species]
    if isFusion? && getDexNumberForSpecies(@species) < 1000000
      specieslist = [GameData::Species.get(getBodyID(@species)).species, GameData::Species.get(getHeadID(@species)).species]
    end
    specieslist.each_with_index do |species, i|
      getFormList("Paradox")[i].each do |paradox|
        next unless species == paradox.species
        next unless @paradoxform[i] == paradox.form
        ret[i] = paradox
      end
    end
    return ret
  end

  def getRegionalForm()
    setDefaultForms() if !@regionalform
    ret = [GameData::Species.get(getBodyIDNormalized(@species)), GameData::Species.get(getHeadIDNormalized(@species))]
    specieslist = [@species, @species]
    if isFusion? && getDexNumberForSpecies(@species) < 1000000
      specieslist = [GameData::Species.get(getBodyID(@species)).species, GameData::Species.get(getHeadID(@species)).species]
    end
    specieslist.each_with_index do |species, i|
      getFormList("Regional")[i].each do |regional|
        next unless species == regional.species
        next unless @regionalform[i] == regional.form
        ret[i] = regional
      end
    end
    return ret
  end

  def getRotomForm()
    setDefaultForms() if !@rotomform
    ret = [GameData::Species.get(getBodyIDNormalized(@species)), GameData::Species.get(getHeadIDNormalized(@species))]
    specieslist = [@species, @species]
    if isFusion? && getDexNumberForSpecies(@species) < 1000000
      specieslist = [GameData::Species.get(getBodyID(@species)).species, GameData::Species.get(getHeadID(@species)).species]
    end

    isrotom = false
    specieslist.each do |species|
      next unless [:ROTOM, :WASHROTOM, :HEATROTOM, :FROSTROTOM, :FANROTOM, :MOWROTOM, :STEREOROTOM, :DRONEROTOM, :BIKEROTOM, :PHONEROTOM].include?(species)
      isrotom = true
    end
    specieslist.each_with_index do |species, i|
      getFormList("Rotom")[i].each do |rotom|
        next unless @rotomform[i] == rotom.form
        ret[i] = rotom
      end
    end
    return ret
  end

  def setDefaultForms(override = false)
    specieslist = [@species, @species]
    ret = []
    if isFusion? && getDexNumberForSpecies(@species) < 1000000
      specieslist = [GameData::Species.get(getBodyID(@species)).species, GameData::Species.get(getHeadID(@species)).species]
    end
    megalist = 
    rotomlist = 
    regionallist = 
    paradoxlist = 
    if !@megaform || override
      @megaform = [0, 0]
      getFormList("Mega").each_with_index do |mega, i|
        if mega.length == 0
          @megaform[i] = 0
          next
        end
        @megaform[i] = mega[-1].form
        next
      end
    end
    if !@rotomform || override
      @rotomform = [0, 0]
      @rotomability = [nil, nil]
      getFormList("Rotom").each_with_index do |rotom, i|
        if rotom.length == 0
          @rotomform[i] = 0
          next
        end
        @rotomform[i] = rotom[-1].form
        abilitylist = rotom[-1].abilities + rotom[-1].hidden_abilities
        @rotomability[i] = abilitylist[-1]
      end
    end
    if !@paradoxform || override
      @paradoxform = [0, 0]
      @paradoxability = [nil, nil]
      getFormList("Paradox").each_with_index do |paradox, i|
        if paradox.length == 0
          @paradoxform[i] = 0
          next
        end
        @paradoxform[i] = paradox[-1].form
        abilitylist = paradox[-1].abilities + paradox[-1].hidden_abilities
        @paradoxability[i] = abilitylist[-1]
      end
    end
    if !@regionalform || override
      @regionalform = [0, 0]
      @regionalability = [nil, nil]
      getFormList("Regional").each_with_index do |regional, i|
        if regional.length == 0
          @regionalform[i] = 0
          next
        end
        @regionalform[i] = regional[-1].form
        abilitylist = regional[-1].abilities + regional[-1].hidden_abilities
        @regionalability[i] = abilitylist[-1]
      end
    end
  end

  def getMegaShardForm(megasource=nil)
    setDefaultForms() if !@megaform
    ret = [GameData::Species.get(getBodyIDNormalized(@species)), GameData::Species.get(getHeadIDNormalized(@species))]
    specieslist = [@species, @species]
    if isFusion? && getDexNumberForSpecies(@species) < 1000000
      specieslist = [GameData::Species.get(getBodyID(@species)).species, GameData::Species.get(getHeadID(@species)).species]
    end
    availablelist = []
    availablelist.push(:CHIMECHO) if megasource.include?(:PUREINCENSE)
    availablelist.push(:LATIAS, :LATIOS) if megasource.include?(:EON)
    availablelist = specieslist if megasource.include?(:MEGASHARD)
    specieslist.each_with_index do |species, i|
      getFormList("Mega")[i].each do |mega|
        next unless availablelist.include?(species)
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
