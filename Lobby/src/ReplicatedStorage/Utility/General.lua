local Players = game:GetService("Players")

local General = {}

--Variables---------------------------------------------

General.Levels = 100
General.DoorTime = 20

--Stats---------------------------------------------

General.PowerCost = 100
General.PowerIncrease = 100
General.PowerDefault = 1

General.AClickCost = 150
General.AClickIncrease = 150
General.AClickDefault = 0

General.CMultiCost = 200
General.CMultiIncrease = 150
General.CMultiDefault = 0

General.LuckCost = 50
General.LuckIncrease = 100
General.LuckDefault = 0

function General.getCost(typer, current)
    if typer == "Power" then
        return General.PowerCost + General.PowerIncrease * ((current or General.PowerDefault) - 1)
    elseif typer == "AClick" then
        return General.AClickCost + General.AClickIncrease * (current or General.AClickDefault)
    elseif typer == "CMulti" then
        return General.CMultiCost + General.CMultiIncrease * (current or General.CMultiDefault)
    elseif typer == "Luck" then
        return General.LuckCost + General.LuckIncrease * (current or General.LuckDefault)
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
    [2] = "Collect coins to buy upgrades",
    [3] = "Watch out for bombs and other obstacles",
    [5] = "Teleport with the levels button",
    [7] = "Spikes will now appear",
    [10] = "Lava will now appear",
    [15] = "Speeding Walls will now appear",
    [20] = "Laser Walls will now appear",
    [25] = "Rockets will now appear",
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

function General.playerCheck(player)
    if player and
    player.Character and
    player.Character.PrimaryPart and
    player.Character.PrimaryPart.Parent ~= nil and
    player.Character.Humanoid.Health > 0 then
        return true
    end
end

return General