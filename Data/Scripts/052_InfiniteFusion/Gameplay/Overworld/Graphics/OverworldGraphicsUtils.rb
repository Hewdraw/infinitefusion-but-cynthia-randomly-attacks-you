def displayPicture(image, x, y, z = 0)
  pictureWindow = PictureWindow.new(image)
  pictureWindow.z = z
  pictureWindow.x = x
  pictureWindow.y = y
  pictureWindow.opacity = 0
  return pictureWindow
end

def showPokemonInPokeballWithMessage(pif_sprite, message, x_position = nil, y_position = nil)
  x_position = Graphics.width / 4 if !x_position
  y_position = 10 if !y_position

  background_sprite = displayPicture("Graphics/Pictures/Trades/trade_pokeball_open_back", x_position, y_position, 1)
  foreground_sprite = displayPicture("Graphics/Pictures/Trades/trade_pokeball_open_front", x_position, y_position, 9999)
  displaySpriteWindowWithMessage(pif_sprite, message, 90, -10, 201)
  background_sprite.dispose
  foreground_sprite.dispose
end