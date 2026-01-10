
class PokemonStorage
end


class StorageTransferBox < PokemonBox
  TRANSFER_BOX_NAME = _INTL("Transfer Box")
  def initialize()
    super(TRANSFER_BOX_NAME,PokemonBox::BOX_SIZE)
    @pokemon = []
    @background = 16
    for i in 0...PokemonBox::BOX_SIZE
      @pokemon[i] = nil
    end
    loadTransferBoxPokemon
  end


  def loadTransferBoxPokemon
    path = transferBoxSavePath
    if File.exist?(path)
      File.open(path, "rb") do |f|
        @pokemon = Marshal.load(f)
      end
    end
  rescue => e
    echoln "Failed to load transfer box: #{e}"
    @pokemon = Array.new(PokemonBox::BOX_SIZE, nil)
  end

  def []=(i,value)
    @pokemon[i] = value
    saveTransferBox()
    Game.save()
  end

  def saveTransferBox
    path = transferBoxSavePath
    dir = File.dirname(path)
    Dir.mkdir(dir) unless Dir.exist?(dir)
    File.open(path, "wb") do |f|
      Marshal.dump(@pokemon, f)
    end
    echoln "Transfer box saved to #{path}"
    $game_temp.must_save_now=true
  rescue => e
    echoln "Failed to save transfer box: #{e}"
  end


  private

  def transferBoxSavePath
    save_dir = System.data_directory  # e.g., %appdata%/infinitefusion
    parent_dir = File.expand_path("..", save_dir)
    File.join(parent_dir, "infinitefusion_common", "transfer_pokemon_storage")
  end

end

#Never add more than 1, it would just be a copy
def addPokemonStorageTransferBox()
  $PokemonStorage.boxes << StorageTransferBox.new
end

def verifyTransferBoxAutosave()
  if !$game_temp.transfer_box_autosave
    confirmed = pbConfirmMessage(_INTL("Moving Pokémon in and out of the transfer box will save the game automatically. Is this okay?"))
    $game_temp.transfer_box_autosave=true if confirmed
    return confirmed
  end
  return true
end