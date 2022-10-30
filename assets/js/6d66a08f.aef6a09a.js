"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[5],{74064:e=>{e.exports=JSON.parse('{"functions":[{"name":"CheckInput","desc":"Makes argument a boolean","params":[{"name":"player","desc":"Player who the input came from","lua_type":"Player"},{"name":"distance","desc":"The distance of player when input got activated","lua_type":"number"},{"name":"input","desc":"The input","lua_type":"any"}],"returns":[{"desc":"If click is valid","lua_type":"boolean"},{"desc":"Reason","lua_type":"string"}],"function_type":"static","source":{"line":58,"path":"src/init.lua"}},{"name":"Block","desc":"Adds player to the public blacklist","params":[{"name":"player","desc":"Targeted player","lua_type":"Player"}],"returns":[],"function_type":"method","source":{"line":82,"path":"src/init.lua"}},{"name":"Unblock","desc":"Removes player from the public blacklist","params":[{"name":"player","desc":"Targeted player","lua_type":"Player"}],"returns":[],"function_type":"method","source":{"line":93,"path":"src/init.lua"}},{"name":"Timeout","desc":"Blocks player for given amount of time for every clickdetector","params":[{"name":"player","desc":"Targeted player","lua_type":"Player"},{"name":"seconds","desc":"Amount of time to wait before removing player from public blacklist","lua_type":"number"}],"returns":[],"function_type":"method","source":{"line":105,"path":"src/init.lua"}},{"name":"ConnectActivated","desc":"Runs given function if input is valid","params":[{"name":"func","desc":"The function to connect to","lua_type":"(playerWhoActivated: Player) -> ()"}],"returns":[{"desc":"","lua_type":"RBXScriptConnection"}],"function_type":"method","source":{"line":120,"path":"src/init.lua"}},{"name":"AddInput","desc":"Adds new input","params":[{"name":"inputType","desc":"Type of input, current types: \\"ClickDetector\\", \\"ProximityPrompt\\" and \\"VRHandInteract\\"","lua_type":"string"},{"name":"properties","desc":"Properties of instance","lua_type":"{[string]: any}?"}],"returns":[],"function_type":"method","source":{"line":130,"path":"src/init.lua"}},{"name":"SetMaxActivationDistance","desc":"Changes max activation distance","params":[{"name":"distance","desc":"New max activation distance","lua_type":"number"}],"returns":[],"function_type":"method","source":{"line":140,"path":"src/init.lua"}},{"name":"Enable","desc":"Enables input (Note, input is enabled by default)","params":[],"returns":[],"function_type":"method","source":{"line":148,"path":"src/init.lua"}},{"name":"Disable","desc":"Disables input","params":[],"returns":[],"function_type":"method","source":{"line":156,"path":"src/init.lua"}},{"name":"Destroy","desc":"Disconnects all connections and removes inputs","params":[],"returns":[],"function_type":"method","source":{"line":164,"path":"src/init.lua"}},{"name":"new","desc":"Creates a new secure input","params":[{"name":"parent","desc":"To what should the input be parented to?","lua_type":"Instance"}],"returns":[],"function_type":"static","source":{"line":173,"path":"src/init.lua"}}],"properties":[],"types":[],"name":"SecureInput","desc":"Creates secure inputs","realm":["Server"],"source":{"line":39,"path":"src/init.lua"}}')}}]);