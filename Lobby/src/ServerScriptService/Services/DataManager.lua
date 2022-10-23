local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local Helpers = ReplicatedStorage.Helpers
local ErrorCodeHelper = require(Helpers.ErrorCodeHelper)

local SerServices = ServerScriptService.Services
local DataStorage = SerServices.DataStorage
local ProfileService = require(DataStorage.ProfileService)
local ProfileTemplate = require(DataStorage.ProfileTemplate)

local DataManager = {}
DataManager.Profiles = {}

function DataManager:Initialize(player, storeName)
	local PlayerDataProfileStore = ProfileService.GetProfileStore(
		storeName,
		ProfileTemplate
	)

	local profile = PlayerDataProfileStore:LoadProfileAsync("Player_"..player.UserId)
	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile:ListenToRelease(function()
			if not RunService:IsStudio() then
				player:Kick(ErrorCodeHelper.FormatCode("0001"))
			end
		end)

		if player:IsDescendantOf(Players) then
			self.Profiles[player] = profile
		else
			-- player left before data was loaded
			profile:Release()
		end
	elseif not RunService:IsStudio() then
		player:Kick(ErrorCodeHelper.FormatCode("0002"))
	end

	return profile
end

function DataManager:SetValue(player, property, value)
	local playerProfile = self:GetProfile(player)
	if playerProfile then
		playerProfile.Data[property] = value
	end

	return nil
end

function DataManager:IncrementValue(player, property, value)
	local playerProfile = self:GetProfile(player)
	if playerProfile then
		playerProfile.Data[property] = (playerProfile.Data[property] or 0) + value
	end

	return playerProfile.Data[property]
end

function DataManager:GetValue(player, property)
	local playerProfile = self:GetProfile(player)

	if playerProfile then
		if property then
			return playerProfile.Data[property]
		else
			return playerProfile.Data
		end
	end

	warn(player, "has no profile stored in the data")
	return nil
end

function DataManager:GetProfile(player)
	return self.Profiles[player]
end

----------------------------------------------------------------------------------

function DataManager:SetSpawn(player, levelNum)
	if DataManager:GetValue(player, "Level") + 1 == levelNum then
		DataManager:SetValue(player, "Level", levelNum)
		PlayerValues:SetValue(player, "Level", levelNum)

		local level = player:FindFirstChild("leaderstats"):FindFirstChild("Level")
		level.Value += 1
	end
end

function DataManager:GiveCash(player, cash)
	cash = math.floor(cash * (PlayerValues:GetValue(player, "CMulti") or 1))

	DataManager:IncrementValue(player, "Cash", cash)
	PlayerValues:IncrementValue(player, "Cash", cash, "playerOnly")
end

function DataManager:GivePower(player, power)
	DataManager:IncrementValue(player, "Power", power)
	PlayerValues:IncrementValue(player, "Power", power, "playerOnly")
end

function DataManager:GiveCMulti(player, cMulti)
	DataManager:IncrementValue(player, "CMulti", cMulti)
	PlayerValues:IncrementValue(player, "CMulti", cMulti, "playerOnly")
end

function DataManager:GiveLuck(player, luck)
	DataManager:IncrementValue(player, "Luck", luck)
	PlayerValues:IncrementValue(player, "Luck", luck, "playerOnly")
end

return DataManager