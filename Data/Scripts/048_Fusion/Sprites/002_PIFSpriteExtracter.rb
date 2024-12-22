class PIFSpriteExtracter
  COLUMNS = 20               # Number of columns in the spritesheet
  @@spritesheet_cache = SpritesBitmapCache.new

  def load_sprite(pif_sprite,download_allowed=true)
    begin
    start_time = Time.now
    bitmap = @@spritesheet_cache.get_bitmap(pif_sprite)
    loaded_from_spritesheet=false

    if !bitmap
      download_new_spritesheet(pif_sprite) if should_update_spritesheet?(pif_sprite) && download_allowed
      if pbResolveBitmap(getSpritesheetPath(pif_sprite))
        bitmap = load_bitmap_from_spritesheet(pif_sprite)
        loaded_from_spritesheet=true
        @@spritesheet_cache.add(pif_sprite, bitmap)
      else
        return nil
      end
    end
    sprite_bitmap = AnimatedBitmap.from_bitmap(bitmap)
    end_time = Time.now
    source = loaded_from_spritesheet ? :"spritesheet" : "cache"
    echoln "Loaded sprite for <head:#{pif_sprite.head_id}, body: #{pif_sprite.body_id}, variant: #{pif_sprite.alt_letter}> from #{source} in #{end_time - start_time} seconds"
    return sprite_bitmap
    rescue Exception
      e = $!
      echoln "Error loading sprite: #{e}" if bitmap
    end
  end

  def download_new_spritesheet(pif_sprite)
    spritesheet_file = getSpritesheetPath(pif_sprite)
    if download_spritesheet(pif_sprite,spritesheet_file)
      $updated_spritesheets << spritesheet_file
      update_downloaded_spritesheets_list()
      return true
    end
    return false
  end

  def update_downloaded_spritesheets_list()
    File.open(Settings::UPDATED_SPRITESHEETS_CACHE, "w") do |file|
      $updated_spritesheets.each { |line| file.puts(line) }
    end
  end

  def get_sprite_position_on_spritesheet(body_id,sprite_size,nb_column)
    row = body_id / nb_column
    col = body_id % nb_column
    # echoln "(#{col},#{row})"
    # Define the area of the sprite on the spritesheet
    sprite_x_position = col * sprite_size
    sprite_y_position = row * sprite_size
    return sprite_x_position, sprite_y_position
  end


  def extract_bitmap_to_file(pif_sprite, dest_folder)
    # Create the directory if it doesn't exist
    Dir.mkdir(dest_folder) unless Dir.exist?(dest_folder)
    single_sprite_bitmap=load_sprite(pif_sprite)

    # Save the single sprite bitmap to a file
    file_path = "#{dest_folder}/#{head_id}.#{body_id}.png"
    single_sprite_bitmap.save_to_png(file_path)

    # Dispose of the single sprite bitmap
    single_sprite_bitmap.dispose

    # Return the path to the saved PNG file
    return file_path
  end

  #Implemented for base and custom, not autogen
  def should_update_spritesheet?(spritesheet_file)
    return false
  end

  def getSpritesheetPath(pif_sprite)
    return nil #implement in subclasses
  end

  def clear_cache()
    @@spritesheet_cache.clear
  end

  end

class PokemonGlobalMetadata
  attr_accessor :current_spritepack_date
end





# class SpritesBitmapCache
#   @@cache = {} # Cache storage for spritesheets
#   @@usage_order = [] # Tracks usage order for LRU eviction
#
#   def self.fetch(key)
#     if @@cache.key?(key)
#       # Move key to the end to mark it as recently used
#       @@usage_order.delete(key)
#       @@usage_order << key
#       return @@cache[key]
#     end
#
#     # Load spritesheet via block if not found in cache
#     spritesheet = yield
#
#     if @@cache.size >= Settings::SPRITE_CACHE_MAX_NB
#       # Evict least recently used (first in order)
#       oldest_key = @@usage_order.shift
#       @@cache.delete(oldest_key)
#       echoln "Evicted: #{oldest_key} from spritesheet cache"
#     end
#
#     # Add new spritesheet to cache and track its usage
#     @@cache[key] = spritesheet
#     @@usage_order << key
#     spritesheet
#   end
# end