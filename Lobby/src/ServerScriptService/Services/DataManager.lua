local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local Helpers = ReplicatedStorage.Helpers
local ErrorCodeHelper = require(Helpers.ErrorCodeHelper)

local Utility = ReplicatedStorage.Utility
local General = require(Utility.General)

local Remotes = ReplicatedStorage.Remotes
local BuyConnection = Remotes.BuyConnection

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
	if cash > 0 then
		cash = math.floor(cash * (PlayerValues:GetValue(player, "CMulti") or 1))
	end

	DataManager:IncrementValue(player, "Cash", cash)
	PlayerValues:IncrementValue(player, "Cash", cash, "playerOnly")
end

function DataManager:BuyPower(player)
	local cost = General.PowerCost + General.PowerIncrease * (PlayerValues:GetValue(player, "Power") - 1)
	if PlayerValues:GetValue(player, "Cash") >= cost then
		DataManager:GiveCash(player, -cost)

		DataManager:IncrementValue(player, "Power", 1)
		PlayerValues:IncrementValue(player, "Power", 1, "playerOnly")
	end
end

function DataManager: BuyCMulti(player)
	local cost = General.CMultiCost + General.CMultiIncrease * (PlayerValues:GetValue(player, "CMulti") - 1)
	if PlayerValues:GetValue(player, "Cash") >= cost then
		DataManager:GiveCash(player, -cost)

		DataManager:IncrementValue(player, "CMulti", 1)
		PlayerValues:IncrementValue(player, "CMulti", 1, "playerOnly")
	end
end

function DataManager:BuyLuck(player)
	local cost = General.LuckCost + General.LuckIncrease * (PlayerValues:GetValue(player, "Luck") - 1)
	if PlayerValues:GetValue(player, "Cash") >= cost then
		DataManager:GiveCash(player, -cost)

		DataManager:IncrementValue(player, "Luck", 1)
		PlayerValues:IncrementValue(player, "Luck", 1, "playerOnly")
	end
end

BuyConnection.OnServerEvent:Connect(function(player, action)
	if action == "Power" then
		DataManager:BuyPower(player)
	elseif action == "CMulti" then
		DataManager:BuyCMulti(player)
	elseif action == "Luck" then
		DataManager:BuyLuck(player)
	end
end)

return DataManager