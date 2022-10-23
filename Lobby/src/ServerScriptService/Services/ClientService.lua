local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local Remotes = ReplicatedStorage.Remotes
local ClientConnection = Remotes.ClientConnection

local ClientService = {}

function ClientService.InitializeClient(player, profile)
    PlayerValues:SetValue(player, "Level", profile.Data.Level, "playerOnly")
    PlayerValues:SetValue(player, "Cash", profile.Data.Cash, "playerOnly")
    PlayerValues:SetValue(player, "Power", profile.Data.Power, "playerOnly")
    PlayerValues:SetValue(player, "CMulti", profile.Data.Power, "playerOnly")
    PlayerValues:SetValue(player, "Luck", profile.Data.Power, "playerOnly")

    ClientConnection:FireClient(player, "loadPlayerValues")
end

return ClientService