DS.Players = {}

local cache = {}
for k,v in pairs(DS.config.models) do
	if v ~= true then
		cache[v:lower()] = true
	else
		cache[k] = v
	end
end
DS.config.models = cache

util.AddNetworkString("DS.OpenMenu")

function DS:HaveDisguiseSwep(ply)
	local weapons = ply:GetWeapons()

	for k,v in pairs(weapons) do
		if v:GetClass() == "disguise_swep" then
			return true
		end
	end

	return false
end

function DS:ActiveWeaponIsDisguiseSwep(ply)
	local weapon = ply:GetActiveWeapon()

	if not IsValid(weapon) then
		return false
	end

	return weapon:GetClass() == "disguise_swep"
end

function DS:Disguise(ply, model)
	DS.Players[ply] = model
	ply:SetModel(model)
end

util.AddNetworkString("DS.Disguise")
net.Receive("DS.Disguise", function(_, ply)
	local model = net.ReadString()

	if not ply:Alive() then
		DarkRP.notify(ply, 1, 7, "Vous devez être en vie pour vous déguiser.")
		return
	end

	if not DS.config.models[model] then
		DarkRP.notify(ply, 1, 7, "Le modèle n'existe pas.")
		return
	end

	if not DS:ActiveWeaponIsDisguiseSwep(ply) then
		DarkRP.notify(ply, 1, 7, "L'arme active n'est pas la malette.")
		return
	end

	DS:Disguise(ply, model)

	net.Start("DS.Disguise")
		net.WriteString(model)
	net.Send(ply)
end)

function DS:Undisguise(ply)
	local model = RPExtraTeams[ply:Team()].model
	model = istable(model) and select(2, next(model)) or model

	ply:SetModel(model)
	DS.Players[ply] = nil

	return model
end

util.AddNetworkString("DS.UnDisguise")
net.Receive("DS.UnDisguise", function(_, ply)
	if not ply:Alive() then
		DarkRP.notify(ply, 1, 7, "Vous devez être en vie pour vous déguiser.")
		return
	end

	if not DS:ActiveWeaponIsDisguiseSwep(ply) then
		DarkRP.notify(ply, 1, 7, "L'arme active n'est pas la malette.")
		return
	end

	if not DS.Players[ply] then
		DarkRP.notify(ply, 1, 7, "Vous n'avez pas la malette.")
		return
	end

	local model = DS:Undisguise(ply)

	net.Start("DS.UnDisguise")
	net.Send(ply)
end)

function DS:FindPassport(ply)
	local weapons = ply:GetWeapons()

	for k,v in pairs(weapons) do
		if v:GetClass() == "disguise_passport" then
			return v
		end
	end

	return false
end

hook.Add("PlayerDeath", "DS.DropDisguise", function(ply)
	if DS.Players[ply] then
		DS:Undisguise(ply)
		DS.Players[ply] = nil
	end
end)

hook.Add("PlayerSwitchWeapon", "DS.BlockSwitchToPassport", function(ply, old_wep, new_wep)
	if new_wep and new_wep:GetClass() == "disguise_passport" and not new_wep.Suppress then
		return true
	end
end)