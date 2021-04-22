local load = {
	sv = SERVER and include or function() end,
	cl = SERVER and AddCSLuaFile or include,
}

load.sh = function(f)
	load.cl(f)
	load.sv(f)
end

local function loadFolder(folder_name, depth)

	depth = depth or 0

	local folder_path = folder_name .. "/"
	local files, folders = file.Find(folder_path .. "*", "LUA")

	for _, file_name in SortedPairsByValue(files) do
		if string.GetExtensionFromFilename(file_name) ~= "lua" then continue end

		if string.find(file_name, "^sh_*") then
			load.sh(folder_path .. file_name)
		end

		if string.find(file_name, "^sv_*") then
			load.sv(folder_path .. file_name)
		end

		if string.find(file_name, "^cl_*") then
			load.cl(folder_path .. file_name)
		end
	end
	
	for _, folder_name in SortedPairsByValue(folders) do
		if folder_name == "." or folder_name == ".." then continue end

		loadFolder(folder_path .. folder_name, depth + 1)
	end
end

local function loadAddon(addon_name, folder_name)
	MsgC(Color(0, 89, 255), "[" .. addon_name .. "] Chargement...\n")
	loadFolder(folder_name)
	MsgC(Color(0, 89, 255), "[" .. addon_name .. "] Chargement terminé\n")
end

hook.Add("InitPostEntity", "DS.Loading", function()
	DS = {}

	loadAddon("Disguise System", "disguise_system")
end)