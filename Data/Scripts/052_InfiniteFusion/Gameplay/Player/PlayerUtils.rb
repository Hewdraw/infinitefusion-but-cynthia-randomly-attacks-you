def isPlayerMale()
  return pbGet(VAR_TRAINER_GENDER) == GENDER_MALE
end

def isPlayerFemale()
  return pbGet(VAR_TRAINER_GENDER) == GENDER_FEMALE
end

def getPlayerGenderId()
  return pbGet(VAR_TRAINER_GENDER)
end


def isPostgame?()
  return $game_switches[SWITCH_BEAT_THE_LEAGUE]
end