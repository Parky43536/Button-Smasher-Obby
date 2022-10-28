local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Assets = ReplicatedStorage.Assets

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)
local EventService = require(Utility.EventService)
local TweenService = require(Utility.TweenService)
local ModelTweenService = require(Utility.ModelTweenService)
local AudioService = require(Utility.AudioService)

local Event = {}

local function destroyRocket(rocket, touchConnection, data)
    if rocket.Parent ~= nil then
        if touchConnection then
            touchConnection:Disconnect()
        end

        for _,player in pairs(EventService.getPlayersInRadius(rocket.Position, data.size / 2)) do
            if player.Character then
                player.Character.Humanoid:TakeDamage(data.damage)
            end
        end

        local particle = Assets.Levels.Explosion:Clone()
        particle:PivotTo(rocket.CFrame)
        particle.Parent = workspace

        AudioService:Create(16433289, rocket.Position, {Volume = 0.8})

        local growsize = Vector3.new(1, 1, 1) * data.size
        local goal = {Transparency = 0.9, Size = growsize}
        local properties = {Time = 0.15}
        TweenService.tween(particle, goal, properties)

        local goal = {Transparency = 1}
        local properties = {Time = 1.35}
        TweenService.tween(particle, goal, properties)

        game.Debris:AddItem(particle, 1.5)

        rocket:Destroy()
    end
end

function Event.Main(levelNum, level, data)
    local rOS = EventService.randomObstacleSpawner(levelNum, level)
    if rOS then
        local rocket = Assets.Levels.Rocket:Clone()
        rocket:SetPrimaryPartCFrame(rOS.CFrame)

        local playersInLevel = EventService.getPlayersInSize(level.Floor.CFrame, level.Floor.Size + Vector3.new(4, 100, 4))
        local targetPlayer = EventService.getClosestPlayer(rocket.Stand.PrimaryPart.Position, playersInLevel)
        local touchConnection = false

        if targetPlayer then
            rocket.Parent = workspace.Misc

            for i = 1 , data.faceRate do
                if General.playerCheck(targetPlayer) then
                    local rocketPos = rocket.Stand.PrimaryPart.Position
                    local targetPos = targetPlayer.Character.PrimaryPart.Position
                    targetPos = Vector3.new(targetPos.X, rocketPos.Y, targetPos.Z)
                    rocket.Stand:SetPrimaryPartCFrame(CFrame.new(rocketPos, targetPos))
                end
                task.wait(data.delayTime/data.faceRate)
            end

            local realRocket = rocket.Stand.Rocket
            realRocket.Parent = workspace.Misc
            rocket:Destroy()
            rocket = realRocket
            rocket.Attachment.Fire.Enabled = true

            local goal = {CFrame = rocket.CFrame + rocket.CFrame.lookVector * 100}
            local properties = {Time = data.travelTime}
            TweenService.tween(rocket, goal, properties)

            touchConnection = rocket.Touched:Connect(function()
                destroyRocket(rocket, touchConnection, data)
            end)

            for i = 1 , data.raycastRate do
                if rocket.Parent ~= nil then
                    local RayOrigin = rocket.Position
                    local RayDirection = rocket.CFrame.lookVector * rocket.Size.X

                    local Params = RaycastParams.new()
                    Params.FilterType = Enum.RaycastFilterType.Blacklist
                    Params.FilterDescendantsInstances = {rocket}

                    local Result = workspace:Raycast(RayOrigin, RayDirection, Params)
                    if Result and not CollectionService:HasTag(Result.Instance, "Collectable") then
                        destroyRocket(rocket, touchConnection, data)
                    end
                end
                task.wait(data.travelTime/data.raycastRate)
            end
        end

        destroyRocket(rocket, touchConnection, data)

        EventService.toggleObstacleSpawner(levelNum, rOS, false)
    end
end

return Event