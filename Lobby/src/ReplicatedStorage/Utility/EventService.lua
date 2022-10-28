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

local obstacleSpawners = {}

function EventService.toggleObstacleSpawner(levelNum, obstacleSpawner, toggle)
    if not obstacleSpawners[levelNum] then obstacleSpawners[levelNum] = {} end
    obstacleSpawners[levelNum][obstacleSpawner] = toggle
end

function EventService.checkObstacleSpawner(levelNum, obstacleSpawner)
    if obstacleSpawners[levelNum] and obstacleSpawners[levelNum][obstacleSpawner] then
        return false
    end

    return true
end

function EventService.randomObstacleSpawner(levelNum, level)
    local rng = Random.new()
    local obstacleSpawnerList = {}

    for _, part in pairs(level:GetDescendants()) do
        if part.Name == "ObstacleSpawner" then
            table.insert(obstacleSpawnerList, part)
        end
    end

    local pickedSpawner
    repeat
        local num = rng:NextInteger(1, #obstacleSpawnerList)
        if EventService.checkObstacleSpawner(levelNum, obstacleSpawnerList[num]) then
            pickedSpawner = obstacleSpawnerList[num]
        else
            table.remove(obstacleSpawnerList, num)
        end
    until pickedSpawner or #obstacleSpawnerList == 0

    if pickedSpawner then
        EventService.toggleObstacleSpawner(levelNum, pickedSpawner, true)
    end

    return pickedSpawner
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

function EventService.getPlayersInRadius(position, radius, players)
    local currentPlayers = Players:GetChildren()
    local playersInRadius = {}

    for _, player in pairs(players or currentPlayers) do
        if General.playerCheck(player) then
            if (player.Character.PrimaryPart.Position - position).Magnitude <= radius then
                table.insert(playersInRadius, player)
            end
        end
    end

    return playersInRadius
end

function EventService.getPlayersInSize(cframe, size, players)
    local currentPlayers = Players:GetChildren()
    local playersInSize = {}

    for _,player in pairs(players or currentPlayers) do
        if General.playerCheck(player) then
            local relativePoint = cframe:Inverse() * player.Character.PrimaryPart.Position
            local isInsideHitbox = true
            for _,axis in ipairs{"X","Y","Z"} do
                if math.abs(relativePoint[axis]) > size[axis]/2 then
                    isInsideHitbox = false
                    break
                end
            end

            if isInsideHitbox then
                table.insert(playersInSize, player)
            end
        end
    end

    return playersInSize
end

function EventService.getClosestPlayer(position, players)
    local currentPlayers = Players:GetChildren()
    local closestPlayer

    for _, player in pairs(players or currentPlayers) do
        if General.playerCheck(player) then
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