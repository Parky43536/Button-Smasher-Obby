local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local SerServices = ServerScriptService.Services
local DataManager = require(SerServices.DataManager)

local Assets = ReplicatedStorage.Assets

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)
local TweenService = require(Utility.TweenService)
local ModelTweenService = require(Utility.ModelTweenService)
local AudioService = require(Utility.AudioService)

local Event = {}

function Event.Main(levelNum, level, data)
    local rlp = General.randomLevelPoint(level)
    if rlp then
        local bomb = Assets.Levels.Bomb:Clone()
        bomb.Position = rlp.Position + Vector3.new(0, 3.5, 0)
        bomb.Parent = workspace.Misc

        AudioService:Create(11565378, bomb, {Volume = 0.8, Duration = 2})

        task.wait(2)

        for _,player in pairs(General.getPlayersInRadius(bomb.Position, data.size / 2)) do
            if player.Character then
                player.Character.Humanoid:TakeDamage(data.damage)
            end
        end

        local particle = Assets.Levels.Explosion:Clone()
        particle:PivotTo(bomb.CFrame)
        particle.Parent = workspace

        AudioService:Create(16433289, bomb.Position, {Volume = 0.8})

        local growsize = Vector3.new(1, 1, 1) * data.size
        local goal = {Transparency = 0.9, Size = growsize}
        local properties = {Time = 0.15}
        TweenService.tween(particle, goal, properties)

        local goal = {Transparency = 1}
        local properties = {Time = 1.35}
        TweenService.tween(particle, goal, properties)

        game.Debris:AddItem(particle, 1.5)
        bomb:Destroy()
    end
end

return Event