local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
        local spike = Assets.Obstacles.Spike:Clone()
        spike.Position = rlp.Position - Vector3.new(0, spike.Size.Y / 2, 0)
        spike.Parent = workspace.Misc

        local goal = {Position = spike.Position + Vector3.new(0, spike.Size.Y, 0)}
        local properties = {Time = data.delayTime}
        TweenService.tween(spike, goal, properties)

        task.wait(data.delayTime)

        local touchConnection
        touchConnection = spike.Touched:Connect(function(hit)
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
        if spike.Parent ~= nil then
            touchConnection:Disconnect()
            spike:Destroy()
        end
    end
end

return Event