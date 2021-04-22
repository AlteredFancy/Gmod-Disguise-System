include("shared.lua")

function SWEP:Initialize()
	-- util.PrecacheSound(self.Primary.Sound)
	self:SetHoldType("normal")
end 

function SWEP:ShouldDrawViewModel()
	return false
end

function SWEP:DrawWorldModel()
	local hand, WorldModelOffset, rotate

	if not IsValid(self.Owner) then
		self:DrawModel()
		return
	end

	if not self.Hand or DS.SetupHand then
		self.Hand = self.Owner:LookupAttachment("anim_attachment_rh")
		DS.SetupHand = false
	end

	hand = self.Owner:GetAttachment(self.Hand)

	if not hand then
		self:DrawModel()
		return
	end

	WorldModelOffset = hand.Ang:Right() * self.WorldModelOffset.Pos.Right + hand.Ang:Forward() * self.WorldModelOffset.Pos.Forward + hand.Ang:Up() * self.WorldModelOffset.Pos.Up

	hand.Ang:RotateAroundAxis(hand.Ang:Right(), self.WorldModelOffset.Ang.Right)
	hand.Ang:RotateAroundAxis(hand.Ang:Forward(), self.WorldModelOffset.Ang.Forward)
	hand.Ang:RotateAroundAxis(hand.Ang:Up(), self.WorldModelOffset.Ang.Up)

	self:SetRenderOrigin(hand.Pos + WorldModelOffset)
	self:SetRenderAngles(hand.Ang)

	self:DrawModel()
end