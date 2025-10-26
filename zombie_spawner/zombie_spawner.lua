-- ============================================================================
-- IMPORT DE LA CONFIGURATION
-- ============================================================================
-- Charge le fichier config.lua qui contient tous les paramètres
require 'config'

-- ============================================================================
-- VARIABLES GLOBALES
-- ============================================================================
-- Table pour stocker tous les zombies avec leurs informations
local spawnedZombies = {}

-- Copie la configuration dans des variables locales pour utilisation rapide
local zombieConfig = Config.zombieStats
local zombieModels = Config.zombieModels
local combatBehavior = Config.combatBehavior
local relationships = Config.relationships
local threadSettings = Config.threadSettings
local messages = Config.messages
local spawnZones = Config.spawnZones
local zoneSettings = Config.zoneSettings

-- Variables pour tracker le temps de spawn par zone
local lastSpawnTimeByZone = {}

-- Pré-calcul des GetHashKey pour optimisation
local HATES_PLAYER_HASH = GetHashKey("HATES_PLAYER")
local PLAYER_HASH = GetHashKey("PLAYER")
local CIVILIAN_HASH = GetHashKey("CIVILIAN")
local GANG_HASH = GetHashKey("GANG")
local ANIMAL_HASH = GetHashKey("ANIMAL")
local WILD_ANIMAL_HASH = GetHashKey("WILD_ANIMAL")

