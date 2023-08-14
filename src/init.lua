--[[
	Secures unified 3D input

	@GGshor
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maid = require(script.Maid)
local Signal = require(script.Signal)
local Utils = require(script.Utils)

-- Init Unified3DInput
local Unified3DInputModule = script:FindFirstChild("Unified3DInput")

if ReplicatedStorage:FindFirstChild("Unified3DInput") then
	Unified3DInputModule = ReplicatedStorage.Unified3DInput
else
	script.Unified3DInput.Parent = ReplicatedStorage
	Unified3DInputModule = ReplicatedStorage.Unified3DInput
end

Players.PlayerAdded:Connect(function(player)
	local clone = script.SetupInput:Clone()
	clone.Parent = player:WaitForChild("PlayerGui")
end)

local Unified3DInput = require(Unified3DInputModule)
local Unified3DInputTypes = require(Unified3DInputModule.Unified3DInputTypes)

--[=[
	@class SecureInput

	Creates secure inputs

	@server
]=]
local SecureInput = {
	["Blacklist"] = {},
	["TooFar"] = Signal.new(),
	["AutoClick"] = Signal.new(),
}
SecureInput.__index = SecureInput

--[=[
	Makes argument a boolean

	@within SecureInput

	@param player Player -- Player who the input came from
	@param distance number -- The distance of player when input got activated
	@param input any -- The input

	@return boolean -- If click is valid
	@return string -- Reason
]=]
local function CheckInput(
	player: Player,
	distance: number,
	input: Unified3DInputTypes.Unified3DInput
): (boolean, string)
	if
		(player and player.Character and player.Character:FindFirstChild("HumanoidRootPart"))
		and (input and input.Part)
	then
		if distance <= (input.MaxActivationDistance + 10) then -- Add 10 to avoid false detections
			return true, "Valid"
		else
			return false, "DistanceError"
		end
	else
		return false, "ParamError"
	end
end

--[=[
	Adds player to the public blacklist

	@param player Player -- Targeted player
]=]
function SecureInput:Block(player: Player)
	if player and player.Parent == Players then
		table.insert(SecureInput.Blacklist, player.UserId)
	end
end

--[=[
	Removes player from the public blacklist

	@param player Player -- Targeted player
]=]
function SecureInput:Unblock(player: Player)
	if player and player.Parent == Players then
		table.remove(SecureInput.Blacklist, player.UserId)
	end
end

--[=[
	Blocks player for given amount of time for every clickdetector

	@param player Player -- Targeted player
	@param seconds number -- Amount of time to wait before removing player from public blacklist
]=]
function SecureInput:Timeout(player: Player, seconds: number)
	task.spawn(function()
		SecureInput:Block(player)
		task.wait(seconds)
		SecureInput:Unblock(player)
	end)
end

--[=[
	Runs given function if input is valid

	@param func (playerWhoActivated: Player) -> () -- The function to connect to

	@return RBXScriptConnection
]=]
function SecureInput:ConnectActivated(func: (Player) -> ())
	self._onClick:Connect(func)
end

--[=[
	Adds new input

	@param inputType string -- Type of input, current types: "ClickDetector", "ProximityPrompt" and "VRHandInteract"
	@param properties {[string]: any}? -- Properties of instance
]=]
function SecureInput:AddInput(inputType: string, properties: { [string]: any }?)
	self._input:AddInput(inputType, properties)
	return self
end

--[=[
	Changes max activation distance

	@param distance number -- New max activation distance
]=]
function SecureInput:SetMaxActivationDistance(distance: number)
	self._input:SetMaxActivationDistance(distance)
	return self
end

--[=[
	Enables input (Note, input is enabled by default)
]=]
function SecureInput:Enable()
	self._input:Enable()
	return self
end

--[=[
	Disables input
]=]
function SecureInput:Disable()
	self._input:Disable()
	return self
end

--[=[
	Disconnects all connections and removes inputs
]=]
function SecureInput:Destroy()
	self._maid:DoCleaning()
end

--[=[
	Creates a new secure input

	@param parent Instance -- To what should the input be parented to?
]=]
function SecureInput.new(parent: Instance)
	local self = setmetatable({}, SecureInput)
	local Input = Unified3DInput.new(parent)
	local maid = Maid.new()
	local onClick = Signal.new()

	self._maid = maid
	self._debounce = {} :: {[Player]: boolean}
	self._onClick = onClick
	self._input = Input
	self._blacklist = {}
	self._clickCount = {}

	self._maid.onClick = self._onClick
	self._maid.input = self._input

	self._input.Activated:Connect(function(playerWhoActivated: Player, distance: number)
		if self._debounce[playerWhoActivated] == true then
			return
		end
		self._debounce = true

		if
			table.find(SecureInput.Blacklist, playerWhoActivated.UserId)
			or table.find(self._blacklist, playerWhoActivated.UserId)
		then
			self._debounce[playerWhoActivated] = false
			return
		end

		task.spawn(function()
			if self._clickCount[tostring(playerWhoActivated.UserId)] then
				self._clickCount[tostring(playerWhoActivated.UserId)] += 1

				task.wait(1)

				if self._clickCount[tostring(playerWhoActivated.UserId)] > 0 then
					self._clickCount[tostring(playerWhoActivated.UserId)] -= 1
				else
					self._clickCount[tostring(playerWhoActivated.UserId)] = 0
				end
			else
				self._clickCount[tostring(playerWhoActivated.UserId)] = 1

				task.wait(1)

				if self._clickCount[tostring(playerWhoActivated.UserId)] > 0 then
					self._clickCount[tostring(playerWhoActivated.UserId)] -= 1
				else
					self._clickCount[tostring(playerWhoActivated.UserId)] = 0
				end
			end
		end)

		if self._clickCount[tostring(playerWhoActivated.UserId)] > 16 then
			self:Timeout(playerWhoActivated, (5 * 60))
			SecureInput.AutoClick:Fire(playerWhoActivated)
			self._debounce[playerWhoActivated] = false
			return
		end

		local accepted, reason = CheckInput(playerWhoActivated, distance, self._input)

		if accepted == true and reason == "Valid" then
			self._onClick:Fire(playerWhoActivated)
			self._debounce[playerWhoActivated] = false
			return
		elseif accepted == false and reason == "DistanceError" then
			SecureInput.TooFar:Fire(playerWhoActivated)
			self._debounce[playerWhoActivated] = false
			return
		elseif accepted == false and reason == "ParamError" then
			local currentData = {
				PlayerWhoClicked = {
					Instance = (playerWhoActivated and "true" or "nil"),
					Name = (playerWhoActivated and playerWhoActivated.Name or "nil"),
					UserId = (playerWhoActivated and playerWhoActivated.UserId or "nil"),
					Character = (
						playerWhoActivated
							and playerWhoActivated.Character
							and playerWhoActivated.Character:GetFullName()
						or "nil"
					),
					HumanoidRootPart = (
						playerWhoActivated
							and playerWhoActivated.Character
							and playerWhoActivated.Character:FindFirstChild("HumanoidRootPart")
							and "true"
						or "nil"
					),
				},
				Input = {
					Instance = (self._input and "true" or "nil"),
					Parent = (self._input and self._input.Part and self._input.Part:GetFullName() or "nil"),
				},
			}

			task.spawn(
				error,
				"[SecureInput.Error] - Unexpected fail, printing data and firing onError.\n"
					.. Utils.TableToString(currentData, "Input event data", true)
			)

			self._debounce[playerWhoActivated] = false
			return
		end
	end)

	return self
end

return SecureInput
