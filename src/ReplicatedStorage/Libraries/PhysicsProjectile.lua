local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Projectile = {
    Debug = true
}
Projectile.__index = Projectile

local NilVector: Vector3 = Vector3.new()
local AirMaterial = Enum.Material.Air
local Gravity = workspace.Gravity

-- u -> initial velocity
-- a -> acceleration
-- s -> displacement of the particle
-- t -> delta time

-- v = u + a*t
-- Need to get t
-- (v - u) / a
local function GetTime(v:Vector3,u:Vector3,a:Vector3): Vector3
    return (v-u)/a
end

-- s = u*t + 0.5*a*t²
local function GetDisplacement(a,u,t): Vector3
    return u*t + .5*a*(t^2)
end

-- v² = u² - 2*a*s
local function GetAcceleration(u, a, s): ()
    return a^2 - 2*a*s
end

export type ProjectileParameters = {
    Velocity: Vector3;
    Force: number;
    Mass: number;
    Acceleration: Vector3;
    Preciseness: number;
}

export type CastResult = {
    InstancesPassed: {BasePart?};
    FinalInstance: BasePart?;
    Position: Vector3;
    Normal: Vector3;
    Material: Enum.Material;
}

export type Projectile = {
     Destroy: (self: Projectile)->();

     Cast: (self: Projectile, Origin: Vector3, Direction: Vector3, Parameteres: ProjectileParameters)->CastResult;
}

function Projectile.new(): Projectile
     local self: any = {}

     return setmetatable(self,Projectile) :: Projectile
end

function Projectile:Cast(Origin: Vector3, Direction: Vector3, Parameteres: ProjectileParameters): ()
    local CastResult: CastResult = {
        InstancesPassed = nil;
        FinalInstance = nil;
        Acceleration = NilVector;
        Position = NilVector;
        Normal = NilVector;
        Material = AirMaterial
    }

    local Acceleration: Vector3 = Parameteres.Acceleration - Vector3.new(0,(Parameteres.Mass or Gravity)/Gravity,0)

    local Model, Part

        local Model = Instance.new("Model")
        local Part = Instance.new("Part")
        Part.Anchored = true
        Part.CanCollide = false
        Part.CanQuery = false
        Part.CanTouch = false
        Part.Size = Vector3.new(2,2,2)
        Model.Parent = workspace


    local Time: number = GetTime(NilVector,Acceleration, Parameteres.Velocity).Magnitude
    for iter=0,Time, Time/Parameteres.Preciseness do
        local Displacement: Vector3 = GetDisplacement(Acceleration,Parameteres.Velocity,iter)
        local Position: Vector3 = Origin + Displacement

            local NewPart: Part = Part:Clone()
            NewPart.Position = Position
            TweenService:Create(NewPart, TweenInfo.new(10), {Transparency=1}):Play()
            NewPart.Parent = Model


        task.wait(0.1)
    end

        Debris:AddItem(Model,11)


    return nil
end

function Projectile:Destroy(): ()
     table.clear(self)
end

return Projectile