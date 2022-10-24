local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local RepServices = ReplicatedStorage:WaitForChild("Services")
local PlayerValues = require(RepServices:WaitForChild("PlayerValues"))

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerUi = PlayerGui:WaitForChild("PlayerUi")
local SideFrame = PlayerUi:WaitForChild("SideFrame")

local Utility = ReplicatedStorage:WaitForChild("Utility")
local TweenService = require(Utility:WaitForChild("TweenService"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ClientConnection = Remotes:WaitForChild("ClientConnection")

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

local currentCash
local currentTween
local lastCashUpate
local function loadCash(value)
    if SideFrame then
        if currentCash then
            local cashGain = value - currentCash
            if cashGain ~= 0 then
                if cashGain > 0 then
                    SideFrame.Cash.CashIncrease.Text = "+" .. comma_value(cashGain)
                else
                    SideFrame.Cash.CashIncrease.Text = comma_value(cashGain)
                end

                if currentTween then currentTween:Cancel() end
                SideFrame.Cash.CashIncrease.Size = UDim2.new(0.6, 0, 0.6, 0)
                SideFrame.Cash.CashIncrease.TextColor3 = Color3.fromRGB(255, 255, 0)
                local goal = {Size = SideFrame.Cash.CashIncrease.Size + UDim2.new(0.2, 0, 0.2, 0), TextColor3 = Color3.fromRGB(255, 175, 110)}
                local properties = {Time = 1, Dir = "In", Style = "Bounce", Reverse = true}
                currentTween = TweenService.tween(SideFrame.Cash.CashIncrease, goal, properties)
                SideFrame.Cash.CashIncrease.Visible = true

                local ticker = tick()
                lastCashUpate = ticker
                task.delay(2, function()
                    if lastCashUpate == ticker then
                        SideFrame.Cash.CashIncrease.Visible = false
                        currentCash = value
                    end
                end)
            end
        else
            currentCash = value
        end

        SideFrame.Cash.CashAmount.Text = comma_value(value)
    end
end

local function loadStats()
    SideFrame.ShopAndStats.Stats.Power.Text = "Power: " .. PlayerValues:GetValue(LocalPlayer, "Power")
    SideFrame.ShopAndStats.Stats.CMulti.Text = "C. Multi: " .. PlayerValues:GetValue(LocalPlayer, "CMulti")
    SideFrame.ShopAndStats.Stats.Luck.Text = "Luck: " .. PlayerValues:GetValue(LocalPlayer, "Luck")
end

PlayerValues:SetCallback("Cash", function(player, value)
    loadCash(value)
end)

PlayerValues:SetCallback("Power", function()
    loadStats()
end)

PlayerValues:SetCallback("CMulti", function()
    loadStats()
end)

PlayerValues:SetCallback("Luck", function()
    loadStats()
end)

ClientConnection.OnClientEvent:Connect(function()
    loadCash(PlayerValues:GetValue(LocalPlayer, "Cash"))
    loadStats()
end)
