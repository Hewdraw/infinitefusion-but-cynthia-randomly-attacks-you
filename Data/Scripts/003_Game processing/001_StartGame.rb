# The Game module contains methods for saving and loading the game.
module Game
  # Initializes various global variables and loads the game data.


  def self.initialize
    $PokemonTemp = PokemonTemp.new
    $game_temp = Game_Temp.new
    $game_system = Game_System.new
    $data_animations = load_data('Data/Animations.rxdata')
    $data_tilesets = load_data('Data/Tilesets.rxdata')
    $data_common_events = load_data('Data/CommonEvents.rxdata')
    $data_system = load_data('Data/System.rxdata')
    pbLoadBattleAnimations
    load_sprites_list_caches()
    $updated_spritesheets = load_updated_spritesheets()
    GameData.load_all
    map_file = format('Data/Map%03d.rxdata', $data_system.start_map_id)
    if $data_system.start_map_id == 0 || !pbRgssExists?(map_file)
      raise _INTL('No starting position was set in the map editor.')
    end
  end

  def self.load_updated_spritesheets
    updated_spritesheets_file = Settings::UPDATED_SPRITESHEETS_CACHE
    updated_spritesheets = []
    if File.exist?(updated_spritesheets_file)
      File.open(updated_spritesheets_file, "r") do |file|
        file.each_line { |line| updated_spritesheets << line.chomp }
      end
    end
    return updated_spritesheets
  end

  def self.load_sprites_list_caches()
    self.load_custom_sprites_list_cache() if File.exists?(Settings::CUSTOM_SPRITES_FILE_PATH)
    self.load_base_sprites_list_cache() if File.exists?(Settings::BASE_SPRITES_FILE_PATH)
  end

  def self.load_custom_sprites_list_cache()
    return if !$game_temp.custom_sprites_list.keys.empty? #only load once at loadup
    echoln "loading custom sprites cache"
    sprite_index = {}
    File.foreach(Settings::CUSTOM_SPRITES_FILE_PATH) do |line|
      filename = line.strip
      next unless filename =~ /^(\d+)\.(\d+)([a-zA-Z]*)\.png$/  # Regex: Captures the numbers and any trailing letters

      # Match groups
      head_number = $1.to_i   # Head (e.g., "1" in "1.2.png")
      body_number = $2.to_i  # Body (e.g., "2" in "1.2.png")
      letters = $3             # Letters after the second number (e.g., "a", "b", etc.)

      key = "B#{body_number}H#{head_number}".to_sym
      sprite_index[key] ||= []
      if letters.empty?
        sprite_index[key] << ""
      else
        sprite_index[key] << letters
      end
    end
    $game_temp.custom_sprites_list = sprite_index
    echoln "custom sprites loaded"
  end

  #
  # {1 => ["","a","b"]
  #etc.
  #
  def self.load_base_sprites_list_cache()
    return if !$game_temp.base_sprites_list.keys.empty? #only load once at loadup
    echoln "loading base sprites cache"
    sprite_index = {}
    File.foreach(Settings::BASE_SPRITES_FILE_PATH) do |line|
      filename = line.strip
      next unless filename =~ /^(\d+)([a-zA-Z]*)\.png$/  # Regex: Captures the numbers and any trailing letters

      # Match groups
      dex_number = $1.to_i   # Head (e.g., "1" in "1.2.png")
      letters = $2             # Letters after the second number (e.g., "a", "b", etc.)

      key = dex_number
      sprite_index[key] ||= []
      if letters.empty?
        sprite_index[key] << ""
      else
        sprite_index[key] << letters
      end
    end
    $game_temp.base_sprites_list = sprite_index
    echoln "custom sprites loaded"
  end

  #
  # {:B10H10 => ["","a","b"]
  #etc.
  #
  def self.set_up_system
    SaveData.move_old_windows_save if System.platform[/Windows/]
    save_data = (SaveData.exists?) ? SaveData.read_from_file(SaveData::FILE_PATH) : {}
    if save_data.empty?
      SaveData.initialize_bootup_values
    else
      SaveData.load_bootup_values(save_data)
    end
    # Set resize factor
    pbSetResizeFactor([$PokemonSystem.screensize, 4].min)
    # Set language (and choose language if there is no save file)
    if Settings::LANGUAGES.length >= 2
      $PokemonSystem.language = pbChooseLanguage if save_data.empty?
      pbLoadMessages('Data/' + Settings::LANGUAGES[$PokemonSystem.language][1])
    end
  end

  #For new game plus - resets everything in boxes/party to level 5 and 1st stage
  def self.ngp_clean_pc_data(old_storage, old_party)
    new_storage = old_storage
    for pokemon in old_party
      new_storage.pbStoreCaught(pokemon)
    end

    for box in new_storage.boxes
      for pokemon in box.pokemon
        if pokemon != nil
          if !pokemon.egg?
            pokemon.exp_when_fused_head=nil
            pokemon.exp_when_fused_body=nil
            pokemon.exp_gained_since_fused=nil
            pokemon.level = 5

            echoln pokemon.owner.id
            pokemon.owner.id = $Trainer.id
            pokemon.ot=$Trainer.name
            pokemon.obtain_method = 0
            pokemon.species = GameData::Species.get(pokemon.species).get_baby_species(false)
            $Trainer.pokedex.set_seen(pokemon.species)
            $Trainer.pokedex.set_owned(pokemon.species)
            pokemon.reset_moves
            pokemon.calc_stats

          end
        end
      end
    end
    return new_storage
  end

  #For new game plus - removes key items
  def self.ngp_clean_item_data(old_bag)
    new_storage = old_bag
    new_storage.clear

    for pocket in old_bag.pockets
      for bagElement in pocket
        item_id = bagElement[0]
        item_qt = bagElement[1]
        item = GameData::Item.get(item_id)
        if !item.is_key_item? && !item.is_HM?
          new_storage.pbStoreItem(item, 1)
        end
      end
    end
    return new_storage
  end

  # Called when starting a new game. Initializes global variables
  # and transfers the player into the map scene.
  def self.start_new(ngp_bag = nil, ngp_storage = nil, ngp_trainer = nil)

    if $game_map && $game_map.events
      $game_map.events.each_value { |event| event.clear_starting }
    end
    $game_temp.common_event_id = 0 if $game_temp
    $PokemonTemp.begunNewGame = true
    $scene = Scene_Map.new
    SaveData.load_new_game_values
    $MapFactory = PokemonMapFactory.new($data_system.start_map_id)
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.refresh
    $PokemonEncounters = PokemonEncounters.new
    $PokemonEncounters.setup($game_map.map_id)
    $game_map.autoplay
    $game_map.update
    #
    # if ngp_bag != nil
    #   $PokemonBag = ngp_clean_item_data(ngp_bag)
    # end
    if ngp_storage != nil
      $PokemonStorage = ngp_clean_pc_data(ngp_storage, ngp_trainer.party)
    end
    onStartingNewGame()
  end

  # Loads the game from the given save data and starts the map scene.
  # @param save_data [Hash] hash containing the save data
  # @raise [SaveData::InvalidValueError] if an invalid value is being loaded
  def self.load(save_data)
    validate save_data => Hash
    SaveData.load_all_values(save_data)
    self.load_map
    pbAutoplayOnSave
    $game_map.update
    $PokemonMap.updateMap
    $scene = Scene_Map.new
    onLoadExistingGame()
  end

  # Loads and validates the map. Called when loading a saved game.
  def self.load_map
    $game_map = $MapFactory.map
    magic_number_matches = ($game_system.magic_number == $data_system.magic_number)
    if !magic_number_matches || $PokemonGlobal.safesave
      if pbMapInterpreterRunning?
        pbMapInterpreter.setup(nil, 0)
      end
      begin
        $MapFactory.setup($game_map.map_id)
      rescue Errno::ENOENT
        if $DEBUG
          pbMessage(_INTL('Map {1} was not found.', $game_map.map_id))
          map = pbWarpToMapList
          exit unless map
          $MapFactory.setup(map[0])
          $game_player.moveto(map[1], map[2])
        else
          raise _INTL('The map was not found. The game cannot continue.')
        end
      end
      $game_player.center($game_player.x, $game_player.y)
    else
      $MapFactory.setMapChanged($game_map.map_id)
    end
    if $game_map.events.nil?
      raise _INTL('The map is corrupt. The game cannot continue.')
    end
    $PokemonEncounters = PokemonEncounters.new
    $PokemonEncounters.setup($game_map.map_id)
    pbUpdateVehicle
  end

  # Saves the game. Returns whether the operation was successful.
  # @param save_file [String] the save file path
  # @param safe [Boolean] whether $PokemonGlobal.safesave should be set to true
  # @return [Boolean] whether the operation was successful
  # @raise [SaveData::InvalidValueError] if an invalid value is being saved
  def self.save(save_file = SaveData::FILE_PATH, safe: false)
    validate save_file => String, safe => [TrueClass, FalseClass]
    $PokemonGlobal.safesave = safe
    $game_system.save_count += 1
    $game_system.magic_number = $data_system.magic_number
    begin
      SaveData.save_to_file(save_file)
      Graphics.frame_reset
    rescue IOError, SystemCallError
      $game_system.save_count -= 1
      return false
    end
    return true
  end
end
