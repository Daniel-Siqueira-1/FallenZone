local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedFirst.Packages.BridgeNet2)
local PlaceBuilding = BridgeNet2.ServerBridge("PlaceBuilding")

local SnapFunctions = ReplicatedStorage:WaitForChild("SnapFunctions")
local Buildings = ReplicatedStorage:WaitForChild("Buildings")

type BuildRequest = {
    Type: string;
    Name: string;
    Position: CFrame;
    Mouse: {Hit: CFrame; Target: BasePart?};
}

local function OnBuildRequest(Player: Player, Request: BuildRequest): ()
    if type(Request) ~= "table" then
        return
    end
    
    local Character: Model? = Player.Character
    if Character then
        local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid
        if Humanoid and Humanoid.Health > 0 then
            if Request.Name and Request.Position then
                local SnapModule: ModuleScript? = SnapFunctions:FindFirstChild(Request.Type) :: ModuleScript?
                if SnapModule then
                    local Model: Model? = Buildings:FindFirstChild(Request.Name, true) :: Model?
                    if Model and (Model.Parent :: Folder).Name == Request.Type then
                        local SnapFunction = require(SnapModule)
                        local ModelSize: Vector3 = Model:GetExtentsSize()
                        task.desynchronize()
                        local Position, IsPositionable: boolean = SnapFunction(Character, Model, ModelSize, Request.Mouse)
                        task.synchronize()

                        if not IsPositionable then
                            return
                        end

                        local NewModel: Model = Model:Clone()
                        NewModel:SetAttribute("BuildingType", Request.Type)
                        NewModel:SetAttribute("Material", (string.split(Request.Name, " ")[1]))
                        NewModel:PivotTo(Position)

                        NewModel.Parent = workspace

                        local Overlap: OverlapParams = OverlapParams.new()
                        Overlap.FilterType = Enum.RaycastFilterType.Exclude
                        Overlap.FilterDescendantsInstances = {NewModel}

                        local Collider: BasePart = NewModel:WaitForChild("Collision") :: BasePart
                        local Colliding: {BasePart} = workspace:GetPartsInPart(Collider, Overlap)

                        if #Colliding > 0 then
                            NewModel:Destroy()
                            return
                        end
                    end
                end
            end
        end
    end
end

PlaceBuilding:Connect(OnBuildRequest)