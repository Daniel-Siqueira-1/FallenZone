local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local DataController = require(ServerScriptService.DataController)

type DataController = DataController.DataController

local function OnPlayerAdded(Player: Player): ()
    local PhysicalAttributes: DataController = DataController.new()
    PhysicalAttributes.Object.Parent = Player

    local function OnAttributesLoaded(Data): ()
        PhysicalAttributes:Import(Data, "PhysicalAttributes")
    end

    local Attributes: { Energy: number, Hunger: number, Radiation: number, Thirst: number } = {
        Energy = 100;
        Hunger = 100;
        Thirst = 100;
        Radiation = 100;
    }

    PhysicalAttributes:Load(nil, nil, Attributes):andThen(OnAttributesLoaded)
end

Players.PlayerAdded:Connect(OnPlayerAdded)