-- ============================================================================
-- FONCTION: ConfigureZombie()
-- DESCRIPTION: Configure les propriétés et relations d'un zombie
-- PARAMÈTRES:
--   zombie: Le handle du zombie à configurer
-- UTILITÉ: Évite la duplication de code entre SpawnZombie et SpawnRandomZombie
-- ============================================================================
local function ConfigureZombie(zombie)
    -- Configure les propriétés du zombie
    SetEntityHealth(zombie, zombieConfig.health)
    SetPedAccuracy(zombie, math.floor(zombieConfig.accuracy * 100))
    SetPedMoveRateOverride(zombie, zombieConfig.speed)
    
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
-- DESCRIPTION: Crée un zombie à une position aléatoire dans une zone donnée
-- PARAMÈTRES:
--   zone: La table de configuration de la zone
--   zoneIndex: L'index de la zone dans la table spawnZones
-- RETOUR: Le handle (identifiant) du zombie créé, ou nil si erreur
-- ============================================================================
local function SpawnZombieInZone(zone, zoneIndex)
    -- Vérifie que la zone est valide
    if not zone or not zone.coords then
        return nil
    end
    
    -- Récupère les coordonnées du centre de la zone
    local zoneCoords = zone.coords
    
    -- Génère une position aléatoire dans le rayon de la zone
    -- Calcule un angle aléatoire (0 à 360 degrés)
    local angle = math.rad(math.random(0, 360))
    
    -- Calcule une distance aléatoire entre 0 et le rayon de la zone
    local distance = math.random(0, math.floor(zone.radius * 100)) / 100
    
    -- Calcule les coordonnées X et Y en fonction de l'angle et de la distance
    local spawnX = zoneCoords.x + math.cos(angle) * distance
    local spawnY = zoneCoords.y + math.sin(angle) * distance
    local spawnZ = zoneCoords.z
    
    -- Choisit un modèle de zombie au hasard
    local modelHash = GetHashKey(zombieModels[math.random(#zombieModels)])
    
    -- ========================================================================
    -- CHARGEMENT DU MODÈLE EN MÉMOIRE
    -- ========================================================================
    -- Demande au jeu de charger le modèle du zombie en mémoire
    RequestModel(modelHash)
    
    -- Boucle d'attente: attend que le modèle soit complètement chargé
    -- HasModelLoaded() retourne true quand le modèle est prêt
    -- Wait(1) pause le script pendant 1 milliseconde pour ne pas bloquer le jeu
    while not HasModelLoaded(modelHash) do
        Wait(1)
    end
    
    -- ========================================================================
    -- CRÉATION DU ZOMBIE
    -- ========================================================================
    -- CreatePed() crée un nouveau personnage (zombie) dans le jeu
    -- Paramètres:
    --   modelHash: le modèle du zombie
    --   spawnX, spawnY, spawnZ: position X, Y, Z
    --   0.0: orientation (direction où regarde le zombie)
    --   true: isNetwork (synchronisé sur le réseau)
    --   true: bScriptHostPed (géré par le script)
    local zombie = CreatePed(
        modelHash,
        spawnX,
        spawnY,
        spawnZ,
        0.0,
        true,
        true
    )
    
    -- ========================================================================
    -- CONFIGURATION DU ZOMBIE
    -- ========================================================================
    -- Appelle la fonction ConfigureZombie() pour configurer toutes les propriétés
    ConfigureZombie(zombie)
    
    -- ========================================================================
    -- ENREGISTREMENT DU ZOMBIE
    -- ========================================================================
    -- Ajoute le zombie à la table spawnedZombies pour le suivi
    -- On crée une table avec:
    --   handle: l'identifiant du zombie
    --   zoneIndex: l'index de la zone à laquelle appartient le zombie
    --   zoneName: le nom de la zone
    --   spawnCoords: les coordonnées de spawn
    table.insert(spawnedZombies, {
        handle = zombie,
        zoneIndex = zoneIndex,
        zoneName = zone.name,
        spawnCoords = vector3(spawnX, spawnY, spawnZ)
    })
    
    -- ========================================================================
    -- NETTOYAGE DE LA MÉMOIRE
    -- ========================================================================
    -- Indique au jeu que le modèle n'est plus nécessaire
    SetModelAsNoLongerNeeded(modelHash)
    
    return zombie
end

-- ============================================================================
-- FONCTION: CleanupZombies()
-- DESCRIPTION: Supprime les zombies morts ou éloignés de leur zone
-- UTILITÉ: Évite les fuites mémoire et garde la table à jour
-- ============================================================================
local function CleanupZombies()
    -- Boucle à travers la table spawnedZombies en sens inverse
    -- On boucle en sens inverse pour pouvoir supprimer des éléments sans problème
    for i = #spawnedZombies, 1, -1 do
        -- Récupère les données du zombie à la position i
        local zombieData = spawnedZombies[i]
        local zombie = zombieData.handle
        
        -- Flag pour indiquer si le zombie doit être supprimé
        local shouldRemove = false
        
        -- Vérifie si le zombie n'existe plus OU s'il est mort
        if not DoesEntityExist(zombie) or IsEntityDead(zombie) then
            shouldRemove = true
        else
            -- Vérifie si le zombie s'est éloigné trop loin de sa zone
            local zoneIndex = zombieData.zoneIndex
            if zoneIndex and spawnZones[zoneIndex] then
                local zone = spawnZones[zoneIndex]
                local zombieCoords = GetEntityCoords(zombie)
                
                -- Calcule la distance entre le zombie et le centre de la zone
                local dx = zombieCoords.x - zone.coords.x
                local dy = zombieCoords.y - zone.coords.y
                local dz = zombieCoords.z - zone.coords.z
                local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
                
                -- Si le zombie est trop loin, le supprime
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
-- DESCRIPTION: Compte le nombre de zombies vivants dans une zone donnée
-- PARAMÈTRES:
--   zoneIndex: L'index de la zone dans la table spawnZones
-- RETOUR: Le nombre de zombies vivants dans la zone
-- ============================================================================
local function GetZombieCountInZone(zoneIndex)
    local count = 0
    for _, zombieData in ipairs(spawnedZombies) do
        -- Vérifie si le zombie appartient à cette zone ET s'il est vivant
        if zombieData.zoneIndex == zoneIndex and DoesEntityExist(zombieData.handle) and not IsEntityDead(zombieData.handle) then
            count = count + 1
        end
    end
    return count
end

-- ============================================================================
-- FONCTION: GetTotalZombieCount()
-- DESCRIPTION: Compte le nombre total de zombies vivants
-- RETOUR: Le nombre total de zombies vivants
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
-- FONCTION: DrawZoneMarkers()
-- DESCRIPTION: Affiche les marqueurs visuels des zones sur la map
-- UTILITÉ: Utile pour le debug et la configuration des zones
-- ============================================================================
local function DrawZoneMarkers()
    if not zoneSettings.showMarkers then
        return
    end
    
    for _, zone in ipairs(spawnZones) do
        if zone.enabled then
            -- Récupère les paramètres du marqueur
            local r, g, b, a = zoneSettings.markerColor[1], zoneSettings.markerColor[2], zoneSettings.markerColor[3], zoneSettings.markerColor[4]
            
            -- Affiche un marqueur circulaire au centre de la zone
            DrawMarker(
                1,  -- Type de marqueur (1 = cylindre)
                zone.coords.x,
                zone.coords.y,
                zone.coords.z,
                0.0, 0.0, 0.0,  -- Direction
                0.0, 0.0, 0.0,  -- Rotation
                zone.radius * 2, zone.radius * 2, 5.0,  -- Taille
                r, g, b, a,     -- Couleur
                false,           -- Bobbing
                true,            -- FaceCamera
                2,               -- p19
                false,           -- RotateToCamera
                nil, nil, false  -- TextureDict, TextureName, DrawOnEnts
            )
        end
    end
end

-- ============================================================================
-- THREAD PRINCIPAL
-- DESCRIPTION: Boucle qui s'exécute en continu pour gérer les zombies par zone
-- ============================================================================
Citizen.CreateThread(function()
    -- Initialise les temps de spawn pour chaque zone
    for i, zone in ipairs(spawnZones) do
        lastSpawnTimeByZone[i] = 0
    end
    
    -- Boucle infinie: le thread s'exécute indéfiniment
    while true do
        -- Pause le thread selon l'intervalle défini dans la configuration
        Citizen.Wait(threadSettings.threadInterval)
        
        -- Nettoie les zombies morts ou éloignés
        CleanupZombies()
        
        -- Affiche les marqueurs des zones si activé
        DrawZoneMarkers()
        
        -- Parcourt chaque zone de spawn
        for zoneIndex, zone in ipairs(spawnZones) do
            -- Vérifie que la zone est activée
            if zone.enabled then
                -- Récupère l'intervalle de spawn pour cette zone (ou utilise la valeur par défaut)
                local spawnInterval = zone.spawnInterval or zoneSettings.spawnInterval
                
                -- Récupère le temps actuel en millisecondes
                local currentTime = GetGameTimer()
                
                -- Vérifie si l'intervalle de spawn est écoulé pour cette zone
                if (currentTime - (lastSpawnTimeByZone[zoneIndex] or 0)) >= spawnInterval then
                    -- Compte les zombies actuels dans cette zone
                    local currentZombieCount = GetZombieCountInZone(zoneIndex)
                    
                    -- Vérifie si on peut spawner plus de zombies dans cette zone
                    if currentZombieCount < zone.maxZombies then
                        -- Spawn un zombie dans la zone
                        SpawnZombieInZone(zone, zoneIndex)
                    end
                    
                    -- Met à jour le temps du dernier spawn pour cette zone
                    lastSpawnTimeByZone[zoneIndex] = currentTime
                end
            end
        end
    end
end)

-- ============================================================================
-- COMMANDE: /spawnzombie
-- DESCRIPTION: Permet au joueur de spawner des zombies manuellement
-- UTILISATION: /spawnzombie [nombre] [zoneIndex]
-- EXEMPLE: /spawnzombie 5 1 (spawn 5 zombies dans la zone 1)
-- ============================================================================
RegisterCommand("spawnzombie", function(source, args, rawCommand)
    -- Récupère le nombre de zombies à spawner depuis les arguments
    local count = tonumber(args[1]) or 1
    
    -- Récupère l'index de la zone (par défaut 1)
    local zoneIndex = tonumber(args[2]) or 1
    
    -- Vérifie que la zone existe
    if not spawnZones[zoneIndex] then
        TriggerEvent("chat:addMessage", {
            color = messages.colors.error,
            args = {messages.prefix, "Zone " .. zoneIndex .. " n'existe pas"}
        })
        return
    end
    
    -- Boucle pour spawner le nombre de zombies demandé
    for i = 1, count do
        SpawnZombieInZone(spawnZones[zoneIndex], zoneIndex)
    end
    
    -- Affiche un message de confirmation
    TriggerEvent("chat:addMessage", {
        color = messages.colors.success,
        args = {messages.prefix, "Spawned " .. count .. " zombie(s) in zone " .. zoneIndex}
    })
end)

-- ============================================================================
-- COMMANDE: /setzombiestats
-- DESCRIPTION: Permet de modifier les statistiques des zombies
-- UTILISATION: /setzombiestats [stat] [valeur]
-- EXEMPLE: /setzombiestats health 300 (augmente la santé à 300)
-- ============================================================================
RegisterCommand("setzombiestats", function(source, args, rawCommand)
    -- Vérifie si l'utilisateur a fourni au moins 2 arguments
    -- #args = nombre d'arguments fournis
    if #args < 2 then
        -- Affiche un message d'erreur avec les instructions d'utilisation
        TriggerEvent("chat:addMessage", {
            color = messages.colors.error,
            args = {messages.prefix, "Usage: /setzombiestats [stat] [value]"}
        })
        return  -- Arrête l'exécution de la fonction
    end
    
    -- Récupère le nom de la statistique et le convertit en minuscules
    -- :lower() convertit le texte en minuscules
    local stat = args[1]:lower()
    
    -- Récupère la valeur et la convertit en nombre
    local value = tonumber(args[2])
    
    -- Vérifie si la statistique existe dans zombieConfig
    -- zombieConfig[stat] == nil signifie: la clé n'existe pas
    if zombieConfig[stat] == nil then
        -- Affiche un message d'erreur avec les statistiques disponibles
        TriggerEvent("chat:addMessage", {
            color = messages.colors.error,
            args = {messages.prefix, "Invalid stat. Available stats: health, damageModifier, accuracy, speed, aggression"}
        })
        return
    end
    
    -- Met à jour la configuration globale avec la nouvelle valeur
    zombieConfig[stat] = value
    
    -- Met à jour tous les zombies existants avec la nouvelle statistique
    -- ipairs() parcourt la table spawnedZombies
    for _, zombieData in ipairs(spawnedZombies) do
        local zombie = zombieData.handle
        
        -- Vérifie que le zombie existe toujours
        if DoesEntityExist(zombie) then
            -- Applique la modification selon la statistique
            if stat == "health" then
                -- Change la santé du zombie
                SetEntityHealth(zombie, value)
            elseif stat == "speed" then
                -- Change la vitesse de déplacement
                SetPedMoveRateOverride(zombie, value)
            elseif stat == "accuracy" then
                -- Change la précision du tir
                SetPedAccuracy(zombie, math.floor(value * 100))
            end
        end
    end
    
    -- Affiche un message de confirmation
    TriggerEvent("chat:addMessage", {
        color = messages.colors.success,
        args = {messages.prefix, "Updated " .. stat .. " to " .. tostring(value)}
    })
end)

-- ============================================================================
-- COMMANDE: /zombiestatus
-- DESCRIPTION: Affiche le nombre de zombies actuellement en jeu par zone
-- UTILISATION: /zombiestatus
-- ============================================================================
RegisterCommand("zombiestatus", function(source, args, rawCommand)
    -- Compte le nombre total de zombies vivants
    local totalZombies = GetTotalZombieCount()
    
    -- Affiche les statistiques globales
    TriggerEvent("chat:addMessage", {
        color = messages.colors.info,
        args = {messages.prefix, "Statistiques des zombies:"}
    })
    TriggerEvent("chat:addMessage", {
        color = messages.colors.info,
        args = {"", "Total: " .. totalZombies}
    })
    
    -- Affiche les statistiques par zone
    for zoneIndex, zone in ipairs(spawnZones) do
        local zoneCount = GetZombieCountInZone(zoneIndex)
        local status = zone.enabled and "✓" or "✗"
        TriggerEvent("chat:addMessage", {
            color = messages.colors.info,
            args = {"", status .. " Zone " .. zoneIndex .. " (" .. zone.name .. "): " .. zoneCount .. "/" .. zone.maxZombies}
        })
    end
end)

-- ============================================================================
-- COMMANDE: /listzones
-- DESCRIPTION: Affiche la liste de toutes les zones configurées
-- UTILISATION: /listzones
-- ============================================================================
RegisterCommand("listzones", function(source, args, rawCommand)
    TriggerEvent("chat:addMessage", {
        color = messages.colors.info,
        args = {messages.prefix, "Zones configurées:"}
    })
    
    for zoneIndex, zone in ipairs(spawnZones) do
        local status = zone.enabled and "✓ Activée" or "✗ Désactivée"
        TriggerEvent("chat:addMessage", {
            color = messages.colors.info,
            args = {"", "Zone " .. zoneIndex .. ": " .. zone.name .. " - " .. status .. " (" .. zone.maxZombies .. " max)"}
        })
    end
end)

-- ============================================================================
-- COMMANDE: /togglezone
-- DESCRIPTION: Active ou désactive une zone
-- UTILISATION: /togglezone [zoneIndex]
-- EXEMPLE: /togglezone 1 (bascule la zone 1)
-- ============================================================================
RegisterCommand("togglezone", function(source, args, rawCommand)
    local zoneIndex = tonumber(args[1])
    
    if not zoneIndex or not spawnZones[zoneIndex] then
        TriggerEvent("chat:addMessage", {
            color = messages.colors.error,
            args = {messages.prefix, "Usage: /togglezone [zoneIndex]"}
        })
        return
    end
    
    -- Bascule l'état de la zone
    spawnZones[zoneIndex].enabled = not spawnZones[zoneIndex].enabled
    
    local newStatus = spawnZones[zoneIndex].enabled and "activée" or "désactivée"
    TriggerEvent("chat:addMessage", {
        color = messages.colors.success,
        args = {messages.prefix, "Zone " .. zoneIndex .. " (" .. spawnZones[zoneIndex].name .. ") " .. newStatus}
    })
end)

-- ============================================================================
-- COMMANDE: /togglemarkers
-- DESCRIPTION: Active ou désactive l'affichage des marqueurs des zones
-- UTILISATION: /togglemarkers
-- ============================================================================
RegisterCommand("togglemarkers", function(source, args, rawCommand)
    zoneSettings.showMarkers = not zoneSettings.showMarkers
    
    local status = zoneSettings.showMarkers and "activés" or "désactivés"
    TriggerEvent("chat:addMessage", {
        color = messages.colors.success,
        args = {messages.prefix, "Marqueurs des zones " .. status}
    })
end)

-- ============================================================================
-- COMMANDE: /addzonemarker
-- DESCRIPTION: Ajoute un marqueur à la position actuelle du joueur
-- UTILISATION: /addzonemarker [nom] [radius] [maxZombies]
-- EXEMPLE: /addzonemarker "Forêt Sombre" 100 5
-- ============================================================================
RegisterCommand("addzonemarker", function(source, args, rawCommand)
    if #args < 3 then
        TriggerEvent("chat:addMessage", {
            color = messages.colors.error,
            args = {messages.prefix, "Usage: /addzonemarker [name] [radius] [maxZombies]"}
        })
        return
    end
    
    -- Récupère la position du joueur
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Récupère les paramètres
    local zoneName = args[1]
    local radius = tonumber(args[2]) or 100.0
    local maxZombies = tonumber(args[3]) or 5
    
    -- Affiche les coordonnées pour que le joueur les copie dans config.lua
    TriggerEvent("chat:addMessage", {
        color = messages.colors.info,
        args = {messages.prefix, "Nouvelle zone détectée:"}
    })
    TriggerEvent("chat:addMessage", {
        color = messages.colors.info,
        args = {"", "{"}
    })
    TriggerEvent("chat:addMessage", {
        color = messages.colors.info,
        args = {"", "    name = \"" .. zoneName .. "\","}
    })
    TriggerEvent("chat:addMessage", {
        color = messages.colors.info,
        args = {"", "    coords = vector3(" .. string.format("%.1f", playerCoords.x) .. ", " .. string.format("%.1f", playerCoords.y) .. ", " .. string.format("%.1f", playerCoords.z) .. "),"}
    })
    TriggerEvent("chat:addMessage", {
        color = messages.colors.info,
        args = {"", "    radius = " .. radius .. ","}
    })
    TriggerEvent("chat:addMessage", {
        color = messages.colors.info,
        args = {"", "    maxZombies = " .. maxZombies .. ","}
    })
    TriggerEvent("chat:addMessage", {
        color = messages.colors.info,
        args = {"", "    enabled = true"}
    })
    TriggerEvent("chat:addMessage", {
        color = messages.colors.info,
        args = {"", "}"}
    })
end)

-- ============================================================================
-- ÉVÉNEMENT: onResourceStop
-- DESCRIPTION: S'exécute quand la ressource est arrêtée
-- UTILITÉ: Nettoie tous les zombies pour éviter les bugs
-- ============================================================================
AddEventHandler('onResourceStop', function(resourceName)
    -- Vérifie que c'est bien cette ressource qui s'arrête
    -- GetCurrentResourceName() retourne le nom de cette ressource
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Parcourt tous les zombies et les supprime
    for _, zombieData in ipairs(spawnedZombies) do
        -- Vérifie que le zombie existe
        if DoesEntityExist(zombieData.handle) then
            -- Supprime le zombie du jeu
            DeleteEntity(zombieData.handle)
        end
    end
end)
