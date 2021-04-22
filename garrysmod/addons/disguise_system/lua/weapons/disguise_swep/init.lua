include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

function SWEP:Initialize()
	timer.Simple(0, function()
		self.owner = self:GetOwner()
	end)

	self:SetHoldType("normal")
end 

function SWEP:Deploy()
	local owner = self.owner or self:GetOwner()

	if not IsValid(owner) or not owner:IsPlayer() then return end

	if not self.passport or not IsValid(self.passport) then
		self.passport = self:GetOwner():Give("disguise_passport")
	end
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 1)

	local owner = self.owner or self:GetOwner()

	if not IsValid(owner) or not owner:IsPlayer() then return end

	local model = DS.Players[owner]

	net.Start("DS.OpenMenu")
		net.WriteString(model or "")
	net.Send(owner)
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + 1)

	local owner = self.owner or self:GetOwner()

	if not IsValid(owner) or not owner:IsPlayer() then return end

	self.passport = self.passport or DS:FindPassport(owner)
	
	if not self.passport then
		self.passport = owner:Give("disguise_passport")
	end

	if not self.passport then
		MsgC(Color(255, 0, 0), "Passport SWEP doesn't found")
	end

	-- owner:SetActiveWeapon(passport)
	self.passport.Suppress = true
	owner:SelectWeapon("disguise_passport")
	self.passport.Suppress = nil
end

function SWEP:Reload()
	local owner = self.owner or self:GetOwner()

	if not IsValid(owner) or not owner:IsPlayer() then return end

	DS:Undisguise(owner)
end

function SWEP:Holster(wep)
	local owner = self.owner or self:GetOwner()
	
	if IsValid(owner) and owner:IsPlayer() then
		if wep:GetClass() ~= "disguise_passport" then
			owner:StripWeapon("disguise_passport")
		end
	end
	
	return true
end

function SWEP:OnRemove()
	local owner = self.owner or self:GetOwner()

	if not IsValid(owner) or not owner:IsPlayer() then
		return
	end

	DS:Undisguise(owner)
	owner:StripWeapon("disguise_passport")
end

function SWEP:OnDrop()
	local owner = self.owner or self:GetOwner()

	if not IsValid(owner) or not owner:IsPlayer() then
		return
	end

	DS:Undisguise(owner)
	owner:StripWeapon("disguise_passport")
end