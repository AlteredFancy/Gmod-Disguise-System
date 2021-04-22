SWEP.Base = "weapon_base"

SWEP.HoldType = "fist" 

SWEP.UseHands = true
SWEP.FiresUnderwater = false
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = false

-- SWEP.ViewModelFOV = 80
-- SWEP.ViewModelFlip = false
-- SWEP.ViewModel = "models/hoff/weapons/briefcasebomb/briefcase.mdl" 

SWEP.WorldModel = "models/props_c17/briefcase001a.mdl"
SWEP.WorldModelOffset = {
	Pos = {
		Up = 1,
		Right = .2,
		Forward = 10,
	},
	Ang = {
		Up = 0,
		Right = 90,
		Forward = 0,
	}
}

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = true

SWEP.Slot = 5
SWEP.SlotPos = 1

SWEP.Category = "Disguise System"
SWEP.PrintName = "Disguise Case"
SWEP.Author = "Keenelge"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false


//SWEP.ReloadSound = "weapons/reload.wav"

SWEP.Primary.Damage = 11
SWEP.Primary.TakeAmmo = 1

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1 
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true

SWEP.Primary.Spread = 0.1
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Recoil = 1.9

SWEP.Primary.Delay = 0.1
SWEP.Primary.Force = 17

//SWEP.Primary.Sound = Sound("pd2gmod/maskon/maskon.wav") 

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = true