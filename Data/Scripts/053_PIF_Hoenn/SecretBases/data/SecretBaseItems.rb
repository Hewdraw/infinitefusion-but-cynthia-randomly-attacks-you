# frozen_string_literal: true
module SecretBasesData

  SECRET_BASE_ITEMS = {}

  def SecretBasesData::register_base_item(id, **kwargs)
    SECRET_BASE_ITEMS[id] = SecretBaseItem.new(id: id, **kwargs)
  end

  register_base_item(
    :PC,
    graphics: "Furniture/pc.png",
    real_name: "PC",
    deletable: false,
    price: 0,
    behavior: ->(event = nil) {
      #Behavior for PC is handled in SecretBasesController
      #useSecretBasePC
    }
  )

  register_base_item(
    :MANNEQUIN,
    graphics: "Furniture/mannequin.png",
    real_name: _INTL("Mannequin"),
    price: 500,
    behavior: ->(event = nil) {
      useSecretBaseMannequin
    }

  )

  register_base_item(
    :PLANT,
    graphics: "Furniture/plant.png",
    real_name: _INTL("Decorative Plant"),
    price: 500
  )

  register_base_item(
    :RED_CHAIR,
    graphics: "Furniture/red_chair.png",
    real_name: _INTL("Red Chair"),
    price: 350,
    trigger: TRIGGER_PLAYER_TOUCH,
    behavior: ->(itemInstance = nil) {
      sit_on_chair(itemInstance)
    }
  )

  register_base_item(
    :FANCY_CARPET,
    graphics: "Carpets/fancy_carpet.png",
    real_name: _INTL("Fancy Carpet"),
    price: 5000,
    pass_through: true,
    under_player: true
  )

  register_base_item(
    :FANCY_CARPET_CONNECT,
    graphics: "Carpets/fancy_carpet_connect.png",
    real_name: _INTL("Fancy Carpet (Connection)"),
    price: 100,
    pass_through: true,
    under_player: true
  )

  register_base_item(
    :BOULDER,
    graphics: "Furniture/boulder.png",
    real_name: _INTL("Boulder"),
    price: 600,
    under_player: false,
    behavior: ->(itemInstance = nil) {
      pbStrength
      if $PokemonMap.strengthUsed
        pushEvent(itemInstance)
      end
    }
  )

  #Skitty set

  register_base_item(
    :SKITTY_CHAIR_3x3,
    graphics: "skittySet/deco_3x3chair_skitty.png",
    real_name: _INTL("Skitty Armchair"),
    price: 1000,
    height: 1,
    width: 3,
    trigger: TRIGGER_PLAYER_TOUCH,
    behavior: ->(itemInstance = nil) {
      sit_on_chair(itemInstance)
    },
    uninteractable_positions: [[-1,0],[1,0]]
  )

  register_base_item(
    :SKITTY_CHAIR_3x3,
    graphics: "skittySet/deco_3x3chair_skitty.png",
    real_name: _INTL("Skitty Armchair"),
    price: 1000,
    height: 1,
    width: 3,
    trigger: TRIGGER_PLAYER_TOUCH,
    behavior: ->(itemInstance = nil) {
      sit_on_chair(itemInstance)
    },
    uninteractable_positions: [[-1,0],[1,0]]
  )

  register_base_item(
    :SKITTY_COUCH_3x4,
    graphics: "skittySet/deco_3x4chair_skitty.png",
    real_name: _INTL("Skitty Couch"),
    price: 2000,
    height: 1,
    width: 4,
    trigger: TRIGGER_PLAYER_TOUCH,
    behavior: ->(itemInstance = nil) {
      sit_on_chair(itemInstance)
    },
    uninteractable_positions: [[-2,0],[2,0]]
  )

  register_base_item(
    :SKITTY_COUCH_3x5,
    graphics: "skittySet/deco_3x5couch_skitty.png",
    real_name: _INTL("Wide Skitty Couch"),
    price: 2000,
    height: 1,
    width: 5,
    trigger: TRIGGER_PLAYER_TOUCH,
    behavior: ->(itemInstance = nil) {
      sit_on_chair(itemInstance)
    },
    uninteractable_positions: [[-2,0],[2,0]]
  )

  register_base_item(
    :SKITTY_RUG_3x3,
    graphics: "skittySet/deco_3x3rug_skitty.png",
    real_name: _INTL("Large Skitty Rug"),
    price: 3000,
    pass_through: true,
    under_player: true
  )

  #Rock set
  register_base_item(
    :ROCK_CHAIR_1x1,
    graphics: "rockSet/deco_1x1chair_rock.png",
    real_name: _INTL("Rocky Stool"),
    price: 350,
    trigger: TRIGGER_PLAYER_TOUCH,
    behavior: ->(itemInstance = nil) {
      sit_on_chair(itemInstance)
    }
  )

  register_base_item(
    :ROCK,
    graphics: "rockSet/deco_1x1deco_rock.png",
    real_name: _INTL("Rock"),
    price: 50
  )

  register_base_item(
    :ROCK_STATUE,
    graphics: "rockSet/deco_1x1statue_rock.png",
    real_name: _INTL("Rocky Statue"),
    price: 50
  )

  register_base_item(
    :ROCK_WALL,
    graphics: "rockSet/deco_1x2wall_rock.png",
    real_name: _INTL("Rocky Wall"),
    price: 50
  )

  register_base_item(
    :ROCK_TABLE_2x3,
    graphics: "rockSet/deco_2x3table_rock.png",
    real_name: _INTL("Large Rocky Table"),
    width:3,
    height:2,
    price: 5000
  )

  register_base_item(
    :ROCK_CHAIR_3x3,
    graphics: "rockSet/deco_3x3chair_rock.png",
    real_name: _INTL("Rocky Armchair"),
    price: 1000,
    height: 1,
    width: 3,
    trigger: TRIGGER_PLAYER_TOUCH,
    behavior: ->(itemInstance = nil) {
      sit_on_chair(itemInstance)
    },
    uninteractable_positions: [[-1,0],[1,0]]
  )

  register_base_item(
    :ROCK_RUG_1x1,
    graphics: "rockSet/deco_1x1rug_rock.png",
    real_name: _INTL("Small Rocky Rug"),
    price: 500,
    pass_through: true,
    under_player: true
  )

  register_base_item(
    :ROCK_RUG_3x3,
    graphics: "rockSet/deco_3x3rug_rock.png",
    real_name: _INTL("Large Rocky Rug"),
    price: 2000,
    pass_through: true,
    under_player: true
  )

end

