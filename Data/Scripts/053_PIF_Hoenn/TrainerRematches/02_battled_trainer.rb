class BattledTrainer
  DELAY_BETWEEN_NPC_TRADES = 180 #In seconds (3 minutes)
  MAX_FRIENDSHIP = 100

  attr_accessor :trainerType
  attr_accessor :trainerName

  attr_accessor :currentTeam  #list of Pokemon. The game selects in this list for trade offers. They can increase levels & involve as you rebattle them.

  #trainers will randomly find items and add them to this list. When they have the :ITEM status, they will
  # give one of them at random.
  #Items equipped to the Pokemon traded by the player will end up in that list.
  #
  # If there is an evolution that the trainer can use on one of their Pokemon in that list, they will
  # instead use it to evolve their Pokemon.
  #
  #DNA Splicers/reversers can be used on their Pokemon if they have at least 2 unfused/1 fused
  #
  #Healing items that are in that list can be used by the trainer in rematches
  #
  attr_accessor :foundItems


  attr_accessor :nb_rematches

  #What the trainer currently wants to do
  # :IDLE -> Nothing. Normal postbattle dialogue
  # Should prompt the player to register the trainer in their phone.
  # Or maybe done automatically at the end of the battle?

  # :TRADE -> Trainer wants to trade one of its Pokémon with the player

  # :BATTLE -> Trainer wants to rebattle the player

  # :ITEM -> Trainer has an item they want to give the player
  attr_accessor :current_status
  attr_accessor :previous_status
  attr_accessor :previous_trade_timestamp

  attr_accessor :favorite_type
  attr_accessor :favorite_pokemon #Used for generating trade offers. Should be set from trainer.txt (todo)
  #If empty, then trade offers ask for a Pokemon of a type depending on the trainer's class

  attr_accessor :previous_random_events
  attr_accessor :has_pending_action
  attr_accessor :custom_appearance

  attr_accessor :friendship #increases the more you interact with them, unlocks more interact options
  attr_accessor :friendship_level
  def initialize(trainerType,trainerName,trainerVersion)
    @trainerType = trainerType
    @trainerName = trainerName
    @currentTeam = loadOriginalTrainerTeam(trainerVersion)
    @foundItems = []
    @nb_rematches = 0
    @currentStatus = :IDLE
    @previous_status = :IDLE
    @previous_trade_timestamp = Time.now-DELAY_BETWEEN_NPC_TRADES
    @previous_random_events =[]
    @has_pending_action=false
    @favorite_type = pick_favorite_type(trainerType)
    @friendship = 0
    @friendship_level = 0
  end

  def friendship_level
    @friendship_level =0 if !@friendship_level
    return @friendship_level
  end
  def increase_friendship(amount)
    @friendship=0 if !@friendship
    @friendship_level=0 if !@friendship_level
    gain = amount / ((@friendship + 1) ** 0.4)
    @friendship += gain
    @friendship = MAX_FRIENDSHIP if @friendship > MAX_FRIENDSHIP

    echoln "Friendship with #{@trainerName} increased by #{gain.round(2)} (total: #{@friendship.round(2)})"

    thresholds = FRIENDSHIP_LEVELS[@trainerType] || []
    echoln thresholds

    while @friendship_level < thresholds.length && @friendship >= thresholds[@friendship_level]
      @friendship_level += 1

      trainerClassName = GameData::TrainerType.get(@trainerType).real_name
      pbMessage(_INTL("\\C[3]Friendship increased with #{trainerClassName} #{@trainerName}!"))
      case @friendship_level
      when 1
        pbMessage(_INTL("You can now trade with each other!"))
      when 2
        pbMessage(_INTL("They will now give you items from time to time!"))
      when 3
        pbMessage(_INTL("You can now partner up with them!"))
      end

      echoln "🎉 #{@trainerName}'s friendship level increased to #{@friendship_level}!"
    end
  end

  def set_custom_appearance(trainer_appearance)
    @custom_appearance = trainer_appearance
  end

  def pick_favorite_type(trainer_type)
    if TRAINER_CLASS_FAVORITE_TYPES.has_key?(trainer_type)
      return TRAINER_CLASS_FAVORITE_TYPES[trainer_type].sample
    else
      return :NORMAL
    end
  end

  def set_pending_action(value)
    @has_pending_action=value
  end

  def log_evolution_event(unevolved_pokemon_species, evolved_pokemon_species)
    echoln "NPC Trainer #{@trainerName} evolved their #{get_species_readable_internal_name(unevolved_pokemon_species)} to #{get_species_readable_internal_name(evolved_pokemon_species)}!"

    event = BattledTrainerRandomEvent.new(:EVOLVE)
    event.unevolved_pokemon = unevolved_pokemon_species
    event.evolved_pokemon = evolved_pokemon_species
    @previous_random_events = [] unless @previous_random_events
    @previous_random_events << event
  end

  def log_fusion_event(body_pokemon_species, head_pokemon_species, fused_pokemon_species)
    echoln "NPC trainer #{@trainerName} fused #{body_pokemon_species} and #{head_pokemon_species}!"
    event = BattledTrainerRandomEvent.new(:FUSE)
    event.fusion_body_pokemon =body_pokemon_species
    event.fusion_head_pokemon =head_pokemon_species
    event.fusion_fused_pokemon =fused_pokemon_species
    @previous_random_events = [] unless @previous_random_events
    @previous_random_events << event
  end

  def log_unfusion_event(original_fused_pokemon_species, unfused_body_species, unfused_body_head)
    echoln "NPC trainer #{@trainerName} unfused #{get_species_readable_internal_name(original_fused_pokemon_species)}!"
    event = BattledTrainerRandomEvent.new(:UNFUSE)
    event.unfused_pokemon = original_fused_pokemon_species
    event.fusion_body_pokemon = unfused_body_species
    event.fusion_head_pokemon = unfused_body_head
    @previous_random_events = [] unless @previous_random_events
    @previous_random_events << event
  end

  def log_reverse_event(original_fused_pokemon_species, reversed_fusion_species)
    echoln "NPC trainer #{@trainerName} reversed #{get_species_readable_internal_name(original_fused_pokemon_species)}!"

    event = BattledTrainerRandomEvent.new(:REVERSE)
    event.unreversed_pokemon = original_fused_pokemon_species
    event.reversed_pokemon = reversed_fusion_species
    @previous_random_events = [] unless @previous_random_events
    @previous_random_events << event
  end

  def log_catch_event(new_pokemon_species)
    echoln "NPC Trainer #{@trainerName} caught a #{new_pokemon_species}!"
    event = BattledTrainerRandomEvent.new(:CATCH)
    event.caught_pokemon = new_pokemon_species
    @previous_random_events = [] unless @previous_random_events
    @previous_random_events <<  event
  end

  def clear_previous_random_events()
    @previous_random_events = []
  end

  def loadOriginalTrainer(trainerVersion=0)
    return pbLoadTrainer(@trainerType,@trainerName,trainerVersion)
  end

  def loadOriginalTrainerTeam(trainerVersion=0)
    original_trainer = pbLoadTrainer(@trainerType,@trainerName,trainerVersion)
    return if !original_trainer
    echoln "Loading Trainer #{@trainerType}"
    current_party = []
    original_trainer.party.each do |partyMember|
      echoln "PartyMember: #{partyMember}"
      if partyMember.is_a?(Pokemon)
        current_party << partyMember
      elsif partyMember.is_a?(Array)  #normally always gonna be this
        pokemon_species = partyMember[0]
        pokemon_level = partyMember[1]
        current_party << Pokemon.new(pokemon_species,pokemon_level)
      else
        echoln "Could not add Pokemon #{partyMember} to rematchable trainer's party."
      end
    end

    return current_party
  end

  def getTimeSinceLastTrade()
    @previous_trade_timestamp ||= Time.now - DELAY_BETWEEN_NPC_TRADES
    return Time.now - @previous_trade_timestamp
  end

  def isNextTradeReady?()
    return getTimeSinceLastTrade < DELAY_BETWEEN_NPC_TRADES
  end

  def list_team_unfused_pokemon
    list = []
    @currentTeam.each do |pokemon|
      list << pokemon if !pokemon.isFusion?
    end
    return list
  end

  def list_team_fused_pokemon
    list = []
    @currentTeam.each do |pokemon|
      list << pokemon if pokemon.isFusion?
    end
    return list
  end
end