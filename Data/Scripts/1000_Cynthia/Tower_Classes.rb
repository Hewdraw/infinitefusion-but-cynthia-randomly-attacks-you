TRAINERCLASSDICT = {
	:ACETRAINER => {
		:name => "Ace Trainer",
		:emera => :TRAININGGEAR,
	},
	:BUGCATCHER => {
		:name => "Bug Catcher",
		:emera => :CATCHINGNET,
	},
}

def selectTrainerClass()
	Kernel.pbMessage("Select your Trainer Class.")
	trainerlist = []
	namelist = []
	descriptionlist = []
	TRAINERCLASSDICT.each do |trainerclass, dict|
		trainerlist.push(trainerclass)
		namelist.push(dict[:name])
		descriptionlist.push(EMERADICT[dict[:emera]][:description])
	end
	choice = pbUnknownCommands(namelist, descriptionlist)
	trainerclass = trainerlist[choice]
    getLooplet.pbStoreEmera(TRAINERCLASSDICT[trainerclass][:emera])
end