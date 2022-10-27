local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)

local EventData = {
	["Rocket"] = {
		chance = 60,
		levels = {min = 25, max = General.Levels},
		negativeLuck = true,

		faceRate = 30,
		raycastRate = 40,
		delayTime = 3,
		travelTime = 5,
		size = 12,
		damage = 40,
	},
	["LaserWall"] = {
		chance = 55,
		levels = {min = 20, max = General.Levels},
		negativeLuck = true,

		despawnTime = 10,
		riseDelayTime = 0.5,
		laserDelayTime = 0.5,
		damage = 30,
	},
	["SpeedingWall"] = {
		chance = 50,
		levels = {min = 15, max = General.Levels},
		negativeLuck = true,

		travelTime = 3.5,
	},
	["LavaLine"] = {
		chance = 50,
		levels = {min = 10, max = General.Levels},
		negativeLuck = true,

		despawnTime = 6,
		delayTime = 1,
		damage = 20,
	},
	["Spike"] = {
		chance = 35,
		levels = {min = 7, max = General.Levels},
		negativeLuck = true,

		despawnTime = 10,
		delayTime = 0.5,
		damage = 30,
	},
	["Bomb"] = {
		chance = 50,
		levels = {min = 3, max = General.Levels},
		negativeLuck = true,

		delayTime = 2,
		size = 24,
		damage = 50,
	},
	["Coin"] = {
		chance = 10,
		levels = {min = 1, max = General.Levels},
		value = 10,
		despawnTime = 30,
	},
}
return EventData
