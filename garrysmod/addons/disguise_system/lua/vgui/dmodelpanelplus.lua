local defaultAnimations = { "idle_all_01", "menu_walk" }
PANEL = {}

function PANEL:Init()
    self.modelColor = Color(255, 255, 255, 255)
    self.modelMaterial = nil
    self.offsetX, self.offsetY, self.offsetZ = 0, 0, 0
    self.rotatingData = nil
    self.subMaterials = nil
    self.mouseRotate = false
    self.entAngs = Angle(0, 0, 0)
end

function PANEL:EnableRotateByMouse(var)
	self.mouseRotate = var
end

function PANEL:EnableHoverSpinning(rate)
	self.OnCursorEntered = function()
		self:SetRotatingData(rate)
	end
	self.OnCursorExited = function()
		self:SetRotatingData(0)
	end
end

function PANEL:SetRotatingData(rate)
	self.rotatingData = rate
end

function PANEL:SetModelColor(color)
	self.modelColor = color
end

function PANEL:SetModelMaterial(mat)
	self.modelMaterial = mat
end

function PANEL:SetModelOffset(x, y, z)
	self.offsetX, self.offsetY, self.offsetZ = x or 0, y or 0, z or 0
end

function PANEL:SetModelRotation(angle)
	self.modelRotation = angle
end

function PANEL:SetSubMaterial(index, mat)
	self.subMaterials = self.subMaterials or {}
	self.subMaterials[index] = mat
end

function PANEL:ResetSubMaterials()
	self.subMaterials = {}
	for k,v in pairs(self.Entity:GetMaterials()) do
		self.Entity:SetSubMaterial(k - 1, v)
	end
end

function PANEL:SetRandomSequence()
	self.currentAnim = defaultAnimations[math.random(#defaultAnimations)]
	local animList = list.Get("PlayerOptionsAnimations")
	local niceName = player_manager.TranslateToPlayerModelName(self.Entity:GetModel())
	if animList[niceName] then
		local extraAnim = animList[niceName][math.random(#animList[niceName])]
		local newAnimTable = table.Copy(defaultAnimations)
		table.insert(newAnimTable, extraAnim)
		self.currentAnim = newAnimTable[math.random(#newAnimTable)]
	end
	self.isSequenceLoaded = false
end

function PANEL:SetLayoutEntity()
	self.LayoutEntity = function()
		if self.bAnimated then self:RunAnimation() end

		self.Entity:SetColor(self.modelColor)

		if self.modelMaterial then self.Entity:SetMaterial(self.modelMaterial) end

		if self.subMaterials then
			for index, mat in pairs(self.subMaterials) do
				self.Entity:SetSubMaterial(index, mat)
			end
		end

		if not self.isSequenceLoaded and self.currentAnim then
			local sequence = self.Entity:LookupSequence(self.currentAnim)
			self.Entity:SetSequence(sequence)
			self.Entity:ResetSequence(sequence)
			self.isSequenceLoaded = true
		end

		self.Entity:SetPos(Vector(self.offsetX, self.offsetY, self.offsetZ))

		if self.modelRotation then self.Entity:SetAngles(self.modelRotation) end

		if self.rotatingData then
			local entAngs = self.entAngs
			entAngs:RotateAroundAxis(entAngs:Up(), math.sin(CurTime()) * self.rotatingData)
			self.Entity:SetAngles(entAngs)
		end

		if self.mouseRotate then
			if self.Pressed then
				local mx = gui.MousePos()
				self.entAngs = self.entAngs - Angle(0, (self.PressX - mx) / 1.5, 0)

				self.PressX, self.PressY = gui.MousePos()
			end

			self.Entity:SetAngles(self.entAngs)
		end
	end
end

function PANEL:LoadModel(mdl)
	self:SetModel(mdl)
	self:CalculateModelView()
	self:SetLayoutEntity()
end

function PANEL:DragMousePress()
	self.PressX, self.PressY = gui.MousePos()
	self.Pressed = true
end

function PANEL:DragMouseRelease()
	self.Pressed = false
end

function PANEL:ToPerfectModel(fov)
	self:SetModelRotation(Angle(0, 0, 0))
	self:SetFOV(fov or 30)
end

function PANEL:OnMouseWheeled(del)
	if self.mouseRotate then
		self.entAngs = self.entAngs + Angle(0, 5, 0) * del
	end
end

function PANEL:SetPlayerModelColor(color)
	if not IsValid(self.Entity) then return end
	self.Entity.GetPlayerColor = function() 
		return (Vector(color.r / 255, color.g / 255, color.b / 255))
	end 
end

function PANEL:CalculateModelView(x, y, z, div)
	local xMult, yMult, zMult = x or 0.75, y or 0.75, z or 0.5
	local boundsDiv = div or 2
	local renderMins, renderMaxs = self.Entity:GetRenderBounds()
	self:SetCamPos(renderMins:Distance(renderMaxs) * Vector(xMult, yMult, zMult))
	self:SetLookAt((renderMaxs + renderMins) / boundsDiv)
end

function PANEL:LookAtBone(bone, fallBackX, fallBackY, fallBackZ)
	local fBackX, fBackY, fBackZ = fallBackX or 30, fallBackY or 10, fallBackZ or 75
	local bonePos = self.Entity:GetBonePosition(self.Entity:LookupBone(bone))
	if bonePos then
		self:SetLookAt(bonePos)
	else
		self:SetCamPos(Vector(fBackX, fBackY, fBackZ))
	end
end

function PANEL:SetEntityEyeTarget(vecX, vecY, vecZ)
	local vX, vY, vZ = vecX or 20, vecY or 0, vecZ or 65
end

function PANEL:Paint(w, h)

	if not IsValid(self.Entity) then return end

	local x, y = self:LocalToScreen(0, 0)

	self:LayoutEntity(self.Entity)

	local ang = self.aLookAngle
	if not ang then
		ang = (self.vLookatPos - self.vCamPos):Angle()
	end

	cam.Start3D(self.vCamPos, ang, self.fFOV, x, y, w, h, 5, self.FarZ)

	render.SuppressEngineLighting(true)
	render.SetLightingOrigin(self.Entity:GetPos())
	render.ResetModelLighting(self.colAmbientLight.r / 255, self.colAmbientLight.g / 255, self.colAmbientLight.b / 255)
	render.SetColorModulation(self.colColor.r / 255, self.colColor.g / 255, self.colColor.b / 255)
	render.SetBlend((self:GetAlpha() / 255) * (self.colColor.a / 255)) -- * surface.GetAlphaMultiplier()

	for i = 0, 6 do
		local col = self.DirectionalLight[i]
		if col then
			render.SetModelLighting(i, col.r / 255, col.g / 255, col.b / 255)
		end
	end

	self:DrawModel()

	render.SuppressEngineLighting(false)
	cam.End3D()

	self.LastPaint = RealTime()

end

vgui.Register("DModelPanelPlus", PANEL, "DModelPanel")