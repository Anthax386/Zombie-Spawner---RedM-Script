Config = {}
Lang = "Français"

Config.threadSettings = {
    threadInterval = 5000
}

Config.messages = {
    colors = {
        success = {0, 255, 0},      -- Vert
        error = {255, 0, 0},        -- Rouge
        info = {0, 150, 255}        -- Bleu
    },
    prefix = "[Zombie Spawner]" 
}


Config.ZombieModels = {
    "A_M_M_UniCorpse_01",
    "A_M_M_UniCorpse_02",
    "A_F_M_UniCorpse_01",
    "A_F_M_UniCorpse_02"
}

Config.ZombieStats = {
    health = 100.0,
    damageModifier = 1,
    accuracy = 0.3,
    speed = 0.7,
    aggression = 0.8,
}

Config.combatBehavior = {
    combatAbility = 2,
    combatRange = 0,
    combatMovement = 2,
    alwaysFight = 46,
    useMeleeWeapons = 5
}

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

Config.zoneSettings = {
    spawnInterval = 30000,
    cleanupDistance = 200.0,
    showMarkers = false,
    markerColor = {255, 0, 0, 100},
    
}