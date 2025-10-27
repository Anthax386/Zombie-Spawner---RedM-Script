-- Commandes pour gérer les zombies depuis la console ou le chat
print("Commandes zombies chargées avec succès !")

-- Copie la configuration pour les commandes
local spawnZones = Config.spawnZones

-- Commande pour spawn des zombies manuellement
RegisterCommand("spawnzombies", function(source, args, rawCommand)
    local zoneIndex = tonumber(args[1]) or 1

    if spawnZones[zoneIndex] then
        -- Appelle directement la fonction serveur
        local zone = spawnZones[zoneIndex]
        local zombie = SpawnZombieInZone(zone, zoneIndex)
        if zombie then
            print("Zombie spawné par le joueur " .. source .. " dans la zone " .. zone.name)
            TriggerClientEvent('chat:addMessage', source, {
                args = {"[Zombie Spawner]", "Zombie spawné dans la zone " .. zone.name}
            })
        end
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = {"[Zombie Spawner]", "Zone invalide. Utilisez: /spawnzombies <numéro_zone>"}
        })
    end
end, false) -- false = accessible à tous

-- Commande pour nettoyer tous les zombies (admin seulement)
RegisterCommand("clearzombies", function(source, args, rawCommand)
    if IsPlayerAceAllowed(source, "command") then -- Vérifie les permissions admin
        TriggerClientEvent("zombieSpawner:clearAllZombies", -1) -- -1 = tous les joueurs
        TriggerClientEvent('chat:addMessage', source, {
            args = {"[Zombie Spawner]", "Tous les zombies ont été supprimés"}
        })
        print("Tous les zombies ont été supprimés par l'admin")
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = {"[Zombie Spawner]", "Accès refusé: permissions admin requises"}
        })
    end
end, true) -- true = nécessite d'être admin

-- Commande pour afficher le nombre de zombies (admin seulement)
RegisterCommand("zombiecount", function(source, args, rawCommand)
    if IsPlayerAceAllowed(source, "command") then -- Vérifie les permissions admin
        TriggerClientEvent("zombieSpawner:getZombieCount", source)
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = {"[Zombie Spawner]", "Accès refusé: permissions admin requises"}
        })
    end
end, true) -- true = nécessite d'être admin

print("Commandes zombies chargées avec succès !")