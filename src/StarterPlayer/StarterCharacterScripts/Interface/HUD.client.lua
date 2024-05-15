local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local UpdateBar = require(ReplicatedStorage.Libraries.UpdateBar)

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Character = Player.Character
local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid

local HUD = PlayerGui:WaitForChild("HUD")
local Main = HUD:WaitForChild("Main")

local Energy, Health = Main:WaitForChild("Energy"), Main:WaitForChild("Health")
local Healthbar = Health:FindFirstChild("Bar"):FindFirstChild("Gradient")

local function UpdateEnergy(): ()

end

local function UpdateHealth(): ()
    local Delta: number = Humanoid.Health / Humanoid.MaxHealth
    UpdateBar.horizontalBar(Healthbar, Delta)
end

UpdateBar.horizontalBar(Healthbar, 1)
Humanoid.HealthChanged:Connect(UpdateHealth)