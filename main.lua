--[[
This has been fully created by MiAiHsIs1226
Published by MikePetar

Patched
	Fixed the highlight color for rigs: 1/17/2022

Added
	HighlightModule.HighlightModel(BodyModel: RigModel, Color: BrickColor/Color3)
		! Notice: Recommend for models or non-humanoids
		:Creates the highlight for the Model
		:returns viewportcopy

Examples:
Part Highlight
	local Highlight=require(workspace.HighlightModule) 
	Highlight.CreateGui() -- You MUST do this, otherwise it will not work
	Highlight.HighlightPart(workspace.Part,BrickColor.Red())

Rig Highlight
	local Highlight=require(workspace.HighlightModule) 
	Highlight.CreateGui() -- You MUST do this, otherwise it will not work
	Highlight.HighlightBody(workspace.Dummy,BrickColor.Red())

Rig Highlight
	local Highlight=require(workspace.HighlightModule) 
	Highlight:RemoveHighlightGuis() --Remove the other highlights
	Highlight:CreateGui() -- You MUST do this, otherwise it will not work
	Highlight:HighlightBody(workspace.Dummy,BrickColor.Red())

Pros and Cons

	Pros
		Can work on meshes and specialmeshes
		Can work on characters
		Part Following
		No physics resources needed.
		Can work on low performance
	Cons
		Cannot work on the server
		Cannot create outlines
		On beta testing(There could be bugs)


Functions
	HighlightModule.CreateGui(Part: BasePart, Transparency: number) 
		:Creates the viewportframe and screengui(Do this first)
		:returns void
	HighlightModule.HighlightPart(Part: BasePart, Color: BrickColor/Color3)
		!Notice: This is recommend for parts. Models and rigs(etc) will not work on this
		:Creates the highlight for the part
		:returns viewportcopy
	HighlightModule.HighlightBody(BodyModel: RigModel, Color: BrickColor/Color3)
		! Notice: Recommend for player characters and npcs
		:Creates the highlight for the RigModel
		:returns viewportcopy
	HighlightModule.HighlightModel(BodyModel: RigModel, Color: BrickColor/Color3)
		! Notice: Recommend for models or non-humanoids
		:Creates the highlight for the Model
		:returns viewportcopy
	HighlightModule.GetGuiObjects()
		! Notice: If you wish to make effects, this is perfect for it.
		:returns the gui objects[ViewportFrame, ScreenGui]
	HighlightModule.RemoveHighlightGuis()
		Destroys all HighlightGuis
Values
	HighlightModule.TestingMode
		! Notice: If you wish to use this in-game, set this value to false!
		Enables/Disables Studio Testing Mode(It means that if you wish to use this inside studio, set this to true)
	HighlightModule.DefaultTransparency
		! Notice: Do not set this to nil.
		I'm not gonna explain this.

How does this work?
	Of course viewportframes(doesn't effect physics, yay)
	I think this does support low performance devices
	
	Its hard to explain..
	Check the source below


Things to remember
	Do not try to make a highlight without using CreateGui this will make your highlight not show up
	If you wish to test this in studio, look below and set HighlightModule.TestingMode to true
	The Gui can support multiple highlights, so don't keep creating the same gui and adding a highlight.
	Please understand the notices on functions and values. 

I'm bored.
]]


local HighlightModule={}
local Services=setmetatable({},{__index=function(t,k)
	return game:GetService(k)
end,})
local HighlightGui,HighlightFrame
HighlightModule.TestingMode=false
HighlightModule.DefaultTransparency=0.5
local function UnnamedFunction1(func)--Advanced coding
	return func()
end
function HighlightModule.CreateGui(Transparency)
	local GuiParent=UnnamedFunction1(function()
		if HighlightModule.TestingMode==true then
			return game:GetService("CoreGui")
		elseif HighlightModule.TestingMode==false then
			return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
		end
		return nil
	end)
	HighlightGui=Instance.new("ScreenGui",GuiParent)
	HighlightFrame=Instance.new("ViewportFrame",HighlightGui)

	HighlightGui.IgnoreGuiInset=true
	HighlightGui.Name="HighlightGui"
	HighlightGui.Enabled=true
	HighlightGui.ResetOnSpawn=false

	HighlightFrame.Name="HighlightFrame"
	HighlightFrame.Ambient=Services.Lighting.Ambient
	HighlightFrame.LightColor=Color3.fromRGB(255,255,255)
	HighlightFrame.Size=UDim2.fromScale(1,1)
	HighlightFrame.AnchorPoint=Vector2.new(0.5,0.5)
	HighlightFrame.Position=UDim2.fromScale(0.5,0.5)
	HighlightFrame.BackgroundColor3=Color3.fromRGB(255,255,255)
	HighlightFrame.BackgroundTransparency=1
	HighlightFrame.CurrentCamera=Services.Workspace.CurrentCamera
	HighlightFrame.ImageTransparency=UnnamedFunction1(function()
		if Transparency==nil then
			return HighlightModule.DefaultTransparency
		elseif type(Transparency)=="number" or type(Transparency)=="string" then
			return Transparency
		else
			return HighlightModule.DefaultTransparency
		end
	end)

end
function HighlightModule.HighlightPart(Part,Color)
	local PartDestroyedEvent=Instance.new("BindableEvent")
	local ColorExists=UnnamedFunction1(function()
		if Color and (typeof(Color)=="BrickColor" or typeof(Color)=="Color3") then
			return true
		else
			return false
		end	
	end)
	local Clone=Part:Clone()
	for i,v in pairs(Part:GetDescendants()) do
		if v:IsA("LuaSourceContainer") then
			v:Destroy()
		end
	end
	spawn(function()
		Services.RunService.RenderStepped:Connect(function()
			Clone.CFrame=Part.CFrame
		end)
	end)
	Part.Changed:Connect(function(Property)
		pcall(function()
			if ColorExists then
				if Property~="BrickColor" and Property~="Color" then
					if Property~="Transparency" and Property~="Material" then
						Clone[Property]=Part[Property]
					end
				end
			else
				if Property~="Transparency" and Property~="Material" then
					Clone[Property]=Part[Property]
				end
			end
		end)
	end)
	Part.AncestryChanged:Connect(function(Child,Parent)
		if not Parent and Child~=Part then
			PartDestroyedEvent:Fire(Part)
		end
	end)
	Part.Changed:Connect(function(Property)
		if Property=="Parent" and Part.Parent==nil then
			PartDestroyedEvent:Fire(Part)
		end
	end)
	PartDestroyedEvent.Event:Connect(function(Child)
		Clone:Destroy()
	end)
	if ColorExists then
		if typeof(Color)=="BrickColor" then
			Clone.BrickColor=Color
		else
			Clone.Color=Color
		end
	end
	if Clone:IsA("MeshPart") then
		Clone.TextureID=""
	end
	for i,v in pairs(Clone:GetChildren()) do
		if v:IsA("SpecialMesh") then
			v.TextureId=""
		elseif v:IsA('Texture') or v:IsA("Decal") then
			v:Destroy()
		end
	end
	Clone.Transparency=0
	Clone.Parent=HighlightFrame
	Clone.Material="Neon"
	return Clone
end
function HighlightModule.HighlightBody(BodyModel,Color,AllowClothing)
	if AllowClothing==nil then AllowClothing=false end
	local HumanoidModel=Instance.new("Model")
	local Humanoid=Instance.new("Humanoid",HumanoidModel)
	local Parts={}
	local ColorExists=UnnamedFunction1(function()
		if Color and (typeof(Color)=="BrickColor" or typeof(Color)=="Color3") then
			return true
		else
			return false
		end	
	end)
	Humanoid.DisplayDistanceType="None"
	for i,v in pairs(BodyModel:GetChildren()) do
		if v:IsA("BasePart") then
			if v.Name~="HumanoidRootPart" then
				local Part=HighlightModule.HighlightPart(v,Color)
				Part.Parent=HumanoidModel
				table.insert(Parts,Part)
			end
		end
	end
	for i,v in pairs(BodyModel:GetDescendants()) do
		if v:IsA("BasePart") and v.Parent~=BodyModel then
			local Part=HighlightModule.HighlightPart(v,Color)
			Part.Parent=HumanoidModel
			table.insert(Parts,Part)
		elseif v:IsA("CharacterMesh") then
			local Clone=v:Clone()
			Clone:ClearAllChildren()
			Clone.Parent=HumanoidModel
		elseif v:IsA("BodyColors") or v:IsA("Shirt") or v:IsA("ShirtGraphic") or v:IsA("Pants") then
			if AllowClothing then
				local Clone=v:Clone()
				Clone:ClearAllChildren()
				Clone.Parent=HumanoidModel
			end
		end
	end
	HumanoidModel.Parent=HighlightFrame
	if ColorExists then
		for i,v in pairs(Parts) do
			if ColorExists then
				if typeof(Color)=="BrickColor" then
					v.BrickColor=Color
				else
					v.Color=Color
				end
			end
		end
	end
	return HumanoidModel
end
function HighlightModule.HighlightModel(BodyModel,Color)
	local NewModel=Instance.new("Model")
	local Parts={}
	local ColorExists=UnnamedFunction1(function()
		if Color and (typeof(Color)=="BrickColor" or typeof(Color)=="Color3") then
			return true
		else
			return false
		end	
	end)
	for i,v in pairs(BodyModel:GetChildren()) do
		if v:IsA("BasePart") then
			if v.Name~="HumanoidRootPart" then
				local Part=HighlightModule.HighlightPart(v,Color)
				Part.Parent=NewModel
				table.insert(Parts,Part)
			end
		end
	end
	for i,v in pairs(BodyModel:GetDescendants()) do
		if v:IsA("BasePart") and v.Parent~=BodyModel then
			local Part=HighlightModule.HighlightPart(v,Color)
			Part.Parent=NewModel
			table.insert(Parts,Part)
		end
	end
	NewModel.Parent=HighlightFrame
	if ColorExists then
		for i,v in pairs(Parts) do
			if ColorExists then
				if typeof(Color)=="BrickColor" then
					v.BrickColor=Color
				else
					v.Color=Color
				end
			end
		end
	end
	return NewModel
end
function HighlightModule.GetGuiObjects()
	return HighlightFrame,HighlightGui
end
function HighlightModule.RemoveHighlightGuis()
	local GuiParent=UnnamedFunction1(function()
		if HighlightModule.TestingMode==true then
			return game:GetService("CoreGui")
		elseif HighlightModule.TestingMode==false then
			return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
		end
		return nil
	end)
	if GuiParent then
		for i,v in pairs(GuiParent:GetChildren()) do
			if v.Name=="HighlightGui" and v:IsA('ScreenGui') and v:FindFirstChild("HighlightFrame") then
				v:Destroy()
			end
		end
	end
end

return HighlightModule
