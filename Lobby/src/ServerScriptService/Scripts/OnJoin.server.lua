local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local ServerValues = require(ServerScriptService.ServerValues)

local SerServices = ServerScriptService.Services
local DataManager = require(SerServices.DataManager)
local ClientService = require(SerServices.ClientService)

local PlayerProfiles = {}

local function getPlayerProfile(player)
    return DataManager:Initialize(player, ServerValues.DATASTORE_NAME)
end

local function loadPlayerProfile(player, profile)
    PlayerProfiles[player] = profile
end

local function playerAdded(newPlayer)
    local profile = getPlayerProfile(newPlayer)
	if profile ~= nil then
		loadPlayerProfile(newPlayer, profile)

        local stats = Instance.new("Folder")
        stats.Name = "leaderstats"
        local stage = Instance.new("NumberValue")
        stage.Name = "Level"
        stage.Value = DataManager:GetValue(newPlayer, "Level")
        stats.Parent = newPlayer
        stage.Parent = stats
	else
        warn("Could not load player profile")
    end

    local function loadPlayer()
        task.spawn(function()
            if not newPlayer.Character then
                repeat task.wait(1) until newPlayer.Character
            end

            local currentLevel = DataManager:GetValue(newPlayer, "Level")
            if currentLevel ~= 1 then
                local physicalLevel = workspace.Levels:FindFirstChild(currentLevel)
                repeat
                    newPlayer.Character:PivotTo(physicalLevel.Spawn.CFrame)
                    task.wait()
                until (newPlayer.Character:GetPivot().Position - physicalLevel.Spawn.Position).Magnitude < 10
            end
        end)

        ClientService.InitializeClient(newPlayer, profile)
    end

    loadPlayer()

    newPlayer.CharacterAdded:Connect(function()
        loadPlayer()
    end)
end

local function playerRemoved(player)
	local profile = PlayerProfiles[player]
	if profile ~= nil then
		profile:Release()
        PlayerProfiles[player] = nil
	end
end

Players.PlayerAdded:Connect(playerAdded)
Players.PlayerRemoving:Connect(playerRemoved)

for _,currentPlayers in pairs(Players:GetChildren()) do
    playerAdded(currentPlayers)
end