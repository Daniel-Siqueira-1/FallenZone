--!native
--!optimize 2

return function(Character, Model: Model, Size: Vector3, Mouse: Mouse): CFrame
    if Character then
        local Root: BasePart? = Character:FindFirstChild("HumanoidRootPart") :: BasePart?
        local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid
        if Root and Humanoid and Humanoid.Health > 0 then
            local Pos: Vector3 = Mouse.Hit.Position
            local RootPos: Vector3 = Root.Position
            local deltaX: number, deltaY: number, deltaZ: number = RootPos.X - Pos.X, RootPos.Y - Pos.Y, RootPos.Z - Pos.Z
            local FinalCFrame: CFrame = CFrame.new(
                RootPos.X - math.clamp(deltaX, -30,30),
                RootPos.Y - math.clamp(deltaY, -30,30) + Size.X/2,
                RootPos.Z - math.clamp(deltaZ, -30, 30)
            ) * CFrame.Angles(math.pi/2, 0, 0);

            if Mouse.Target then
                local TargetModel: Model = Mouse.Target.Parent :: Model
                if TargetModel:IsA("Model") and TargetModel:GetAttribute("BuildingType") == "Floor" then
                    local TargetPivot: CFrame = TargetModel:GetPivot()

                    task.synchronize()
                    local TargetSize: Vector3 = TargetModel:GetExtentsSize()
                    task.desynchronize()

                    local X: number,Y: number,Z: number = TargetPivot:ToEulerAnglesXYZ()
                    local Angles: CFrame = CFrame.Angles(X, 0, 0) * CFrame.Angles(0, Y, 0) * CFrame.Angles(0, 0, Z)

                    local SameAngleHit: CFrame = CFrame.new(Pos) * Angles
                    local Offset: CFrame = SameAngleHit:ToObjectSpace(TargetPivot)

                    local xLength: number, zLength: number = Offset.X, Offset.Z
                    local xSign: number, zSign: number = math.sign(xLength), math.sign(zLength)


                    if math.abs(xLength) > math.abs(zLength) then
                        zLength = 0
                        zSign = 0
                    else
                        xLength = 0
                        xSign = 0
                    end

                    FinalCFrame = CFrame.new(TargetPivot.Position) * Angles * CFrame.new(
                        TargetSize.X/2 * -xSign,
                        TargetPivot.Y+TargetSize.X/2-.05, 
                        TargetSize.Z/2 * -zSign
                    )
                    FinalCFrame = CFrame.new(FinalCFrame.Position, TargetPivot.Position) * CFrame.Angles(-math.pi/4, 0, 0)

                    local Distance: number = (FinalCFrame.Position - RootPos).Magnitude

                    return FinalCFrame, Distance < 30
                end
            end

            return FinalCFrame, false
        end
    end

    return CFrame.new()
end