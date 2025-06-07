
COMMON_EVENT_TRAINER_REMATCH_PARTNER = 200
def partnerWithTrainer(eventId, mapID, trainer)
  Kernel.pbAddDependency2(eventId,trainer.trainerName,COMMON_EVENT_TRAINER_REMATCH_PARTNER)
  pbCancelVehicles
  originalTrainer = pbLoadTrainer(trainer.trainerType, trainer.trainerName, 0)
  Events.onTrainerPartyLoad.trigger(nil, originalTrainer)
  for i in trainer.currentTeam
    i.owner = Pokemon::Owner.new_from_trainer(originalTrainer)
    i.calc_stats
  end
  $PokemonGlobal.partner = [trainer.trainerType, trainer.trainerName, 0, trainer.currentTeam]
end
