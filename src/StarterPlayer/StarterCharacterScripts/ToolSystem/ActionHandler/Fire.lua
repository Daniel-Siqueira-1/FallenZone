local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TweenService = game:GetService("TweenService")

local ItemConfig = require(ReplicatedFirst.ItemConfig)
local BridgeNet2 = require(ReplicatedFirst.Packages.BridgeNet2)
local GunShootRequest = BridgeNet2.ClientBridge("GunShoot")

local Shooting: boolean = false

function Random(Min, Max, Accuracy)
	local Inverse = 1 / (Accuracy or 1)
	return (math.random(Min * Inverse, Max * Inverse) / Inverse)
end

function Fx(ToolSystem)
    local ItemModel = ToolSystem.Equipped.Model
    local ItemSettings = ToolSystem.Equipped.Settings

    local Handle: BasePart = ItemModel.Handle :: BasePart

    local Suppressor: boolean, FlashHider: boolean = false,false -- IMPLEMENT LATER ON

	if Suppressor == true then
		ItemModel.Handle.Muzzle.Supressor:Play()
	else
		ItemModel.Handle.Muzzle.Fire:Play()
	end

	if FlashHider == true then
		ItemModel.Handle.Muzzle["Smoke"]:Emit(10)
	else
		ItemModel.Handle.Muzzle["FlashFX[Flash]"]:Emit(10)
		ItemModel.Handle.Muzzle["Smoke"]:Emit(10)
	end

	if ToolSystem.Variables.BSpread then
		ToolSystem.Variables.BSpread = math.min(ItemSettings.MaxSpread * ItemConfig.MaxSpread, ToolSystem.Variables.BSpread + ItemSettings.AimInaccuracyStepAmount * ItemConfig.AimInaccuracyStepAmount)
		ToolSystem.Variables.RecoilPower =  math.min(ItemSettings.MaxRecoilPower * ItemConfig.MaxRecoilPower, ToolSystem.Variables.RecoilPower + ItemSettings.RecoilPowerStepAmount * ItemConfig.RecoilPowerStepAmount)
	end

    local Ammo: number = ToolSystem.Equipped.Settings.Ammo

    local Slide: Motor6D = Handle:FindFirstChild("Slide") :: Motor6D

    if not ItemSettings.SlideLock and Slide and Slide:IsA("Motor6D") then
        local INFO: TweenInfo;

        if Ammo > 0 then
            INFO = TweenInfo.new(30/ItemSettings.ShootRate,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,true,0)
        else
            INFO = TweenInfo.new(30/ItemSettings.ShootRate,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0)
        end

        TweenService:Create(Slide,INFO, {C1 =  ItemSettings.SlideEx}):Play()
    end

    local Bolt = Handle:FindFirstChild("Bolt")
    if Bolt and Bolt:IsA("Motor6D") then
        local INFO: TweenInfo;

        if Ammo > 0 then
            INFO = TweenInfo.new(30/ItemSettings.ShootRate,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,true,0)
        else
            INFO = TweenInfo.new(30/ItemSettings.ShootRate,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0)
        end

        TweenService:Create(Bolt,INFO, {C1 =  ItemSettings.BoltEx}):Play()
    end

    local Chamber: Attachment = Handle:FindFirstChild("Chamber") :: Attachment
    if Chamber then
        local Smoke: ParticleEmitter = Chamber:FindFirstChild("Smoke") :: ParticleEmitter
        local Shell: ParticleEmitter = Chamber:FindFirstChild("Shell") :: ParticleEmitter

        if Smoke then
	        Smoke:Emit(10)
        end

        if Shell then
	        Shell:Emit(1)
        end
    end
end

