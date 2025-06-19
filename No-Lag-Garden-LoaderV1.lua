local scriptUrl = "https://raw.githubusercontent.com/NotyourScripter/PetxSeedSpawner/refs/heads/main/Garden-V1"
local response = game:HttpGet(scriptUrl)
local loadedScript = loadstring(response)
loadedScript()
