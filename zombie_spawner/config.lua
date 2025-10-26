-- ============================================================================
-- FICHIER DE CONFIGURATION - ZOMBIE SPAWNER
-- ============================================================================
-- Ce fichier centralise tous les paramètres du script
-- Modifiez les valeurs ici pour personnaliser le comportement des zombies
-- ============================================================================

-- ============================================================================
-- TABLE DES MODÈLES DE ZOMBIES DISPONIBLES
-- ============================================================================
-- EXPLICATION:
-- Cette table contient tous les modèles de zombies que le script peut utiliser
-- Le script en choisira un au hasard à chaque spawn
--
-- COMMENT AJOUTER DES MODÈLES:
-- 1. Ajoutez simplement une nouvelle ligne avec le nom du modèle
-- 2. Assurez-vous que le modèle existe dans le jeu
-- 3. Utilisez des virgules pour séparer les modèles
--
-- EXEMPLE:
-- local zombieModels = {
--     "A_M_M_UniCorpse_01",
--     "A_M_M_UniCorpse_02",
--     "A_C_Bear_01",
--     "mon_modele_personnalise"
-- }
-- ============================================================================

Config = {}

Config.zombieModels = {
    "A_C_Bear_01",
    "amsp_robsdgunsmith_males_01"
    -- Ajoutez d'autres modèles ici:
    -- "A_M_M_UniCorpse_01",
    -- "A_M_M_UniCorpse_02",
    -- "A_F_M_UniCorpse_01",
    -- "A_F_M_UniCorpse_02",
}

-- ============================================================================
-- CONFIGURATION DES STATISTIQUES DES ZOMBIES
-- ============================================================================
-- EXPLICATION:
-- Ces paramètres définissent les statistiques par défaut de tous les zombies
-- Vous pouvez les modifier ici ou en jeu avec la commande /setzombiestats
--
-- PARAMÈTRES:
-- - health: Points de vie du zombie (recommandé: 100-500)
-- - damageModifier: Multiplicateur de dégâts (recommandé: 0.5-3.0)
-- - accuracy: Précision du tir (0.0 = jamais, 1.0 = toujours)
-- - speed: Vitesse de déplacement (1.0 = normal, 0.5 = lent, 2.0 = rapide)
-- - aggression: Agressivité (0.0 = passif, 1.0 = très agressif)
-- - spawnRadius: Distance de spawn autour du joueur en mètres (recommandé: 30-100)
-- - maxZombies: Nombre maximum de zombies simultanés (recommandé: 5-30)
--
-- PROFILS PRÉDÉFINIS:
-- - Facile: health=100, accuracy=0.2, speed=0.8, maxZombies=5
-- - Normal: health=200, accuracy=0.3, speed=1.0, maxZombies=10
-- - Difficile: health=300, accuracy=0.6, speed=1.3, maxZombies=15
-- - Cauchemar: health=500, accuracy=0.9, speed=1.5, maxZombies=25
-- ============================================================================

Config.zombieStats = {
    health = 200.0,
    damageModifier = 1.5,
    accuracy = 0.3,
    speed = 1.0,
    aggression = 0.8,
    spawnRadius = 50.0,
    maxZombies = 10
}

