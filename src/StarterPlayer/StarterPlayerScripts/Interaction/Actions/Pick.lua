local ReplicatedFirst = game:GetService("ReplicatedFirst")

local BridgeNet2 = require(ReplicatedFirst.Packages.BridgeNet2)
local PickItem = BridgeNet2.ClientBridge("PickItem")

return function(Prompt: ProximityPrompt): ()
    PickItem:Fire(Prompt)
end
