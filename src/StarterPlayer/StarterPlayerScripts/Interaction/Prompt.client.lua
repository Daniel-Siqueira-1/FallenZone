local Players = game:GetService("Players")
local RunService = game:GetService('RunService')
local PromptService = game:GetService('ProximityPromptService')
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild('PlayerGui')

local Actions = script.Parent:WaitForChild("Actions")

local Gamepad = require(StarterPlayer.StarterPlayerScripts.Interaction.ImageMaps.Gamepad)
local Janitor = require(ReplicatedFirst.Packages.Janitor)
local Flipbook = require(ReplicatedStorage.Libraries.Flipbook)

local SquareRadial = Flipbook.new('Square')
SquareRadial:Preload()

local Prompt = script.Parent:FindFirstChild("PromptInterface")

local SIZE_FACTOR: number = 1.5

local DEFAULT_TEXT_COLOR: Color3 = Color3.fromRGB(38,38,38)
local DEFAULT_RADIAL_COLOR: Color3 = Color3.fromRGB(85, 255, 0)

local DEFAULT_BUTTON_BG_SIZE = Prompt.ButtonBackground.Size
local DEFAULT_RADIAL_SIZE = Prompt.Radial.Size
local DEFAULT_ACTIONTEXT_SIZE = Prompt.ActionText.Size

local SMALL_BUTTON_BG_SIZE: UDim2 = UDim2.fromScale(DEFAULT_BUTTON_BG_SIZE.X.Scale/SIZE_FACTOR,DEFAULT_BUTTON_BG_SIZE.Y.Scale/SIZE_FACTOR)
local SMALL_RADIAL_SIZE: UDim2 = UDim2.fromScale(DEFAULT_RADIAL_SIZE.X.Scale/SIZE_FACTOR,DEFAULT_RADIAL_SIZE.Y.Scale/SIZE_FACTOR)
local SMALL_ACTIONTEXT_SIZE: UDim2 = UDim2.fromScale(DEFAULT_ACTIONTEXT_SIZE.X.Scale/SIZE_FACTOR,DEFAULT_ACTIONTEXT_SIZE.Y.Scale/SIZE_FACTOR)

local ITEMPROMPT_DEFAULT_SIZE: UDim2 = (script.Parent:WaitForChild("ItemDisplay"):WaitForChild("Frame") :: Frame).Size
local ITEMPROMPT_SMALL_SIZE: UDim2 = UDim2.fromScale(ITEMPROMPT_DEFAULT_SIZE.X.Scale/2,ITEMPROMPT_DEFAULT_SIZE.Y.Scale/2)

