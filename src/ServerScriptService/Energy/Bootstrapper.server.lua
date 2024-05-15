-- quando estiver em 0 bloquear ações que usam energia

local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ServerScriptService.Energy.Config)
local BridgeNet2 = require(ReplicatedFirst.Packages.BridgeNet2)
local Changeable = require(ReplicatedStorage.Classes.Changeable)

type ServerBridge<send> = BridgeNet2.ServerBridge<send>
type Changeable = Changeable.Changeable

local PlayerRun: ServerBridge<any> = BridgeNet2.ServerBridge("PlayerRun")

local EnergyCache: {[Player]: Changeable} = {}

local function OnPlayerAdded(Player: Player): ()
    local Cache: Folder = Player:WaitForChild("Cache"):: Folder
    local PhysicalAttributes: Folder = Cache:WaitForChild("PhysicalAttributes"):: Folder
    local EnergyValue: NumberValue = PhysicalAttributes:WaitForChild("Energy"):: NumberValue
    
    EnergyCache[Player] = Changeable.new(EnergyValue)
end

local function OnPlayerRun(Player: Player, State: boolean): ()
    local Energy: Changeable = EnergyCache[Player]

    if State then
        Energy:Start(Config.RunCost, Config.Rate)
    else
        Energy:Stop()
    end
end

PlayerRun:Connect(OnPlayerRun)
Players.PlayerAdded:Connect(OnPlayerAdded)