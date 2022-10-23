local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local ClientService = {}

function ClientService.InitializeClient(player, profile)
    PlayerValues:SetValue(player, "Level", profile.Data.Level, "playerOnly")
    PlayerValues:SetValue(player, "Cash", profile.Data.Cash, "playerOnly")
    PlayerValues:SetValue(player, "Strength", profile.Data.Strength, "playerOnly")
end

return ClientService