local POPUP_TWEENINFO: TweenInfo = TweenInfo.new(.2)
local MAIN_TWEENINFO: TweenInfo = TweenInfo.new(.6,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
local UNHOLD_SPEED: number = 1

PromptService.MaxPromptsVisible = 1

Prompt.ButtonBackground.Button.TextColor3 = DEFAULT_TEXT_COLOR
Prompt.ButtonBackground.Icon.ImageColor3 = DEFAULT_TEXT_COLOR
Prompt.Radial.ImageColor3 = DEFAULT_RADIAL_COLOR

local function Disconnect(Listeners)
	for _,Listener in pairs(Listeners) do
		if typeof(Listener) == 'RBXScriptConnection' then
			Listener:Disconnect()
		elseif type(Listener) == 'table' then
			Disconnect(Listener)
		end
	end
end

local function Group(...)
	return {
		List={...};
		Play = function(self)
			for _,Effect in pairs(self.List) do
				Effect:Play()
			end
		end,
	}
end

local function PromptShown(prompt,device)
	local Connections = Janitor.new()
	
	local IsTriggering: boolean = false
	local RadialPos: number = 0;
	local Prompt = Prompt:Clone()
	local ItemPrompt
	
	local HOLD_DURATION: number = prompt.HoldDuration
	
	Prompt.ButtonBackground.Size = SMALL_BUTTON_BG_SIZE
	Prompt.Radial.Size = SMALL_RADIAL_SIZE
	Prompt.ActionText.Size = SMALL_ACTIONTEXT_SIZE
	Prompt.ActionText.Text = prompt.ActionText

	if device == Enum.ProximityPromptInputType.Keyboard then
		local Text = UserInputService:GetStringForKeyCode(prompt.KeyboardKeyCode)
		if Text then
			Prompt.ButtonBackground.Button.Visible = true
			Prompt.ButtonBackground.Button.Text = Text
		else
			Prompt.ButtonBackground.Icon.Visible = true
			Prompt.ButtonBackground.Icon.Image = Gamepad[prompt.GamepadKeyCode]
		end
	elseif device == Enum.ProximityPromptInputType.Gamepad then
		local Text = UserInputService:GetStringForKeyCode(prompt.GamepadKeyCode)
		if Text then
			Prompt.ButtonBackground.Button.Visible = true
			Prompt.ButtonBackground.Button.Text = Text
		else
			Prompt.ButtonBackground.Icon.Visible = true
			Prompt.ButtonBackground.Icon.Image = Gamepad[prompt.GamepadKeyCode]
		end
	elseif device == Enum.ProximityPromptInputType.Touch then
		Prompt.ButtonBackground.Icon.Visible = true
		Prompt.ButtonBackground.Icon.Image = 'rbxassetid://6739480846'
	end
	
	Group(
		TweenService:Create(Prompt.ButtonBackground,POPUP_TWEENINFO,{Size = DEFAULT_BUTTON_BG_SIZE}),
		TweenService:Create(Prompt.Radial,POPUP_TWEENINFO,{Size = DEFAULT_RADIAL_SIZE}),
		TweenService:Create(Prompt.ActionText,POPUP_TWEENINFO,{Size = DEFAULT_ACTIONTEXT_SIZE})
	):Play()
	
	local function HidePrompt(): ()
		RunService:UnbindFromRenderStep('Prompt')
		Disconnect(Connections)

		Group(
			TweenService:Create(Prompt.ButtonBackground,POPUP_TWEENINFO,{Size = SMALL_BUTTON_BG_SIZE;BackgroundTransparency = 1;}),
			TweenService:Create(Prompt.ButtonBackground.Button,POPUP_TWEENINFO,{TextTransparency = 1;}),
			TweenService:Create(Prompt.Radial,POPUP_TWEENINFO,{Size = SMALL_RADIAL_SIZE;ImageTransparency = 1;}),
			TweenService:Create(Prompt.ActionText,POPUP_TWEENINFO,{Size = SMALL_ACTIONTEXT_SIZE;TextTransparency = 1;}),
			TweenService:Create(Prompt.ButtonBackground.UICorner,MAIN_TWEENINFO,{CornerRadius = UDim.new(.2,0)}),
			TweenService:Create(Prompt.Radial.UICorner,MAIN_TWEENINFO,{CornerRadius = UDim.new(.2,0)})
		):Play()
		
		wait(POPUP_TWEENINFO.Time)
		Prompt:Destroy()
	end
	
	local function HoldEntered(): ()
		if IsTriggering then return end
		IsTriggering = true
		
		Group(
			TweenService:Create(Prompt.ButtonBackground,POPUP_TWEENINFO,{Size = DEFAULT_BUTTON_BG_SIZE}),
			TweenService:Create(Prompt.Radial,POPUP_TWEENINFO,{Size = DEFAULT_RADIAL_SIZE}),
			TweenService:Create(Prompt.ActionText,POPUP_TWEENINFO,{Size = DEFAULT_ACTIONTEXT_SIZE}),
			TweenService:Create(Prompt.ButtonBackground.UICorner,MAIN_TWEENINFO,{CornerRadius = UDim.new(1,0)}),
			TweenService:Create(Prompt.Radial.UICorner,MAIN_TWEENINFO,{CornerRadius = UDim.new(1,0)})
		):Play()

		RunService:UnbindFromRenderStep('Prompt')
		RunService:BindToRenderStep('Prompt',Enum.RenderPriority.Camera.Value+1,function(dt: number): ()
			RadialPos += dt
			SquareRadial:UpdateLabel(RadialPos/HOLD_DURATION,Prompt.Radial)
		end)
	end
	
	local function HoldEnded(): ()
		if not IsTriggering then return end
		IsTriggering = false
		
		RunService:UnbindFromRenderStep('Prompt')
		
		Group(
			TweenService:Create(Prompt.ButtonBackground.UICorner,MAIN_TWEENINFO,{CornerRadius = UDim.new(.2,0)}),
			TweenService:Create(Prompt.Radial.UICorner,MAIN_TWEENINFO,{CornerRadius = UDim.new(.2,0)})
		):Play()

		RunService:BindToRenderStep('Prompt',Enum.RenderPriority.Camera.Value+1,function(dt)
			RadialPos = math.clamp((RadialPos - dt*UNHOLD_SPEED*HOLD_DURATION),0,1)
			prompt.HoldDuration = HOLD_DURATION - RadialPos
		
			SquareRadial:UpdateLabel(RadialPos/HOLD_DURATION,Prompt.Radial)
		
			if RadialPos == 0 then
				RunService:UnbindFromRenderStep('Prompt')
			end
		end)
	end
	
	local function InputBegan(input): ()
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			prompt:InputHoldBegin()
		end
	end
	
	local function InputEnded(input): ()
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			prompt:InputHoldEnd()
		end
	end
	
	local function Triggered(): ()
		RunService:UnbindFromRenderStep('Prompt')
		prompt.HoldDuration = HOLD_DURATION
		
		task.spawn(function(): ()
            local ActionHandler: ModuleScript = Actions:FindFirstChild(prompt.ActionText)
            if ActionHandler then
                require(ActionHandler)(prompt, device)
            end
		end)
		
		HidePrompt()
	end
	
	Connections.PromptHidden = prompt.PromptHidden:Connect(HidePrompt)
	Connections.HoldBegan = prompt.PromptButtonHoldBegan:Connect(HoldEntered)
	Connections.HoldEnded = prompt.PromptButtonHoldEnded:Connect(HoldEnded)
	Connections.TriggerEntered = prompt.Triggered:Connect(Triggered)
	Connections.InputBegan = Prompt.Collider.InputBegan:Connect(InputBegan)
	Connections.InputEnded = Prompt.Collider.InputEnded:Connect(InputEnded)

	Prompt.Parent = PlayerGui
	Prompt.Adornee = prompt.Parent
	
end

local function PromptTriggerEnded(): ()
    
end

PromptService.PromptShown:Connect(PromptShown)
PromptService.PromptTriggerEnded:Connect(PromptTriggerEnded)