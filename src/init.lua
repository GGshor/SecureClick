--[[
	For documentation go to: unknown
]]


--// Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Maid = require(script.Maid)
local Signal = require(script.Signal)
local Utils = require(script.Utils)


--[=[
	@class SecureClick
	Creates secure clickdetectors

	@server
]=]
local SecureClick = {
	["PublicBlacklist"] = {}
}
SecureClick.__index = SecureClick


--[=[
	Makes argument a boolean

	@within SecureClick

	@param ... any -- Argument to make boolean

	@return boolean
]=]
local function ToBoolean(...: any): boolean
	if ... then
		return true
	else
		return false
	end
end

--[=[
	Makes argument a boolean

	@within SecureClick

	@param playerWhoClicked Player -- Player who clicked
	@param clickDetector ClickDetector -- The clickdetector that got activated
	@param maxActivationDistance number -- The max activation distance of the clickdetector

	@return boolean -- If click is valid
	@return string -- Reason
]=]
local function CheckClick(playerWhoClicked: Player, clickDetector: ClickDetector, maxActivationDistance: number): (boolean, string)
	if (playerWhoClicked and
		playerWhoClicked.Character and
		playerWhoClicked.Character:FindFirstChild("HumanoidRootPart")) and
		(clickDetector and clickDetector.Parent)
	then
		local character = playerWhoClicked.Character
		local root = character.HumanoidRootPart
		local clickParent = clickDetector.Parent

		local distance = (root.Position - clickParent.Position).Magnitude

		if distance <= (maxActivationDistance + 1) then -- Add 1 to avoid false detections
			return true, "VALID"

		else
			return false, "TOO FAR"
		end

	else
		return false, "NO EXIST"
	end
end


--[=[
	Adds player to the public blacklist

	@param player Player -- Targeted player
]=]
function SecureClick:Block(player: Player)
	if player and player.Parent == Players then
		table.insert(SecureClick.PublicBlacklist, player.UserId)
	end
end

--[=[
	Removes player from the public blacklist

	@param player Player -- Targeted player
]=]
function SecureClick:Unblock(player: Player)
	if player and player.Parent == Players then
		table.remove(SecureClick.PublicBlacklist, player.UserId)
	end
end

--[=[
	Blocks player for given amount of time for every clickdetector

	@param player Player -- Targeted player
	@param seconds number -- Amount of time to wait before removing player from public blacklist
]=]
function SecureClick:Timeout(player: Player, seconds: number)
	task.spawn(function()
		SecureClick:Block(player)
		task.wait(seconds)
		SecureClick:Unblock(player)
	end)
end

