local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)

local EventData = {
	["SpeedingWall"] = {
		chance = 60,
		levels = {min = 20, max = General.Levels},
		negativeLuck = true,

		travelTime = 4,
	},
	["LavaLine"] = {
		chance = 60,
		levels = {min = 15, max = General.Levels},
		negativeLuck = true,

		despawnTime = 6,
		delayTime = 1,
		damage = 15,
	},
	["Spike"] = {
		chance = 35,
		levels = {min = 10, max = General.Levels},
		negativeLuck = true,

		despawnTime = 6,
		delayTime = 0.5,
		damage = 25,
	},
	["Bomb"] = {
		chance = 50,
		levels = {min = 3, max = General.Levels},
		negativeLuck = true,

		size = 24,
		damage = 60,
	},
	["Coin"] = {
		chance = 10,
		levels = {min = 1, max = General.Levels},
		value = 10,
		despawnTime = 30,
	},
}
return EventData
