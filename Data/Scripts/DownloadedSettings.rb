
module Settings
  LATEST_GAME_RELEASE = "6.3.0"

  SHINY_POKEMON_CHANCE = 16
  DISCORD_URL = "https://discord.com/invite/infinitefusion"
  WIKI_URL = "https://infinitefusion.fandom.com/"
  STARTUP_MESSAGES = ""
  
  CREDITS_FILE_URL = "https://infinitefusion.net/Sprite Credits.csv"
  SPRITES_FILE_URL = "https://raw.githubusercontent.com/infinitefusion/infinitefusion-e18/main/Data/CUSTOM_SPRITES"
  VERSION_FILE_URL = "https://raw.githubusercontent.com/infinitefusion/infinitefusion-e18/main/Data/VERSION"
  CUSTOM_DEX_FILE_URL = "https://raw.githubusercontent.com/infinitefusion/infinitefusion-e18/main/Data/dex.json"

  # CUSTOM SPRITES
  AUTOGEN_SPRITES_REPO_URL = ""
  
  CUSTOM_SPRITES_REPO_URL = "https://bitbucket.org/infinitefusionsprites/customsprites/raw/main/CustomBattlers/"
  CUSTOM_SPRITES_NEW_URL = "https://infinitefusion.net/CustomBattlers/"

  BASE_POKEMON_SPRITES_REPO_URL = ""
  
  BASE_POKEMON_ALT_SPRITES_REPO_URL = "https://bitbucket.org/infinitefusionsprites/customsprites/raw/main/Other/BaseSprites/"
  BASE_POKEMON_ALT_SPRITES_NEW_URL = "https://infinitefusion.net/Other/BaseSprites/"


  
  CUSTOMSPRITES_RATE_MAX_NB_REQUESTS = 5  #Nb. requests allowed in each time window
  CUSTOMSPRITES_ENTRIES_RATE_TIME_WINDOW = 120    # In seconds
  MAX_NB_SPRITES_TO_DOWNLOAD_AT_ONCE =5

  #POKEDEX ENTRIES

  AI_ENTRIES_URL = "https://infinitefusion.net/dex/"
  AI_ENTRIES_RATE_MAX_NB_REQUESTS = 10  #Nb. requests allowed in each time window
  AI_ENTRIES_RATE_TIME_WINDOW = 120    # In seconds
  AI_ENTRIES_RATE_LOG_FILE = 'Data/pokedex/rate_limit.log'  # Path to the log file




end
