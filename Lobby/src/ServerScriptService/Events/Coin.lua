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

return Event