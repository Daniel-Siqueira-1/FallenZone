local ReplicatedFirst = game:GetService("ReplicatedFirst")
local StarterPlayer = game:GetService("StarterPlayer")
local BridgeNet2 = require(ReplicatedFirst.Packages.BridgeNet2)

local ChangeStanceEvent = BridgeNet2.ClientBridge("ChangeStance")

return {
    Stances = {
        [0] = "Idle";
        [1] = "Walking";
        [2] = "Aiming";
        [3] = "Sprinting";
    };

    ShootingTypes = {
        [1] = "Semi";
        [2] = "Burst";
        [3] = "Auto";
        [4] = "Pump-Action";
        [5] = "Bolt-Action";
    };

    ItemEquipped = nil;
    ItemDetails = {
        Stance = 0;
        Model = nil;
        Viewmodel = nil;
        Animationpart = nil;

        Animations = nil;
        Settings = nil;
    };
}