-- ============================================================================
-- CONFIGURATION DU COMPORTEMENT AU COMBAT
-- ============================================================================
-- EXPLICATION:
-- Ces paramètres définissent comment les zombies se comportent au combat
--
-- PARAMÈTRES:
-- - combatAbility: Niveau de compétence au combat
--   0 = Novice (mauvais)
--   1 = Intermédiaire (moyen)
--   2 = Expert (très bon)
--
-- - combatRange: Distance de combat préférée
--   0 = Proche (mêlée)
--   1 = Moyen
--   2 = Loin (distance)
--
-- - combatMovement: Style de mouvement au combat
--   0 = Stationnaire (ne bouge pas)
--   1 = Défensif (recule)
--   2 = Offensif (fonce)
--   3 = Flanking (contourne l'ennemi)
--
-- - alwaysFight: Attribut de combat RedM
--   Valeur: 46 (constante RedM)
--   Effet: Force le zombie à toujours combattre quand il rencontre un ennemi
--   Modification: Changez cette valeur si vous utilisez d'autres attributs RedM
--
-- - useMeleeWeapons: Attribut de combat RedM
--   Valeur: 5 (constante RedM)
--   Effet: Permet au zombie d'utiliser des armes de mêlée (couteaux, etc.)
--   Modification: Changez cette valeur si vous utilisez d'autres attributs RedM
-- ============================================================================

Config.combatBehavior = {
    combatAbility = 2,       -- 0=Novice, 1=Intermédiaire, 2=Expert
    combatRange = 0,         -- 0=Proche, 1=Moyen, 2=Loin
    combatMovement = 2,      -- 0=Stationnaire, 1=Défensif, 2=Offensif, 3=Flanking
    -- Attributs de combat (SetPedCombatAttributes)
    alwaysFight = 46,        -- Attribut: toujours combattre
    useMeleeWeapons = 5      -- Attribut: peut utiliser des armes de mêlée
}

-- ============================================================================
-- CONFIGURATION DES RELATIONS
-- ============================================================================
-- EXPLICATION:
-- Ces paramètres définissent comment les zombies réagissent aux autres entités
--
-- VALEURS DE RELATION:
-- 0 = Neutre (pas d'interaction)
-- 1 = Respectueux
-- 2 = Amical
-- 3 = Familier
-- 4 = Amour
-- 5 = Haine (attaquent)
--
-- Les relations sont bidirectionnelles (si A déteste B, alors B déteste A)
-- ============================================================================

Config.relationships = {
    -- Relation avec le joueur
    playerRelationship = 5,
    
    -- Relation avec les civils
    civilianRelationship = 5,
    
    -- Relation avec les gangs
    gangRelationship = 5,
    
    -- Relation avec les animaux domestiques
    animalRelationship = 5,
    
    -- Relation avec les animaux sauvages
    wildAnimalRelationship = 5
}

-- ============================================================================
-- CONFIGURATION DU THREAD PRINCIPAL
-- ============================================================================
-- EXPLICATION:
-- Ces paramètres contrôlent comment le script gère les zombies en arrière-plan
--
-- PARAMÈTRES:
-- - threadInterval: Intervalle de vérification en millisecondes
--   (plus bas = plus réactif mais plus gourmand en ressources)
--   Recommandé: 3000-10000 (3-10 secondes)
-- ============================================================================

Config.threadSettings = {
    threadInterval = 5000
}

-- ============================================================================
-- CONFIGURATION DES ZONES DE SPAWN (V2)
-- ============================================================================
-- EXPLICATION:
-- Ces paramètres définissent les zones où les zombies peuvent spawner
-- Les zombies spawnent dans ces zones au lieu de suivre le joueur
--
-- STRUCTURE D'UNE ZONE:
-- {
--     name = "Nom de la zone",              -- Nom descriptif
--     coords = vector3(x, y, z),           -- Coordonnées du centre de la zone
--     radius = 100.0,                      -- Rayon de la zone en mètres
--     maxZombies = 5,                      -- Nombre maximum de zombies dans cette zone
--     enabled = true,                      -- Active/désactive la zone
--     spawnInterval = 5000                 -- Intervalle de spawn en millisecondes (optionnel)
-- }
--
-- PARAMÈTRES:
-- - name: Nom unique pour identifier la zone
-- - coords: Position centrale de la zone (vector3)
-- - radius: Rayon de spawn autour du centre
-- - maxZombies: Nombre maximum de zombies simultanés dans cette zone
-- - enabled: true = zone active, false = zone désactivée
-- - spawnInterval: Intervalle entre chaque spawn (optionnel, utilise la valeur globale par défaut)
--
-- COMMENT AJOUTER UNE ZONE:
-- 1. Ajoutez une nouvelle table à Config.spawnZones
-- 2. Remplissez les paramètres requis
-- 3. Utilisez /addzonemarker pour trouver les bonnes coordonnées
--
-- EXEMPLE:
-- {
--     name = "Forêt Sombre",
--     coords = vector3(100.0, 200.0, 50.0),
--     radius = 150.0,
--     maxZombies = 10,
--     enabled = true
-- }
-- ============================================================================

Config.spawnZones = {
    -- ZONE EXEMPLE 1 - À REMPLACER PAR VOS COORDONNÉES
    {
        name = "Zone Test 1",
        coords = vector3(0.0, 0.0, 0.0),
        radius = 100.0,
        maxZombies = 5,
        enabled = true
    },
    
    -- ZONE EXEMPLE 2 - À REMPLACER PAR VOS COORDONNÉES
    {
        name = "Zone Test 2",
        coords = vector3(500.0, 500.0, 0.0),
        radius = 150.0,
        maxZombies = 8,
        enabled = true
    }
    
    -- Ajoutez d'autres zones ici
}

-- ============================================================================
-- CONFIGURATION GLOBALE DES ZONES
-- ============================================================================
-- EXPLICATION:
-- Ces paramètres contrôlent le comportement général du système de zones
--
-- PARAMÈTRES:
-- - spawnInterval: Intervalle par défaut entre chaque spawn en millisecondes
--   Défaut: 5000 (5 secondes)
--   Note: Peut être overridé par zone
--
-- - cleanupDistance: Distance à partir de laquelle un zombie est supprimé s'il s'éloigne de sa zone
--   Défaut: 200.0 (200 mètres)
--   Note: Évite que les zombies s'échappent trop loin
--
-- - showMarkers: Affiche les marqueurs des zones sur la map
--   Défaut: false
--   Note: Utile pour le debug et la configuration
--
-- - markerColor: Couleur des marqueurs (R, G, B, A)
--   Défaut: {255, 0, 0, 100} (Rouge semi-transparent)
-- ============================================================================

Config.zoneSettings = {
    spawnInterval = 5000,        -- Intervalle par défaut de spawn (5 secondes)
    cleanupDistance = 200.0,     -- Distance avant suppression d'un zombie éloigné
    showMarkers = false,         -- Afficher les marqueurs des zones
    markerColor = {255, 0, 0, 100}  -- Couleur des marqueurs (R, G, B, A)
}

-- ============================================================================
-- CONFIGURATION DU SPAWN ALÉATOIRE SUR LA MAP
-- ============================================================================
-- EXPLICATION:
-- Ces paramètres contrôlent le spawn aléatoire de zombies sur la map
--
-- PARAMÈTRES:
-- - enabled: Active/désactive le spawn aléatoire (true/false)
--   Défaut: false (désactivé)
--
-- - spawnInterval: Intervalle entre chaque spawn en millisecondes
--   Défaut: 10000 (10 secondes)
--   Note: Plus bas = plus fréquent (mais plus gourmand en ressources)
--
-- - spawnRadius: Rayon de spawn autour du joueur en mètres
--   Défaut: 200.0
--   Note: Utilisé pour calculer la zone de spawn aléatoire (non modifiable en jeu)
--
-- - minDistance: Distance minimale du joueur pour spawner
--   Défaut: 50.0
--   Note: Les zombies ne spawnent pas trop près du joueur
--
-- - maxDistance: Distance maximale du joueur pour spawner
--   Défaut: 200.0
--   Note: Les zombies ne spawnent pas trop loin du joueur
--
-- - maxRandomZombies: Nombre maximum de zombies aléatoires simultanés
--   Défaut: 5
--   Note: Indépendant de maxZombies (zombies manuels)
--
-- - spawnChance: Pourcentage de chance de spawn à chaque intervalle
--   Défaut: 0.6 (60%)
--   Note: Valeur entre 0 et 100 (en pourcentage)
--
-- - defaultSearchRadius: Rayon par défaut pour les commandes de détection
--   Défaut: 100.0
--   Note: Peut être overridé en passant un rayon en paramètre
-- ============================================================================

Config.randomSpawn = {
    enabled = false,             -- Désactivé par défaut, mettez à true pour activer
    spawnInterval = 10000,       -- Spawn toutes les 10 secondes
    spawnRadius = 200.0,         -- Rayon de spawn de 200 mètres
    minDistance = 50.0,          -- Minimum 50 mètres du joueur
    maxDistance = 200.0,         -- Maximum 200 mètres du joueur
    maxRandomZombies = 5,        -- Maximum 5 zombies aléatoires
    spawnChance = 0.6,           -- 60% de chance de spawn à chaque intervalle
    defaultSearchRadius = 100.0  -- Rayon par défaut pour les commandes /zombiesradius et /zombieslist
}

-- ============================================================================
-- CONFIGURATION DES MESSAGES
-- ============================================================================
-- EXPLICATION:
-- Ces paramètres contrôlent l'apparence des messages du chat
--
-- - colors: Couleurs des messages en RGB (0-255)
-- - prefix: Préfixe des messages
-- ============================================================================

Config.messages = {
    colors = {
        success = {0, 255, 0},      -- Vert
        error = {255, 0, 0},        -- Rouge
        info = {0, 150, 255}        -- Bleu
    },
    prefix = "[Zombie Spawner]" 
}

-- ============================================================================
-- PROFILS PRÉDÉFINIS
-- ============================================================================
-- EXPLICATION:
-- Vous pouvez utiliser ces profils pour changer rapidement la difficulté
-- Décommentez le profil que vous voulez utiliser
--
-- UTILISATION:
-- 1. Décommentez le profil souhaité ci-dessous
-- 2. Commentez la configuration par défaut
-- 3. Redémarrez la ressource
-- ============================================================================

-- PROFIL FACILE
-- Config.zombieStats = {
--     health = 100.0,
--     damageModifier = 0.8,
--     accuracy = 0.2,
--     speed = 0.8,
--     aggression = 0.5,
--     spawnRadius = 50.0,
--     maxZombies = 5
-- }

-- PROFIL DIFFICILE
-- Config.zombieStats = {
--     health = 300.0,
--     damageModifier = 2.0,
--     accuracy = 0.6,
--     speed = 1.3,
--     aggression = 0.9,
--     spawnRadius = 50.0,
--     maxZombies = 15
-- }

-- PROFIL CAUCHEMAR
-- Config.zombieStats = {
--     health = 500.0,
--     damageModifier = 3.0,
--     accuracy = 0.9,
--     speed = 1.5,
--     aggression = 1.0,
--     spawnRadius = 50.0,
--     maxZombies = 25
-- }

-- ============================================================================
-- FIN DU FICHIER DE CONFIGURATION
-- ============================================================================
