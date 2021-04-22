for i = 8, 64 do
	surface.CreateFont("DS.Font_" .. i, {
		font = "Rubik",
		extended = true,
		size = i,
		weight = 1000,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	})
end

function DS:RotatedBox(x, y, w, h, ang, color)
	draw.NoTexture()
	surface.SetDrawColor(color or color_white)
	surface.DrawTexturedRectRotated(x, y, w, h, ang)
end

function DS:RotatedText(text, font, x, y, color, ang)
	render.PushFilterMag( TEXFILTER.ANISOTROPIC )
	render.PushFilterMin( TEXFILTER.ANISOTROPIC )

	local m = Matrix()
	m:Translate( Vector( x, y, 0 ) )
	m:Rotate( Angle( 0, ang, 0 ) )

	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )

	m:Translate( -Vector( w / 2, h / 2, 0 ) )

	cam.PushModelMatrix( m )
		draw.DrawText( text, font, 0, 0, color )
	cam.PopModelMatrix()

	render.PopFilterMag()
	render.PopFilterMin()
end

function DS:SetCurrentModelToPanel()
	local model = self.Model or ""

	if model and model ~= "" then
		self.MainFrame.CurrentModelPanel.Model:LoadModel(model)
		self.MainFrame.CurrentModelPanel.Model:CalculateModelView(1, 0)
	end
end

function DS:SetSelectedModel(model)
	model = model or ""

	DS.SelectedModel = model
	
	if model and model ~= "" then
		self.MainFrame.SelectedModelPanel.Model:LoadModel(model)
		self.MainFrame.SelectedModelPanel.Model:CalculateModelView(1, 0)
	else
		self.MainFrame.SelectedModelPanel.Model:SetModel("")
	end
end

