local ContextActionService = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

local Player = Players.LocalPlayer
local PlayerGui: PlayerGui = Player:WaitForChild("PlayerGui")

local Inventory: ScreenGui = PlayerGui:WaitForChild("Inventory") :: ScreenGui
local Blur = Inventory:WaitForChild("InventoryBlur")

local function OpenInventory(Action: string, InputState: Enum.UserInputState): ()
    if Action == "OpenInventory" and InputState == Enum.UserInputState.End then
        Inventory.Enabled = not Inventory.Enabled
        Blur.Parent = Inventory.Enabled and Lighting or Inventory
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, not Inventory.Enabled)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not Inventory.Enabled)
    end
end

ContextActionService:BindAction("OpenInventory", OpenInventory, false, Enum.KeyCode.M)