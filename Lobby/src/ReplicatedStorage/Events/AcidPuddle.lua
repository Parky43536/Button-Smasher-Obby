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
        local touchConnection

        local acid = Assets.Obstacles.Acid:Clone()
        acid.Position = rlp.Position
        acid.Parent = workspace.Misc

        local goal = {Size = Vector3.new(data.size, acid.Size.Y, data.size)}
        local properties = {Time = data.growTime}
        TweenService.tween(acid, goal, properties)

        local goal2 = {Transparency = 0.5}
        local properties2 = {Time = data.delayTime}
        TweenService.tween(acid, goal2, properties2)

        task.wait(data.delayTime)

        acid.AcidParticle.Enabled = true

        touchConnection = acid.Touched:Connect(function(hit)
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

        if acid.Parent ~= nil then
            touchConnection:Disconnect()
            acid:Destroy()
        end
    end
end

return Event