function DS:OpenMenu()

	DS.SelectedModel = nil

	if IsValid(self.MainFrame) then self.MainFrame:Remove() end

	self.MainFrame = vgui.Create("EditablePanel")
	self.MainFrame:SetSize(1019, 575)
	self.MainFrame:Center()
	self.MainFrame:MakePopup()
	self.MainFrame.Paint = function(sel, w, h)
		draw.RoundedBox(16, 0, 0, w, h, Color(45, 45, 45))
	end

	self.MainFrame.Header = vgui.Create("EditablePanel", self.MainFrame)
	self.MainFrame.Header:SetTall(100)
	self.MainFrame.Header:DockMargin(0, 0, 0, 0)
	self.MainFrame.Header:Dock(TOP)
	self.MainFrame.Header.Paint = function(sel, w, h)
		-- draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 230))
		draw.SimpleText("Select prefered model for disguise", "DS.Font_36", w/2, h/2, Color(240, 240, 240), 1, 1)
	end
	self.MainFrame.Header:InvalidateParent(true)
	
	self.MainFrame.Header.CloseButton = vgui.Create("DButton", self.MainFrame.Header)
	self.MainFrame.Header.CloseButton:SetSize(32, 32)
	self.MainFrame.Header.CloseButton:SetPos(self.MainFrame.Header:GetWide() - 48, 16)
	self.MainFrame.Header.CloseButton:SetText("")
	self.MainFrame.Header.CloseButton.Paint = function(sel, w, h)
		draw.RoundedBox(w, 0, 0, w, h, Color(230, 30, 30))
		-- draw.RoundedBox(w, 0, 0, w * .7, 5, Color(230, 30, 30))
		self:RotatedBox(w/2, h/2, w * .7, 5, 45)
		self:RotatedBox(w/2, h/2, w * .7, 5, 135)
	end
	self.MainFrame.Header.CloseButton.DoClick = function(sel)
		if IsValid(self.MainFrame) then self.MainFrame:Remove() end
	end

	self.MainFrame.CurrentModelPanel = vgui.Create("EditablePanel", self.MainFrame)
	self.MainFrame.CurrentModelPanel:SetWide(200)
	self.MainFrame.CurrentModelPanel:Dock(LEFT)
	self.MainFrame.CurrentModelPanel:DockMargin(30, 0, 30, 30)

	self.MainFrame.CurrentModelPanel.Header = vgui.Create("EditablePanel", self.MainFrame.CurrentModelPanel)
	self.MainFrame.CurrentModelPanel.Header:SetTall(60)
	self.MainFrame.CurrentModelPanel.Header:DockMargin(0, 0, 0, 10)
	self.MainFrame.CurrentModelPanel.Header:Dock(TOP)
	self.MainFrame.CurrentModelPanel.Header.Paint = function(sel, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(35, 35, 35))
		draw.DrawText("Current\nDisguised Model", "DS.Font_24", w/2, 7, Color(240, 240, 240), 1)
	end

	self.MainFrame.CurrentModelPanel.Model = vgui.Create("DModelPanelPlus", self.MainFrame.CurrentModelPanel)
	self.MainFrame.CurrentModelPanel.Model:Dock(FILL)
	self.MainFrame.CurrentModelPanel.Model:EnableRotateByMouse(true)
	self.MainFrame.CurrentModelPanel.Model:ToPerfectModel(26)
	self.MainFrame.CurrentModelPanel.Model.OldPaint = self.MainFrame.CurrentModelPanel.Model.Paint
	self.MainFrame.CurrentModelPanel.Model.Paint = function(sel, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(35, 35, 35))
		if not self.Model or self.Model == "" then
			draw.SimpleText("NO MODEL", "DS.Font_30", w * .5, h * .5, Color(240, 240, 240), 1, 1)
		else
			self.MainFrame.CurrentModelPanel.Model:OldPaint(w, h)
		end
	end
	self.MainFrame.CurrentModelPanel.Model.OnMouseWheeled = function(sel, del)
		if self.Model and self.Model == "" then
			sel.entAngs = sel.entAngs + Angle(0, 5, 0) * del
		end
	end
	self:SetCurrentModelToPanel()

	self.MainFrame.SelectedModelPanel = vgui.Create("EditablePanel", self.MainFrame)
	self.MainFrame.SelectedModelPanel:SetWide(200)
	self.MainFrame.SelectedModelPanel:Dock(RIGHT)
	self.MainFrame.SelectedModelPanel:DockMargin(30, 0, 30, 30)
	
	self.MainFrame.SelectedModelPanel.Header = vgui.Create("EditablePanel", self.MainFrame.SelectedModelPanel)
	self.MainFrame.SelectedModelPanel.Header:SetTall(60)
	self.MainFrame.SelectedModelPanel.Header:DockMargin(0, 0, 0, 10)
	self.MainFrame.SelectedModelPanel.Header:Dock(TOP)
	self.MainFrame.SelectedModelPanel.Header.Paint = function(sel, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(35, 35, 35))
		draw.DrawText("Selected\nDisguised Model", "DS.Font_24", w/2, 7, Color(240, 240, 240), 1)
	end

	self.MainFrame.SelectedModelPanel.Model = vgui.Create("DModelPanelPlus", self.MainFrame.SelectedModelPanel)
	self.MainFrame.SelectedModelPanel.Model:Dock(FILL)
	self.MainFrame.SelectedModelPanel.Model:EnableRotateByMouse(true)
	self.MainFrame.SelectedModelPanel.Model:ToPerfectModel(26)
	self.MainFrame.SelectedModelPanel.Model.OldPaint = self.MainFrame.SelectedModelPanel.Model.Paint
	self.MainFrame.SelectedModelPanel.Model.Paint = function(sel, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(35, 35, 35))
		if not self.SelectedModel or DS.SelectedModel == "" then
			draw.SimpleText("NO MODEL", "DS.Font_30", w * .5, h * .5, Color(240, 240, 240), 1, 1)
		else
			self.MainFrame.SelectedModelPanel.Model:OldPaint(w, h)
		end
	end
	self.MainFrame.SelectedModelPanel.Model.OnMouseWheeled = function(sel, del)
		if DS.Model and DS.Model == "" then
			sel.entAngs = sel.entAngs + Angle(0, 5, 0) * del
		end
	end

	self.MainFrame.MainButtons = vgui.Create("EditablePanel", self.MainFrame)
	self.MainFrame.MainButtons:SetTall(60)
	self.MainFrame.MainButtons:DockMargin(0, 0, 0, 30)
	self.MainFrame.MainButtons:Dock(BOTTOM)
	self.MainFrame.MainButtons.Paint = function(sel, w, h)
		-- draw.RoundedBox(0, 0, 0, w, h, Color(230, 32300, 30))
	end

	self.MainFrame.MainButtons.DisguiseButton = vgui.Create("DButton", self.MainFrame.MainButtons)
	self.MainFrame.MainButtons.DisguiseButton:SetWide(235)
	self.MainFrame.MainButtons.DisguiseButton:Dock(RIGHT)
	self.MainFrame.MainButtons.DisguiseButton:SetText("")
	self.MainFrame.MainButtons.DisguiseButton.Paint = function(sel, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(30, 220, 30))
		draw.SimpleText("To Disguise", "DS.Font_30", w * .5, h * .5, Color(240, 240, 240), 1, 1)
	end
	self.MainFrame.MainButtons.DisguiseButton.DoClick = function(sel)
		local model = self.MainFrame.SelectedModelPanel.Model:GetModel()

		if not model or model == "" then return end

		net.Start("DS.Disguise")
			net.WriteString(model)
		net.SendToServer()
	end

	self.MainFrame.MainButtons.UndisguiseButton = vgui.Create("DButton", self.MainFrame.MainButtons)
	self.MainFrame.MainButtons.UndisguiseButton:SetWide(235)
	self.MainFrame.MainButtons.UndisguiseButton:Dock(LEFT)
	self.MainFrame.MainButtons.UndisguiseButton:SetText("")
	self.MainFrame.MainButtons.UndisguiseButton.Paint = function(sel, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(220, 30, 30))
		draw.SimpleText("To Undisguise", "DS.Font_30", w * .5, h * .5, Color(240, 240, 240), 1, 1)
	end
	self.MainFrame.MainButtons.UndisguiseButton.DoClick = function(sel)
		net.Start("DS.UnDisguise")
		net.SendToServer()
	end

	self.MainFrame.PlayerModels = vgui.Create("DPanelList", self.MainFrame)
	self.MainFrame.PlayerModels:DockMargin(0, 0, 0, 30)
	self.MainFrame.PlayerModels:Dock(FILL)
	self.MainFrame.PlayerModels:SetSpacing(8)
	self.MainFrame.PlayerModels.Paint = function(sel, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(35, 35, 35))
	end
	local spacer = vgui.Create("EditablePanel")
	spacer:SetTall(0)
	self.MainFrame.PlayerModels:AddItem(spacer)

	local models = DS.config.models
	
	local count = #models
	local levels = count / 8 - (count / 8) % 1 + 1
	-- (75 + 7) x 6 + 7
	local stop = false
	for i = 1, levels do
		local models_row = vgui.Create("EditablePanel", self.MainFrame)
		models_row:SetTall(74)

		for k = 1, 6 do
			local model = models[k + (i - 1) * 6]

			if not model then stop = true break end

			local modelPanel = vgui.Create("EditablePanel", models_row)
			modelPanel:SetWide(74)
			modelPanel:Dock(LEFT)
			modelPanel:DockMargin(8, 0, 0, 0)
			modelPanel.Paint = function(sel, w, h)
				draw.RoundedBox(0, 0, 0, w, h, (sel:IsHovered() or sel:IsChildHovered()) and Color(24, 24, 24) or Color(31, 31, 31))
			end

			local modelIcon = vgui.Create("SpawnIcon", modelPanel)
			modelIcon:Dock(FILL)
			modelIcon:DockMargin(7, 7, 7, 7)
			modelIcon:SetModel(model)
			modelIcon.DoClick = function(sel, w, h)
				local model = sel:GetModelName()

				self:SetSelectedModel(model)
			end
			modelIcon.PaintOver = function(sel, w, h)
				sel:DrawSelections()
			end
		end

		self.MainFrame.PlayerModels:AddItem(models_row)

		if stop then break end
	end
end

net.Receive("DS.OpenMenu", function()
	DS.Model = net.ReadString()

	DS:OpenMenu()
end)

net.Receive("DS.Disguise", function()
	DS.Model = net.ReadString()
	DS.SelectedModel = nil
	DS.SetupHand = true

	if IsValid(DS.MainFrame) then
		DS:SetCurrentModelToPanel()

		DS:SetSelectedModel(model)
	end
end)

net.Receive("DS.UnDisguise", function()
	DS.Model = nil
end)