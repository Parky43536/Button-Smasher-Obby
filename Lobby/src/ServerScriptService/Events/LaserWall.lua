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

local touchCooldown = {}
local walls = {}

function Event.Main(levelNum, level, data)
    if not walls[levelNum] then walls[levelNum] = {left = false, right = false} end

    local rng = Random.new()
    local side = rng:NextInteger(1, 2)
    if side == 1 then
        if not walls[levelNum].left then
            walls[levelNum].left = true
        else
            return
        end
    else
        if not walls[levelNum].right then
            walls[levelNum].right = true
        else
            return
        end
    end

    local laserWall = Assets.Levels.LaserWall:Clone()

    if side == 1 then
        laserWall:SetPrimaryPartCFrame(level.Floor.CFrame)
    else
        laserWall:SetPrimaryPartCFrame(level.Floor.CFrame * CFrame.Angles(0, math.rad(180), 0))
    end

    laserWall.Parent = workspace.Misc

    local tweenInfo = TweenInfo.new(data.riseDelayTime)
    ModelTweenService.TweenModulePosition(laserWall, tweenInfo, laserWall.PrimaryPart.Position + Vector3.new(0, 17, 0))
    task.wait(data.riseDelayTime)

    local tweenInfo2 = TweenInfo.new(data.laserDelayTime)
    ModelTweenService.TweenModuleTransparency(laserWall.Lasers, tweenInfo2, 0.1)
    task.wait(data.laserDelayTime)

    laserWall.Damage.CanCollide = true
    local touchConnection
    touchConnection = laserWall.Damage.Touched:Connect(function(hit)
        local player = game.Players:GetPlayerFromCharacter(hit.Parent)
        if player and player.Character then
            if not touchCooldown[player] then
                touchCooldown[player] = tick() - General.TouchCooldown
            end
            if tick() - touchCooldown[player] > General.TouchCooldown then
                touchCooldown[player] = tick()
                player.Character.Humanoid:TakeDamage(data.damage)
            end
        end
    end)

    task.wait(data.despawnTime)
    if laserWall.Parent ~= nil then
        touchConnection:Disconnect()
        laserWall:Destroy()
    end

    if side == 1 then
        walls[levelNum].left = false
    else
        walls[levelNum].right = false
    end
end

return Event