function Recoil(ToolSystem): ()
    local CameraSpring = ToolSystem.Springs.Camera
    local RecoilSpring = ToolSystem.Springs.Recoil

    local CameraRecoil = ToolSystem.Equipped.Settings.camRecoil
    local GunRecoil = ToolSystem.Equipped.Settings.gunRecoil

	local vr: number = (math.random(CameraRecoil.camRecoilUp[1], CameraRecoil.camRecoilUp[2])/2) * ItemConfig.camRecoilMod.RecoilUp
	local lr: number = (math.random(CameraRecoil.camRecoilLeft[1],CameraRecoil.camRecoilLeft[2])) * ItemConfig.camRecoilMod.RecoilLeft
	local rr: number = (math.random(CameraRecoil.camRecoilRight[1], CameraRecoil.camRecoilRight[2])) * ItemConfig.camRecoilMod.RecoilRight
	local hr: number = (math.random(-rr, lr)/2)
	local tr: number = (math.random(CameraRecoil.camRecoilTilt[1], CameraRecoil.camRecoilTilt[2])/2) * ItemConfig.camRecoilMod.RecoilTilt

	local RecoilX: number = math.rad(vr * Random( 1, 1, .1))
	local RecoilY: number = math.rad(hr * Random(-1, 1, .1))
	local RecoilZ: number = math.rad(tr * Random(-1, 1, .1))

	local gvr: number = (math.random(GunRecoil.gunRecoilUp[1], GunRecoil.gunRecoilUp[2]) /10) * ItemConfig.gunRecoilMod.RecoilUp
	local gdr: number = (math.random(-1,1) * math.random(GunRecoil.gunRecoilTilt[1], GunRecoil.gunRecoilTilt[2]) /10) * ItemConfig.gunRecoilMod.RecoilTilt
	local glr: number = (math.random(GunRecoil.gunRecoilLeft[1], GunRecoil.gunRecoilLeft[2])) * ItemConfig.gunRecoilMod.RecoilLeft
	local grr: number = (math.random(GunRecoil.gunRecoilRight[1], GunRecoil.gunRecoilRight[2])) * ItemConfig.gunRecoilMod.RecoilRight

	local ghr: number = (math.random(-grr, glr)/10)	

	local ARR = ToolSystem.Equipped.Settings.AimRecoilReduction * ItemConfig.AimRM

	CameraSpring:accelerate(Vector3.new( RecoilX , RecoilY, RecoilZ ))

    local RecoilPower: number = ToolSystem.Variables.RecoilPower
	if not ToolSystem.Equipped.Aiming then
		RecoilSpring:accelerate(Vector3.new( math.rad(gvr * RecoilPower), math.rad(ghr * RecoilPower), math.rad(gdr)))
		ToolSystem.Variables.RecoilCFrame *= CFrame.new(0,-0.05,.1) * CFrame.Angles( math.rad( gvr * RecoilPower ),math.rad( ghr * RecoilPower ),math.rad( gdr * RecoilPower ))

	else
		RecoilSpring:accelerate(Vector3.new( math.rad(gvr * RecoilPower/ARR) , math.rad(ghr * RecoilPower/ARR), math.rad(gdr/ ARR)))
		ToolSystem.Variables.RecoilCFrame *= CFrame.new(0,0,.1) * CFrame.Angles( math.rad( gvr * ToolSystem.Variables.RecoilPower/ARR ),math.rad( ghr * RecoilPower/ARR ),math.rad( gdr * RecoilPower/ARR ))
	end
end

return function(ToolSystem, InputState: Enum.UserInputState): ()
    local Type = ToolSystem.Equipped.Type

    if not ToolSystem:CanFire() then
        return
    end

    if InputState == Enum.UserInputState.Begin then
        if ToolSystem.Equipped.Firing then
            return
        end

        local Equipped = ToolSystem.Equipped
        Equipped.Firing = true
        if Type == "Gun" then
            if ToolSystem.Equipped.Settings.Ammo > 0 then
                ToolSystem:Animate("FireAnim")
                local function Shoot(): ()
                    Equipped.Settings.Ammo -= 1
                    Recoil(ToolSystem)
                    Fx(ToolSystem)
                    GunShootRequest:Fire()
                end

                local ShootingType = Equipped.Settings.ShootType
                if ShootingType == 1 then 
                    Shoot()
                elseif ShootingType == 2 then
                    for _=1, Equipped.Settings.BurstShot do
                        if not ToolSystem:CanFire() then
                            break
                        end

                        Shoot()

                        task.wait(60/ToolSystem.Equipped.Settings.ShootRate)
                    end
                elseif ShootingType == 3 then
                    Shooting = true
                    while Shooting do
                        if ToolSystem:CanFire() then
                            Shoot()
                            task.wait(60/ToolSystem.Equipped.Settings.ShootRate)
                        else
                            break
                        end
                    end
                elseif ShootingType == 4 or ShootingType == 5 then
                    print("For now, does nothing ahhaahha")
                end
            end
        elseif Type == "Melee" then
            task.spawn(ToolSystem.Animate, ToolSystem, "FireAnim")
            task.wait(ToolSystem.Equipped.Animations.FireDebounce)
        end

        Equipped.Firing = false
    else
        Shooting = false
    end
end