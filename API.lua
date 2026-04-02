repeat task.wait() until game:IsLoaded()
task.wait(5)

local Version = 1.25

for I = 1, 2 do
	print("\n\n\t\t\t\t API v" .. Version .. " made by DEVIX7\n")
	warn("\n\n\t\t\t\t API v" .. Version .. " made by DEVIX7\n")
end

local Api = {}
local StartClock = os.clock()
local Remotes = game:WaitForChild("ReplicatedStorage"):WaitForChild("Remotes")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TeleportService = game:GetService("TeleportService")
local PlaceIds = {9503261072, 11739766412}
local IsLocalMode = false
local BaseUrl = (IsLocalMode and "http://192.168.88.100:9999") or "https://raw.githubusercontent.com/DEVIX7/X2botWJuv8stnFRnJTDGqoqtRN8gHtTDXStrat/master"

local LoadReqs = loadstring(game:HttpGet(BaseUrl .. "/reqs.lua"))()
local Dep1, Dep2, Branch = LoadReqs()
print("branch :", Branch)

getgenv().API = Api
getgenv().API.IsLoaded = false

task.spawn(function()
	StartClock = os.clock()
	repeat task.wait() until getgenv().API.IsLoaded
	print("API Loaded:", os.clock() - StartClock)
end)

local function EnsureFolder(FolderPath)
	if not isfolder(FolderPath) then
		makefolder(FolderPath)
		print("Make Folder:", FolderPath)
	else
		print("...")
	end
end

local FolderRoot = "DEVIX7"
local FolderStrat = "DEVIX7/TDX Strat"
EnsureFolder(FolderRoot)
EnsureFolder(FolderStrat)

local function ParseBool(Value)
	if tostring(Value) == "true" then
		return true
	elseif tostring(Value) == "false" then
		return false
	end
end

local function ParseVector3(Value)
	if type(Value) ~= "string" then
		warn("Invalid argument for parseVector3, expected string but got:", type(Value))
		return Vector3.new(0, 0, 0)
	end
	local X, Y, Z = Value:match("([^,]+),([^,]+),([^,]+)")
	return Vector3.new(tonumber(X), tonumber(Y), tonumber(Z))
end

task.spawn(function()
	if game.PlaceId == 9503261072 then
		local Network = game:GetService("ReplicatedStorage"):WaitForChild("Network")
		if game:GetService("Players").LocalPlayer.PlayerGui.GUI.DailyRewards.Visible == true then
			Network:WaitForChild("DailyRewardClaim"):InvokeServer()
		end
	end
end)

task.spawn(function()
	if game.PlaceId == 11739766412 then
		local GameOverScreen = game:GetService("Players").LocalPlayer.PlayerGui.Interface.GameOverScreen
		GameOverScreen:GetPropertyChangedSignal("Visible"):Connect(function()
			if GameOverScreen.Visible then
				print("Game over")
				task.wait(3)
				if getgenv().PrivateServer == true then
					print("Rejoin to private server...")
					local Socket = WebSocket.connect("ws://localhost:8126")
					Socket:Send("connect-to-vip-server")
					task.wait()
					Remotes:WaitForChild("RequestTeleportToLobby"):FireServer()
				else
					Remotes:WaitForChild("RequestTeleportToLobby"):FireServer()
				end
			end
		end)

		if game:GetService("Workspace"):GetAttribute("PlayerCount") > 1 or #game:GetService("Players"):GetChildren() > 1 then
			task.wait(3)
			TeleportService:Teleport(9503261072, game:GetService("Players").LocalPlayer)
		end
	end

	if game.PlaceId == 11739766412 then
		if getgenv().Debug == true then
			print("Debug Index : ", tostring(getgenv().Debug))
			loadstring(game:HttpGet(BaseUrl .. "/modules/debug.lua"))()
		end
		if getgenv().AllowPowerUps == true then
			print("Using Power-Up's:", tostring(getgenv().AllowPowerUps))
		end
	end
end)

local function CheckPlace()
	return game.PlaceId == 11739766412
end

Api.map = function(Self, MapName)
	if game.PlaceId == 9503261072 then
		getgenv().map = tostring(MapName)
		print("Loading elevator module...")
		local Success, Error = pcall(function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/LARTAJE/tx/main/Elevator.lua"))()
		end)
		if Success then
			print("Elevator module loaded successfully.")
		else
			warn("Failed to load elevator module:", Error)
		end
	end
end

