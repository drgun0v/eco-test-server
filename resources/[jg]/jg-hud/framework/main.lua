QBCore, ESX = nil, nil
Framework = {
  Client = {},
  Server = {},
}

-- Debug: Check resource states
print(("[JG HUD] es_extended state: %s"):format(GetResourceState("es_extended")))
print(("[JG HUD] qb-core state: %s"):format(GetResourceState("qb-core")))
print(("[JG HUD] qbx_core state: %s"):format(GetResourceState("qbx_core")))
print(("[JG HUD] Config.Framework: %s"):format(Config.Framework))

if (Config.Framework == "auto" and GetResourceState("qbx_core") == "started") or Config.Framework == "Qbox" then
  Config.Framework = "Qbox"
  print("[JG HUD] Framework set to: Qbox")
elseif (Config.Framework == "auto" and GetResourceState("qb-core") == "started") or Config.Framework == "QBCore" then
  QBCore = exports['qb-core']:GetCoreObject()
  Config.Framework = "QBCore"
  print("[JG HUD] Framework set to: QBCore")
elseif (Config.Framework == "auto" and GetResourceState("es_extended") == "started") or Config.Framework == "ESX" then
  ESX = exports["es_extended"]:getSharedObject()
  Config.Framework = "ESX"
  print("[JG HUD] Framework set to: ESX")
else
  Config.Framework = "none"
  print("[JG HUD] Framework set to: none (standalone)")
end