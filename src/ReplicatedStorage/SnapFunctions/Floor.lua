--!native
--!optimize 2

return function(Character, Model: Model, Size: Vector3, Mouse: Mouse): (CFrame,boolean)
    if Character then
        local Root: BasePart? = Character:FindFirstChild("HumanoidRootPart") :: BasePart?
        if Root then
            local Pos: Vector3 = Mouse.Hit.Position
            local RootPos: Vector3 = Root.Position
            local deltaX: number, deltaY: number, deltaZ: number = RootPos.X - Pos.X, RootPos.Y - Pos.Y, RootPos.Z - Pos.Z
            local FinalCFrame: CFrame = CFrame.new(
                RootPos.X - math.clamp(deltaX, -30,30),
                RootPos.Y - math.clamp(deltaY, -30,30),
                RootPos.Z - math.clamp(deltaZ, -30, 30)
            ) + Vector3.new(0,Size.Y,0);

            if Mouse.Target then
                local TargetModel: Model = Mouse.Target.Parent :: Model
                if TargetModel:IsA("Model") and TargetModel:GetAttribute("BuildingType") == "Floor" then
                    local TargetPivot: CFrame = TargetModel:GetPivot()
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

                    FinalCFrame = CFrame.new(TargetPivot.Position) * Angles * CFrame.new(Size.X * -xSign,0, Size.Z * -zSign)
                else 
                    return FinalCFrame, false
                end
            end
            
            return FinalCFrame, true
        end
    end

    return CFrame.new(),false
end