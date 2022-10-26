local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local SerServices = ServerScriptService.Services
local GameService = require(SerServices.GameService)

local Remotes = ReplicatedStorage.Remotes
local ClientConnection = Remotes.ClientConnection
local ShopConnection = Remotes.ShopConnection

local ClientService = {}

function ClientService.InitializeClient(player, profile)
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    local stage = Instance.new("NumberValue")
    stage.Name = "Level"
    stage.Value = profile.Data.Level
    stats.Parent = player
    stage.Parent = stats

    --PlayerValues:SetValue(player, "CurrentLevel", profile.Data.Level)
    PlayerValues:SetValue(player, "Level", profile.Data.Level, "playerOnly")
    PlayerValues:SetValue(player, "Cash", profile.Data.Cash, "playerOnly")
    PlayerValues:SetValue(player, "Power", profile.Data.Power, "playerOnly")
    PlayerValues:SetValue(player, "AClick", profile.Data.AClick, "playerOnly")
    PlayerValues:SetValue(player, "CMulti", profile.Data.CMulti, "playerOnly")
    PlayerValues:SetValue(player, "Luck", profile.Data.Luck, "playerOnly")

    ClientConnection:FireClient(player)
    ShopConnection:FireClient(player)
end

return ClientService