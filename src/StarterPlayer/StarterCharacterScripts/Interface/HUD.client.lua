local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UpdateBar = require(ReplicatedStorage.Libraries.UpdateBar)

local Player = Players.LocalPlayer
local PlayerGui: PlayerGui = Player:WaitForChild("PlayerGui")

local Cache: Folder = Player:WaitForChild("Cache"):: Folder
local PhysicalAttributes: Folder = Cache:WaitForChild("PhysicalAttributes"):: Folder

local Character = Player.Character
local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid

local HUD: ScreenGui = PlayerGui:WaitForChild("HUD"):: ScreenGui
local Main: Frame = HUD:WaitForChild("Main"):: Frame

local Energy: ImageLabel, Health: ImageLabel, Hunger: ImageLabel, Thirst: ImageLabel, Radiation: ImageLabel = Main:WaitForChild("Energy"):: ImageLabel, Main:WaitForChild("Health"):: ImageLabel, Main:WaitForChild("Hunger"):: ImageLabel, Main:WaitForChild("Thirst"):: ImageLabel, Main:WaitForChild("Radiation"):: ImageLabel
local Healthbar: UIGradient = (Health:FindFirstChild("Bar"):: any):FindFirstChild("Gradient")
local EnergyBar: UIGradient = (Energy:FindFirstChild("Bar"):: any):FindFirstChild("Gradient")
local HungerBar: UIGradient = (Hunger:FindFirstChild("Bar"):: any):FindFirstChild("Gradient")
local ThirstBar: UIGradient = (Thirst:FindFirstChild("Bar"):: any):FindFirstChild("Gradient")
local RadiationBar: UIGradient = (Radiation:FindFirstChild("Bar"):: any):FindFirstChild("Gradient")

local EnergyValue: NumberValue = PhysicalAttributes:WaitForChild("Energy"):: NumberValue
local BaseEnergy: number = EnergyValue.Value

local HungerValue: NumberValue = PhysicalAttributes:WaitForChild("Hunger"):: NumberValue
local BaseHunger: number = HungerValue.Value

local ThirstValue: NumberValue = PhysicalAttributes:WaitForChild("Thirst"):: NumberValue
local BaseThirst: number = ThirstValue.Value

local RadiationValue: NumberValue = PhysicalAttributes:WaitForChild("Radiation"):: NumberValue
local BaseRadiation: number = RadiationValue.Value

local function UpdateEnergy(NewValue: number): ()
    local Delta: number = NewValue / BaseEnergy
    UpdateBar.horizontalBar(EnergyBar, Delta)
end

local function UpdateHealth(): ()
    local Delta: number = Humanoid.Health / Humanoid.MaxHealth
    UpdateBar.horizontalBar(Healthbar, Delta)
end

local function UpdateHunger(NewValue: number): ()
    local Delta: number = NewValue / BaseHunger
    UpdateBar.verticalBar(HungerBar, Delta)
end

local function UpdateThirst(NewValue: number): ()
    local Delta: number = NewValue / BaseThirst
    UpdateBar.verticalBar(ThirstBar, Delta)
end

local function UpdateRadiation(NewValue: number): ()
    local Delta: number = NewValue / BaseRadiation
    UpdateBar.verticalBar(RadiationBar, Delta)
end

UpdateBar.horizontalBar(Healthbar, 1)
UpdateBar.horizontalBar(EnergyBar, 1)
UpdateBar.verticalBar(HungerBar, 1)
UpdateBar.verticalBar(ThirstBar, 1)
UpdateBar.verticalBar(RadiationBar, 1)

Humanoid.HealthChanged:Connect(UpdateHealth)
EnergyValue.Changed:Connect(UpdateEnergy)
HungerValue.Changed:Connect(UpdateHunger)
ThirstValue.Changed:Connect(UpdateThirst)
RadiationValue.Changed:Connect(UpdateRadiation)