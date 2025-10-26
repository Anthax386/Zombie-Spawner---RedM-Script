# Zombie Spawner RedM

**Système de spawn de zombies avec synchronisation multi-joueurs pour Red Dead Redemption 2**

Un script complet pour créer et gérer des zombies dans votre serveur RedM avec une architecture client-serveur optimisée pour le multijoueur.

## 📋 Table des Matières

- [🔧 Fonctionnalités](#fonctionnalités)
- [⚡ Prérequis Techniques](#prérequis-techniques)
- [🚀 Installation Rapide](#installation-rapide)
- [📦 Installation Détaillée](#installation-détaillée)
  - [Installation](#installation)
  - [Configuration de Base](#configuration-de-base)
  - [Configuration Avancée](#configuration-avancée)
- [📋 Commandes Disponibles](#commandes-disponibles)
- [✅ Vérification de l'Installation](#vérification-de-linstallation)
- [⚙️ Configuration Détaillée](#configuration-détaillée)
  - [Messages](#messages)
  - [Modèles de Zombies](#modèles-de-zombies)
  - [Statistiques des Zombies](#statistiques-des-zombies)
  - [Comportement au Combat](#comportement-au-combat)
  - [Relations](#relations)
  - [Zones de Spawn](#zones-de-spawn)
  - [Paramètres des Zones](#paramètres-des-zones)
- [🏗️ Architecture Client-Serveur](#architecture-client-serveur)
- [📁 Structure du Script](#structure-du-script)
- [🆘 Support et Dépannage](#support-et-dépannage)
- [📋 Informations Supplémentaires](#informations-supplémentaires)

## 🔧 Fonctionnalités {#fonctionnalités}

- ✅ **Synchronisation multi-joueurs** complète
- ✅ **Système de zones** configurables
- ✅ **Commandes admin** et utilisateur
- ✅ **Marqueurs visuels** des zones
- ✅ **Configuration avancée** des zombies
- ✅ **Nettoyage automatique** des entités
- ✅ **Optimisé performance** avec variables locales

## ⚡ Prérequis Techniques {#prérequis-techniques}

- **RedM Server** build 2802 ou supérieur
- **FiveM/RedM Framework** correctement configuré
- **Accès administrateur** au serveur de jeu
- **Connaissance de base** de la configuration Lua (optionnel)

## 🚀  Installation Rapide {#installation-rapide}

1. **Placez** le dossier dans `resources/`
2. **Ajoutez** `ensure Zombie-Spawner` dans `server.cfg`
3. **Redémarrez** votre serveur
4. **Testez** avec `/zombiecount`

## 📦 Installation Détaillée {#installation-détaillée}

### 1. Installation {#1-installation}

1. **Téléchargez** le dossier `Zombie-Spawner`
2. **Placez-le** dans votre répertoire `resources/[nom_de_votre_serveur]/`
3. **Ajoutez** cette ligne dans votre `server.cfg` :
   ```cfg
   ensure Zombie-Spawner
   ```
4. **Redémarrez** votre serveur RedM

### 2. Configuration de Base {#2-configuration-de-base}

#### Configuration des Zones
Modifiez `config.lua` pour définir vos zones de spawn :

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

#### Configuration des Permissions (Optionnel)

Ajoutez ces lignes dans votre `server.cfg` :

```cfg
# Permissions Zombie Spawner
add_ace group.admin command.clearzombies allow
add_ace group.admin command.zombiecount allow
add_ace group.moderator command.zombiecount allow
```

### 3. Configuration Avancée {#3-configuration-avancée} 

#### A. Statistiques des Zombies
```lua
Config.zombieStats = {
    health = 100.0,
    accuracy = 0.3,
    speed = 0.7,
    aggression = 0.8
}
```

#### B. Modèles Disponibles
```lua
Config.zombieModels = {
    "A_M_M_UniCorpse_01",
    "A_M_M_UniCorpse_02",
    "A_F_M_UniCorpse_01",
    "A_F_M_UniCorpse_02"
}
```

#### C. Marqueurs Visuels
```lua
Config.zoneSettings = {
    showMarkers = true,
    markerColor = {255, 0, 0, 100},
    cleanupDistance = 200.0
}
```

## 📋 Commandes Disponibles {#commandes-disponibles}

| Commande | Description | Permission | Exemple |
|----------|-------------|------------|---------|
| `/zombiecount` | Affiche le nombre de zombies actifs | Admin | `/zombiecount` |
| `/clearzombies` | Supprime tous les zombies | Admin | `/clearzombies` |
| `/spawnzombies <zone>` | Spawn un zombie dans une zone | Tous | `/spawnzombies 1` |

## ✅ Vérification de l'Installation {#vérification-de-linstallation}

1. **Démarrez** votre serveur RedM
2. **Connectez-vous** au serveur
3. **Testez les commandes :**
   - `/zombiecount` - Vérifier le système
   - `/spawnzombies 1` - Tester le spawn manuel
   - `/clearzombies` - Tester le nettoyage (admin)

4. **Vérifiez la console serveur** pour ces messages :
   ```
   Script serveur Zombie Spawner chargé avec succès !
   Script client Zombie Spawner chargé avec succès !
   Commandes zombies chargées avec succès !
   ```

## ⚙️ Configuration Détaillée {#configuration-détaillée}

### Messages {#messages}

Ces paramètres définissent les couleurs et le préfixe des messages

**PARAMÈTRES:**
- `colors`: Couleurs des messages en RGB (0-255)
- `prefix`: Préfixe des messages

```lua
Config.messages = {
    colors = {
        success = {0, 255, 0},
        error = {255, 0, 0},
        info = {0, 150, 255}
    },
    prefix = "[Zombie Spawner]"
}
```

### Modèles de Zombies {#modèles-de-zombies} 

Cette table contient tous les modèles de zombies que le script peut utiliser.
Le script en choisira un au hasard à chaque spawn.

**COMMENT AJOUTER DES MODÈLES:**
1. Ajoutez simplement une nouvelle ligne avec le nom du modèle
2. Assurez-vous que le modèle existe dans le jeu
3. Utilisez des virgules pour séparer les modèles

```lua
Config.zombieModels = {
    "A_M_M_UniCorpse_01",
    "A_M_M_UniCorpse_02",
    "A_F_M_UniCorpse_01",
    "A_F_M_UniCorpse_02"
}
```

### Statistiques des Zombies {#statistiques-des-zombies}

Ces paramètres définissent les statistiques par défaut de tous les zombies.

**PARAMÈTRES:**
- `health`: Points de vie du zombie (recommandé: 100-500)
- `accuracy`: Précision du tir (0.0 = jamais, 1.0 = toujours)
- `speed`: Vitesse de déplacement (1.0 = normal, 0.5 = lent, 2.0 = rapide)
- `aggression`: Agressivité (0.0 = passif, 1.0 = très agressif)

```lua
Config.zombieStats = {
    health = 100.0,
    accuracy = 0.3,
    speed = 0.7,
    aggression = 0.8
}
```

### Comportement au Combat {#comportement-au-combat}

Ces paramètres définissent le comportement des zombies au combat.

**PARAMÈTRES:**
- `combatAbility`: Niveau de compétence au combat (0-2)
- `combatRange`: Distance de combat préférée (0-2)
- `combatMovement`: Style de mouvement au combat (0-3)
- `alwaysFight`: Attribut RedM (46)
- `useMeleeWeapons`: Attribut RedM (5)

```lua
Config.combatBehavior = {
    combatAbility = 2,
    combatRange = 0,
    combatMovement = 2,
    alwaysFight = 46,
    useMeleeWeapons = 5
}
```

### Relations {#relations}

Ces paramètres définissent comment les zombies réagissent aux autres entités.

**PARAMÈTRES:**
- `playerRelationship`: Relation avec le joueur
- `civilianRelationship`: Relation avec les civils
- `gangRelationship`: Relation avec les gangs
- `animalRelationship`: Relation avec les animaux domestiques
- `wildAnimalRelationship`: Relation avec les animaux sauvages

**VALEURS:** 0 = Neutre, 5 = Haine (attaquent)

```lua
Config.relationships = {
    playerRelationship = 5,
    civilianRelationship = 5,
    gangRelationship = 5,
    animalRelationship = 5,
    wildAnimalRelationship = 5
}
```

### Zones de Spawn {#zones-de-spawn}

Ces paramètres définissent les zones où les zombies peuvent spawner.

**PARAMÈTRES:**
- `name`: Nom unique pour identifier la zone
- `coords`: Position centrale de la zone (vector3)
- `radius`: Rayon de spawn autour du centre
- `maxZombies`: Nombre maximum de zombies simultanés dans cette zone
- `enabled`: true = zone active, false = zone désactivée
- `spawnInterval`: Intervalle entre chaque spawn (optionnel)

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

### Statistiques des Zombies {#statistiques-des-zombies}

Ces paramètres définissent les statistiques par défaut de tous les zombies.

**PARAMÈTRES:**
- `health`: Points de vie du zombie (recommandé: 100-500)
- `accuracy`: Précision du tir (0.0 = jamais, 1.0 = toujours)
- `speed`: Vitesse de déplacement (1.0 = normal, 0.5 = lent, 2.0 = rapide)
- `aggression`: Agressivité (0.0 = passif, 1.0 = très agressif)

```lua
Config.zombieStats = {
    health = 100.0,
    accuracy = 0.3,
    speed = 0.7,
    aggression = 0.8
}
```

### Comportement au Combat {#comportement-au-combat}

Ces paramètres définissent le comportement des zombies au combat.

**PARAMÈTRES:**
- `combatAbility`: Niveau de compétence au combat (0-2)
- `combatRange`: Distance de combat préférée (0-2)
- `combatMovement`: Style de mouvement au combat (0-3)
- `alwaysFight`: Attribut RedM (46)
- `useMeleeWeapons`: Attribut RedM (5)

```lua
Config.combatBehavior = {
    combatAbility = 2,
    combatRange = 0,
    combatMovement = 2,
    alwaysFight = 46,
    useMeleeWeapons = 5
}
```

## 🏗️ Architecture Client-Serveur {#architecture-client-serveur}

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

## 📁 Structure du Script {#structure-du-script}

```
Zombie-Spawner/
├── client/
│   └── client.lua          # Logique client (interface, marqueurs)
├── server/
│   ├── server.lua          # Logique serveur (spawn, nettoyage, synchro)
│   └── commands.lua        # Commandes serveur
├── config.lua              # Configuration
└── fxmanifest.lua          # Manifest du script
```

## 🆘 Support et Dépannage {#support-et-dépannage}

### Problèmes Courants

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

### Logs et Debug   

- **Console serveur** : Messages de spawn/nettoyage
- **Console client** : Messages de configuration
- **Chat du jeu** : Feedback des commandes

### Mise à Jour 

1. **Sauvegardez** votre configuration (`config.lua`)
2. **Remplacez** les fichiers du script
3. **Redémarrez** le serveur
4. **Vérifiez** que tout fonctionne

## 📋 Informations Supplémentaires {#informations-supplémentaires}

### Version et Changelog 

**Version Actuelle :** 1.0.0
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