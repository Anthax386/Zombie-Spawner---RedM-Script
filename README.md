## Configuration 

### Messages

Ces paramètres définissent les couleurs et le préfixe des messages

PARAMÈTRES:
- colors: Couleurs des messages en RGB (0-255)
- prefix: Préfixe des messages

**Exemple:**
```lua
Config.messages = {
    colors = {
        success = {0, 255, 0},      -- Vert
        error = {255, 0, 0},        -- Rouge
        info = {0, 150, 255}        -- Bleu
    },
    prefix = "[Zombie Spawner]" 
}
```

### Table des modèles de zombies disponibles

Cette table contient tous les modèles de zombies que le script peut utiliser
Le script en choisira un au hasard à chaque spawn

COMMENT AJOUTER DES MODÈLES:
1. Ajoutez simplement une nouvelle ligne avec le nom du modèle
2. Assurez-vous que le modèle existe dans le jeu
3. Utilisez des virgules pour séparer les modèles

**Exemple:**
```lua
local zombieModels = {
    "A_M_M_UniCorpse_01",
    "A_M_M_UniCorpse_02",
    "A_C_Bear_01",
    "mon_modele_personnalise"
}
```

### Statistiques des zombies

Ces paramètres définissent les statistiques par défaut de tous les zombies

PARAMÈTRES:
- health: Points de vie du zombie (recommandé: 100-500)
- damageModifier: Multiplicateur de dégâts (recommandé: 0.5-3.0)
- accuracy: Précision du tir (0.0 = jamais, 1.0 = toujours)
- speed: Vitesse de déplacement (1.0 = normal, 0.5 = lent, 2.0 = rapide)
- aggression: Agressivité (0.0 = passif, 1.0 = très agressif)
- spawnRadius: Distance de spawn autour du joueur en mètres (recommandé: 30-100)
- maxZombies: Nombre maximum de zombies simultanés (recommandé: 5-30)

**Exemple:**
```lua
Config.zombieStats = {
    health = 200.0,
    damageModifier = 1.5,
    accuracy = 0.3,
    speed = 1.0,
    aggression = 0.8,
    spawnRadius = 50.0,
    maxZombies = 10
}
```

### Comportement au combat

Ces paramètres définissent le comportement des zombies au combat

PARAMÈTRES:
- combatAbility: Niveau de compétence au combat
  0 = Novice (mauvais)
  1 = Intermédiaire (moyen)
  2 = Expert (très bon)

- combatRange: Distance de combat préférée
  0 = Proche (mêlée)
  1 = Moyen
  2 = Loin (distance)

