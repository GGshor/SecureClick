local ServerStorage = game:GetService("ServerStorage")

local SecureInput = require(ServerStorage.SecureInput)

local input = SecureInput.new(workspace.SpawnLocation):AddInput("ClickDetector"):AddInput("ProximityPrompt")

input:ConnectActivated(function(player)
	print(player.Name, "has activated input!")
end)
