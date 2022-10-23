local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)
local TweenService = require(Utility.TweenService)
local ModelTweenService = require(Utility.ModelTweenService)

local VisualService = {}

local ButtonPositionSaver = {}
function VisualService.PressButton(button)
    if not ButtonPositionSaver[button] then ButtonPositionSaver[button] = button.Position end

    button.Position = ButtonPositionSaver[button]
    local goal = {Position = ButtonPositionSaver[button] - Vector3.new(0, 0.99, 0)}
    local properties = {Time = General.PressedCooldown, Reverse = true}
    TweenService.tween(button, goal, properties)
end

function VisualService.OpenDoors(level)
    local DoorR = level.DoorR
    local DoorL = level.DoorL

    local tweenInfo = TweenInfo.new(2)

    ModelTweenService.TweenModulePosition(DoorR, tweenInfo, DoorR.PrimaryPart.Position + DoorR.PrimaryPart.CFrame.RightVector * -9)
    ModelTweenService.TweenModulePosition(DoorL, tweenInfo, DoorL.PrimaryPart.Position + DoorL.PrimaryPart.CFrame.RightVector * 9)

    task.spawn(function()
        task.wait(General.DoorTime - 4)

        ModelTweenService.TweenModulePosition(DoorR, tweenInfo, DoorR.PrimaryPart.Position + DoorR.PrimaryPart.CFrame.RightVector * 9)
        ModelTweenService.TweenModulePosition(DoorL, tweenInfo, DoorL.PrimaryPart.Position + DoorL.PrimaryPart.CFrame.RightVector * -9)
    end)
end

local lastPrimaryColor
function VisualService.SetUpLevelColor(levelNum, level)
    local rng = Random.new(levelNum * 1000)

    local PrimaryColor
    repeat
        PrimaryColor = General.Colors[rng:NextInteger(1, #General.Colors)]
    until lastPrimaryColor ~= PrimaryColor
    lastPrimaryColor = PrimaryColor

    local SecondaryColor = PrimaryColor:Lerp(Color3.fromRGB(255,255,255), General.SecondaryColorLerp)

    for _, part in pairs(level:GetDescendants()) do
        if CollectionService:HasTag(part, "PrimaryColor") then
            part.Color = PrimaryColor
        elseif CollectionService:HasTag(part, "SecondaryColor") then
            part.Color = SecondaryColor
        elseif CollectionService:HasTag(part, "SupportColor") then
            part.Color = General.SupportColor
        end
    end
end

return VisualService