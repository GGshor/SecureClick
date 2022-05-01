--[=[
	@class ClickDetector
	Custom click detector instance for secure click

	@server
]=]
local ClickDetector = {}
ClickDetector.__index = ClickDetector

--[=[
	Runs callback when click is valid

	@param callback (playerWhoClicked: Player) -> () -- Callback that runs on click

	@return RBXScriptConnection -- Connection that is made
]=]
function ClickDetector:OnClick(callback: (playerWhoClicked: Player) -> ())
	return self._onClick:Connect(callback)
end

--[=[
	Waits for clickdetector to be clicked

	@return Player -- Player that has clicked the clickdetector

	@yields
]=]
function ClickDetector:Wait()
	return self._onClick:Wait()
end

--[=[
	Runs callback when player has been blocked

	@param callback (playerBlocked: Player) -> () -- Callback that runs on blocked

	@return RBXScriptConnection -- Connection that is made
]=]
function ClickDetector:OnBlock(callback: (playerBlocked: Player) -> ())
	return self.onBlock:Connect(callback)
end

--[=[
	Runs callback when player has been timed out

	@param callback (playerTimedOut: Player) -> () -- Callback that runs on time out

	@return RBXScriptConnection -- Connection that is made
]=]
function ClickDetector:OnTimeOut(callback: (playerTimedOut: Player) -> ())
	return self.onTimeOut:Connect(callback)
end

--[=[
	Runs callback when player clicked too far

	@param callback (playerWhoClicked: Player) -> () -- Callback that runs on too far

	@return RBXScriptConnection -- Connection that is made
]=]
function ClickDetector:OnTooFar(callback: (playerWhoClicked: Player) -> ())
	return self._onTooFar:Connect(callback)
end

--[=[
	Runs callback when there was an error

	@param callback (reason: string, data: {[string]: any}) -> () -- Callback that runs on error

	@return RBXScriptConnection -- Connection that is made
]=]
function ClickDetector:OnError(callback: (reason: string, data: {[string]: any}) -> ())
	return self._onError:Connect(callback)
end

--[=[
	Runs callback when player has an auto clicker

	@param callback (playerWhoClicked: Player) -> () -- Callback that runs on atuo clicker detected

	@return RBXScriptConnection -- Connection that is made
]=]
function ClickDetector:OnAutoClick(callback: (playerWhoClicked: Player) -> ())
	return self.onAutoClick:Connect(callback)
end

--[=[
	Sets max activation distance of the clickdetector

	@param distance number -- Amount of distance
]=]
function ClickDetector:SetMaxActivationDistance(distance: number)
	self._ClickDetector.MaxActivationDistance = distance
	self._maxActivationDistance = distance
end

--[[
	Sets the cursor icon.

	@param id string | number -- Asset ID of image
--]]
function ClickDetector:SetCursorIcon(id: string|number)
	if typeof(id) == "number" then
		id = "rbxassetid://" .. tostring(id)
	end
	self._ClickDetector.CursorIcon = id
end

--[=[
	Adds player to the blacklist of this clickdetector

	@param player Player -- Targeted player
]=]
function ClickDetector:Block(player: Player)
	table.insert(self._privateBlacklist, player.UserId)
end

--[=[
	Removes player from the blacklist of this clickdetector

	@param player Player -- Targeted player
]=]
function ClickDetector:Unblock(player: Player)
	table.remove(self._privateBlacklist, player.UserId)
end

--[=[
	Blocks player for given amount of time for this clickdetector

	@param player Player -- Targeted player
	@param seconds number -- Amount of time to wait before removing player from public blacklist
]=]
function ClickDetector:Timeout(player: Player, seconds: number)
	task.spawn(function()
		self:Block(player)
		task.wait(seconds)
		self:Unblock()
	end)
end

--[=[
	Disables the clickdetector, enabling debounce and setting the max activation distance to 0
]=]
function ClickDetector:Disable()
	self._debounce = true
	self._ClickDetector.MaxActivationDistance = 0
end

--[=[
	Enables the clickdetector, disabling debounce and setting the max activation distance back to what it was
]=]
function ClickDetector:Enable()
	self._debounce = false
	self._ClickDetector.MaxActivationDistance = self._maxActivationDistance
end

--[=[
	Destroys the clickdetector and removes the connections

	@return nil
]=]
function ClickDetector:Destroy()
	self._maid:DoCleaning()
	self = nil
	return nil
end


return ClickDetector
