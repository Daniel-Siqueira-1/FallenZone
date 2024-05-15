--!native

local ContentProvider = game:GetService("ContentProvider")

type ImageInstance = ImageButton | ImageLabel

local RadialImage = { _version = 1 }
RadialImage.__index = RadialImage

local ConfigurationProperties = {
	version = "number";
	size = "number";
	count = "number";
	columns = "number";
	rows = "number";
	images = "table";
}

RadialImage.Designs = {
	Square = {version=1,size=128,count=120,columns=8,rows=8,images={"rbxassetid://6739051767","rbxassetid://6739051581"}};
}

function RadialImage.new(config, label)
	if type(config) == "string" then
		config = RadialImage.Designs[config]
	elseif type(config) ~= "table" then
		error("Argument #1 (configuration) must be a JSON string or table.", 2)
	end

	for k, v in pairs(config) do
		if ConfigurationProperties[k] == nil then
			error(("Invalid property name in Radial Image configuration: %s"):format(k), 2)
		end

		if type(v) ~= ConfigurationProperties[k] then
			error(("Invalid property type %q in Radial Image configuration: must be a %s."):format(k, ConfigurationProperties[k]), 2)
		end
	end

	if config.version ~= RadialImage._version then
		error(("Passed configuration version does not match this module's version (which is %d)"):format(RadialImage._version), 2)
	end

	local self = { config = config; label = label }
	setmetatable(self, RadialImage)

	return self
end

function RadialImage:Preload()
	local labels = {}

	for _, image in ipairs(self.config.images) do
		local label = Instance.new('ImageLabel')
		label.Image = image
		label.Visible = true
		label.Size = UDim2.new(0, 0, 0, 0)
		table.insert(labels, label)
	end

	ContentProvider:PreloadAsync(labels)
	for _,label in pairs(labels) do
		label:Destroy()
	end
end

function RadialImage:Destroy()
	for _, label in ipairs(self.labels) do
		label:Destroy()
	end

	self.labels = nil
end

function RadialImage:GetFromAlpha(alpha: number): (number, number, number)
	if type(alpha) ~= "number" then
		error("Argument #1 (alpha) to GetFromAlpha must be a number.", 2)
	end

	local count: number, size: number, columns: number, rows: number = self.config.count, self.config.size, self.config.columns, self.config.rows
	local index: number = alpha >= 
    
    1 and count - 1 or math.floor(alpha * count)
	local page: number = math.floor(index / (columns * rows)) + 1
	local pageIndex: number = index - (columns * rows * (page - 1))
	local x: number = (pageIndex % columns) * size
	local y: number = math.floor(pageIndex / columns) * size

	return x, y, page
end

function RadialImage:UpdateLabel(alpha: number, label: ImageLabel): ()
	label = label or self.label

	local x: number?, y: number?, page = self:GetFromAlpha(alpha)

	label.ImageRectSize = Vector2.new(self.config.size, self.config.size)
	label.ImageRectOffset = Vector2.new(x, y)
	label.Image = alpha <= 0 and "" or self.config.images[page]
end

return RadialImage