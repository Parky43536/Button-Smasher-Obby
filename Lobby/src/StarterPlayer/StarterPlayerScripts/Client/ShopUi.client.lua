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
local ShopUi = PlayerGui:WaitForChild("ShopUi")
local Shop = ShopUi.ShopFrame.ScrollingFrame

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ShopConnection = Remotes:WaitForChild("ShopConnection")
local BuyConnection = Remotes:WaitForChild("BuyConnection")

local function shopUiEnable()
    if ShopUi.Enabled == true then
        ShopUi.Enabled = false
    else
        ShopUi.Enabled = true
    end
end

SideFrame.ShopAndStats.Shop.Activated:Connect(function()
    shopUiEnable()
end)

ShopUi.ShopFrame.TopFrame.Close.Activated:Connect(function()
    shopUiEnable()
end)

local function onKeyPress(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.Z and gameProcessedEvent == false then
		shopUiEnable()
	end
end

------------------------------------------------------------------

local cooldown = 0.2
local cooldownTime = tick()

Shop.Power.Buy.Activated:Connect(function()
    if tick() - cooldownTime > cooldown then
        cooldownTime = tick()
        BuyConnection:FireServer("Power")
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
    Shop.Power.Cost.Amount.Text = "C " .. comma_value(General.PowerCost + General.PowerIncrease * (PlayerValues:GetValue(LocalPlayer, "Power") - 1))
    Shop.CMulti.Cost.Amount.Text = "C " .. comma_value(General.CMultiCost + General.CMultiIncrease * (PlayerValues:GetValue(LocalPlayer, "CMulti") - 1))
    Shop.Luck.Cost.Amount.Text = "C " .. comma_value(General.LuckCost + General.LuckIncrease * (PlayerValues:GetValue(LocalPlayer, "Luck") - 1))
end

PlayerValues:SetCallback("Power", function()
    loadCosts()
end)

PlayerValues:SetCallback("CMulti", function()
    loadCosts()
end)

PlayerValues:SetCallback("Luck", function()
    loadCosts()
end)

ShopConnection.OnClientEvent:Connect(function()
    loadCosts()
end)

UserInputService.InputBegan:Connect(onKeyPress)
