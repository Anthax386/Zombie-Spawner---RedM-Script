-- server/server.lua
-- Script serveur pour la gestion des zombies avec synchronisation réseau
print("Script serveur Zombie Spawner chargé avec succès !")

-- Table pour stocker tous les zombies avec leurs informations (côté serveur)
local spawnedZombies = {}
-- Table pour stocker les temps de spawn par zone
local lastSpawnTimeByZone = {}

-- Copie la configuration dans des variables locales pour utilisation rapide
local zombieConfig = Config.zombieStats
local zombieModels = Config.zombieModels
local combatBehavior = Config.combatBehavior
local relationships = Config.relationships
local spawnZones = Config.spawnZones
local zoneSettings = Config.zoneSettings
local threadSettings = Config.threadSettings

-- Pré-calcul des GetHashKey pour optimisation (côté serveur)
local HATES_PLAYER_HASH = GetHashKey("HATES_PLAYER")
local PLAYER_HASH = GetHashKey("PLAYER")
local CIVILIAN_HASH = GetHashKey("CIVILIAN")
local GANG_HASH = GetHashKey("GANG")
local ANIMAL_HASH = GetHashKey("ANIMAL")
local WILD_ANIMAL_HASH = GetHashKey("WILD_ANIMAL")

-- ============================================================================
-- FONCTION: ConfigureZombieServer()
-- DESCRIPTION: Configure les propriétés d'un zombie côté serveur
-- PARAMÈTRES:
--   zombie: Le handle du zombie à configurer
-- ============================================================================
local function ConfigureZombieServer(zombie)
    -- Configuration côté serveur (fonctions natives serveur)
    SetEntityHealth(zombie, zombieConfig.health)

    -- Configure le comportement au combat
    SetPedCombatAttributes(zombie, combatBehavior.alwaysFight, true)
    SetPedCombatAttributes(zombie, combatBehavior.useMeleeWeapons, true)
    SetPedCombatAbility(zombie, combatBehavior.combatAbility)
    SetPedCombatRange(zombie, combatBehavior.combatRange)
    SetPedCombatMovement(zombie, combatBehavior.combatMovement)

    -- Configure les relations (utilise les hashes pré-calculés)
    SetPedRelationshipGroupHash(zombie, HATES_PLAYER_HASH)
    SetRelationshipBetweenGroups(relationships.playerRelationship, HATES_PLAYER_HASH, PLAYER_HASH)
    SetRelationshipBetweenGroups(relationships.playerRelationship, PLAYER_HASH, HATES_PLAYER_HASH)
    SetRelationshipBetweenGroups(relationships.civilianRelationship, HATES_PLAYER_HASH, CIVILIAN_HASH)
    SetRelationshipBetweenGroups(relationships.civilianRelationship, CIVILIAN_HASH, HATES_PLAYER_HASH)
    SetRelationshipBetweenGroups(relationships.gangRelationship, HATES_PLAYER_HASH, GANG_HASH)
    SetRelationshipBetweenGroups(relationships.gangRelationship, GANG_HASH, HATES_PLAYER_HASH)
    SetRelationshipBetweenGroups(relationships.animalRelationship, HATES_PLAYER_HASH, ANIMAL_HASH)
    SetRelationshipBetweenGroups(relationships.animalRelationship, ANIMAL_HASH, HATES_PLAYER_HASH)
    SetRelationshipBetweenGroups(relationships.wildAnimalRelationship, HATES_PLAYER_HASH, WILD_ANIMAL_HASH)
    SetRelationshipBetweenGroups(relationships.wildAnimalRelationship, WILD_ANIMAL_HASH, HATES_PLAYER_HASH)