Api.loadout = function(Self, Towers)
	if game.PlaceId == 9503261072 then
		local Network = game:GetService("ReplicatedStorage"):WaitForChild("Network")
		local LoadoutArgs = {
			[1] = Towers[1] or "",
			[2] = Towers[2] or "",
			[3] = Towers[3] or "",
			[4] = Towers[4] or "",
			[5] = Towers[5] or "",
			[6] = Towers[6] or ""
		}
		if Network then
			if Network:FindFirstChild("UpdateLoadout") then
				Network:WaitForChild("UpdateLoadout"):FireServer(unpack({LoadoutArgs}))
			else
				warn("UpdateLoadout not found in Network")
			end
		else
			warn("Cannot update loadout: Network not available")
		end
	end
end

Api.SpeedUp = function()
	local Args = {true}
	print("Speed Up :", unpack(Args))
	Remotes:WaitForChild("ToggleSpeedupTier1"):FireServer(unpack(Args))
end

Api.diff = function(Self, Difficulty)
	if CheckPlace() then
		local Args = {tostring(Difficulty)}
		print("Setting difficulty : ", unpack(Args))
		Remotes:WaitForChild("DifficultyVoteCast"):FireServer(unpack(Args))
		print("Ready")
		Remotes:WaitForChild("DifficultyVoteReady"):FireServer()
		if getgenv().SpeedUp == true then
			local SpeedArgs = {true}
			print("Speed Up :", unpack(SpeedArgs))
			Remotes:WaitForChild("ToggleSpeedupTier1"):FireServer(unpack(SpeedArgs))
		end
	end
end

Api.place = function(Self, Slot, TowerName, Position, Rotation, SecondPosition)
	if CheckPlace() then
		local Args = {tonumber(Slot), tostring(TowerName), ParseVector3(Position), tonumber(Rotation)}
		if SecondPosition then
			Args[5] = ParseVector3(SecondPosition)
		end
		print("Placing tower : ", tostring(Args[2]))
		Remotes:WaitForChild("PlaceTower"):InvokeServer(unpack(Args))
	end
end

Api.update = function(Self, TowerIndex, UpgradePath)
	if CheckPlace() then
		local Args = {tonumber(TowerIndex), tonumber(UpgradePath)}
		print("Updating tower : ", unpack(Args))
		Remotes:WaitForChild("TowerUpgradeRequest"):FireServer(unpack(Args))
	end
end

Api.targettype = function(Self, TowerIndex, TargetType)
	if CheckPlace() then
		local Args = {tonumber(TowerIndex), tonumber(TargetType)}
		print("Changing target type :", unpack(Args))
		Remotes:WaitForChild("ChangeQueryType"):FireServer(unpack(Args))
	end
end

Api.sell = function(Self, TowerIndex)
	if CheckPlace() then
		local Args = {tonumber(TowerIndex)}
		print("Selling tower : ", unpack(Args))
		Remotes:WaitForChild("SellTower"):FireServer(unpack(Args))
	end
end

Api.useability = function(Self, TowerIndex, AbilityIndex, Position, ExtraValue)
	if CheckPlace() then
		local Args = {tonumber(TowerIndex), tonumber(AbilityIndex)}
		if Position and type(Position) == "string" and Position ~= "nil" then
			Args[3] = ParseVector3(Position)
		elseif Position == "nil" and ExtraValue and type(ExtraValue) == "number" then
			Args[4] = ExtraValue
		end
		Remotes:WaitForChild("TowerUseAbilityRequest"):InvokeServer(unpack(Args))
		print("Using ability : ", "N?A")
	end
end

Api.retarget = function(Self, TowerIndex, Position)
	if CheckPlace() then
		local Args = {tonumber(TowerIndex), ParseVector3(Position)}
		print("Retargeting tower : ", unpack(Args))
		Remotes:WaitForChild("RetargetTower"):FireServer(unpack(Args))
	end
end

Api.skip = function(Self, ShouldSkip)
	if CheckPlace() then
		local Args = {ParseBool(ShouldSkip)}
		print("Skipping wave : ", unpack(Args))
		Remotes:WaitForChild("SkipWaveVoteCast"):FireServer(unpack(Args))
	end
end

Api.usepowerup = function(Self, PowerUpName)
	if CheckPlace() then
		if getgenv().AllowPowerUps == true then
			local Args = {tostring(PowerUpName)}
			Remotes:WaitForChild("RequestUsePowerUp"):InvokeServer(unpack(Args))
			print("Using power-up:", unpack(Args))
		else
			print("Skipped: Power Up don't used", tostring(PowerUpName), "!!!")
		end
	end
end

getgenv().API.IsLoaded = true
return Api
