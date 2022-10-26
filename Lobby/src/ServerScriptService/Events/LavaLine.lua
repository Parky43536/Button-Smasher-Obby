local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local SerServices = ServerScriptService.Services
local DataManager = require(SerServices.DataManager)

local Assets = ReplicatedStorage.Assets

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)
local EventService = require(Utility.EventService)
local TweenService = require(Utility.TweenService)
local ModelTweenService = require(Utility.ModelTweenService)
local AudioService = require(Utility.AudioService)

local Event = {}

local touchCooldown = {}

function Event.Main(levelNum, level, data)
    local rlp = EventService.randomLevelPoint(level)
    if rlp then
        local lava = Assets.Levels.Lava:Clone()
        local rng = Random.new()
        if rng:NextInteger(1, 2) == 1 then
            lava.Position = Vector3.new(rlp.Position.X, rlp.Position.Y, level.Floor.Position.Z)
            lava.Size = Vector3.new(lava.Size.X, lava.Size.Y, level.Floor.Size.Z - 0.01)
        else
            lava.Position = Vector3.new(level.Floor.Position.X, rlp.Position.Y, rlp.Position.Z)
            lava.Size = Vector3.new(level.Floor.Size.X - 0.01, lava.Size.Y, lava.Size.Z)
        end

        lava.Parent = workspace.Misc

        local goal = {Transparency = 0.1}
        local properties = {Time = data.delayTime}
        TweenService.tween(lava, goal, properties)

        task.wait(data.delayTime)

        lava.LavaParticle.Enabled = true

        local touchConnection
        touchConnection = lava.Touched:Connect(function(hit)
            local player = game.Players:GetPlayerFromCharacter(hit.Parent)
            if player and player.Character then
                if not touchCooldown[player] then
                    touchCooldown[player] = tick() - EventService.TouchCooldown
                end
                if tick() - touchCooldown[player] > EventService.TouchCooldown then
                    touchCooldown[player] = tick()
                    player.Character.Humanoid:TakeDamage(data.damage)
                end
            end
        end)

        task.wait(data.despawnTime)
        if lava.Parent ~= nil then
            touchConnection:Disconnect()
            lava:Destroy()
        end
    end
end

return Event