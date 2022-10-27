local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local RepServices = ReplicatedStorage:WaitForChild("Services")
local PlayerValues = require(RepServices:WaitForChild("PlayerValues"))

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerUi = PlayerGui:WaitForChild("PlayerUi")
local SideFrame = PlayerUi:WaitForChild("SideFrame")
local LevelsUi = PlayerGui:WaitForChild("LevelsUi")
local ShopUi = PlayerGui:WaitForChild("ShopUi")
local UpgradeUi = PlayerGui:WaitForChild("UpgradeUi")
local Upgrade = UpgradeUi.UpgradeFrame.ScrollingFrame

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local UpgradeConnection = Remotes:WaitForChild("UpgradeConnection")
local DataConnection = Remotes:WaitForChild("DataConnection")

local function upgradeUiEnable()
    if UpgradeUi.Enabled == true then
        UpgradeUi.Enabled = false
    else
        UpgradeUi.Enabled = true
        ShopUi.Enabled = false
        LevelsUi.Enabled = false
    end
end

SideFrame.Upgrade.Activated:Connect(function()
    upgradeUiEnable()
end)

UpgradeUi.UpgradeFrame.TopFrame.Close.Activated:Connect(function()
    upgradeUiEnable()
end)

local function onKeyPress(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.E and gameProcessedEvent == false then
		upgradeUiEnable()
	end
end

------------------------------------------------------------------

local cooldown = 0.2
local cooldownTime = tick()

Upgrade.Power.Buy.Activated:Connect(function()
    if tick() - cooldownTime > cooldown then
        cooldownTime = tick()
        DataConnection:FireServer("Power")
    end
end)

Upgrade.AClick.Buy.Activated:Connect(function()
    if tick() - cooldownTime > cooldown then
        cooldownTime = tick()
        DataConnection:FireServer("AClick")
    end
end)

Upgrade.CMulti.Buy.Activated:Connect(function()
    if tick() - cooldownTime > cooldown then
        cooldownTime = tick()
        DataConnection:FireServer("CMulti")
    end
end)

Upgrade.Luck.Buy.Activated:Connect(function()
    if tick() - cooldownTime > cooldown then
        cooldownTime = tick()
        DataConnection:FireServer("Luck")
    end
end)

------------------------------------------------------------------

local function comma_value(amount)
    local formatted = amount
    while true do
      formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then
            break
        end
    end
    return formatted
end

local function loadCosts()
    Upgrade.Power.Cost.Amount.Text = "C " .. comma_value(General.getCost("Power", PlayerValues:GetValue(LocalPlayer, "Power")))
    Upgrade.AClick.Cost.Amount.Text = "C " .. comma_value(General.getCost("AClick", PlayerValues:GetValue(LocalPlayer, "AClick")))
    Upgrade.CMulti.Cost.Amount.Text = "C " .. comma_value(General.getCost("CMulti", PlayerValues:GetValue(LocalPlayer, "CMulti")))
    Upgrade.Luck.Cost.Amount.Text = "C " .. comma_value(General.getCost("Luck", PlayerValues:GetValue(LocalPlayer, "Luck")))
end

PlayerValues:SetCallback("Power", function()
    loadCosts()
end)

PlayerValues:SetCallback("AClick", function()
    loadCosts()
end)

PlayerValues:SetCallback("CMulti", function()
    loadCosts()
end)

PlayerValues:SetCallback("Luck", function()
    loadCosts()
end)

UpgradeConnection.OnClientEvent:Connect(function()
    loadCosts()
end)

UserInputService.InputBegan:Connect(onKeyPress)
