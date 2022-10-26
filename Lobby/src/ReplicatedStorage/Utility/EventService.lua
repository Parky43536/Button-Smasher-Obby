local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)

local EventService = {}

--Variables---------------------------------------------

EventService.TouchCooldown = 1

--Functions---------------------------------------------

local corners = {}

function EventService.toggleLevelCorner(levelNum, corner, toggle)
    if not corners[levelNum] then corners[levelNum] = {} end
    corners[levelNum][corner] = toggle
end

function EventService.checkLevelCorner(levelNum, corner)
    if corners[levelNum] and corners[levelNum][corner] then
        return false
    end

    return true
end

function EventService.randomLevelPoint(level, offset)
    local rng = Random.new()
    local floor = level.Floor
    if not offset then offset = 2 end

    local x = floor.Position.X + rng:NextInteger((-floor.Size.X/2) + offset, (floor.Size.X/2) - offset)
    local z = floor.Position.Z + rng:NextInteger((-floor.Size.Z/2) + offset, (floor.Size.Z/2) - offset)
    local pos = Vector3.new(x, 10, z)

    local RayOrigin = pos
    local RayDirection = Vector3.new(0, -100, 0)

    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Whitelist
    Params.FilterDescendantsInstances = {floor}

    local Result = workspace:Raycast(RayOrigin, RayDirection, Params)
    return Result
end

function EventService.getPlayersInRadius(position, radius)
    local currentPlayers = Players:GetChildren()
    local playersInRadius = {}

    for _, player in pairs(currentPlayers) do
        if General.playerCheck(player) then
            if (player.Character.PrimaryPart.Position - position).Magnitude <= radius then
                table.insert(playersInRadius, player)
            end
        end
    end

    return playersInRadius
end

function EventService.getClosestPlayer(position, levelNum)
    local currentPlayers = Players:GetChildren()
    local closestPlayer

    for _, player in pairs(currentPlayers) do
        if General.playerCheck(player) and PlayerValues:GetValue(player, "CurrentLevel") == levelNum then
            if not closestPlayer then
                closestPlayer = player
            elseif not General.playerCheck(closestPlayer) then
                closestPlayer = player
            elseif (player.Character.PrimaryPart.Position - position).Magnitude < (closestPlayer.Character.PrimaryPart.Position - position).Magnitude then
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

return EventService