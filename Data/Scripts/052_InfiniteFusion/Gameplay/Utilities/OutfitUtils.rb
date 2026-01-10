def unlock_easter_egg_hats()
  if $Trainer.name.downcase == "ash"
    $Trainer.hat = HAT_ASH
    $Trainer.unlock_hat(HAT_ASH)
  end
  if $Trainer.name.downcase == "frogman"
    $Trainer.hat = HAT_FROG
    $Trainer.unlock_hat(HAT_FROG)
  end
end

def getPlayerDefaultName(gender)
  if gender == GENDER_MALE
    return Settings::GAME_ID == :IF_HOENN ? "Brendan" : "Red"
  else
    return Settings::GAME_ID == :IF_HOENN ? "May" : "Green"
  end
end

def getDefaultClothes(gender)
  if gender == GENDER_MALE
    return Settings::GAME_ID == :IF_HOENN ? CLOTHES_BRENDAN : DEFAULT_OUTFIT_MALE
  else
    return Settings::GAME_ID == :IF_HOENN ? CLOTHES_MAY : DEFAULT_OUTFIT_FEMALE
  end
end

def getDefaultHat(gender)
  if gender == GENDER_MALE
    return Settings::GAME_ID == :IF_HOENN ? HAT_BRENDAN : DEFAULT_OUTFIT_MALE
  else
    return Settings::GAME_ID == :IF_HOENN ? HAT_MAY : DEFAULT_OUTFIT_FEMALE
  end
end

def getDefaultHair(gender)
  if gender == GENDER_MALE
    return Settings::GAME_ID == :IF_HOENN ? HAIR_BRENDAN : DEFAULT_OUTFIT_MALE
  else
    return Settings::GAME_ID == :IF_HOENN ? HAIR_MAY : DEFAULT_OUTFIT_FEMALE
  end
end

def setupStartingOutfit()
  default_clothes_male = getDefaultClothes(GENDER_MALE)
  default_clothes_female = getDefaultClothes(GENDER_FEMALE)

  default_hat_male = getDefaultHat(GENDER_MALE)
  default_hat_female = getDefaultHat(GENDER_FEMALE)

  default_hair_male = getDefaultHair(GENDER_MALE)
  default_hair_female = getDefaultHair(GENDER_FEMALE)

  $Trainer.hat = nil
  $Trainer.clothes = STARTING_OUTFIT
  unlock_easter_egg_hats()
  gender = pbGet(VAR_TRAINER_GENDER)
  if gender == GENDER_FEMALE
    $Trainer.unlock_clothes(default_clothes_female, true)
    $Trainer.unlock_hat(default_hat_female, true)
    $Trainer.hair = "3_" + default_hair_female if !$Trainer.hair # when migrating old savefiles

  elsif gender == GENDER_MALE
    $Trainer.unlock_clothes(default_clothes_male, true)
    $Trainer.unlock_hat(default_hat_male, true)

    echoln $Trainer.hair
    $Trainer.hair = ("3_" + default_hair_male) if !$Trainer.hair # when migrating old savefiles
    echoln $Trainer.hair
  end
  $Trainer.unlock_hair(default_hair_male, true)
  $Trainer.unlock_hair(default_hair_female, true)
  $Trainer.unlock_clothes(STARTING_OUTFIT, true)
end

def give_date_specific_hats()
  current_date = Time.new
  # Christmas
  if (current_date.day == 24 || current_date.day == 25) && current_date.month == 12
    if !$Trainer.unlocked_hats.include?(HAT_SANTA)
      pbCallBub(2, @event_id, true)
      pbMessage(_INTL("Hi! We're giving out a special hat today for the holidays season. Enjoy!"))
      obtainHat(HAT_SANTA)
    end
  end

  # April's fool
  if (current_date.day == 1 && current_date.month == 4)
    if !$Trainer.unlocked_hats.include?(HAT_CLOWN)
      pbCallBub(2, @event_id, true)
      pbMessage(_INTL("Hi! We're giving out this fun accessory for this special day. Enjoy!"))
      obtainHat(HAT_CLOWN)
    end
  end
end

def qmarkMaskCheck()
  if $Trainer.seen_qmarks_sprite
    unless hasHat?(HAT_QMARKS)
      obtainHat(HAT_QMARKS)
      obtainClothes(CLOTHES_GLITCH)
    end
  end
end

def purchaseDyeKitMenu(hats_kit_price = 0, clothes_kit_price = 0)

  commands = []
  command_hats = _INTL("Hats Dye Kit (${1})",hats_kit_price)
  command_clothes = _INTL("Clothes Dye Kit (${1})",clothes_kit_price)
  command_cancel = _INTL("Cancel")

  commands << command_hats if !$PokemonBag.pbHasItem?(:HATSDYEKIT)
  commands << command_clothes if !$PokemonBag.pbHasItem?(:CLOTHESDYEKIT)
  commands << command_cancel

  if commands.length <= 1
    pbCallBub(2, @event_id)
    pbMessage(_INTL("\\C[1]Dye Kits\\C[0] can be used to dye clothes all sorts of colours!"))

    pbCallBub(2, @event_id)
    pbMessage(_INTL("You can use them at any time when you change clothes."))
    return
  end
  pbCallBub(2, @event_id)
  pbMessage(_INTL("\\GWelcome! Are you interested in dyeing your outfits different colours?"))

  pbCallBub(2, @event_id)
  pbMessage(_INTL("I make handy \\C[1]Dye Kits\\C[0] from my Smeargle's paint that can be used to dye your outfits any color you want!"))

  pbCallBub(2, @event_id)
  pbMessage(_INTL("\\GWhat's more is that it's reusable so you can go completely wild with it if you want! Are you interested?"))

  choice = optionsMenu(commands, commands.length)
  case commands[choice]
  when command_hats
    if $Trainer.money < hats_kit_price
      pbCallBub(2, @event_id)
      pbMessage(_INTL("Oh, you don't have enough money..."))
      return
    end
    pbMessage(_INTL("\\G\\PN purchased the dye kit."))
    $Trainer.money -= hats_kit_price
    pbSEPlay("SlotsCoin")
    Kernel.pbReceiveItem(:HATSDYEKIT)
    pbCallBub(2, @event_id)
    pbMessage(_INTL("\\GHere you go! Have fun dyeing your hats!"))
  when command_clothes
    if $Trainer.money < clothes_kit_price
      pbCallBub(2, @event_id)
      pbMessage(_INTL("Oh, you don't have enough money..."))
      return
    end
    pbMessage(_INTL("\\G\\PN purchased the dye kit."))
    $Trainer.money -= clothes_kit_price
    pbSEPlay("SlotsCoin")
    Kernel.pbReceiveItem(:CLOTHESDYEKIT)
    pbCallBub(2, @event_id)
    pbMessage(_INTL("\\GHere you go! Have fun dyeing your clothes!"))
  end
  pbCallBub(2, @event_id)
  pbMessage(_INTL("You can use \\C[1]Dye Kits\\C[0] at any time when you change clothes."))
end

