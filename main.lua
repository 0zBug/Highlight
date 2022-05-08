
local Highlight = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local HighlightGui, HighlightFrame
function Highlight.CreateGui(Transparency)
	HighlightGui = Instance.new("ScreenGui", CoreGui)
	HighlightFrame = Instance.new("ViewportFrame", HighlightGui)

	HighlightGui.IgnoreGuiInset = true
	HighlightGui.Name = "HighlightGui"
	HighlightGui.Enabled = true
	HighlightGui.ResetOnSpawn = false

	HighlightFrame.Name = "HighlightFrame"
	HighlightFrame.Ambient = Color3.new(1, 1, 1)
	HighlightFrame.LightColor = Color3.fromRGB(255, 255, 255)
	HighlightFrame.Size = UDim2.fromScale(1, 1)
	HighlightFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	HighlightFrame.Position = UDim2.fromScale(0.5, 0.5)
	HighlightFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	HighlightFrame.BackgroundTransparency = 1
	HighlightFrame.CurrentCamera = Workspace.CurrentCamera
	HighlightFrame.ImageTransparency = Transparency or 0.5
end

function Highlight.HighlightPart(Part, Color)
	local Color = Color or Color3.new(1, 1, 1)

	if typeof(Color) == "BrickColor" then
		Color = Color.Color
	end

	local Clone = Part:Clone()
	Clone.Parent = HighlightFrame
	Clone.Transparency = 0
	Clone.Material = Enum.Material.Neon
	Clone.Color = Color

	if Clone:IsA("MeshPart") then
		Clone.TextureID = ""
	end

	RunService.RenderStepped:Connect(function()
		Clone.CFrame = Part.CFrame
	end)

	for _, v in pairs(Part:GetDescendants()) do
		if v:IsA("LuaSourceContainer") then
			v:Destroy()
		end
	end

	Part.Changed:Connect(function(Property)
		pcall(function()
			if Property ~= "BrickColor" and Property ~= "Color" then
				if Property ~= "Transparency" and Property ~= "Material" then
					Clone[Property] = Part[Property]
				end
			end
		end)
	end)

	Part.AncestryChanged:Connect(function(Child,Parent)
		if not Parent and Child ~= Part then
			Clone:Destroy()
		end
	end)

	Part.Changed:Connect(function(Property)
		if Property == "Parent" and Part.Parent == nil then
			Clone:Destroy()
		end
	end)

	for _, v in pairs(Clone:GetChildren()) do
		if v:IsA("SpecialMesh") then
			v.TextureId= ""
		elseif v:IsA("Texture") or v:IsA("Decal") then
			v:Destroy()
		end
	end

	return Clone
end

function Highlight.HighlightBody(BodyModel, Color, AllowClothing)
	local Color = Color or Color3.new(1, 1, 1)
	local AllowClothing = AllowClothing or false

	if typeof(Color) == "BrickColor" then
		Color = Color.Color
	end

	local HumanoidModel = Instance.new("Model", HighlightFrame)

	local Humanoid = Instance.new("Humanoid", HumanoidModel)
	Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

	local Parts = {}

	for _, v in pairs(BodyModel:GetChildren()) do
		if v:IsA("BasePart") then
			if v.Name ~= "HumanoidRootPart" then
				local Part = Highlight.HighlightPart(v, Color)
				Part.Parent = HumanoidModel
				table.insert(Parts, Part)
			end
		end
	end

	for _, v in pairs(BodyModel:GetDescendants()) do
		if v:IsA("BasePart") and v.Parent ~= BodyModel then
			local Part = Highlight.HighlightPart(v, Color)
			Part.Parent = HumanoidModel
			table.insert(Parts, Part)
		elseif v:IsA("CharacterMesh") then
			local Clone = v:Clone()
			Clone:ClearAllChildren()
			Clone.Parent = HumanoidModel
		elseif v:IsA("BodyColors") or v:IsA("Shirt") or v:IsA("ShirtGraphic") or v:IsA("Pants") then
			if AllowClothing then
				local Clone = v:Clone()
				Clone:ClearAllChildren()
				Clone.Parent = HumanoidModel
			end
		end
	end

	for _, v in pairs(Parts) do
		v.Color = Color
	end

	return HumanoidModel
end

function Highlight.HighlightModel(BodyModel,Color)
	local Color = Color or Color3.new(1, 1, 1)

	if typeof(Color) == "BrickColor" then
		Color = Color.Color
	end

	local NewModel = Instance.new("Model", HighlightFrame)
	local Parts = {}

	for _, v in pairs(BodyModel:GetChildren()) do
		if v:IsA("BasePart") then
			if v.Name ~= "HumanoidRootPart" then
				local Part = Highlight.HighlightPart(v, Color)
				Part.Parent = NewModel
				table.insert(Parts, Part)
			end
		end
	end

	for _,v in pairs(BodyModel:GetDescendants()) do
		if v:IsA("BasePart") and v.Parent ~= BodyModel then
			local Part = Highlight.HighlightPart(v, Color)
			Part.Parent = NewModel
			table.insert(Parts, Part)
		end
	end

	for _, v in pairs(Parts) do
		v.Color = Color
	end

	return NewModel
end

function Highlight.GetGuiObjects()
	return HighlightFrame, HighlightGui
end

function Highlight.RemoveHighlightGuis()
	for _, v in pairs(CoreGui:GetChildren()) do
		if v.Name == "HighlightGui" and v:IsA("ScreenGui") and v:FindFirstChild("HighlightFrame") then
			v:Destroy()
		end
	end
end

return Highlight
