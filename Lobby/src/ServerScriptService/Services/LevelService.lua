local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local SerServices = ServerScriptService.Services
local DataManager = require(SerServices.DataManager)

local DataBase = ReplicatedStorage.Database
local ChanceData = require(DataBase:WaitForChild("ChanceData"))

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local Assets = ReplicatedStorage.Assets

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)
local TweenService = require(Utility.TweenService)
local ModelTweenService = require(Utility.ModelTweenService)
local AudioService = require(Utility.AudioService)

local LevelService = {}

--Helpers------------------------------------------------

local function randomLevelPoint(level)
    local rng = Random.new()
    local floor = level.Floor

    local x = floor.Position.X + rng:NextInteger((-floor.Size.X/2) + 2, (floor.Size.X/2) - 2)
    local z = floor.Position.Z + rng:NextInteger((-floor.Size.Z/2) + 2, (floor.Size.Z/2) - 2)
    local pos = Vector3.new(x, 10, z)

    local RayOrigin = pos
    local RayDirection = Vector3.new(0, -100, 0)

    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Whitelist
    Params.FilterDescendantsInstances = {floor}

    local Result = workspace:Raycast(RayOrigin, RayDirection, Params)
    return Result
end

local function getPlayersInRadius(position, radius)
    local currentPlayers = Players:GetChildren()
    local playersInRadius = {}

    radius += 1 --limbs

    for _,player in pairs(currentPlayers) do
        if (player.Character.PrimaryPart.Position - position).Magnitude <= radius then
            table.insert(playersInRadius, player)
        end
    end

    return playersInRadius
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
    task.spawn(function()
        local DoorR = level.DoorR
        local DoorL = level.DoorL

        local tweenInfo = TweenInfo.new(2)

        ModelTweenService.TweenModulePosition(DoorR, tweenInfo, DoorR.PrimaryPart.Position + DoorR.PrimaryPart.CFrame.RightVector * -9)
        ModelTweenService.TweenModulePosition(DoorL, tweenInfo, DoorL.PrimaryPart.Position + DoorL.PrimaryPart.CFrame.RightVector * 9)

        task.wait(General.DoorTime - 2)

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

function LevelService.Coin(level, data)
    local rlp = randomLevelPoint(level)
    if rlp then
        local coin = Assets.Levels.Coin:Clone()
        coin.Position = rlp.Position + Vector3.new(0, 3.5, 0)
        coin.Parent = workspace.Misc

        local goal = {CFrame = coin.CFrame * CFrame.Angles(0, math.rad(180), 0)}
        local properties = {Time = 1, Repeat = math.huge}
        TweenService.tween(coin, goal, properties)

        local touchConnection
        touchConnection = coin.Touched:Connect(function(hit)
            local player = game.Players:GetPlayerFromCharacter(hit.Parent)
            if player then
                touchConnection:Disconnect()
                coin:Destroy()

                DataManager:GiveCash(player, data.value)
            end
        end)

        task.wait(data.despawnTime)
        if coin.Parent ~= nil then
            touchConnection:Disconnect()
            coin:Destroy()
        end
    end
end

function LevelService.Bomb(level, data)
    local rlp = randomLevelPoint(level)
    if rlp then
        local bomb = Assets.Levels.Bomb:Clone()
        bomb.Position = rlp.Position + Vector3.new(0, 3.5, 0)
        bomb.Parent = workspace.Misc

        AudioService:Create(11565378, bomb, {Volume = 0.8, Duration = 2})

        task.wait(2)

        for _,player in pairs(getPlayersInRadius(bomb.Position, data.size / 2)) do
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

function LevelService.ButtonEvent(levelNum, level, player)
    local rng = Random.new()

    for key, data in pairs(ChanceData) do
        if data.levelRequired and levelNum < data.levelRequired then
            continue
        end

        local playerLuck = PlayerValues:GetValue(player, "Luck")
        local chance = data.chance

        if data.negativeLuck then
            chance += (playerLuck - 1)
        end

        if rng:NextInteger(1, chance) <= 1 + (playerLuck / 10) then
            task.spawn(function()
                if key == "Coin" then
                    LevelService.Coin(level, data)
                elseif key == "Bomb" then
                    LevelService.Bomb(level, data)
                end
            end)

            break
        end
    end
end

return LevelService