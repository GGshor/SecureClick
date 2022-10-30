local ServerStorage = game:GetService("ServerStorage")

local SecureInput = require(ServerStorage.SecureInput)

local input = SecureInput.new(workspace.SpawnLocation)
:AddInput("ClickDetector")
:AddInput("ProximityPrompt", {ActionText = "Press", ObjectText = "SpawnPoint", HoldDuration = 0.5, Offset = Vector3.new(0, 0, 0.5)})
:AddInput("VRHandInteract", {DisableOtherInputs = false})


input:ConnectActivated(function(player)
	print(player.Name, "has activated input!")
	
	input:Disable()
	task.wait(5)
	input:Enable()
	
	input:SetMaxActivationDistance(10)
	print("Max activation distance set to 10")
	
	task.wait(5)
	
	input:Timeout(player, 10)
	print("Timed out", player.Name, "for 10 seconds")
end)