end
-- ============================================================================
-- FONCTION: SpawnZombieInZone()
-- DESCRIPTION: Spawne un zombie dans une zone spécifique (côté serveur)
-- PARAMÈTRES:
--   zone: La zone dans laquelle spawn le zombie
--   zoneIndex: L'index de la zone
-- RETOUR: Le handle du zombie spawné
-- ============================================================================
local function SpawnZombieInZone(zone, zoneIndex)
    -- Vérifie que la zone est valide
    if not zone or not zone.coords then
        return nil
    end

    -- Récupère les coordonnées du centre de la zone
    local zoneCoords = zone.coords

    -- Génère une position aléatoire dans le rayon de la zone
    local angle = math.rad(math.random(0, 360))
    local distance = math.random(0, math.floor(zone.radius * 100)) / 100

    local spawnX = zoneCoords.x + math.cos(angle) * distance
    local spawnY = zoneCoords.y + math.sin(angle) * distance
    local spawnZ = 0

    -- Récupère la hauteur du sol à la position de spawn
    local success, groundZ = GetGroundZFor_3dCoord(spawnX, spawnY, spawnZ, false)

    if success then
        spawnZ = groundZ
    end

    -- Choisit un modèle de zombie au hasard
    local modelHash = GetHashKey(zombieModels[math.random(#zombieModels)])

    -- Charge le modèle en mémoire
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(1)
    end

    -- Crée le zombie côté serveur (avec synchronisation réseau)
    local zombie = CreatePed(modelHash, spawnX, spawnY, spawnZ, 0.0, true, true)

    -- Configure le zombie côté serveur
    ConfigureZombieServer(zombie)

    -- Déclenche la configuration côté client pour tous les joueurs
    TriggerClientEvent("zombieSpawner:configureZombie", -1, zombie)

    -- Enregistre le zombie dans la table serveur
    table.insert(spawnedZombies, {
        handle = zombie,
        zoneIndex = zoneIndex,
        zoneName = zone.name,
        spawnCoords = vector3(spawnX, spawnY, spawnZ)
    })

    -- Nettoie la mémoire
    SetModelAsNoLongerNeeded(modelHash)

    return zombie
end

-- ============================================================================
-- FONCTION: CleanupZombies()
-- DESCRIPTION: Supprime les zombies morts ou éloignés de leur zone (côté serveur)
-- ============================================================================
local function CleanupZombies()
    for i = #spawnedZombies, 1, -1 do
        local zombieData = spawnedZombies[i]
        local zombie = zombieData.handle

        local shouldRemove = false

        -- Vérifie si le zombie n'existe plus ou s'il est mort
        if not DoesEntityExist(zombie) or IsEntityDead(zombie) then
            shouldRemove = true
        else
            -- Vérifie si le zombie s'est éloigné trop loin de sa zone
            local zoneIndex = zombieData.zoneIndex
            if zoneIndex and spawnZones[zoneIndex] then
                local zone = spawnZones[zoneIndex]
                local zombieCoords = GetEntityCoords(zombie)

                local dx = zombieCoords.x - zone.coords.x
                local dy = zombieCoords.y - zone.coords.y
                local dz = zombieCoords.z - zone.coords.z
                local distance = math.sqrt(dx * dx + dy * dy + dz * dz)

                if distance > zoneSettings.cleanupDistance then
                    shouldRemove = true
                end
            end
        end

        -- Supprime le zombie si nécessaire
        if shouldRemove then
            if DoesEntityExist(zombie) then
                DeleteEntity(zombie)
            end
            table.remove(spawnedZombies, i)
        end
    end
end

-- ============================================================================
-- FONCTION: GetZombieCountInZone()
-- DESCRIPTION: Compte le nombre de zombies vivants dans une zone donnée (côté serveur)
-- ============================================================================
local function GetZombieCountInZone(zoneIndex)
    local count = 0
    for _, zombieData in ipairs(spawnedZombies) do
        if zombieData.zoneIndex == zoneIndex and DoesEntityExist(zombieData.handle) and not IsEntityDead(zombieData.handle) then
            count = count + 1
        end
    end
    return count
end

-- ============================================================================
-- FONCTION: GetTotalZombieCount()
-- DESCRIPTION: Compte le nombre total de zombies vivants (côté serveur)
-- ============================================================================
local function GetTotalZombieCount()
    local count = 0
    for _, zombieData in ipairs(spawnedZombies) do
        if DoesEntityExist(zombieData.handle) and not IsEntityDead(zombieData.handle) then
            count = count + 1
        end
    end
    return count
end

-- ============================================================================
-- THREAD PRINCIPAL SERVEUR
-- DESCRIPTION: Boucle qui s'exécute en continu pour gérer les zombies par zone
-- ============================================================================
Citizen.CreateThread(function()
    -- Initialise les temps de spawn pour chaque zone
    for i, zone in ipairs(spawnZones) do
        lastSpawnTimeByZone[i] = 0
    end

    while true do
        Citizen.Wait(threadSettings.threadInterval)

        -- Nettoie les zombies morts ou éloignés
        CleanupZombies()

        -- Parcourt chaque zone de spawn
        for zoneIndex, zone in ipairs(spawnZones) do
            if zone.enabled then
                local spawnInterval = zone.spawnInterval or zoneSettings.spawnInterval
                local currentTime = GetGameTimer()

                if (currentTime - (lastSpawnTimeByZone[zoneIndex] or 0)) >= spawnInterval then
                    local currentZombieCount = GetZombieCountInZone(zoneIndex)

                    if currentZombieCount < zone.maxZombies then
                        SpawnZombieInZone(zone, zoneIndex)
                    end

                    lastSpawnTimeByZone[zoneIndex] = currentTime
                end
            end
        end
    end
end)

-- ============================================================================
-- EVENT HANDLERS SERVEUR
-- ============================================================================

-- Event pour spawn un zombie depuis une commande client
RegisterNetEvent("zombieSpawner:spawnZombie")
AddEventHandler("zombieSpawner:spawnZombie", function(zoneIndex)
    local source = source
    if zoneIndex and spawnZones[zoneIndex] then
        local zone = spawnZones[zoneIndex]
        local zombie = SpawnZombieInZone(zone, zoneIndex)
        if zombie then
            print("Zombie spawné par le joueur " .. source .. " dans la zone " .. zone.name)
        end
    end
end)

-- Event pour nettoyer tous les zombies depuis une commande client
RegisterNetEvent("zombieSpawner:clearAllZombies")
AddEventHandler("zombieSpawner:clearAllZombies", function()
    local source = source
    print("Nettoyage de tous les zombies demandé par le joueur " .. source)

    for i = #spawnedZombies, 1, -1 do
        local zombie = spawnedZombies[i].handle
        if DoesEntityExist(zombie) then
            DeleteEntity(zombie)
        end
        table.remove(spawnedZombies, i)
    end

    print("Tous les zombies ont été supprimés")
end)

-- Event pour récupérer le nombre de zombies depuis une commande client
RegisterNetEvent("zombieSpawner:getZombieCount")
AddEventHandler("zombieSpawner:getZombieCount", function()
    local source = source
    local count = GetTotalZombieCount()

    -- Envoie le résultat au joueur qui a demandé
    TriggerClientEvent("zombieSpawner:displayCount", source, count)
    print("Joueur " .. source .. " a demandé le nombre de zombies: " .. count)
end)

-- ============================================================================
-- FONCTIONS D'EXPORT (pour usage avancé)
-- ============================================================================

-- Export pour spawn un zombie depuis d'autres scripts
exports('SpawnZombieInZone', function(zoneIndex)
    if zoneIndex and spawnZones[zoneIndex] then
        return SpawnZombieInZone(spawnZones[zoneIndex], zoneIndex)
    end
    return nil
end)

-- Export pour récupérer le nombre total de zombies
exports('GetTotalZombieCount', function()
    return GetTotalZombieCount()
end)

print("Script serveur Zombie Spawner chargé avec succès !")