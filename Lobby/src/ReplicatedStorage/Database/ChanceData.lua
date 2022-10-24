local ChanceData = {
	["LavaLine"] = {
		chance = 60,
		levelRequired = 10,
		negativeLuck = true,

		despawnTime = 4,
		fadeInTime = 1,
		damage = 15,
	},
	["Bomb"] = {
		chance = 40,
		levelRequired = 3,
		negativeLuck = true,

		size = 30,
		damage = 55,
	},
	["Coin"] = {
		chance = 10,
		value = 10,
		despawnTime = 30,
	},
}
return ChanceData
