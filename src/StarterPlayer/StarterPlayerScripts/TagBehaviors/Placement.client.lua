--!native
--!optimize 2

local PreviewModels: Model = Instance.new("Model")
PreviewModels.Name = "Preview"
PreviewModels.Parent = workspace

local CAN_POSITION_COLOR: Color3 = Color3.fromRGB(0,220,0)
local CAN_NOT_POSITION_COLOR: Color3 = Color3.fromRGB(249, 58, 58)

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local SnapFunctions = ReplicatedStorage:WaitForChild("SnapFunctions")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local IDs = {};

local function OnPreviewStarted(Model: Model): ()
    if Model:HasTag("Previewable") then
        Model:RemoveTag("Previewable")
    else
        return
    end

    Model.Parent = PreviewModels

    local ID: string = HttpService:GenerateGUID()
    IDs[Model] = ID

    local Position: CFrame;
    local CanPosition: boolean = true;
    local IsPositionable: boolean = true;
    local Size: Vector3 = Model:GetExtentsSize()

    local BuildingType = Model:GetAttribute("BuildingType")
    local SnapModule: ModuleScript? = SnapFunctions:FindFirstChild(BuildingType) :: ModuleScript?
    if SnapModule then
        local SnapFunction = require(SnapModule)

        local Collision: BasePart = Model:WaitForChild("Collision") :: BasePart
        local Overlap: OverlapParams = OverlapParams.new()
        Overlap.FilterType = Enum.RaycastFilterType.Exclude
        Overlap.FilterDescendantsInstances = {Model}

        Mouse.TargetFilter = Model
        RunService:BindToRenderStep(ID, Enum.RenderPriority.Input.Value+1, function(Delta: number): ()
            task.desynchronize()
            local Colliding: {BasePart} = workspace:GetPartsInPart(Collision,Overlap)
            local Character: Model? = Player.Character
            if Character then
                Position, IsPositionable = SnapFunction(Character, Model,Size, Mouse)
                CanPosition = #Colliding == 0
            end
            task.synchronize()

            for _, Part: Instance in Model:GetDescendants() do
                if Part:IsA("BasePart") then
                    Part.Color = IsPositionable and CanPosition and CAN_POSITION_COLOR or CAN_NOT_POSITION_COLOR
                end
            end
            Model:PivotTo(Position)
        end)
    end
end

local function OnPreviewEnded(Model: Model): ()
    if IDs[Model] then
        RunService:UnbindFromRenderStep(IDs[Model])
    end
end

CollectionService:GetInstanceAddedSignal("PlacementPreview"):Connect(OnPreviewStarted)
CollectionService:GetInstanceRemovedSignal("PlacementPreview"):Connect(OnPreviewEnded)