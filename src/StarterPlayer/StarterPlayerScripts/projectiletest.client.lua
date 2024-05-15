local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Projectile = require(ReplicatedStorage.Libraries.Projectile)
local MyProjectile = Projectile.new()

local function InputBegan(Input: InputObject, IsProcessed: boolean): ()
    if IsProcessed then
        return
    end

    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        local Camera = workspace.CurrentCamera

        local Origin: Vector3 = Camera.CFrame.Position
        local Direction: Vector3 = Camera.CFrame.LookVector.Unit

        print("Casting")
        MyProjectile:Cast(Origin, Direction, {
            Acceleration = Direction*15 + Vector3.new(0,-workspace.Gravity/100,0);
            Mass = 500;
            Velocity = Direction * 3;
            Preciseness = 20
        })
    end
end

--UserInputService.InputBegan:Connect(InputBegan)