- combatMovement: Style de mouvement au combat
  0 = Stationnaire (ne bouge pas)
  1 = Défensif (recule)
  2 = Offensif (fonce)
  3 = Flanking (contourne l'ennemi)

- alwaysFight: Attribut de combat RedM
  Valeur: 46 (constante RedM)
  Effet: Force le zombie à toujours combattre quand il rencontre un ennemi
  Modification: Changez cette valeur si vous utilisez d'autres attributs RedM

- useMeleeWeapons: Attribut de combat RedM
  Valeur: 5 (constante RedM)
  Effet: Permet au zombie d'utiliser des armes de mêlée (couteaux, etc.)
  Modification: Changez cette valeur si vous utilisez d'autres attributs RedM

**Exemple:**
```lua
Config.combatBehavior = {
    combatAbility = 2,
    combatRange = 0,
    combatMovement = 2,
    alwaysFight = 46,
    useMeleeWeapons = 5
}
```

### Relations

Ces paramètres définissent comment les zombies réagissent aux autres entités

PARAMÈTRES:
- playerRelationship: Relation avec le joueur
- civilianRelationship: Relation avec les civils
- gangRelationship: Relation avec les gangs
- animalRelationship: Relation avec les animaux domestiques
- wildAnimalRelationship: Relation avec les animaux sauvages

VALEURS DE RELATION:
- 0 = Neutre (pas d'interaction)
- 1 = Respectueux
- 2 = Amical
- 3 = Familier
- 4 = Amour
- 5 = Haine (attaquent)

**Exemple:**
```lua
Config.relationships = {
    playerRelationship = 5,
    civilianRelationship = 5,
    gangRelationship = 5,
    animalRelationship = 5,
    wildAnimalRelationship = 5
}
```

### Zones de spawn

Ces paramètres définissent les zones où les zombies peuvent spawner

Paramètres :
- name: Nom unique pour identifier la zone
- coords: Position centrale de la zone (vector3)
- radius: Rayon de spawn autour du centre
- maxZombies: Nombre maximum de zombies simultanés dans cette zone
- enabled: true = zone active, false = zone désactivée
- spawnInterval: Intervalle entre chaque spawn (optionnel, utilise la valeur globale par défaut)

**Exemple:**
```lua
Config.spawnZones = {
    {
        name = "Zone Test 1",
        coords = vector3(0.0, 0.0, 0.0),
        radius = 100.0,
        maxZombies = 5,
        enabled = true
    }
}
```

### Paramètres des zones

Ces paramètres contrôlent le comportement général du système de zones

PARAMÈTRES:
- spawnInterval: Intervalle par défaut entre chaque spawn en millisecondes
- cleanupDistance: Distance à partir de laquelle un zombie est supprimé s'il s'éloigne de sa zone
- showMarkers: Affiche les marqueurs des zones sur la map
- markerColor: Couleur des marqueurs (R, G, B, A)

**Exemple:**
```lua
Config.zoneSettings = {
    spawnInterval = 5000,
    cleanupDistance = 200.0,
    showMarkers = false,
    markerColor = {255, 0, 0, 100},
}
```

## Commandes

Le script inclut plusieurs commandes pour gérer les zombies depuis le chat du jeu.

### Commandes disponibles

#### `/zombiecount`
- **Description:** Affiche le nombre de zombies actuellement actifs
- **Permission:** Administrateurs uniquement
- **Usage:** `/zombiecount`

#### `/clearzombies`
- **Description:** Supprime tous les zombies du serveur
- **Permission:** Administrateurs uniquement
- **Usage:** `/clearzombies`

### Configuration des permissions

Pour restreindre l'accès aux commandes admin, ajoutez cette ligne dans votre `server.cfg`:

## Prérequis Techniques

- **RedM Server** build 2802 ou supérieur
- **FiveM/RedM Framework** correctement configuré
- **Accès administrateur** au serveur de jeu
- **Connaissance de base** de la configuration Lua (optionnel)

## Installation et Configuration

### Installation Automatique

1. **Téléchargez** le dossier `Nouveau dossier`
2. **Placez-le** dans votre répertoire `resources/[nom_de_votre_serveur]/`
3. **Ajoutez** cette ligne dans votre `server.cfg` :
   ```cfg
   ensure Nouveau dossier
   ```
4. **Redémarrez** votre serveur RedM

### Configuration de Base

#### 1. Configuration des Zones
Modifiez `config.lua` pour définir vos zones de spawn :

```lua
Config.spawnZones = {
    {
        name = "Saint Denis",
        coords = vector3(2500.0, -1300.0, 48.0),  -- Coordonnées de Saint Denis
        radius = 150.0,
        maxZombies = 10,
        enabled = true,
        spawnInterval = 30000  -- 30 secondes
    },
    {
        name = "Valentine",
        coords = vector3(-300.0, 800.0, 120.0),   -- Coordonnées de Valentine
        radius = 100.0,
        maxZombies = 8,
        enabled = true
    }
}
```

#### 2. Configuration des Permissions (Optionnel)

Ajoutez ces lignes dans votre `server.cfg` pour restreindre les commandes admin :

```cfg
# Permissions Zombie Spawner
add_ace group.admin command.clearzombies allow
add_ace group.admin command.zombiecount allow
add_ace group.moderator command.zombiecount allow

# Remplacez 'group.admin' par vos groupes de permissions
```

#### 3. Configuration Avancée

**A. Ajuster les statistiques des zombies :**
```lua
Config.zombieStats = {
    health = 150.0,        -- Points de vie (100-500)
    accuracy = 0.2,       -- Précision (0.0-1.0)
    speed = 1.2,          -- Vitesse (0.5-2.0)
    aggression = 0.9      -- Agressivité (0.0-1.0)
}
```

**B. Personnaliser les modèles :**
```lua
Config.zombieModels = {
    "A_M_M_UniCorpse_01",    -- Modèles disponibles dans RedM
    "A_M_M_UniCorpse_02",
    "A_F_M_UniCorpse_01",
    "A_F_M_UniCorpse_02"
}
```

**C. Activer les marqueurs visuels :**
```lua
Config.zoneSettings = {
    showMarkers = true,                    -- Afficher les zones
    markerColor = {255, 0, 0, 100},       -- Rouge transparent
    cleanupDistance = 300.0               -- Distance de nettoyage
}
```

### Vérification de l'Installation

1. **Démarrez** votre serveur RedM
2. **Connectez-vous** au serveur
3. **Testez les commandes :**
   - `/zombiecount` - Vérifier le système
   - `/spawnzombies 1` - Tester le spawn manuel
   - `/clearzombies` - Tester le nettoyage (admin)

4. **Vérifiez la console serveur** pour les messages de chargement :
   ```
   Script serveur Zombie Spawner chargé avec succès !
   Script client Zombie Spawner chargé avec succès !
   Commandes zombies chargées avec succès !
   ```

### Commandes Disponibles

| Commande | Description | Permission | Exemple |
|----------|-------------|------------|---------|
| `/zombiecount` | Affiche le nombre de zombies actifs | Admin | `/zombiecount` |
| `/clearzombies` | Supprime tous les zombies | Admin | `/clearzombies` |
| `/spawnzombies <zone>` | Spawn un zombie dans une zone | Tous | `/spawnzombies 1` |

### Support et Dépannage

#### Problèmes Courants

**1. "Commande inconnue"**
- Vérifiez que le script est bien ajouté dans `server.cfg`
- Redémarrez le serveur après modification

**2. "Zombies ne spawnent pas"**
- Vérifiez les coordonnées des zones dans `config.lua`
- Assurez-vous que les zones sont `enabled = true`
- Vérifiez l'intervalle de spawn (30 secondes par défaut)

**3. "Permissions refusées"**
- Vérifiez la configuration ACE dans `server.cfg`
- Assurez-vous d'être dans le bon groupe admin

**4. Problèmes de Synchronisation**
- Vérifiez la connexion réseau
- Testez avec un autre joueur sur le serveur

#### Logs et Debug

- **Console serveur** : Messages de spawn/nettoyage
- **Console client** : Messages de configuration
- **Chat du jeu** : Feedback des commandes

### Mise à Jour

1. **Sauvegardez** votre configuration (`config.lua`)
2. **Remplacez** les fichiers du script
3. **Redémarrez** le serveur
4. **Vérifiez** que tout fonctionne

### Support

Pour toute question ou problème :
- Vérifiez la console serveur pour les erreurs
- Testez avec la configuration par défaut
- Consultez la [documentation FiveM/RedM](https://docs.fivem.net/)

## Architecture Client-Serveur

Le script utilise une architecture **client-serveur** pour une synchronisation optimale :

### 🖥️ Côté Serveur (server/server.lua)
- **Gestion des entités** : Spawn et suppression des zombies
- **Synchronisation réseau** : Tous les joueurs voient les mêmes zombies
- **Thread principal** : Contrôle automatique du spawn/nettoyage
- **Persistance** : Les zombies restent même si un joueur se déconnecte

### 🎮 Côté Client (client/client.lua)
- **Interface utilisateur** : Affichage des marqueurs et messages
- **Configuration locale** : Application des propriétés des zombies
- **Communication** : Envoi des demandes au serveur
- **Thread simplifié** : Uniquement pour l'affichage des marqueurs

### 🔄 Communication Client ↔ Serveur
1. **Commandes** → Le client envoie une demande au serveur
2. **Traitement** → Le serveur effectue l'action (spawn/suppression)
3. **Synchronisation** → L'entité est créée pour tous les clients
4. **Feedback** → Le serveur confirme l'action au client demandeur

## Structure du Script

```
Nouveau dossier/
├── client/
│   └── client.lua          # Logique client (interface, marqueurs, configuration)
├── server/
│   ├── server.lua          # Logique serveur (spawn, nettoyage, synchronisation)
│   └── commands.lua        # Commandes serveur et permissions
├── config.lua              # Configuration complète du système
├── fxmanifest.lua          # Manifest du script RedM
└── ReadMe.md              # Cette documentation
```

### Description des Fichiers

- **`client/client.lua`** : Gestion de l'interface utilisateur et communication avec le serveur
- **`server/server.lua`** : Cœur du système avec synchronisation multi-joueurs
- **`server/commands.lua`** : Commandes disponibles et système de permissions
- **`config.lua`** : Configuration centralisée de tous les paramètres
- **`fxmanifest.lua`** : Configuration du script pour RedM

## Informations Supplémentaires

### Version et Changelog

**Version Actuelle :** 0.0.1
- ✅ Architecture client-serveur complète
- ✅ Synchronisation multi-joueurs
- ✅ Système de zones configurable
- ✅ Commandes admin et utilisateur
- ✅ Interface de marqueurs visuels

### Licence

Ce script est fourni **tel quel** sans garantie d'aucune sorte.
Utilisez-le à vos risques et périls.

### Crédits

Développé pour la communauté RedM/FiveM
Modèles de zombies : Rockstar Games (Red Dead Redemption 2)

---

**🎮 Bon jeu et bonne chasse aux zombies ! 🎮**
