local Players = game:GetService("Players")

local General = {}

--Misc---------------------------------------------

General.Levels = 100
General.DoorTime = 16
General.TouchCooldown = 1

--Stats---------------------------------------------

General.PowerCost = 100
General.PowerIncrease = 100
General.CMultiCost = 200
General.CMultiIncrease = 100
General.LuckCost = 50
General.LuckIncrease = 100
function General.getCost(typer, current)
    if typer == "Power" then
        return General.PowerCost + General.PowerIncrease * (current - 1)
    elseif typer == "CMulti" then
        return General.CMultiCost + General.CMultiIncrease * (current - 1)
    elseif typer == "Luck" then
        return General.LuckCost + General.LuckIncrease * (current - 1)
    end
end

--Buttons---------------------------------------------

General.StartingPresses = 10
General.PressedCooldown = 0.1
function General.PressesCalc(levelNum)
    local function round10(num)
        return math.floor(num / 10 + 0.5) * 10
    end

    return round10((levelNum * (General.StartingPresses + levelNum * 2)) + math.pow(2, levelNum/5))
end

General.Signs = {
    [1] = "Click on the button 10 times to open the door",
    [2] = "Collect coins to buy upgrades in the shop",
    [3] = "Watch out for bombs and other obstacles",
    [5] = "Teleport with the levels button",
    [10] = "Spikes will now appear",
    [15] = "Lava will now appear",
    [20] = "Speeding Walls will now appear",
}

--Colors---------------------------------------------

General.SecondaryColorLerp = 0.2
General.SupportColor = Color3.fromRGB(0, 0, 0)
General.Colors = {
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(255, 0, 255),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 255),
    Color3.fromRGB(255, 150, 0),
    Color3.fromRGB(255, 0, 150),
    Color3.fromRGB(0, 150, 255),
    Color3.fromRGB(150, 0, 255),
    Color3.fromRGB(150, 255, 0),
    Color3.fromRGB(0, 255, 150),
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(150, 150, 150),
}

--Functions---------------------------------------------

function General.randomLevelPoint(level, offset)
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

function General.getPlayersInRadius(position, radius)
    local currentPlayers = Players:GetChildren()
    local playersInRadius = {}

    radius += 1 --limbs

    for _,player in pairs(currentPlayers) do
        if player and player.Character and player.Character.PrimaryPart and player.Character.PrimaryPart.Parent ~= nil then
            if (player.Character.PrimaryPart.Position - position).Magnitude <= radius then
                table.insert(playersInRadius, player)
            end
        end
    end

    return playersInRadius
end

return General