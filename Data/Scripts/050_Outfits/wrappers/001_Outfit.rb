class Outfit
  attr_accessor :id
  attr_accessor :name
  attr_accessor :description
  attr_accessor :tags
  attr_accessor :price

  attr_accessor :is_in_regional_set
  attr_accessor :is_in_city_exclusive_set




  REGION_TAGS = ["kanto", "johto", "hoenn", "sinnoh", "unova", "kalos", "alola", "galar", "paldea"]
  def check_if_regional_set(tags)
    REGION_TAGS.any? { |region| tags.include?(region) }
  end

  CITY_OUTFIT_TAGS= [
    "pewter","cerulean","vermillion","lavender","celadon","fuchsia","cinnabar",
    "crimson","goldenrod","azalea", "violet", "blackthorn", "mahogany", "ecruteak",
    "olivine","cianwood", "kin"
  ]
  def check_if_city_set(tags)
    CITY_OUTFIT_TAGS.any? { |city| tags.include?(city) }
  end

  def initialize(id, name, description = '',price=0, tags = [])
    @id = id
    @name = name
    @description = description
    @tags = tags
    @price = price

    @is_in_regional_set = check_if_regional_set(tags)
    @is_in_city_exclusive_set = check_if_city_set(tags)
  end

  def trainer_sprite_path()
    return nil
  end
end