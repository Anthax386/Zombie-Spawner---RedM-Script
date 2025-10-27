-- Charge le fichier config.lua qui contient tous les paramètres
require 'config'
print("Script client Zombie Spawner chargé avec succès !")

-- Table pour stocker tous les zombies avec leurs informations
local spawnedZombies = {}

-- Copie la configuration dans des variables locales pour utilisation rapide
local zombieConfig = Config.zombieStats
local zoneSettings = Config.zoneSettings

-- ============================================================================
-- FONCTION: ConfigureZombie()
-- DESCRIPTION: Configure les propriétés et relations d'un zombie
-- PARAMÈTRES:
--   zombie: Le handle du zombie à configurer
-- UTILITÉ: Évite la duplication de code entre SpawnZombie et SpawnRandomZombie
-- ============================================================================
local function ConfigureZombie(zombie)
    -- Configuration côté client (précision et vitesse)
    SetPedAccuracy(zombie, math.floor(zombieConfig.accuracy * 100))
    SetPedMoveRateOverride(zombie, zombieConfig.speed)
end

-- ============================================================================
-- EVENT HANDLERS CLIENT
-- ============================================================================

-- Event pour configurer un zombie côté client
RegisterNetEvent("zombieSpawner:configureZombie")
AddEventHandler("zombieSpawner:configureZombie", function(zombie)
    ConfigureZombie(zombie)
end)

-- Event pour afficher le nombre de zombies dans le chat
RegisterNetEvent("zombieSpawner:displayCount")
AddEventHandler("zombieSpawner:displayCount", function(count)
    TriggerEvent('chat:addMessage', {
        args = {"[Zombie Spawner]", "Zombies actifs: " .. count}
    })
end)

-- Event pour nettoyer les zombies localement (synchronisé avec serveur)
RegisterNetEvent("zombieSpawner:clearAllZombies")
AddEventHandler("zombieSpawner:clearAllZombies", function()
    spawnedZombies = {}
end)

-- ============================================================================
-- THREAD CLIENT (SIMPLIFIÉ)
-- DESCRIPTION: Thread client pour la gestion locale et l'interface
-- ============================================================================
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        if zoneSettings.showMarkers then
            for _, zone in ipairs(Config.spawnZones) do
                if zone.enabled then
                    DrawMarker(
                        1,
                        zone.coords.x, zone.coords.y, zone.coords.z,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        zone.radius, zone.radius, 2.0,
                        zoneSettings.markerColor[1], zoneSettings.markerColor[2],
                        zoneSettings.markerColor[3], zoneSettings.markerColor[4],
                        false,
                        false, false, 2, false, false, false, false
                    )
                end
            end
        end
    end
end)

print("Script client Zombie Spawner chargé avec succès !")