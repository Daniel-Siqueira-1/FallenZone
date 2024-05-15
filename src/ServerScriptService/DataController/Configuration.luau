local RunService = game:GetService("RunService")
return table.freeze(
    {
        IS_STUDIO = RunService:IsStudio(),
        STUDIO_SAVE = false,
        GAME_SAVE = false,
    }
)