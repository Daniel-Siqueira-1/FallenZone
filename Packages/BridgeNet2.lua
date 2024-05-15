local BridgeNet2: ModuleScript = script.Parent._Index["ffrostflame_bridgenet2@1.0.0"]["bridgenet2"]
local ExportedTypes: nil = require(BridgeNet2:FindFirstChild("ExportedTypes"))
local Types = require(BridgeNet2:WaitForChild("Types"))

export type ClientBridge<send,receive> = ExportedTypes.ClientBridge<send,receive>
export type ServerBridge<send> = ExportedTypes.ServerBridge<send>
export type ExceptPlayerContainer = Types.ExceptPlayerContainer

return require(BridgeNet2)