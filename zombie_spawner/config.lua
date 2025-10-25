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
-- ============================================================================

Config.combatBehavior = {
    combatAbility = 2,
    combatRange = 0,
    combatMovement = 2
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
-- CONFIGURATION DES MESSAGES
-- ============================================================================
-- EXPLICATION:
-- Ces paramètres contrôlent l'apparence des messages du chat
--
-- PARAMÈTRES:
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
