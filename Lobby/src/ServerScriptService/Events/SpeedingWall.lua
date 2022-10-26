local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local SerServices = ServerScriptService.Services
local DataManager = require(SerServices.DataManager)

local Assets = ReplicatedStorage.Assets

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)
local EventService = require(Utility.General)
local TweenService = require(Utility.TweenService)
local ModelTweenService = require(Utility.ModelTweenService)
local AudioService = require(Utility.AudioService)

local Event = {}

function Event.Main(levelNum, level, data)
    local rlp = EventService.randomLevelPoint(level, 6)
    if rlp then
        local wall = Assets.Levels.SpeedingWall:Clone()
        wall.BrickColor = BrickColor.random()
        wall.CFrame = level.Floor.CFrame
        wall.Position = Vector3.new(wall.Position.X, rlp.Position.Y + wall.Size.Y/2, rlp.Position.Z)

        local rng = Random.new()
        if rng:NextInteger(1, 2) == 1 then
            wall.CFrame *= CFrame.Angles(0, math.rad(90), 0)
        else
            wall.CFrame *= CFrame.Angles(0, math.rad(-90), 0)
        end
        wall.CFrame += wall.CFrame.lookVector * -level.Floor.Size.X

        wall.Parent = workspace.Misc

        local goal = {CFrame = wall.CFrame + wall.CFrame.lookVector * level.Floor.Size.X * 2}
        local properties = {Time = data.travelTime}
        TweenService.tween(wall, goal, properties)

        task.wait(data.travelTime)

        if wall.Parent ~= nil then
            wall:Destroy()
        end
    end
end

return Event