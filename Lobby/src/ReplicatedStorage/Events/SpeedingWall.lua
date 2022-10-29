local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)
local EventService = require(Utility.EventService)
local TweenService = require(Utility.TweenService)
local ModelTweenService = require(Utility.ModelTweenService)
local AudioService = require(Utility.AudioService)

local Event = {}

function Event.Main(levelNum, level, data)
    local rlp = EventService.randomLevelPoint(level, 6)
    if rlp then
        local cframe, size = EventService.getBoundingBox(level.Floor)
        local wall = Assets.Obstacles.SpeedingWall:Clone()
        wall.BrickColor = BrickColor.random()
        wall.CFrame = cframe
        wall.Position = Vector3.new(wall.Position.X, rlp.Position.Y + wall.Size.Y/2, rlp.Position.Z)

        local rng = Random.new()
        if rng:NextInteger(1, 2) == 1 then
            wall.CFrame *= CFrame.Angles(0, math.rad(90), 0)
        else
            wall.CFrame *= CFrame.Angles(0, math.rad(-90), 0)
        end
        wall.CFrame += wall.CFrame.lookVector * -size.X

        wall.Parent = workspace.Misc

        local goal = {CFrame = wall.CFrame + wall.CFrame.lookVector * size.X * 2}
        local properties = {Time = data.travelTime}
        TweenService.tween(wall, goal, properties)

        task.wait(data.travelTime)

        if wall.Parent ~= nil then
            wall:Destroy()
        end
    end
end

return Event