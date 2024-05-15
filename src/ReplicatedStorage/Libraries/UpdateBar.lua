local TweenService = game:GetService("TweenService")
local UpdateBar = {}

function UpdateBar.horizontalBar(Bar: UIGradient, Delta: number): ()
    if Bar and Delta then
        TweenService:Create(Bar, TweenInfo.new(1,Enum.EasingStyle.Linear), {Offset = Vector2.new(Delta-1,0)}):Play()
    end
end

function UpdateBar.verticalBar(Bar: UIGradient, Delta: number): ()
    if Bar and Delta then
        TweenService:Create(Bar, TweenInfo.new(1,Enum.EasingStyle.Linear), {Offset = Vector2.new(0,1-Delta)}):Play()
    end
end

return UpdateBar