--[=[
	Creates a new secure clickdetector

	@param parent Instance -- To what should the clickdetector be parented to?
]=]
function SecureClick.new(parent: Instance)
	local self = setmetatable({}, require(script.ClickDetector))
	local ClickObject = Instance.new("ClickDetector")
	local maid = Maid.new()
	local onClick = Signal.new()
	local onAutoClick = Signal.new()
	local onTimeout = Signal.new()
	local onTooFar = Signal.new()
	local onBlock = Signal.new()
	local onError = Signal.new()

	self._maid = maid
	self._debounce = false
	self._onClick = onClick
	self._onAutoClick = onAutoClick
	self._onTimeout = onTimeout
	self._onTooFar = onTooFar
	self._onBlock = onBlock
	self._onError = onError
	self._ClickDetector = ClickObject
	self._maxActivationDistance = self._ClickDetector.MaxActivationDistance
	self._privateBlacklist = {}
	self._privateClickCount = {}

	self._maid.onClick = self._onClick
	self._maid._onAutoClick = self._onAutoClick
	self._maid.onTimeout = self._onTimeout
	self._maid.onTooFar = self._onTooFar
	self._maid.onBlock = self.onBlock
	self._maid.onError = self._onError
	self._maid.ClickDetector = self._ClickDetector

	self._ClickDetector.Name = HttpService:GenerateGUID(false)
	self._ClickDetector.Parent = parent

	self._ClickDetector.MouseClick:Connect(function(playerWhoClicked: Player)
		if self._debounce == true then
			return
		end

		if table.find(SecureClick.PublicBlacklist, playerWhoClicked.UserId) or table.find(self._privateBlacklist, playerWhoClicked.UserId) then
			self._onBlock:Fire(playerWhoClicked)
			return
		end

		task.spawn(function()
			if self._privateClickCount[tostring(playerWhoClicked.UserId)] then
				self._privateClickCount[tostring(playerWhoClicked.UserId)] += 1

				task.wait(1)

				if self._privateClickCount[tostring(playerWhoClicked.UserId)] > 0 then
					self._privateClickCount[tostring(playerWhoClicked.UserId)] -= 1
				else
					self._privateClickCount[tostring(playerWhoClicked.UserId)] = 0
				end
			else
				self._privateClickCount[tostring(playerWhoClicked.UserId)] = 1

				task.wait(1)

				if self._privateClickCount[tostring(playerWhoClicked.UserId)] > 0 then
					self._privateClickCount[tostring(playerWhoClicked.UserId)] -= 1
				else
					self._privateClickCount[tostring(playerWhoClicked.UserId)] = 0
				end
			end
		end)

		if self._privateClickCount[tostring(playerWhoClicked.UserId)] > 16 then
			self:Timeout(playerWhoClicked, (5 * 60))
			self._onTimeout:Fire(playerWhoClicked)
			self._onAutoClick:Fire(playerWhoClicked)
			return
		end


		local accepted, reason = CheckClick(playerWhoClicked, self._ClickDetector, self._maxActivationDistance)

		if accepted == true and reason == "VALID" then
			self._onClick:Fire(playerWhoClicked)
			return

		elseif accepted == false and reason == "TOO FAR" then
			ServerStorage.Security.ClickTooFarAway:Fire(playerWhoClicked)
			self._onTooFar:Fire(playerWhoClicked)
			return

		elseif accepted == false and reason == "NO EXIST" then		
			local currentData = {
				PlayerWhoClicked = {
					Instance = (playerWhoClicked and "Exists" or "Does not exist!");
					Name = (playerWhoClicked and playerWhoClicked.Name or "No name found!");
					UserId = (playerWhoClicked and playerWhoClicked.UserId or "No userid found!");
					Character = (playerWhoClicked and playerWhoClicked.Character and playerWhoClicked.Character:GetFullName() or "Does not exist!");
					HumanoidRootPart = (playerWhoClicked and playerWhoClicked.Character and playerWhoClicked.Character:FindFirstChild("HumanoidRootPart") and "Exists" or "Does not exist!");
				};
				ClickDetector = {
					Instance = (self._ClickDetector and "Exists" or "Does not exist!");
					Parent = (self._ClickDetector and self._ClickDetector.Parent and self._ClickDetector.Parent:GetFullName() or "Does not exist!");
				}
			}

			warn("[SecureClick.Error] - Unexpected fail, printing data and firing onError.\n", Utils:TableToString(currentData, "Click event data", true))

			self._onError:Fire("Something didn't exist", {
				PlayerWhoClicked = {
					Instance = ToBoolean(playerWhoClicked);
					Name = ToBoolean(playerWhoClicked.Name);
					UserId = ToBoolean(playerWhoClicked.UserId);
					Character = ToBoolean(playerWhoClicked.Character);
					HumanoidRootPart = ToBoolean(playerWhoClicked.Character:FindFirstChild("HumanoidRootPart"));
				};
				ClickDetector = {
					Instance = ToBoolean(self._ClickDetector);
					Parent = ToBoolean(self._ClickDetector.Parent);
				}
			})
			self._debounce = false
			return
		end
	end)

	return self
end

return SecureClick
