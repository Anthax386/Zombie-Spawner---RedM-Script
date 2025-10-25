-- ============================================================================
-- IMPORT DE LA CONFIGURATION
-- ============================================================================
-- Charge le fichier config.lua qui contient tous les paramètres
require 'config'

-- ============================================================================
-- VARIABLES GLOBALES
-- ============================================================================
local spawnedZombies = {}

-- Copie la configuration dans une variable locale pour utilisation rapide
local zombieConfig = Config.zombieStats
local zombieModels = Config.zombieModels
local combatBehavior = Config.combatBehavior
local relationships = Config.relationships
local threadSettings = Config.threadSettings
local messages = Config.messages

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
    local spawnCoords = GetOffsetFromEntityInWorldCoords(
        playerPed,                                                    -- Référence: le joueur
        (math.random() - 0.5) * zombieConfig.spawnRadius * 2,       -- Décalage X aléatoire
        (math.random() - 0.5) * zombieConfig.spawnRadius * 2,       -- Décalage Y aléatoire
        0.0                                                           -- Pas de décalage en Z (hauteur)
    )
    
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
    -- CONFIGURATION DES PROPRIÉTÉS DU ZOMBIE
    -- ========================================================================
    
    -- Définit les points de vie du zombie
    -- SetEntityHealth() change la santé d'une entité (zombie, joueur, etc.)
    SetEntityHealth(zombie, zombieConfig.health)
    
    -- Définit la précision du tir du zombie
    -- SetPedAccuracy() prend une valeur entre 0 et 100
    -- math.floor() arrondit à l'entier inférieur
    SetPedAccuracy(zombie, math.floor(zombieConfig.accuracy * 100))
    
    -- Définit la vitesse de déplacement du zombie
    -- SetPedMoveRateOverride() change la vitesse de marche/course
    SetPedMoveRateOverride(zombie, zombieConfig.speed)
    
    -- ========================================================================
    -- CONFIGURATION DU COMPORTEMENT AU COMBAT
    -- ========================================================================
    
    -- SetPedCombatAttributes() configure le comportement de combat
    -- Paramètres: (ped, attribut, valeur)
    -- 46: "Always Fight" - le zombie combattra toujours
    SetPedCombatAttributes(zombie, 46, true)
    
    -- 5: "Can Use Melee Weapons" - le zombie peut utiliser des armes de mêlée
    SetPedCombatAttributes(zombie, 5, true)
    
    -- SetPedCombatAbility() définit le niveau de compétence au combat
    -- Utilise la valeur de la configuration
    SetPedCombatAbility(zombie, combatBehavior.combatAbility)
    
    -- SetPedCombatRange() définit la distance de combat préférée
    -- Utilise la valeur de la configuration
    SetPedCombatRange(zombie, combatBehavior.combatRange)
    
    -- SetPedCombatMovement() définit comment le zombie se déplace au combat
    -- Utilise la valeur de la configuration
    SetPedCombatMovement(zombie, combatBehavior.combatMovement)
    
    -- ========================================================================
    -- CONFIGURATION DES RELATIONS AVEC LE JOUEUR
    -- ========================================================================
    
    -- Crée un groupe de relation "HATES_PLAYER" (déteste le joueur)
    -- GetHashKey() convertit le nom du groupe en code numérique
    -- SetPedRelationshipGroupHash() assigne le zombie à ce groupe
    SetPedRelationshipGroupHash(zombie, GetHashKey("HATES_PLAYER"))
    
    -- Définit la relation entre le groupe "HATES_PLAYER" et "PLAYER"
    -- Utilise la valeur de la configuration
    SetRelationshipBetweenGroups(relationships.playerRelationship, GetHashKey("HATES_PLAYER"), GetHashKey("PLAYER"))
    
    -- Définit la relation inverse: le joueur déteste aussi les zombies
    SetRelationshipBetweenGroups(relationships.playerRelationship, GetHashKey("PLAYER"), GetHashKey("HATES_PLAYER"))
    
    -- ========================================================================
    -- CONFIGURATION DES RELATIONS AVEC LES PNJ
    -- ========================================================================
    
    -- Les zombies détestent les PNJ civils
    -- Utilise la valeur de la configuration
    SetRelationshipBetweenGroups(relationships.civilianRelationship, GetHashKey("HATES_PLAYER"), GetHashKey("CIVILIAN"))
    
    -- Les PNJ civils détestent aussi les zombies
    SetRelationshipBetweenGroups(relationships.civilianRelationship, GetHashKey("CIVILIAN"), GetHashKey("HATES_PLAYER"))
    
    -- Les zombies détestent aussi les PNJ de gang
    SetRelationshipBetweenGroups(relationships.gangRelationship, GetHashKey("HATES_PLAYER"), GetHashKey("GANG"))
    
    -- Les PNJ de gang détestent les zombies
    SetRelationshipBetweenGroups(relationships.gangRelationship, GetHashKey("GANG"), GetHashKey("HATES_PLAYER"))
    
    -- ========================================================================
    -- CONFIGURATION DES RELATIONS AVEC LES ANIMAUX
    -- ========================================================================
    
    -- Les zombies détestent les animaux domestiques (chevaux, chiens, etc.)
    -- Utilise la valeur de la configuration
    SetRelationshipBetweenGroups(relationships.animalRelationship, GetHashKey("HATES_PLAYER"), GetHashKey("ANIMAL"))
    
    -- Les animaux détestent aussi les zombies
    SetRelationshipBetweenGroups(relationships.animalRelationship, GetHashKey("ANIMAL"), GetHashKey("HATES_PLAYER"))
    
    -- Les zombies détestent les animaux sauvages
    SetRelationshipBetweenGroups(relationships.wildAnimalRelationship, GetHashKey("HATES_PLAYER"), GetHashKey("WILD_ANIMAL"))
    
    -- Les animaux sauvages détestent les zombies
    SetRelationshipBetweenGroups(relationships.wildAnimalRelationship, GetHashKey("WILD_ANIMAL"), GetHashKey("HATES_PLAYER"))
    
    -- ========================================================================
    -- ENREGISTREMENT DU ZOMBIE
    -- ========================================================================
    
    -- Ajoute le zombie à la table spawnedZombies pour le suivi
    -- table.insert() ajoute un nouvel élément à la fin d'une table
    -- On crée une table avec:
    --   handle: l'identifiant du zombie
    --   lastPos: sa dernière position connue
    table.insert(spawnedZombies, {
        handle = zombie,
        lastPos = spawnCoords
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
-- THREAD PRINCIPAL
-- DESCRIPTION: Boucle qui s'exécute en continu pour gérer les zombies
-- ============================================================================
Citizen.CreateThread(function()
    -- Boucle infinie: le thread s'exécute indéfiniment
    while true do
        -- Pause le thread selon l'intervalle défini dans la configuration
        -- Cela évite de surcharger le processeur
        Citizen.Wait(threadSettings.threadInterval)
        
        -- Nettoie les zombies morts
        CleanupZombies()
        
        -- Vérifie si on peut spawner plus de zombies
        -- #spawnedZombies = nombre actuel de zombies
        -- Si ce nombre est inférieur au maximum autorisé, spawn un nouveau zombie
        if #spawnedZombies < zombieConfig.maxZombies then
            SpawnZombie()
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
    TriggerEvent("chat:addMessage", {
        color = messages.colors.success,
        args = {messages.prefix, "Spawned " .. count .. " zombie(s)"}
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
            args = {messages.prefix, "Invalid stat. Available stats: health, damageModifier, accuracy, speed, aggression, spawnRadius, maxZombies"}
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
