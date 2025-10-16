--- Save a player's outfit to the database
--- @param outfitName string   -- The name of the outfit being saved
--- @param appearance table    -- The appearance data skin to store
RegisterNetEvent("lvl:core:saveOutfit", function(outfitName, appearance)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)

    exports.oxmysql:insert([[
        INSERT INTO outfits (identifier, name, appearance)
        VALUES (?, ?, ?)
    ]], { identifier, outfitName, json.encode(appearance) })
end)

--- Fetch all saved outfits for the current player and send them back
--- @param src number   -- The server ID of the player requesting their outfits
RegisterNetEvent("lvl:core:getOutfits", function()
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)

    exports.oxmysql:execute([[
        SELECT id, name, appearance FROM outfits WHERE identifier = ?
    ]], {identifier}, function(result)
        print(("[lvl:core] Outfits for %s: %s"):format(identifier, json.encode(result)))
        TriggerClientEvent("lvl:core:sendOutfits", src, result)
    end)
end)

--- Delete a saved outfit for the current player
--- @param outfitName string  -- The name of the outfit to delete
--- @param src number         -- The server ID of the player requesting the deletion
RegisterNetEvent("lvl:core:deleteOutfit", function(outfitName)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0) -- license / identifier

    if not identifier then
        print(("[lvl:core] Failed to get identifier for player %s"):format(src))
        return
    end

    exports.oxmysql:execute(
        "DELETE FROM outfits WHERE identifier = ? AND name = ?",
        { identifier, outfitName },
        function(affectedRows)
            if affectedRows and affectedRows > 0 then
                print(("[lvl:core] Deleted outfit '%s' for %s"):format(outfitName, identifier))
                TriggerClientEvent("lvl:core:outfitDeleted", src, outfitName)
            else
                print(("[lvl:core] No outfit named '%s' found for %s"):format(outfitName, identifier))
            end
        end
    )
end)


RegisterNetEvent("vMenu:sendMessage")
AddEventHandler("vMenu:sendMessage", function(targetId, message)
    local src = source
    local senderName = GetPlayerName(src)
    
    if GetPlayerPing(targetId) > 0 then -- Check if player exists
        TriggerClientEvent('chat:addMessage', targetId, {
            color = {255, 165, 0},
            multiline = true,
            args = {"[Admin Message]", "From " .. senderName .. ": " .. message}
        })
        
        TriggerClientEvent('chat:addMessage', src, {
            color = {0, 255, 0},
            multiline = true,
            args = {"[System]", "Message sent to " .. GetPlayerName(targetId)}
        })
    else
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = true,
            args = {"[Error]", "Player not found"}
        })
    end
end)

RegisterNetEvent("vMenu:kickPlayer")
AddEventHandler("vMenu:kickPlayer", function(targetId, reason)
    local src = source
    local adminName = GetPlayerName(src)
    
    if GetPlayerPing(targetId) > 0 then -- Check if player exists
        local targetName = GetPlayerName(targetId)
        DropPlayer(targetId, "Kicked by " .. adminName .. " - Reason: " .. reason)
        
        TriggerClientEvent('chat:addMessage', -1, {
            color = {255, 165, 0},
            multiline = true,
            args = {"[Admin]", targetName .. " was kicked by " .. adminName .. " - Reason: " .. reason}
        })
    else
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = true,
            args = {"[Error]", "Player not found"}
        })
    end
end)

RegisterNetEvent("vMenu:banPlayer")
AddEventHandler("vMenu:banPlayer", function(targetId, reason)
    local src = source
    local adminName = GetPlayerName(src)
    
    if GetPlayerPing(targetId) > 0 then -- Check if player exists
        local targetName = GetPlayerName(targetId)
        local identifier = GetPlayerIdentifier(targetId, 0)
        
        -- You would typically save this to a database
        -- For now, just kick the player
        DropPlayer(targetId, "Banned by " .. adminName .. " - Reason: " .. reason)
        
        TriggerClientEvent('chat:addMessage', -1, {
            color = {255, 0, 0},
            multiline = true,
            args = {"[Admin]", targetName .. " was banned by " .. adminName .. " - Reason: " .. reason}
        })
    else
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = true,
            args = {"[Error]", "Player not found"}
        })
    end
end)

RegisterNetEvent("vMenu:teleportToPlayer")
AddEventHandler("vMenu:teleportToPlayer", function(targetId)
    local src = source
    
    if GetPlayerPing(targetId) > 0 then -- Check if player exists
        local targetPed = GetPlayerPed(targetId)
        local targetCoords = GetEntityCoords(targetPed)
        
        TriggerClientEvent('vMenu:teleportTo', src, targetCoords.x, targetCoords.y, targetCoords.z)
    else
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = true,
            args = {"[Error]", "Player not found"}
        })
    end
end)

RegisterNetEvent("vMenu:teleportPlayerHere")
AddEventHandler("vMenu:teleportPlayerHere", function(targetId)
    local src = source
    
    if GetPlayerPing(targetId) > 0 then -- Check if player exists
        local adminPed = GetPlayerPed(src)
        local adminCoords = GetEntityCoords(adminPed)
        
        TriggerClientEvent('vMenu:teleportTo', targetId, adminCoords.x, adminCoords.y, adminCoords.z)
    else
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = true,
            args = {"[Error]", "Player not found"}
        })
    end
end)

RegisterNetEvent("vMenu:spawnWeapon")
AddEventHandler("vMenu:spawnWeapon", function(weaponHash, ammo)
    local src = source
    local ammoCount = ammo or 250
    
    TriggerClientEvent('vMenu:giveWeapon', src, weaponHash, ammoCount)
end)
