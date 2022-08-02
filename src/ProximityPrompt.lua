--[=[
	@class ProximityPrompt
	Custom ProximityPrompt instance for secure click

	@server
]=]
local ProximityPrompt = {}
ProximityPrompt.__index = ProximityPrompt

--[=[
	Destroys the ProximityPrompt and removes the connections

	@return nil
]=]
function ProximityPrompt:Destroy()
	self._maid:DoCleaning()
	self = nil
	return nil
end


return ProximityPrompt
