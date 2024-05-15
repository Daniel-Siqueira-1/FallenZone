local CAMERA_OFFSET: CFrame = CFrame.new(0,0,-.5)
local BOB_DAMPEN: number = 5

local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")

local ItemConfig = require(ReplicatedFirst.ItemConfig)
local Spring = require(ReplicatedStorage.Libraries.Spring)
local ToolSystem = require(script.Parent)

local Player = Players.LocalPlayer
local Character = Player.Character
local Humanoid: Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

Player:SetAttribute("ViewmodelOffset", CFrame.new())

local CameraSpring = Spring.new(Vector3.new())
CameraSpring.d = .5
CameraSpring.s = 20

local SwaySpring = Spring.new(Vector3.new())
SwaySpring.d = 2
SwaySpring.s = 40

local InertiaSpring = Spring.new(Vector3.new())
InertiaSpring.d = .5
InertiaSpring.s = 20

local RecoilSpring = Spring.new(Vector3.new())
RecoilSpring.d = .5
RecoilSpring.s = 20

ToolSystem.Springs = {
    Recoil = RecoilSpring;
    Inertia = InertiaSpring;
    Sway = SwaySpring;
    Camera = CameraSpring;
}

local AimCFrame = CFrame.new()

local MovementAmplifier: CFrame = CFrame.new();

local function GetViewmodelBob(Exp: number): CFrame
    Exp = (Exp or 1)
    local ExpTick: number = tick() * Exp

    local translation: Vector3 = Vector3.new(
        math.sin(ExpTick * 4) / 32,       -- Adjust the 4 to slow down the horizontal translation
        math.cos(ExpTick * 8) / 24,       -- Adjust the 8 to slow down the vertical translation
        0
    )

    local rotation: Vector3 = Vector3.new(
        math.sin(ExpTick * 8) / 120 * Exp^2,  -- Adjust the 8 and 120 to slow down the rotation around X-axis
        0,
        math.cos(ExpTick * 4) / 60 * Exp^2   -- Adjust the 4 and 60 to slow down the rotation around Z-axis
    )

    return CFrame.new(translation) * CFrame.fromEulerAnglesXYZ(rotation.X,rotation.Y, rotation.Z)
end

local function UpdateViewmodel(DeltaTime: number): ()
    local Equipped = ToolSystem.Equipped
    local Viewmodel = ToolSystem.Viewmodel

    if Equipped.Model and Viewmodel then
        local Delta = UserInputService:GetMouseDelta()

        local Variables = ToolSystem.Variables
        local Aimpart = Viewmodel.PrimaryPart

        --Camera movement
        Camera.CFrame *= CFrame.Angles(CameraSpring.p.x,CameraSpring.p.y,CameraSpring.p.z)
        Viewmodel.PrimaryPart.CFrame = Camera.CFrame * Variables.MainCFrame *  MovementAmplifier * AimCFrame

        --Recoil
        Variables.RecoilCFrame = Variables.RecoilCFrame*CFrame.Angles(RecoilSpring.p.x,RecoilSpring.p.y,RecoilSpring.p.z)

        local HumanoidVelocity: Vector3 = HumanoidRootPart.AssemblyLinearVelocity
        local GoingLeft: boolean = UserInputService:IsKeyDown(Enum.KeyCode.A)
        local GoingRight: boolean = UserInputService:IsKeyDown(Enum.KeyCode.D) and not GoingLeft
        local MovementVelocity: number = math.abs((HumanoidVelocity.X^2 + HumanoidVelocity.Z^2) ^ .5)
        local Moving: boolean = (MovementVelocity > 1/3)
        local InAir: boolean = (Humanoid.FloorMaterial == Enum.Material.Air)

        local SpeedExp: number = Humanoid.WalkSpeed / StarterPlayer.CharacterWalkSpeed+1
        local Alpha: number = (DeltaTime * 60) * 0.07
        local Aiming = ToolSystem.Equipped.Aiming

        SwaySpring:accelerate(Vector3.new((Delta.X)/60, Delta.Y/60, 0))
        local InertiaAcceleration;
        if Aiming then
            InertiaAcceleration = (GoingLeft and -math.random(20,40)/100 or GoingRight and math.random(20,40)/100 or 0)
        else
            InertiaAcceleration = (GoingLeft and -math.random(80,110)/100 or GoingRight and math.random(80,110)/100 or 0)
        end
        InertiaSpring:accelerate(Vector3.new(InertiaAcceleration,0,0))

        local SwayVector: Vector3 = SwaySpring.p
		local xSway: number = SwayVector.X
		local ySway: number = SwayVector.Y
		local Sway: CFrame = CFrame.Angles(ySway,xSway,xSway)

        local InertiaVector: Vector3 = InertiaSpring.p
		local xInertia: number = InertiaVector.X
		local Inertia: CFrame = CFrame.Angles(0,0,xInertia)

        MovementAmplifier = ((Moving and (not InAir) and MovementAmplifier:Lerp(GetViewmodelBob(SpeedExp), Alpha * (BOB_DAMPEN * (ToolSystem.Equipped.Aiming and .2 or 1)))) or MovementAmplifier:Lerp(CFrame.new(), Alpha))

        if ToolSystem.Equipped.Aiming then
			Variables.MainCFrame = Variables.MainCFrame:Lerp(Variables.MainCFrame * Equipped.Animations.AimOffset * Variables.RecoilCFrame * Sway:Inverse() * Inertia:Inverse() * Aimpart.CFrame:ToObjectSpace(Camera.CFrame), 0.2)
        else
            Variables.MainCFrame = Variables.MainCFrame:Lerp(Variables.MainCFrame * (CAMERA_OFFSET * Equipped.Animations.MainCFrame * Player:GetAttribute("ViewmodelOffset")) * Variables.RecoilCFrame * Sway:Inverse() * Inertia:Inverse() * Aimpart.CFrame:ToObjectSpace(Camera.CFrame), 0.2)
        end

        Variables.RecoilCFrame = Variables.RecoilCFrame:Lerp(CFrame.new() * CFrame.Angles( math.rad(RecoilSpring.p.X), math.rad(RecoilSpring.p.Y), math.rad(RecoilSpring.p.z)), 0.2)
    end
end

local function OnInputBegan(Input: InputObject, IsProcessed: boolean): ()
    if IsProcessed then
        return  
    end

    if not ToolSystem.Equipped.Settings.CanAim then
        return
    end

    local Type: Enum.UserInputType = Input.UserInputType
    if Type == Enum.UserInputType.MouseButton2 and ToolSystem.Viewmodel then
        ToolSystem.Equipped.Aiming = true
    end
end

local function OnInputEnded(Input: InputObject, IsProcessed: boolean): ()
    if IsProcessed then
        return  
    end

    if not ToolSystem.Equipped.Settings.CanAim then
        return
    end

    if Input.UserInputType == Enum.UserInputType.MouseButton2 and ToolSystem.Viewmodel then
        ToolSystem.Equipped.Aiming = false
    end
end

UserInputService.InputBegan:Connect(OnInputBegan)
UserInputService.InputEnded:Connect(OnInputEnded)
RunService.RenderStepped:Connect(UpdateViewmodel)