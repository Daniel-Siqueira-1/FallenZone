local Handler = {
    ToolSystem = nil;
}

function Handler.Handle(Action: string, InputState: Enum.UserInputState): ()
    local HandlerModule: ModuleScript = script:FindFirstChild(Action) :: ModuleScript
	if HandlerModule then
		require(HandlerModule)(Handler.ToolSystem, InputState)
	end
end

return Handler