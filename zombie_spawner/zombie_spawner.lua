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

-- Copie la configuration dans une variable locale pour utilisation rapide
local zombieConfig = Config.zombieStats
local zombieModels = Config.zombieModels
local combatBehavior = Config.combatBehavior
local relationships = Config.relationships
local threadSettings = Config.threadSettings
local randomSpawn = Config.randomSpawn

-- Variables pour tracker les zombies aléatoires
local lastRandomSpawnTime = 0

-- ============================================================================
-- FONCTION: ConfigureZombie()
-- DESCRIPTION: Configure les propriétés et relations d'un zombie
-- PARAMÈTRES:
--   zombie: Le handle du zombie à configurer
-- UTILITÉ: Évite la duplication de code entre SpawnZombie et SpawnRandomZombie
-- ============================================================================
local function ConfigureZombie(zombie)
    SetEntityHealth(zombie, zombieConfig.health)
    SetPedAccuracy(zombie, math.floor(zombieConfig.accuracy * 100))
    SetPedMoveRateOverride(zombie, zombieConfig.speed)
    
    -- Configure le comportement au combat
    SetPedCombatAttributes(zombie, combatBehavior.alwaysFight, true)
    SetPedCombatAttributes(zombie, combatBehavior.useMeleeWeapons, true)
    SetPedCombatAbility(zombie, combatBehavior.combatAbility)
    SetPedCombatRange(zombie, combatBehavior.combatRange)
    SetPedCombatMovement(zombie, combatBehavior.combatMovement)
    
    -- Configure les relations
    SetPedRelationshipGroupHash(zombie, GetHashKey("HATES_PLAYER"))
    SetRelationshipBetweenGroups(relationships.playerRelationship, GetHashKey("HATES_PLAYER"), GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(relationships.playerRelationship, GetHashKey("PLAYER"), GetHashKey("HATES_PLAYER"))
    SetRelationshipBetweenGroups(relationships.civilianRelationship, GetHashKey("HATES_PLAYER"), GetHashKey("CIVILIAN"))
    SetRelationshipBetweenGroups(relationships.civilianRelationship, GetHashKey("CIVILIAN"), GetHashKey("HATES_PLAYER"))
    SetRelationshipBetweenGroups(relationships.gangRelationship, GetHashKey("HATES_PLAYER"), GetHashKey("GANG"))
    SetRelationshipBetweenGroups(relationships.gangRelationship, GetHashKey("GANG"), GetHashKey("HATES_PLAYER"))
    SetRelationshipBetweenGroups(relationships.animalRelationship, GetHashKey("HATES_PLAYER"), GetHashKey("ANIMAL"))
    SetRelationshipBetweenGroups(relationships.animalRelationship, GetHashKey("ANIMAL"), GetHashKey("HATES_PLAYER"))
    SetRelationshipBetweenGroups(relationships.wildAnimalRelationship, GetHashKey("HATES_PLAYER"), GetHashKey("WILD_ANIMAL"))
    SetRelationshipBetweenGroups(relationships.wildAnimalRelationship, GetHashKey("WILD_ANIMAL"), GetHashKey("HATES_PLAYER"))
end

-- ============================================================================
-- FONCTION: SpawnZombie()
-- DESCRIPTION: Crée un zombie à une position aléatoire autour du joueur
-- RETOUR: Le handle (identifiant) du zombie créé
-- ============================================================================
local function SpawnZombie()
    -- Récupère le personnage du joueur
    local playerPed = PlayerPedId()
    
    -- Récupère les coordonnées (position X, Y, Z) du joueur
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Choisit un modèle de zombie au hasard dans la table zombieModels
    -- math.random(#zombieModels) génère un nombre aléatoire entre 1 et le nombre de modèles
    -- GetHashKey() convertit le nom du modèle en code numérique (hash)
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
    -- CALCUL DE LA POSITION DE SPAWN
    -- ========================================================================
    -- Crée une position aléatoire autour du joueur
    -- GetOffsetFromEntityInWorldCoords() calcule une position relative au joueur
    -- math.random() génère un nombre aléatoire entre 0 et 1
    -- (math.random() - 0.5) * zombieConfig.spawnRadius * 2 = position aléatoire
    -- 1. Génère d'abord les coordonnées X et Y
    local spawnCoords = GetOffsetFromEntityInWorldCoords(
        playerPed,
        (math.random() - 0.5) * zombieConfig.spawnRadius * 2,
        (math.random() - 0.5) * zombieConfig.spawnRadius * 2,
        0.0  -- Z temporaire, sera remplacé
    )

    -- 2. Récupère la VRAIE altitude du sol à ces coordonnées
    local success, groundZ = GetGroundZFor_3dCoord(
        spawnCoords.x, 
        spawnCoords.y, 
        spawnCoords.z,  -- Z de départ (n'importe quelle valeur)
        false           -- false = ignore l'eau
    )

    -- 3. Met à jour les coordonnées avec la vraie altitude
    if success then
        spawnCoords.z = groundZ
        -- Maintenant spawnCoords.z contient la vraie altitude du sol !
    end
    
    -- ========================================================================
    -- CRÉATION DU ZOMBIE
    -- ========================================================================
    -- CreatePed() crée un nouveau personnage (zombie) dans le jeu
    -- Paramètres:
    --   modelHash: le modèle du zombie
    --   spawnCoords.x, spawnCoords.y, spawnCoords.z: position X, Y, Z
    --   0.0: orientation (direction où regarde le zombie)
    --   true: isNetwork (synchronisé sur le réseau)
    --   true: bScriptHostPed (géré par le script)
    local zombie = CreatePed(
        modelHash,
        spawnCoords.x,
        spawnCoords.y,
        spawnCoords.z,
        0.0,
        true,
        true
    )
    
    -- ========================================================================
    -- CONFIGURATION DU ZOMBIE
    -- ========================================================================
    -- Appelle la fonction ConfigureZombie() pour configurer toutes les propriétés
    -- Cela évite la duplication de code avec SpawnRandomZombie()
    ConfigureZombie(zombie)
    
    -- ========================================================================
    -- ENREGISTREMENT DU ZOMBIE
    -- ========================================================================
    
    -- Ajoute le zombie à la table spawnedZombies pour le suivi
    -- table.insert() ajoute un nouvel élément à la fin d'une table
    -- On crée une table avec:
    --   handle: l'identifiant du zombie
    --   lastPos: sa dernière position connue
    --   isRandom: false (ce zombie n'est pas aléatoire)
    table.insert(spawnedZombies, {
        handle = zombie,
        lastPos = spawnCoords,
        isRandom = false
    })
    
    -- ========================================================================
    -- NETTOYAGE DE LA MÉMOIRE
    -- ========================================================================
    
    -- Indique au jeu que le modèle n'est plus nécessaire
    -- Cela libère de la mémoire RAM
    SetModelAsNoLongerNeeded(modelHash)
    
    -- Retourne l'identifiant du zombie créé
    return zombie
end

-- ============================================================================
-- FONCTION: CleanupZombies()
-- DESCRIPTION: Supprime les zombies morts de la table de suivi
-- UTILITÉ: Évite les fuites mémoire et garde la table à jour
-- ============================================================================
local function CleanupZombies()
    -- Boucle à travers la table spawnedZombies en sens inverse
    -- On boucle en sens inverse pour pouvoir supprimer des éléments sans problème
    -- #spawnedZombies = nombre d'éléments dans la table
    for i = #spawnedZombies, 1, -1 do
        -- Récupère les données du zombie à la position i
        local zombie = spawnedZombies[i]
        
        -- Vérifie si le zombie n'existe plus OU s'il est mort
        -- DoesEntityExist() retourne true si l'entité existe
        -- IsEntityDead() retourne true si l'entité est morte
        if not DoesEntityExist(zombie.handle) or IsEntityDead(zombie.handle) then
            
            -- Si le zombie existe encore, le supprime du jeu
            if DoesEntityExist(zombie.handle) then
                DeleteEntity(zombie.handle)
            end
            
            -- Supprime le zombie de la table de suivi
            -- table.remove() enlève un élément à une position donnée
            table.remove(spawnedZombies, i)
        end
    end
end

-- ============================================================================
-- FONCTION: GetRandomZombieCount()
-- DESCRIPTION: Compte le nombre de zombies aléatoires vivants
-- RETOUR: Le nombre de zombies aléatoires actuellement vivants
-- ============================================================================
local function GetRandomZombieCount()
    local count = 0
    for _, zombie in ipairs(spawnedZombies) do
        -- Vérifie si c'est un zombie aléatoire ET s'il est vivant
        if zombie.isRandom and DoesEntityExist(zombie.handle) and not IsEntityDead(zombie.handle) then
            count = count + 1
        end
    end
    return count
end

-- ============================================================================
-- FONCTION: GetRandomZombieCountInRadius()
-- DESCRIPTION: Compte les zombies aléatoires dans un rayon autour du joueur
-- PARAMÈTRES:
--   radius: Le rayon de recherche en mètres (optionnel, par défaut config)
-- RETOUR: Le nombre de zombies aléatoires dans le rayon
-- ============================================================================
local function GetRandomZombieCountInRadius(radius)
    -- Rayon par défaut depuis la configuration si non spécifié
    radius = radius or randomSpawn.defaultSearchRadius
    
    -- Récupère la position du joueur UNE SEULE FOIS
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local count = 0
    local radiusSq = radius * radius  -- Pré-calcule le carré du rayon pour optimisation
    
    -- Parcourt tous les zombies
    for _, zombie in ipairs(spawnedZombies) do
        -- Vérifie si c'est un zombie aléatoire ET s'il est vivant
        if zombie.isRandom and DoesEntityExist(zombie.handle) and not IsEntityDead(zombie.handle) then
            -- Récupère la position du zombie
            local zombieCoords = GetEntityCoords(zombie.handle)
            
            -- Calcule la distance au carré (plus rapide que la racine carrée)
            local dx = playerCoords.x - zombieCoords.x
            local dy = playerCoords.y - zombieCoords.y
            local dz = playerCoords.z - zombieCoords.z
            local distanceSq = dx * dx + dy * dy + dz * dz
            
            -- Vérifie si le zombie est dans le rayon
            if distanceSq <= radiusSq then
                count = count + 1
            end
        end
    end
    
    return count
end

-- ============================================================================
-- FONCTION: GetRandomZombiesInRadius()
-- DESCRIPTION: Retourne la liste des zombies aléatoires dans un rayon
-- PARAMÈTRES:
--   radius: Le rayon de recherche en mètres (optionnel, par défaut config)
-- RETOUR: Une table avec les zombies trouvés et leurs distances
-- ============================================================================
local function GetRandomZombiesInRadius(radius)
    -- Rayon par défaut depuis la configuration si non spécifié
    radius = radius or randomSpawn.defaultSearchRadius
    
    -- Récupère la position du joueur UNE SEULE FOIS
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local zombiesInRadius = {}
    local radiusSq = radius * radius  -- Pré-calcule le carré du rayon pour optimisation
    
    -- Parcourt tous les zombies
    for _, zombie in ipairs(spawnedZombies) do
        -- Vérifie si c'est un zombie aléatoire ET s'il est vivant
        if zombie.isRandom and DoesEntityExist(zombie.handle) and not IsEntityDead(zombie.handle) then
            -- Récupère la position du zombie
            local zombieCoords = GetEntityCoords(zombie.handle)
            
            -- Calcule la distance au carré (plus rapide que la racine carrée)
            local dx = playerCoords.x - zombieCoords.x
            local dy = playerCoords.y - zombieCoords.y
            local dz = playerCoords.z - zombieCoords.z
            local distanceSq = dx * dx + dy * dy + dz * dz
            
            -- Vérifie si le zombie est dans le rayon
            if distanceSq <= radiusSq then
                -- Calcule la vraie distance pour l'affichage
                local distance = math.sqrt(distanceSq)
                
                -- Ajoute le zombie à la liste avec sa distance
                table.insert(zombiesInRadius, {
                    handle = zombie.handle,
                    distance = distance,
                    coords = zombieCoords
                })
            end
        end
    end
    
    -- Trie les zombies par distance (du plus proche au plus loin)
    table.sort(zombiesInRadius, function(a, b)
        return a.distance < b.distance
    end)
    
    return zombiesInRadius
end

-- ============================================================================
-- FONCTION: SpawnRandomZombie()
-- DESCRIPTION: Crée un zombie à une position aléatoire sur la map
-- RETOUR: Le handle (identifiant) du zombie créé
-- ============================================================================
local function SpawnRandomZombie()
    -- Récupère le personnage du joueur
    local playerPed = PlayerPedId()
    
    -- Récupère les coordonnées du joueur
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Génère une position aléatoire dans le rayon défini
    -- Calcule un angle aléatoire (0 à 360 degrés)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(100)
    end

    -- Crée le zombie avec des paramètres minimaux
    local zombie = CreatePed(
        modelHash,
        playerCoords.x + 2.0,  -- 2 mètres devant le joueur
        playerCoords.y,
        playerCoords.z,
        0.0,
        true,
        true
    )

    -- Configuration de base
    SetEntityHealth(zombie, 100.0)
    SetPedRelationshipGroupHash(zombie, GetHashKey("HATES_PLAYER"))

    -- Ajoute à la liste
    table.insert(spawnedZombies, {
        handle = zombie,
        lastPos = playerCoords,
        isRandom = false
    })

    -- Libère la mémoire
    SetModelAsNoLongerNeeded(modelHash)

    return zombie
end
            local currentTime = GetGameTimer()
            
            -- Vérifie si l'intervalle de spawn est écoulé
            if (currentTime - lastRandomSpawnTime) >= randomSpawn.spawnInterval then
                -- Génère un nombre aléatoire pour la chance de spawn
                -- math.random() génère un nombre entre 0 et 1
                if math.random() < randomSpawn.spawnChance then
                    -- Récupère le nombre actuel de zombies aléatoires vivants
                    local currentRandomCount = GetRandomZombieCount()
                    
                    -- Vérifie si on peut spawner plus de zombies aléatoires
                    if currentRandomCount < randomSpawn.maxRandomZombies then
                        -- Spawn un zombie aléatoire
                        SpawnRandomZombie()
                    end
                end
                
                -- Met à jour le temps du dernier spawn
                lastRandomSpawnTime = currentTime
            end
        end
    end
end)

-- ============================================================================
-- COMMANDE: /spawnzombie
-- DESCRIPTION: Permet au joueur de spawner des zombies manuellement
-- UTILISATION: /spawnzombie [nombre]
-- EXEMPLE: /spawnzombie 5 (spawn 5 zombies)
-- ============================================================================
RegisterCommand("spawnzombie", function(source, args, rawCommand)
    -- Récupère le nombre de zombies à spawner depuis les arguments
    -- tonumber() convertit le texte en nombre
    -- "or 1" signifie: si aucun argument, spawn 1 zombie par défaut
    local count = tonumber(args[1]) or 1
    
    -- Boucle pour spawner le nombre de zombies demandé
    -- for i = 1, count: boucle de 1 jusqu'à count
    for i = 1, count do
        SpawnZombie()
    end
    
    -- Affiche un message de confirmation dans le chat du jeu
    -- Utilise les paramètres de configuration pour les couleurs et le préfixe
    TriggerEvent("chatMessage", messages.prefix, messages.colors.success, "Spawned " .. count .. " zombie(s)")
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
    TriggerEvent("chatMessage", messages.prefix, messages.colors.error, "Usage: /setzombiestats [stat] [value]")
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
        TriggerEvent("chatMessage", messages.prefix, messages.colors.error, "Invalid stat. Available stats: health, damageModifier, accuracy, speed, aggression, spawnRadius, maxZombies")
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
    TriggerEvent("chatMessage", messages.prefix, messages.colors.success, "Updated " .. stat .. " to " .. tostring(value))
end)

-- ============================================================================
-- COMMANDE: /randomspawn
-- DESCRIPTION: Active/désactive le spawn aléatoire de zombies sur la map
-- UTILISATION: /randomspawn [on/off]
-- EXEMPLE: /randomspawn on (active le spawn aléatoire)
-- ============================================================================
RegisterCommand("randomspawn", function(source, args, rawCommand)
    -- Récupère l'argument (on ou off)
    local action = args[1]
    
    if not action then
        -- Affiche l'état actuel du spawn aléatoire
        local status = randomSpawn.enabled and "activé" or "désactivé"
        TriggerEvent("chatMessage", messages.prefix, messages.colors.info, "Spawn aléatoire est actuellement " .. status)
        return
    end
    
    action = action:lower()
    
    if action == "on" or action == "true" or action == "1" then
        -- Active le spawn aléatoire
        randomSpawn.enabled = true
        lastRandomSpawnTime = GetGameTimer()
        TriggerEvent("chatMessage", messages.prefix, messages.colors.success, "Spawn aléatoire activé!")
    elseif action == "off" or action == "false" or action == "0" then
        -- Désactive le spawn aléatoire
        randomSpawn.enabled = false
        TriggerEvent("chatMessage", messages.prefix, messages.colors.success, "Spawn aléatoire désactivé!")
    else
        -- Argument invalide
        TriggerEvent("chatMessage", messages.prefix, messages.colors.error, "Usage: /randomspawn [on/off]")
    end
end)

-- ============================================================================
-- COMMANDE: /randomspawnstats
-- DESCRIPTION: Affiche et modifie les paramètres du spawn aléatoire
-- UTILISATION: /randomspawnstats [paramètre] [valeur]
-- EXEMPLE: /randomspawnstats maxRandomZombies 10
-- ============================================================================
RegisterCommand("randomspawnstats", function(source, args, rawCommand)
    if #args < 1 then
        -- Affiche les paramètres actuels
        TriggerEvent("chatMessage", messages.prefix, messages.colors.info, "Paramètres du spawn aléatoire:")
        TriggerEvent("chatMessage", "", messages.colors.info, "spawnInterval: " .. randomSpawn.spawnInterval .. "ms")
        TriggerEvent("chatMessage", "", messages.colors.info, "minDistance: " .. randomSpawn.minDistance .. "m")
        TriggerEvent("chatMessage", "", messages.colors.info, "maxDistance: " .. randomSpawn.maxDistance .. "m")
        TriggerEvent("chatMessage", "", messages.colors.info, "maxRandomZombies: " .. randomSpawn.maxRandomZombies)
        TriggerEvent("chatMessage", "", messages.colors.info, "spawnChance: " .. (randomSpawn.spawnChance * 100) .. "%")
        return
    end
    
    local param = args[1]:lower()
    local value = tonumber(args[2])
    
    if not value then
        TriggerEvent("chatMessage", messages.prefix, messages.colors.error, "Usage: /randomspawnstats [param] [value]")
        return
    end
    
    -- Modifie le paramètre demandé
    if param == "spawninterval" then
        randomSpawn.spawnInterval = value
        TriggerEvent("chatMessage", messages.prefix, messages.colors.success, "spawnInterval mis à jour à " .. value .. "ms")
    elseif param == "mindistance" then
        randomSpawn.minDistance = value
        TriggerEvent("chatMessage", messages.prefix, messages.colors.success, "minDistance mis à jour à " .. value .. "m")
    elseif param == "maxdistance" then
        randomSpawn.maxDistance = value
        TriggerEvent("chatMessage", messages.prefix, messages.colors.success, "maxDistance mis à jour à " .. value .. "m")
    elseif param == "maxrandomzombies" then
        randomSpawn.maxRandomZombies = value
        TriggerEvent("chatMessage", messages.prefix, messages.colors.success, "maxRandomZombies mis à jour à " .. value)
    elseif param == "spawnchance" then
        randomSpawn.spawnChance = math.min(value / 100, 1.0)
        TriggerEvent("chatMessage", messages.prefix, messages.colors.success, "spawnChance mis à jour à " .. (randomSpawn.spawnChance * 100) .. "%")
    else
        TriggerEvent("chatMessage", messages.prefix, messages.colors.error, "Paramètre invalide. Disponibles: spawnInterval, minDistance, maxDistance, maxRandomZombies, spawnChance")
    end
end)

-- ============================================================================
-- COMMANDE: /zombiestatus
-- DESCRIPTION: Affiche le nombre de zombies actuellement en jeu
-- UTILISATION: /zombiestatus
-- ============================================================================
RegisterCommand("zombiestatus", function(source, args, rawCommand)
    -- Compte le nombre total de zombies vivants
    local totalZombies = 0
    local randomZombies = GetRandomZombieCount()
    
    for _, zombie in ipairs(spawnedZombies) do
        if DoesEntityExist(zombie.handle) and not IsEntityDead(zombie.handle) then
            totalZombies = totalZombies + 1
        end
    end
    
    local manualZombies = totalZombies - randomZombies
    
    -- Affiche les statistiques
    TriggerEvent("chatMessage", messages.prefix, messages.colors.info, "Statistiques des zombies:")
    TriggerEvent("chatMessage", "", messages.colors.info, "Total: " .. totalZombies .. "/" .. zombieConfig.maxZombies)
    TriggerEvent("chatMessage", "", messages.colors.info, "Manuels: " .. manualZombies)
    TriggerEvent("chatMessage", "", messages.colors.info, "Aléatoires: " .. randomZombies .. "/" .. randomSpawn.maxRandomZombies)
end)

-- ============================================================================
-- COMMANDE: /zombiesradius
-- DESCRIPTION: Affiche le nombre de zombies aléatoires dans un rayon
-- UTILISATION: /zombiesradius [rayon]
-- EXEMPLE: /zombiesradius 100 (affiche les zombies dans un rayon de 100m)
-- ============================================================================
RegisterCommand("zombiesradius", function(source, args, rawCommand)
    -- Récupère le rayon depuis les arguments (par défaut 100 mètres)
    local radius = tonumber(args[1]) or 100.0
    
    -- Compte les zombies aléatoires dans le rayon
    local count = GetRandomZombieCountInRadius(radius)
    
    -- Affiche le résultat
    TriggerEvent("chatMessage", messages.prefix, messages.colors.info, "Zombies aléatoires dans un rayon de " .. radius .. "m: " .. count)
end)

-- ============================================================================
-- COMMANDE: /zombieslist
-- DESCRIPTION: Affiche la liste des zombies aléatoires proches avec distances
-- UTILISATION: /zombieslist [rayon]
-- EXEMPLE: /zombieslist 150 (affiche les zombies dans un rayon de 150m)
-- ============================================================================
RegisterCommand("zombieslist", function(source, args, rawCommand)
    -- Récupère le rayon depuis les arguments (par défaut 100 mètres)
    local radius = tonumber(args[1]) or 100.0
    
    -- Récupère la liste des zombies dans le rayon
    local zombies = GetRandomZombiesInRadius(radius)
    
    -- Affiche le titre
    TriggerEvent("chatMessage", messages.prefix, messages.colors.info, "Zombies aléatoires dans un rayon de " .. radius .. "m:")
    
    -- Affiche chaque zombie avec sa distance
    if #zombies == 0 then
        TriggerEvent("chatMessage", "", messages.colors.info, "Aucun zombie trouvé")
    else
        for i, zombie in ipairs(zombies) do
            -- Arrondit la distance à 2 décimales
            local distance = string.format("%.2f", zombie.distance)
            TriggerEvent("chatMessage", "", messages.colors.info, i .. ". Distance: " .. distance .. "m")
        end
    end
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
