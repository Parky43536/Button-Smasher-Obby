local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataBase = ReplicatedStorage.Database
local ChanceData = require(DataBase:WaitForChild("ChanceData"))

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local Assets = ReplicatedStorage.Assets

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)
local TweenService = require(Utility.TweenService)
local ModelTweenService = require(Utility.ModelTweenService)

local LevelService = {}

--Helpers------------------------------------------------

local function RandomLevelPoint(level)
    local rng = Random.new()
    local floor = level.Floor

    local x = floor.Position.X + rng:NextInteger(-floor.Size.X/2, floor.Size.X/2)
    local z = floor.Position.Z + rng:NextInteger(-floor.Size.Z/2, floor.Size.Z/2)
    local pos = Vector3.new(x, 10, z)

    local RayOrigin = pos
    local RayDirection = Vector3.new(0, -100, 0)

    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Whitelist
    Params.FilterDescendantsInstances = {floor}

    local Result = workspace:Raycast(RayOrigin, RayDirection, Params)
    return Result
end

--Visuals------------------------------------------------

local ButtonPositionSaver = {}
function LevelService.PressButton(button)
    if not ButtonPositionSaver[button] then ButtonPositionSaver[button] = button.Position end

    button.Position = ButtonPositionSaver[button]
    local goal = {Position = ButtonPositionSaver[button] - Vector3.new(0, 0.99, 0)}
    local properties = {Time = General.PressedCooldown, Reverse = true}
    TweenService.tween(button, goal, properties)
end

function LevelService.OpenDoors(level)
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
function LevelService.SetUpLevelColor(levelNum, level)
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

--Button Events------------------------------------------------

function LevelService.Coin(level)
    local rlp = RandomLevelPoint(level)
    if rlp then
        local coin = Assets.Coin:Clone()
        coin.Position = rlp.Position + Vector3.new(0, 3.5, 0)
        coin.Parent = workspace.Misc

        local goal = {CFrame = coin.CFrame * CFrame.Angles(0, math.rad(180), 0)}
        local properties = {Time = 1, Repeat = math.huge}
        local spinTween = TweenService.tween(coin, goal, properties)
    end
end

function LevelService.Bomb(level)
    print'bomb'
end

function LevelService.ButtonEvent(level, player)
    local rng = Random.new()

    for key, data in pairs(ChanceData) do
        local playerLuck = PlayerValues:GetValue(player, "Luck")
        local chance = data.chance

        if data.negativeLuck then
            chance += (playerLuck - 1) * 10
        end

        if rng:NextInteger(1, chance) <= playerLuck then
            if key == "Coin" then
                LevelService.Coin(level)
            elseif key == "Bomb" then
                LevelService.Bomb(level)
            end

            break
        end
    end
end

return LevelService