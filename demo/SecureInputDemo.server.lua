local ServerStorage = game:GetService("ServerStorage")

local SecureInput = require(ServerStorage.SecureInput)

local input = SecureInput.new(workspace.SpawnLocation):AddInput("ClickDetector"):AddInput("ProximityPrompt")

input:ConnectActivated(function(player)
	print(player.Name, "has activated input!")
	input:Disable()
	task.wait(10)
	input:Enable()
	
	input:SetMaxActivationDistance(10)
	print("Max activation distance set to 10")
	
	task.wait(10)
	
	input:Timeout(player, 10)
	print("Timed out", player.Name, "for 10 seconds")
end)
