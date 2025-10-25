# 🧟 Script de Spawn de Zombies pour RedM

Un script LUA complet pour Red Dead Redemption 2 (RedM) qui permet de créer et gérer des zombies avec des statistiques personnalisables.

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

### Spawner des Zombies
```
/spawnzombie [nombre]
```
**Exemple:**
- `/spawnzombie` - Spawn 1 zombie
- `/spawnzombie 5` - Spawn 5 zombies
- `/spawnzombie 10` - Spawn 10 zombies

### Activer/Désactiver le Spawn Aléatoire
```
/randomspawn [on/off]
```
**Exemples:**
- `/randomspawn on` - Active le spawn aléatoire de zombies sur la map
- `/randomspawn off` - Désactive le spawn aléatoire
- `/randomspawn` - Affiche l'état actuel

### Modifier les Paramètres du Spawn Aléatoire
```
/randomspawnstats [paramètre] [valeur]
```
**Paramètres disponibles:**
- `spawnInterval` - Intervalle entre chaque spawn en millisecondes
- `minDistance` - Distance minimale du joueur en mètres
- `maxDistance` - Distance maximale du joueur en mètres
- `maxRandomZombies` - Nombre maximum de zombies aléatoires
- `spawnChance` - Pourcentage de chance de spawn (0-100)

**Exemples:**
```
/randomspawnstats maxRandomZombies 10    -- Permet jusqu'à 10 zombies aléatoires
/randomspawnstats spawnInterval 5000     -- Spawn toutes les 5 secondes
/randomspawnstats minDistance 100        -- Minimum 100 mètres du joueur
/randomspawnstats spawnChance 80         -- 80% de chance de spawn
```

### Afficher le Statut des Zombies
```
/zombiestatus
```
**Affiche:**
- Nombre total de zombies vivants
- Nombre de zombies spawnés manuellement
- Nombre de zombies spawnés aléatoirement

### Vérifier les Zombies Aléatoires dans un Rayon
```
/zombiesradius [rayon]
```
**Description:** Compte le nombre de zombies aléatoires dans un rayon autour du joueur

**Exemples:**
- `/zombiesradius` - Affiche les zombies dans un rayon de 100m (par défaut)
- `/zombiesradius 150` - Affiche les zombies dans un rayon de 150m
- `/zombiesradius 50` - Affiche les zombies dans un rayon de 50m

### Afficher la Liste des Zombies Proches
```
/zombieslist [rayon]
```
**Description:** Affiche la liste détaillée des zombies aléatoires avec leurs distances

**Exemples:**
- `/zombieslist` - Liste les zombies dans un rayon de 100m (par défaut)
- `/zombieslist 200` - Liste les zombies dans un rayon de 200m
- `/zombieslist 75` - Liste les zombies dans un rayon de 75m

**Résultat:** Affiche chaque zombie avec sa distance exacte (triés du plus proche au plus loin)

### Modifier les Statistiques des Zombies
```
/setzombiestats [stat] [valeur]
```

**Statistiques disponibles:**
- `health` - Points de vie (exemple: 200)
- `damageModifier` - Multiplicateur de dégâts (exemple: 1.5)
- `accuracy` - Précision du tir (0.0 à 1.0, exemple: 0.5)
- `speed` - Vitesse de déplacement (exemple: 1.0)
- `aggression` - Agressivité (0.0 à 1.0, exemple: 0.8)
- `spawnRadius` - Distance de spawn autour du joueur en mètres (exemple: 50)
- `maxZombies` - Nombre maximum de zombies simultanés (exemple: 10)

**Exemples:**
```
/setzombiestats health 300          -- Augmente la santé à 300
/setzombiestats speed 1.5           -- Augmente la vitesse de 50%
/setzombiestats accuracy 0.8        -- Augmente la précision à 80%
/setzombiestats maxZombies 20       -- Permet jusqu'à 20 zombies
```

---

## ⚙️ Configuration

### Fichier de Configuration (config.lua)

Le script utilise un fichier `config.lua` séparé pour gérer tous les paramètres. Cela permet de modifier facilement les comportements sans toucher au code principal.

**Avantages:**
- Modification facile des paramètres
- Pas besoin de redémarrer le script pour changer les modèles
- Organisation claire et centralisée
- Facile à sauvegarder et partager

### Configuration par Défaut

Le script utilise ces paramètres par défaut (définis dans `config.lua`):

```lua
local zombieConfig = {
    health = 200.0,          -- Points de vie du zombie
    damageModifier = 1.5,    -- 50% plus de dégâts
    accuracy = 0.3,          -- 30% de précision
    speed = 1.0,             -- Vitesse normale
    aggression = 0.8,        -- Très agressif
    spawnRadius = 50.0,      -- Spawn dans un rayon de 50 mètres
    maxZombies = 10          -- Maximum 10 zombies à la fois
}
```

### Modifier la Configuration par Défaut

Ouvrez le fichier `config.lua` et modifiez les sections souhaitées:

**Pour modifier les statistiques des zombies:**

```lua
Config.zombieStats = {
    health = 300.0,          -- Augmentez la santé
    damageModifier = 2.0,    -- Augmentez les dégâts
    accuracy = 0.7,          -- Augmentez la précision
    speed = 1.5,             -- Augmentez la vitesse
    aggression = 1.0,        -- Agressivité maximale
    spawnRadius = 100.0,     -- Spawn plus loin
    maxZombies = 20          -- Plus de zombies
}
```

**Pour modifier les modèles de zombies:**

