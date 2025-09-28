# Necessary dor setting the various events within the pokemart map, uses the numbers as wondertrade
def get_city_numerical_id(city_sym)
  return get_city_numerical_id_hoenn(city_sym) if Settings::GAME_ID == :IF_HOENN
  current_city_numerical = {
    :PEWTER => 1,
    :CERULEAN => 2,
    :VERMILLION => 3,
    :LAVENDER => 4,
    :CELADON => 5,
    :FUCHSIA => 6,
    :SAFFRON => 7,
    :CINNABAR => 8,
    :LEAGUE => 9,
    :VIOLET => 10,
    :AZALEA => 11,
    :GOLDENROD => 12,
    :ECRUTEAK => 13,
    :MAHOGANY => 14,
    :BLACKTHORN => 15,
    :OLIVINE => 16,
    :CIANWOOD => 17,
    :KNOTISLAND => 18,
    :BOONISLAND => 19,
    :KINISLAND => 20,
    :CHRONOISLAND => 21,
    :CRIMSON => 22,
  }
  return current_city_numerical[city_sym]
end

POKEMART_MAP_ID = 357
POKEMART_DOOR_POS = [12, 12]
# city -> Symbol
def enter_pokemart(city)
  pbSet(VAR_CURRENT_MART, city)
  pbSet(VAR_CURRENT_CITY_NUMERICAL_ID, get_city_numerical_id(city))
  echoln get_city_numerical_id(city)
  pbFadeOutIn {
    $game_temp.player_new_map_id = POKEMART_MAP_ID
    $game_temp.player_new_x = POKEMART_DOOR_POS[0]
    $game_temp.player_new_y = POKEMART_DOOR_POS[1]
    $scene.transfer_player(true)
    $game_map.autoplay
    $game_map.refresh
  }
end

def exit_pokemart()
  return exit_pokemart_hoenn() if Settings::GAME_ID == :IF_HOENN
  pokemart_entrances = {
    :PEWTER => [380, 43, 24],
    :CERULEAN => [1, 24, 22],
    :VERMILLION => [19, 32, 13],
    :LAVENDER => [50, 20, 23],
    :CELADON => [95, 18, 15], # not a real pokemart
    :FUCHSIA => [472, 7, 17],
    :SAFFRON => [108, 53, 24],
    :CINNABAR => [98, 30, 30],
    :CRIMSON => [167, 21, 36],
    :GOLDENROD => [237, 36, 33], # not a real pokemart
    :AZALEA => [278, 34, 17],
    :AZALEA_FLOODED => [338, 34, 17],
    :VIOLET => [230, 20, 31],
    :BLACKTHORN => [329, 16, 36],
    :MAHOGANY => [631, 19, 19], # not a real pokemart
    :ECRUTEAK => [359, 46, 38],
    :OLIVINE => [138, 33, 23],
    :CIANWOOD => [709.8, 46],
  }
  current_city = pbGet(VAR_CURRENT_MART)
  current_city = :PEWTER if !current_city.is_a?(Symbol)

  entrance_map = pokemart_entrances[current_city][0]
  entrance_x = pokemart_entrances[current_city][1]
  entrance_y = pokemart_entrances[current_city][2]

  reset_pokemart_variables
  pbFadeOutIn {
    $game_temp.player_new_map_id = entrance_map
    $game_temp.player_new_x = entrance_x
    $game_temp.player_new_y = entrance_y
    $scene.transfer_player(true)
    $game_map.autoplay
    $game_map.refresh
  }

end

def reset_pokemart_variables
  pbSet(VAR_CURRENT_CITY_NUMERICAL_ID, 0)
  pbSet(VAR_CURRENT_MART, 0)
end
def pokemart_clothes_shop(current_city = nil, include_defaults = true)
  current_city = pbGet(VAR_CURRENT_MART) if !current_city
  echoln current_city
  current_city = :PEWTER if !current_city.is_a?(Symbol)
  current_city_tag = current_city.to_s.downcase
  selector = OutfitSelector.new
  list = selector.generate_clothes_choice(
    baseOptions = include_defaults,
    additionalIds = [],
    additionalTags = [current_city_tag],
    filterOutTags = [])
  clothesShop(list)
end

def pokemart_hat_shop(include_defaults = true)
  current_city = pbGet(VAR_CURRENT_MART)
  current_city = :PEWTER if !current_city.is_a?(Symbol)
  current_city_tag = current_city.to_s.downcase
  selector = OutfitSelector.new
  list = selector.generate_hats_choice(
    baseOptions = include_defaults,
    additionalIds = [],
    additionalTags = [current_city_tag],
    filterOutTags = [])

  hatShop(list)
end

def get_mart_exclusive_items(city)
  return get_mart_exclusive_items_hoenn if Settings::GAME_ID == :IF_HOENN
  items_list = []
  case city
  when :PEWTER;
    items_list = [:ROCKGEM, :NESTBALL]
  when :VIRIDIAN;
    items_list = []
  when :CERULEAN;
    items_list = [:WATERGEM, :NETBALL, :PRETTYWING]
  when :VERMILLION;
    items_list = [:LOVEBALL, :ELECTRICGEM]
  when :LAVENDER;
    items_list = [:GHOSTGEM, :DARKGEM, :DUSKBALL]
  when :CELADON;
    items_list = [:GRASSGEM, :FLYINGGEM, :QUICKBALL, :TIMERBALL,]
  when :FUCHSIA;
    items_list = [:POISONGEM, :REPEATBALL]
  when :SAFFRON;
    items_list = [:PSYCHICGEM, :FIGHTINGGEM, :FRIENDBALL]
  when :CINNABAR;
    items_list = [:FIREGEM, :ICEGEM, :HEAVYBALL]
  when :CRIMSON;
    items_list = [:DRAGONGEM, :LEVELBALL]
  when :GOLDENROD;
    items_list = [:EVERSTONE, :MOONSTONE, :SUNSTONE, :DUSKSTONE, :DAWNSTONE, :SHINYSTONE]
  when :AZALEA;
    items_list = [:BUGGEM]
  when :VIOLET;
    items_list = [:FLYINGGEM, :STATUSBALL]
  when :BLACKTHORN;
    items_list = [:DRAGONGEM, :CANDYBALL]
  when :CHERRYGROVE;
    items_list = [:BUGGEM, :PUREBALL]
  when :MAHOGANY;
    items_list = []
  when :ECRUTEAK;
    items_list = [:GHOSTGEM, :DARKGEM]
  when :OLIVINE;
    items_list = []
  when :CIANWOOD;
    items_list = []
  when :KNOTISLAND;
    items_list = []
  when :BOONISLAND;
    items_list = []
  when :KINISLAND;
    items_list = []
  when :CHRONOISLAND;
    items_list = []
  end
  return items_list
end