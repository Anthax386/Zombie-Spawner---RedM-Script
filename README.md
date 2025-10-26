# 🧟 Zombie Spawner V2 - Système de Zones pour RedM

Un script LUA complet pour Red Dead Redemption 2 (RedM) qui permet de créer et gérer des zombies dans des zones prédéfinies avec des statistiques personnalisables. Les zombies spawnent dans des zones statiques au lieu de suivre le joueur, comme les animaux du jeu.

---

## 📋 Table des Matières

1. [Installation](#installation)
2. [Commandes](#commandes)
3. [Configuration](#configuration)
4. [Modèles de Zombies](#modèles-de-zombies)
5. [Fonctionnement Technique](#fonctionnement-technique)
6. [Personnalisation](#personnalisation)
7. [FAQ](#faq)

---

## 🚀 Installation

### Étape 1: Préparation
1. Téléchargez tous les fichiers du script
2. Créez un dossier `zombie_spawner` dans votre dossier `resources/`

### Étape 2: Structure du Dossier
```
resources/zombie_spawner/
├── fxmanifest.lua
├── zombie_spawner.lua
├── config.lua
└── README.md
```

### Étape 3: Copier les Fichiers
Copiez les fichiers suivants dans le dossier `zombie_spawner/`:
- `fxmanifest.lua` - Configuration de la ressource
- `zombie_spawner.lua` - Script principal
- `config.lua` - Fichier de configuration (modèles et paramètres)
- `README.md` - Documentation

### Étape 4: Activation
Ajoutez cette ligne à votre `server.cfg`:
```
ensure zombie_spawner
```

Redémarrez votre serveur et le script sera actif!

---

## 🎮 Commandes

### Gestion des Zones

**Afficher toutes les zones:**
```
/listzones
```
Affiche la liste de toutes les zones configurées avec leur statut.

**Activer/Désactiver une zone:**
```
/togglezone [zoneIndex]
```
**Exemple:** `/togglezone 1` - Bascule la zone 1

**Afficher les marqueurs des zones:**
```
/togglemarkers
```
Active/désactive l'affichage des marqueurs visuels des zones (utile pour le debug).

### Spawn de Zombies

**Spawner des zombies dans une zone:**
```
/spawnzombie [nombre] [zoneIndex]
```
**Exemples:**
- `/spawnzombie 5 1` - Spawn 5 zombies dans la zone 1
- `/spawnzombie 10 2` - Spawn 10 zombies dans la zone 2
- `/spawnzombie 3` - Spawn 3 zombies dans la zone 1 (par défaut)

### Configuration

**Modifier les statistiques des zombies:**
```
/setzombiestats [stat] [valeur]
```
**Exemples:**
```
/setzombiestats health 300      -- Augmente la santé à 300
/setzombiestats speed 1.5       -- Augmente la vitesse de 50%
/setzombiestats accuracy 0.8    -- Augmente la précision à 80%
```

**Afficher le statut des zombies:**
```
/zombiestatus
```
Affiche le nombre de zombies par zone.

### Outils de Configuration

**Ajouter un marqueur à la position actuelle:**
```
/addzonemarker [nom] [radius] [maxZombies]
```
**Exemple:** `/addzonemarker "Forêt Sombre" 100 5`

Affiche les coordonnées au format prêt à copier dans `config.lua`.

---

## ⚙️ Configuration

### Fichier de Configuration (config.lua)

Le script utilise un fichier `config.lua` séparé pour gérer tous les paramètres. Cela permet de modifier facilement les comportements sans toucher au code principal.

**Avantages:**
- Modification facile des paramètres
- Pas besoin de redémarrer le script pour changer les modèles
- Organisation claire et centralisée
- Facile à sauvegarder et partager

### Configuration des Zones

Les zones définissent où les zombies peuvent spawner. Chaque zone a ses propres paramètres:

```lua
Config.spawnZones = {
    {
        name = "Zone Test 1",
        coords = vector3(0.0, 0.0, 0.0),
        radius = 100.0,
        maxZombies = 5,
        enabled = true
    },
    {
        name = "Zone Test 2",
        coords = vector3(500.0, 500.0, 0.0),
        radius = 150.0,
        maxZombies = 8,
        enabled = true
    }
}
```

**Paramètres d'une zone:**
- `name` - Nom descriptif de la zone
- `coords` - Coordonnées du centre (vector3)
- `radius` - Rayon de spawn en mètres
- `maxZombies` - Nombre maximum de zombies dans cette zone
- `enabled` - Active/désactive la zone
- `spawnInterval` - (Optionnel) Intervalle de spawn personnalisé

### Configuration Globale des Zones

```lua
Config.zoneSettings = {
    spawnInterval = 5000,        -- Intervalle par défaut (5 secondes)
    cleanupDistance = 200.0,     -- Distance avant suppression d'un zombie
    showMarkers = false,         -- Afficher les marqueurs des zones
    markerColor = {255, 0, 0, 100}  -- Couleur des marqueurs (R, G, B, A)
}
```

### Modifier les Statistiques des Zombies

```lua
Config.zombieStats = {
    health = 200.0,          -- Points de vie
    damageModifier = 1.5,    -- Multiplicateur de dégâts
    accuracy = 0.3,          -- Précision du tir (0.0 à 1.0)
    speed = 1.0,             -- Vitesse de déplacement
    aggression = 0.8         -- Agressivité (0.0 à 1.0)
}
```

### Modifier les Modèles de Zombies

```lua
Config.zombieModels = {
    "A_C_Bear_01",
    "amsp_robsdgunsmith_males_01"
}
```

**Après modification, redémarrez la ressource:**
```
/restart zombie_spawner
```

---

## 🧟 Modèles de Zombies

### Modèles par Défaut

Le script utilise ces modèles de zombies (définis dans `config.lua`):

```lua
Config.zombieModels = {
    "A_C_Bear_01",
    "amsp_robsdgunsmith_males_01"
}
```

### Modèles Disponibles dans RDR2

Voici une liste de modèles que vous pouvez utiliser:

**Zombies Originaux:**
- `A_M_M_UniCorpse_01` - Homme corpse 1
- `A_M_M_UniCorpse_02` - Homme corpse 2
- `A_M_M_UniCorpse_03` - Homme corpse 3
- `A_M_M_UniCorpse_04` - Homme corpse 4
- `A_F_M_UniCorpse_01` - Femme corpse 1
- `A_F_M_UniCorpse_02` - Femme corpse 2

**Animaux:**
- `A_C_Bear_01` - Ours
- `A_C_Wolf_01` - Loup
- `A_C_Cougar_01` - Cougar
- `A_C_Coyote_01` - Coyote

**PNJ:**
- `a_m_m_business_01` - Homme d'affaires
- `a_m_m_cowtown_01` - Cowboy
- `a_f_m_business_02` - Femme d'affaires

### Ajouter des Modèles

Modifiez simplement la table `Config.zombieModels` dans `config.lua`:

```lua
Config.zombieModels = {
    "A_M_M_UniCorpse_01",
    "A_M_M_UniCorpse_02",
    "A_C_Bear_01",              -- Nouveau modèle
    "A_C_Wolf_01",              -- Nouveau modèle
    "amsp_robsdgunsmith_males_01"
}
```

Puis redémarrez la ressource avec `/restart zombie_spawner`

---

## 🔧 Fonctionnement Technique

### Système de Zones

Les zombies spawnent dans des zones prédéfinies au lieu de suivre le joueur:

1. **Définition** - Chaque zone est définie par des coordonnées (X, Y, Z) et un rayon
2. **Spawn** - Les zombies spawnent aléatoirement dans le rayon de la zone
3. **Limite** - Chaque zone a un nombre maximum de zombies simultanés
4. **Nettoyage** - Les zombies qui s'éloignent trop sont supprimés

### Fonctions Principales

#### `SpawnZombieInZone(zone, zoneIndex)`
Crée un zombie à une position aléatoire dans une zone donnée.

**Ce qu'elle fait:**
1. Récupère les coordonnées du centre de la zone
2. Génère une position aléatoire dans le rayon
3. Choisit un modèle aléatoire
4. Charge le modèle en mémoire
5. Crée le zombie
6. Configure ses propriétés (santé, combat, relations)
7. L'ajoute à la liste de suivi avec la zone associée

#### `CleanupZombies()`
Supprime les zombies morts ou éloignés de leur zone.

**Ce qu'elle fait:**
1. Parcourt la liste des zombies
2. Vérifie si chaque zombie existe et est vivant
3. Vérifie si le zombie s'est éloigné de sa zone
4. Supprime les zombies morts ou éloignés
5. Libère la mémoire

#### `GetZombieCountInZone(zoneIndex)`
Compte le nombre de zombies vivants dans une zone donnée.

#### `DrawZoneMarkers()`
Affiche les marqueurs visuels des zones sur la map (si activé).

#### Thread Principal
Boucle qui s'exécute toutes les 5 secondes.

**Ce qu'il fait:**
1. Nettoie les zombies morts ou éloignés
2. Affiche les marqueurs des zones
3. Pour chaque zone activée:
   - Vérifie si l'intervalle de spawn est écoulé
   - Compte les zombies actuels
   - Spawn un nouveau zombie si la zone n'a pas atteint son maximum

### Relations avec les Entités

Le script configure les relations suivantes:

**Avec le Joueur:**
- Les zombies **détestent** le joueur (5 = haine complète)
- Le joueur **déteste** les zombies

**Avec les PNJ:**
- Les zombies **détestent** les civils
- Les civils **détestent** les zombies
- Les zombies **détestent** les gangs
- Les gangs **détestent** les zombies

**Avec les Animaux:**
- Les zombies **détestent** les animaux domestiques
- Les animaux **détestent** les zombies
- Les zombies **détestent** les animaux sauvages
- Les animaux sauvages **détestent** les zombies

---

## 🎨 Personnalisation

### Créer des Modèles Personnalisés

#### Option 1: Utiliser une Ressource Existante

1. Téléchargez une ressource RedM avec des modèles personnalisés
2. Installez-la dans votre dossier `resources/`
3. Ajoutez le nom du modèle à la table `zombieModels`

#### Option 2: Créer Votre Propre Ressource

**Étape 1: Créer la Structure**
```
resources/mon_zombie_custom/
├── fxmanifest.lua
├── stream/
│   ├── mon_zombie.ymt
│   └── mon_zombie.ytd
└── README.md
```

**Étape 2: Créer le fxmanifest.lua**
```lua
fx_version 'cerulean'
game 'rdr3'

author 'Votre Nom'
description 'Modèle de zombie personnalisé'
version '1.0.0'

files {
    'stream/mon_zombie.ymt',
    'stream/mon_zombie.ytd'
}

data_file 'DLC_PED_DEFINITIONS_FILE' 'stream/mon_zombie.ymt'
```

**Étape 3: Activer la Ressource**
- Ajoutez `ensure mon_zombie_custom` dans `server.cfg`

**Étape 4: Utiliser le Modèle**
```lua
local zombieModels = {
    "A_M_M_UniCorpse_01",
    "mon_zombie"  -- Votre modèle personnalisé
}
```

### Outils pour Créer des Modèles

- **OpenIV** - Extraire et modifier des modèles du jeu
- **ZModeler3** - Créer des modèles 3D personnalisés
- **Blender** - Créer des modèles 3D (avec plugins RedM)

### Modifier le Comportement au Combat

Dans la fonction `SpawnZombie()`, vous pouvez modifier:

```lua
-- Compétence au combat (0 = novice, 1 = intermédiaire, 2 = expert)
SetPedCombatAbility(zombie, 2)

-- Distance de combat (0 = proche, 1 = moyen, 2 = loin)
SetPedCombatRange(zombie, 2)

-- Mouvement au combat (0 = stationnaire, 1 = défensif, 2 = offensif, 3 = flanking)
SetPedCombatMovement(zombie, 3)
```

---

## ❓ FAQ

### Q: Comment configurer les zones?
**R:** 
1. Utilisez `/addzonemarker "Nom" radius maxZombies` à la position souhaitée
2. Copiez les coordonnées affichées dans `Config.spawnZones` du `config.lua`
3. Redémarrez la ressource avec `/restart zombie_spawner`

### Q: Comment trouver les bonnes coordonnées?
**R:**
1. Activez les marqueurs avec `/togglemarkers`
2. Allez à la position souhaitée
3. Utilisez `/addzonemarker "Nom" 100 5` pour générer le code
4. Copiez les coordonnées dans `config.lua`

### Q: Pourquoi les zombies disparaissent?
**R:** Les zombies sont supprimés s'ils:
- Meurent
- S'éloignent trop de leur zone (> `cleanupDistance`)

Augmentez `cleanupDistance` dans `Config.zoneSettings` si nécessaire.

### Q: Comment arrêter le spawn dans une zone?
**R:** Utilisez `/togglezone [zoneIndex]` pour désactiver la zone.

### Q: Puis-je avoir des zones avec des paramètres différents?
**R:** Oui! Chaque zone peut avoir son propre `spawnInterval` et `maxZombies`.

### Q: Quel est le nombre maximum de zombies recommandé par zone?
**R:** Cela dépend de votre serveur, mais 5-15 par zone est généralement stable.

### Q: Comment augmenter la difficulté?
**R:** Utilisez ces commandes:
```
/setzombiestats health 500
/setzombiestats accuracy 0.9
/setzombiestats speed 1.5
```

### Q: Les zombies ne m'attaquent pas, pourquoi?
**R:** Vérifiez que les relations sont correctement configurées. Les zombies doivent être dans le groupe "HATES_PLAYER".

---

## 📝 Notes Importantes

- **Performance:** Plus il y a de zombies, plus le serveur consomme de ressources
- **Modèles:** Assurez-vous que tous les modèles existent dans le jeu
- **Nettoyage:** Le script nettoie automatiquement les zombies morts
- **Mémoire:** Le script libère la mémoire correctement pour éviter les fuites

---

## 🤝 Support

Si vous rencontrez des problèmes:
1. Vérifiez les logs du serveur
2. Consultez la documentation RedM
3. Vérifiez les forums de la communauté RedM

---

## 📄 Licence

Ce script est fourni à titre d'exemple. Utilisez-le librement dans vos projets RedM.

---

**Dernière mise à jour:** 26 Octobre 2025
**Version:** 2.0.0 - Système de Zones