```lua
Config.zombieModels = {
    "A_M_M_UniCorpse_01",
    "A_M_M_UniCorpse_02",
    "A_C_Bear_01",
    "mon_modele_personnalise"
}
```

**Pour modifier le comportement au combat:**

```lua
Config.combatBehavior = {
    combatAbility = 2,       -- 0=Novice, 1=Intermédiaire, 2=Expert
    combatRange = 2,         -- 0=Proche, 1=Moyen, 2=Loin
    combatMovement = 3       -- 0=Stationnaire, 1=Défensif, 2=Offensif, 3=Flanking
}
```

**Pour modifier les relations avec les entités:**

```lua
Config.relationships = {
    playerRelationship = 5,      -- 5 = Haine (attaquent le joueur)
    civilianRelationship = 5,    -- 5 = Haine (attaquent les civils)
    gangRelationship = 5,        -- 5 = Haine (attaquent les gangs)
    animalRelationship = 5,      -- 5 = Haine (attaquent les animaux)
    wildAnimalRelationship = 5   -- 5 = Haine (attaquent les animaux sauvages)
}
```

**Pour configurer le spawn aléatoire sur la map:**

```lua
Config.randomSpawn = {
    enabled = false,             -- Désactivé par défaut (mettez à true pour activer)
    spawnInterval = 10000,       -- Spawn toutes les 10 secondes
    spawnRadius = 200.0,         -- Rayon de spawn de 200 mètres
    minDistance = 50.0,          -- Minimum 50 mètres du joueur
    maxDistance = 200.0,         -- Maximum 200 mètres du joueur
    maxRandomZombies = 5,        -- Maximum 5 zombies aléatoires
    spawnChance = 0.6            -- 60% de chance de spawn à chaque intervalle
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

### Comment Fonctionne la Table des Modèles

La table `zombieModels` est une liste de modèles:

```lua
local zombieModels = {
    "Modèle 1",  -- Index 1
    "Modèle 2",  -- Index 2
    "Modèle 3",  -- Index 3
    "Modèle 4"   -- Index 4
}
```

**Lors du spawn:**
1. `math.random(#zombieModels)` génère un nombre aléatoire (1, 2, 3 ou 4)
2. `zombieModels[nombre]` récupère le modèle à cet index
3. Le zombie est créé avec ce modèle

**Exemple:**
```
Si math.random(4) = 2 → zombieModels[2] = "Modèle 2"
```

### Fonctions Principales

#### `SpawnZombie()`
Crée un zombie à une position aléatoire autour du joueur.

**Ce qu'elle fait:**
1. Récupère la position du joueur
2. Choisit un modèle aléatoire
3. Charge le modèle en mémoire
4. Crée le zombie
5. Configure ses propriétés (santé, combat, relations)
6. L'ajoute à la liste de suivi

#### `CleanupZombies()`
Nettoie les zombies morts de la mémoire.

**Ce qu'elle fait:**
1. Parcourt la liste des zombies
2. Vérifie si chaque zombie existe et est vivant
3. Supprime les zombies morts
4. Libère la mémoire

#### Thread Principal
Boucle qui s'exécute toutes les 5 secondes.

**Ce qu'il fait:**
1. Nettoie les zombies morts
2. Vérifie si on peut spawner plus de zombies
3. Spawn un nouveau zombie si nécessaire

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

## 🐛 Corrections et Améliorations

### Bug Fix: Compteur de Zombies Aléatoires

**Problème:** Le compteur de zombies aléatoires augmentait mais ne diminuait jamais, ce qui empêchait le spawn de nouveaux zombies aléatoires après un certain temps.

**Solution:** 
- Chaque zombie est maintenant marqué avec un flag `isRandom` (true/false)
- La fonction `GetRandomZombieCount()` compte dynamiquement les zombies aléatoires vivants
- Le compteur se recalcule automatiquement à chaque vérification
- Les zombies aléatoires morts sont correctement retirés du comptage

**Résultat:** Le spawn aléatoire fonctionne maintenant correctement indéfiniment!

---

## ❓ FAQ

### Q: Le script ne fonctionne pas, que faire?
**R:** Vérifiez que:
1. Le dossier `zombie_spawner` est dans `resources/`
2. Le `fxmanifest.lua` est correctement configuré
3. La ligne `ensure zombie_spawner` est dans `server.cfg`
4. Les modèles utilisés existent dans le jeu

### Q: Comment arrêter le spawn automatique de zombies?
**R:** Modifiez `maxZombies` à 0:
```
/setzombiestats maxZombies 0
```

### Q: Puis-je utiliser des modèles d'autres ressources?
**R:** Oui! Assurez-vous que la ressource est activée et ajoutez le nom du modèle à la table `zombieModels`.

### Q: Comment augmenter la difficulté?
**R:** Utilisez ces commandes:
```
/setzombiestats health 500
/setzombiestats accuracy 0.9
/setzombiestats speed 1.5
/setzombiestats maxZombies 20
```

### Q: Les zombies ne m'attaquent pas, pourquoi?
**R:** Vérifiez que les relations sont correctement configurées. Les zombies doivent être dans le groupe "HATES_PLAYER".

### Q: Puis-je modifier les modèles en jeu?
**R:** Non, vous devez modifier la table `zombieModels` dans le script et redémarrer la ressource.

### Q: Quel est le nombre maximum de zombies recommandé?
**R:** Cela dépend de votre serveur, mais 10-20 est généralement stable. Plus de zombies = plus de charge serveur.

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
**Version:** 1.0.0
