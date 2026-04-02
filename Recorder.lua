repeat task.wait() until game:IsLoaded()

for I = 1, 2 do
	print("\t\t --->\tmade by devix7\t<---")
	warn("\t\t --->\tmade by devix7\t<---")
end

local IsLocalMode = false
local BaseUrl = (IsLocalMode and "http://192.168.88.100:9999") or "https://raw.githubusercontent.com/DEVIX7/X2botWJuv8stnFRnJTDGqoqtRN8gHtTDXStrat/master"
local Version = "1.6"

local LoadReqs = loadstring(game:HttpGet(BaseUrl .. "/reqs.lua"))()
local Dep1, Dep2, Dep3 = LoadReqs()

if (getgenv().StratName == false) or (getgenv().StratName == nil) then
	print("Using default strat name")
	getgenv().StratName = "recorded_strat" .. os.clock()
end

if (getgenv().MapName == false) or (getgenv().MapName == nil) then
	print("Input map name in `getgenv().MapName`")
	return false
end

local StratName = tostring(getgenv().StratName)
local LoadoutList = {}

for _, Tower in pairs(game:GetService("Players").LocalPlayer.PlayerGui.Interface.BottomBar.TowersBar:GetChildren()) do
	if (Tower.Name == "UIGridLayout") or (Tower.Name == "TowerTemplate") then
		print("N/A")
	else
		table.insert(LoadoutList, '"' .. tostring(Tower.Name) .. '"')
		print(Tower.Name)
	end
end

getgenv().Loadout = table.concat(LoadoutList, ",")

local FileHeader = "--" .. Version .. '\nlocal api = loadstring(game:HttpGet(\"https://raw.githubusercontent.com/DEVIX7/X2botWJuv8stnFRnJTDGqoqtRN8gHtTDXStrat/master/API/API.lua\", true))()\napi:loadout({' .. getgenv().Loadout .. '})\napi:map(\"' .. getgenv().MapName .. '\")\n'
writefile(StratName .. ".txt", FileHeader)

local LastTick = tick()

local function GetTimeDelta()
	local NewTick = tick()
	local Delta = NewTick - LastTick
	LastTick = NewTick
	return "task.wait(" .. string.format("%.2f", Delta) .. ")\n"
end

print("made by devix7", "[RECORDER V" .. Version .. "] Recording start...")
print("Strat name = " .. StratName)
print("Map name = " .. getgenv().MapName)

local OriginalNamecall
OriginalNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
	local Args = {...}
	local Method = getnamecallmethod()

	if (Method == "InvokeServer") or (Method == "FireServer") then
		task.spawn(function()
			local RemoteName = Self.Name
			local FormattedArgs = {}

			for Index, Value in pairs(Args) do
				if type(Value) == "string" then
					FormattedArgs[Index] = '"' .. Value .. '"'
				elseif typeof(Value) == "Vector3" then
					FormattedArgs[Index] = '"' .. string.format("%f,%f,%f", Value.X, Value.Y, Value.Z) .. '"'
				else
					FormattedArgs[Index] = tostring(Value)
				end
			end

			for Index = 1, #Args do
				if not FormattedArgs[Index] then
					FormattedArgs[Index] = "'nil'"
				end
			end

			local Output = ""

			if RemoteName == "PlaceTower" then
				Output = Output .. GetTimeDelta()
				Output = Output .. "api:place(" .. table.concat(FormattedArgs, ",") .. ")\n"
			elseif RemoteName == "DifficultyVoteCast" then
				Output = Output .. "api:diff(" .. table.concat(FormattedArgs, ",") .. ")\n"
			elseif RemoteName == "UpdateLoadout" then
				Output = Output .. GetTimeDelta()
				Output = Output .. "api:loadout(" .. table.concat(FormattedArgs, ",") .. ")\n"
			elseif RemoteName == "SellTower" then
				Output = Output .. GetTimeDelta()
				Output = Output .. "api:sell(" .. table.concat(FormattedArgs, ",") .. ")\n"
			elseif RemoteName == "TowerUpgradeRequest" then
				Output = Output .. GetTimeDelta()
				Output = Output .. "api:update(" .. table.concat(FormattedArgs, ",") .. ")\n"
			elseif RemoteName == "ChangeQueryType" then
				Output = Output .. GetTimeDelta()
				Output = Output .. "api:targettype(" .. table.concat(FormattedArgs, ",") .. ")\n"
			elseif RemoteName == "TowerUseAbilityRequest" then
				Output = Output .. GetTimeDelta()
				Output = Output .. "api:useability(" .. table.concat(FormattedArgs, ",") .. ")\n"
			elseif RemoteName == "RetargetTower" then
				Output = Output .. GetTimeDelta()
				Output = Output .. "api:retarget(" .. table.concat(FormattedArgs, ",") .. ")\n"
			elseif RemoteName == "SkipWaveVoteCast" then
				Output = Output .. GetTimeDelta()
				Output = Output .. "api:skip(" .. table.concat(FormattedArgs, ",") .. ")\n"
			elseif RemoteName == "RequestUsePowerUp" then
				Output = Output .. GetTimeDelta()
				Output = Output .. "api:usepowerup(" .. table.concat(FormattedArgs, ",") .. ")\n"
			elseif RemoteName == "ToggleSpeedupTier1" then
				Output = Output .. GetTimeDelta()
				Output = Output .. "api:SpeedUp()"
			else
				Output = nil
			end

			if Output then
				appendfile(StratName .. ".txt", Output)
				print("[RECORDER V" .. Version .. "] Recorded Action:" .. RemoteName)
			else
				print("[RECORDER V" .. Version .. "] Skipped Action:" .. RemoteName)
			end
		end)
	end

	return OriginalNamecall(Self, ...)
end)
