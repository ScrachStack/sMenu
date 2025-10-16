Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if NetworkIsSessionStarted() then
			TriggerEvent('menu:start')
			return
		end
	end
end)

RegisterNetEvent('menu:start')
AddEventHandler('menu:start', function()
	ShutdownLoadingScreenNui()
	SetCanAttackFriendly(PlayerPedId(), true, false)
	exports['fivem-appearance']:setPlayerModel('mp_m_freemode_01')
	Citizen.Wait(2000)
	NetworkSetFriendlyFireOption(true)
end)

local lastSpawn = 0
local lastVehicleNetId = nil
local vehGodmode = false
local vehNoDamage = false
local vehBoost = false
local outfits = {}

CreateThread(function()
    while true do
        Wait(100)
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        if veh ~= 0 then
            if vehGodmode then
                SetEntityInvincible(veh, true)
            else
                SetEntityInvincible(veh, false)
            end

            if vehNoDamage then
                SetVehicleEngineHealth(veh, 1000.0)
                SetVehiclePetrolTankHealth(veh, 1000.0)
            end

            if vehBoost and IsControlPressed(0, 21) then
                local fwd = GetEntityForwardVector(veh)
                ApplyForceToEntity(veh, 1, fwd.x * 50.0, fwd.y * 50.0, fwd.z * 5.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
            end
        end
    end
end)

RegisterNetEvent("lvl:core:sendOutfits")
AddEventHandler("lvl:core:sendOutfits", function(serverOutfits)
    outfits = serverOutfits
end)

RegisterNetEvent("vMenu:vehicleSpawned", function(netId)
    local veh = NetToVeh(netId)
    if veh ~= 0 and DoesEntityExist(veh) then
        local ped = PlayerPedId()
        TaskWarpPedIntoVehicle(ped, veh, -1)
    end
end)

lib.registerMenu({
    id = 'outfit_menu',
    title = 'Outfit Management',
    position = 'top-right',
    options = {
        {label = 'Create New Outfit', description = 'Open character customization', args = {id = 'create_outfit'}},
        {label = 'Load Outfit', description = 'Load a saved outfit', args = {id = 'load_outfit'}},
        {label = 'Delete Outfit', description = 'Delete a saved outfit', args = {id = 'delete_outfit'}}
    }
}, function(selected, scrollIndex, args)
    if args and args.id then
        if args.id == 'create_outfit' then
            local input = lib.inputDialog('Create Outfit', {
                {type = 'input', label = 'Outfit Name', required = true}
            })
            if input and input[1] then
                exports['fivem-appearance']:startPlayerCustomization(function(appearance)
                    if appearance then
                        TriggerServerEvent("lvl:core:saveOutfit", input[1], appearance)
                    end
                end, {
                    ped = true,
                    headBlend = true,
                    faceFeatures = true,
                    headOverlays = true,
                    components = true,
                    props = true
                })
            end
        elseif args.id == 'load_outfit' then
            TriggerServerEvent("lvl:core:getOutfits")
            Citizen.Wait(100) 
            lib.showMenu('load_outfit_menu')
        elseif args.id == 'delete_outfit' then
            TriggerServerEvent("lvl:core:getOutfits")
            Citizen.Wait(100)
            lib.showMenu('delete_outfit_menu')
        end
    end
end)
local function getOutfitNames() local names = {} for i, outfit in ipairs(outfits) do print(oufit.name) table.insert(names, outfit.name) end return names end
lib.registerMenu({
    id = 'load_outfit_menu',
    title = 'Select Outfit',
    position = 'top-right',
    options = {
        { label = 'Loading outfits...', description = 'Please wait', disabled = true }
    }
}, function(selected, scrollIndex, args)
    if args and args.index and outfits[args.index] then
        local outfit = outfits[args.index]
        local appearance = json.decode(outfit.appearance)
        exports['fivem-appearance']:setPlayerAppearance(appearance)
        lib.notify({
            title = 'Outfit Loaded',
            description = 'Successfully loaded ' .. outfit.name,
            type = 'success'
        })
    end
end)

RegisterNetEvent("lvl:core:sendOutfits", function(serverOutfits)
    outfits = serverOutfits or {}

    local opts = {}
    for i, outfit in ipairs(outfits) do
        table.insert(opts, {
            label = outfit.name,
            description = 'Load this outfit',
            args = { index = i }
        })
    end

    if #opts == 0 then
        table.insert(opts, {
            label = 'No outfits saved',
            description = 'You have no outfits to load',
            disabled = true
        })
    end
    lib.setMenuOptions('load_outfit_menu', opts)
end)

lib.registerMenu({
    id = 'delete_outfit_menu',
    title = 'Delete Outfit',
    position = 'top-right',
    options = {
        {label = 'Select Outfit to Delete', values = getOutfitNames(), description = 'Choose an outfit to delete'}
    }
}, function(selected, scrollIndex, args)
    if selected == 1 and scrollIndex and outfits[scrollIndex] then
        local outfit = outfits[scrollIndex]
        local confirm = lib.alertDialog({
            header = 'Confirm Delete',
            content = 'Are you sure you want to delete "' .. outfit.name .. '"?',
            centered = true,
            cancel = true
        })
        if confirm == 'confirm' then
            TriggerServerEvent("lvl:core:deleteOutfit", outfit.name)
            lib.notify({
                title = 'Outfit Deleted',
                description = 'Successfully deleted ' .. outfit.name,
                type = 'success'
            })
        end
    end
end)

-- lib.registerMenu({
--     id = 'vehicle_spawn_menu',
--     title = 'Spawn Vehicle',
--     position = 'top-right',
--     options = {
--         {label = 'Enter Vehicle Model', description = 'Type the vehicle model name', args = {id = 'spawn_vehicle'}}
--     }
-- }, function(selected, scrollIndex, args)
--     if args and args.id == 'spawn_vehicle' then
--         local input = lib.inputDialog('Spawn Vehicle', {
--             {type = 'input', label = 'Vehicle Model', placeholder = 'adder', required = true}
--         })
--         if input and input[1] then
--             local model = input[1]
--             local now = GetGameTimer()
--             if now - lastSpawn >= 5000 then
--                 lastSpawn = now
                
--                 -- Delete last spawned vehicle if it exists
--                 if lastVehicleNetId then
--                     local oldVeh = NetToVeh(lastVehicleNetId)
--                     if DoesEntityExist(oldVeh) then
--                         DeleteEntity(oldVeh)
--                     end
--                     lastVehicleNetId = nil
--                 end
                
--                 TriggerServerEvent("vMenu:spawnVehicle", model)
--             else
--                 lib.notify({
--                     title = 'Cooldown Active',
--                     description = 'You must wait 5 seconds before spawning another vehicle.',
--                     type = 'error'
--                 })
--             end
--         end
--     end
-- end)
local VehicleConfig = {
    "zr3806str", "schwarzer2", "gauntlet6str", "yosemite6str", "futo2", "ruiner6str",
    "tempesta2", "sentinel6str2", "ellie6str", "elegyrh4", "elegyrh6", "elegyx",
    "zr250", "zr390", "dubsta4x4", "kriegerc", "sancyb4", "buffaloh", "gresleyh",
    "verlierergt", "vulture", "tampar", "supergts", "millennial", "nexus", "serena",
    "tachyon", "coquette4c", "s98", "ariant", "asteropers", "boorc", "rebeld",
    "sigma3", "sultan2c", "sultanrsv8", "sultanrsv82", "sunrise1", "niner", "argento",
    "mantis", "bati901", "infernussr", "matador", "monroei", "monroec", "monroer",
    "monroeiw", "monroerw", "p711", "callista", "cometr", "mf1", "mf1c", "t20gtr",
    "castella", "castellajp", "adders", "sentinelmk4", "sentinelmk4gtr", "sentineldm",
    "vorstand", "contenderc", "domgtcoupe", "sabot", "hachura", "r255", "zodiac",
    "zodiacc", "zodiacr", "stratumc"
}

lib.registerMenu({
    id = 'vehicle_spawn_menu',
    title = 'Spawn Vehicle',
    position = 'top-right',
    options = (function()
        local opts = {}
        for _, vehicle in ipairs(VehicleConfig) do
            table.insert(opts, {
                label = vehicle,
                description = "Spawn " .. vehicle,
                args = {id = 'spawn_vehicle_item', model = vehicle}
            })
        end
        return opts
    end)()
}, function(selected, scrollIndex, args)
    if args and args.id == 'spawn_vehicle_item' then
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)

        lib.requestModel(args.model, 5000) 

        local veh = CreateVehicle(joaat(args.model), coords.x, coords.y, coords.z, heading, true, false)
        SetPedIntoVehicle(ped, veh, -1)
        SetVehicleDirtLevel(veh, 0.0)
        SetEntityAsMissionEntity(veh, true, true)

        lib.notify({
            title = 'Vehicle Spawned',
            description = 'Spawned ' .. args.model,
            type = 'success'
        })
    end
end)

lib.registerMenu({
    id = 'vehicle_menu',
    title = 'Vehicle Management',
    position = 'top-right',
    options = {
        {label = 'Spawn Vehicle', description = 'Spawn a new vehicle', args = {id = 'spawn_vehicle'}},
        {label = 'Repair Vehicle', description = 'Repair current vehicle', args = {id = 'repair_vehicle'}},
        {label = 'Delete Vehicle', description = 'Delete current vehicle', args = {id = 'delete_vehicle'}},
        {label = 'Vehicle Options', description = 'Toggle vehicle features', args = {id = 'vehicle_options'}},
        {label = 'Customize Vehicle', description = 'Modify vehicle appearance', args = {id = 'customize_vehicle'}}
    }
}, function(selected, scrollIndex, args)
    if args and args.id then
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        
        if args.id == 'spawn_vehicle' then
            lib.showMenu('vehicle_spawn_menu')
        elseif args.id == 'repair_vehicle' then
            if veh ~= 0 then
                SetVehicleFixed(veh)
                SetVehicleDirtLevel(veh, 0.0)
                lib.notify({title = 'Vehicle Repaired', type = 'success'})
            else
                lib.notify({title = 'Not in a vehicle', type = 'error'})
            end
        elseif args.id == 'delete_vehicle' then
            if veh ~= 0 then
                DeleteEntity(veh)
                lib.notify({title = 'Vehicle Deleted', type = 'success'})
            else
                lib.notify({title = 'Not in a vehicle', type = 'error'})
            end
        elseif args.id == 'vehicle_options' then
            lib.showMenu('vehicle_options_menu')
        elseif args.id == 'customize_vehicle' then
            lib.showMenu('vehicle_customize_menu')
        end
    end
end)

-- Vehicle Options Menu
lib.registerMenu({
    id = 'vehicle_options_menu',
    title = 'Vehicle Options',
    position = 'top-right',
    onCheck = function(selected, checked, args)
        if selected == 1 then -- Godmode
            vehGodmode = checked
        elseif selected == 2 then -- No Damage
            vehNoDamage = checked
        elseif selected == 3 then -- Boost
            vehBoost = checked
        end
    end,
    options = {
        {label = 'Vehicle Godmode', checked = vehGodmode, description = 'Makes vehicle invincible'},
        {label = 'No Damage', checked = vehNoDamage, description = 'Prevents engine damage'},
        {label = 'Boost Mode', checked = vehBoost, description = 'Hold Shift for boost'}
    }
})

lib.registerMenu({
    id = 'vehicle_customize_menu',
    title = 'Customize Vehicle',
    position = 'top-right',
    onSelected = function(selected, secondary, args)
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        if veh == 0 then
            lib.notify({title = 'Not in a vehicle', type = 'error'})
            return
        end
        
        if selected == 1 then -- Random Paint
            SetVehicleColours(veh, math.random(0, 159), math.random(0, 159))
            lib.notify({title = 'Paint Applied', type = 'success'})
        elseif selected == 2 then -- Random Wheels
            SetVehicleWheelType(veh, math.random(0, 7))
            SetVehicleMod(veh, 23, math.random(0, 10), false)
            lib.notify({title = 'Wheels Changed', type = 'success'})
        elseif selected == 3 then -
            SetVehicleModKit(veh, 0)
            SetVehicleMod(veh, 11, GetNumVehicleMods(veh, 11) - 1, false) -- Engine
            SetVehicleMod(veh, 12, GetNumVehicleMods(veh, 12) - 1, false) -- Brakes
            SetVehicleMod(veh, 13, GetNumVehicleMods(veh, 13) - 1, false) -- Transmission
            lib.notify({title = 'Performance Upgraded', type = 'success'})
        end
    end,
    options = {
        {label = 'Random Paint Job', description = 'Apply random colors'},
        {label = 'Random Wheels', description = 'Change wheel type and style'},
        {label = 'Max Performance', description = 'Upgrade engine, brakes, transmission'}
    }
})

local WeaponsConfig = {
    Handguns = {
        {name = "Pistol", hash = "weapon_pistol", price = 699, description = "Most reliable and dependable sidearm for law-enforcement, military and personal defense.", ammo = 500},
        {name = "Combat Pistol", hash = "weapon_combatpistol", price = 549, description = "Short recoil-operated, semi-automatic pistol designed and produced by Hawk & Little.", ammo = 500},
        {name = "AP Pistol", hash = "weapon_appistol", price = 6100, description = "High-penetration, fully-automatic pistol. Holds 18 rounds in the magazine.", ammo = 500},
        {name = "Pistol .50", hash = "weapon_pistol50", price = 2550, description = "High-impact pistol that delivers immense power but with extremely strong recoil.", ammo = 500},
        {name = "SNS Pistol", hash = "weapon_snspistol", price = 300, description = "Fits in your pocket for a night on the town.", ammo = 500},
        {name = "Heavy Pistol", hash = "weapon_heavypistol", price = 1100, description = "The heavyweight champion. Delivers accuracy and a serious forearm workout.", ammo = 500},
        {name = "Heavy Revolver", hash = "weapon_revolver", price = 5900, description = "A handgun with enough stopping power to drop a crazed rhino.", ammo = 500},
        {name = "Double Action Revolver", hash = "weapon_doubleaction", price = 279, description = "Sometimes revenge is a dish best served six times.", ammo = 500}
    },
    SubmachineGuns = {
        {name = "Micro SMG", hash = "weapon_microsmg", price = 2400, description = "Compact design with a high rate of fire at 700-900 RPM.", ammo = 500},
        {name = "SMG", hash = "weapon_smg", price = 2150, description = "Good all-around SMG. Lightweight with accurate sight.", ammo = 500},
        {name = "Assault SMG", hash = "weapon_assaultsmg", price = 1480, description = "High-capacity submachine gun. Holds up to 30 bullets.", ammo = 500},
        {name = "Combat PDW", hash = "weapon_combatpdw", price = 1799, description = "Personal weapon worthy of military personnel. Integral suppressor.", ammo = 500},
        {name = "Machine Pistol", hash = "weapon_machinepistol", price = 1100, description = "Perfect for high-speed chaos.", ammo = 500},
        {name = "Mini SMG", hash = "weapon_minismg", price = 1240, description = "Popular for low income areas and compact use.", ammo = 500}
    },
    Shotguns = {
        {name = "Pump Shotgun", hash = "weapon_pumpshotgun", price = 800, description = "Standard shotgun ideal for short-range combat.", ammo = 500},
        {name = "Sawed-Off Shotgun", hash = "weapon_sawnoffshotgun", price = 450, description = "Single-barrel, devastating in close combat.", ammo = 500},
        {name = "Musket", hash = "weapon_musket", price = 1600, description = "Armed with muskets, with a superiority complex.", ammo = 500},
        {name = "Double Barrel Shotgun", hash = "weapon_dbshotgun", price = 300, description = "Turns the other guy into a fine mist.", ammo = 500},
        {name = "Sweeper Shotgun", hash = "weapon_autoshotgun", price = 995, description = "Effective tool for riot control.", ammo = 500},
        {name = "Combat Shotgun", hash = "weapon_combatshotgun", price = 1200, description = "Semi-automatic shotgun with high fire rate.", ammo = 500}
    },
    AssaultRifles = {
        {name = "Assault Rifle", hash = "weapon_assaultrifle", price = 8280, description = "Large capacity magazine and long distance accuracy.", ammo = 500},
        {name = "Carbine Rifle", hash = "weapon_carbinerifle", price = 9700, description = "Long distance accuracy with high capacity magazine.", ammo = 500},
        {name = "Advanced Rifle", hash = "weapon_advancedrifle", price = 8800, description = "Lightweight and compact without compromising accuracy.", ammo = 500},
        {name = "Special Carbine", hash = "weapon_specialcarbine", price = 7200, description = "Accurate, maneuverable and versatile.", ammo = 500},
        {name = "Bullpup Rifle", hash = "weapon_bullpuprifle", price = 1750, description = "Balanced handling rifle.", ammo = 500},
        {name = "Compact Rifle", hash = "weapon_compactrifle", price = 2390, description = "Half the size, all the power.", ammo = 500}
    },
    LightMachineGuns = {
        {name = "MG", hash = "weapon_mg", price = 8500, description = "General purpose machine, long-range penetrative power.", ammo = 500},
        {name = "Combat MG", hash = "weapon_combatmg", price = 9530, description = "Lightweight with high rate of fire to devastating effect.", ammo = 500},
        {name = "Gusenberg Sweeper", hash = "weapon_gusenberg", price = 2800, description = "Looks great sticking out the window of a Roosevelt.", ammo = 500}
    }
}

lib.registerMenu({
    id = 'weapon_menu',
    title = 'Weapon Management',
    position = 'top-right',
    options = (function()
        local opts = {}
        table.insert(opts, {
            label = "Spawn Weapon by Name",
            description = "Enter weapon hash/name manually",
            args = {id = "spawn_weapon"}
        })
        for categoryName, weapons in pairs(WeaponsConfig) do
            table.insert(opts, {
                label = categoryName,
                description = "Open " .. categoryName .. " weapons",
                args = {id = "open_category", category = categoryName},
                close = false
            })
        end

        return opts
    end)()
}, function(selected, scrollIndex, args)
    if not args or not args.id then return end
    if args.id == "spawn_weapon" then
        local input = lib.inputDialog('Spawn Weapon', {
            {type = 'input', label = 'Weapon Name', placeholder = 'weapon_pistol', required = true}
        })
        if input and input[1] then
            TriggerServerEvent("vMenu:spawnWeapon", input[1])
        end
    elseif args.id == "open_category" then
        local categoryWeapons = WeaponsConfig[args.category]
        if not categoryWeapons then return end
        lib.registerMenu({
            id = 'weapon_menu_' .. args.category,
            title = args.category,
            position = 'top-right',
            options = (function()
                local subOpts = {}
                for _, weapon in ipairs(categoryWeapons) do
                    table.insert(subOpts, {
                        label = weapon.name,
                        description = weapon.description .. " | Price: $" .. weapon.price,
                        args = {id = "spawn_weapon_item", hash = weapon.hash, ammo = weapon.ammo}
                    })
                end
                return subOpts
            end)()
        }, function(_, _, subArgs)
            if subArgs and subArgs.id == "spawn_weapon_item" then
                TriggerServerEvent("vMenu:spawnWeapon", subArgs.hash, subArgs.ammo)
                GiveWeaponToPed(
	cache.ped --[[ Ped ]], 
	subArgs.hash --[[ Hash ]], 
	subArgs.ammo --[[ integer ]], 
	false --[[ boolean ]], 
	true --[[ boolean ]]
)


                print(subArgs.hash)
                lib.notify({
                    title = "Weapon Spawned",
                    description = "Spawned " .. subArgs.hash .. " with " .. subArgs.ammo .. " rounds",
                    type = "success"
                })
            end
        end)

        -- Show the submenu
        lib.showMenu('weapon_menu_' .. args.category)
    end
end)



-- Player Options Menu
lib.registerMenu({
    id = 'player_options_menu',
    title = 'Player Options',
    position = 'top-right',
    options = {
        {label = 'Heal Player', description = 'Restore full health', args = {id = 'heal_player'}},
        {label = 'Give Armor', description = 'Set armor to 100%', args = {id = 'give_armor'}},
        {label = 'Clean Player', description = 'Remove dirt and blood', args = {id = 'clean_player'}},
        {label = 'Dry Player', description = 'Remove wetness', args = {id = 'dry_player'}}
    }
}, function(selected, scrollIndex, args)
    if args and args.id then
        local player = PlayerPedId()
        if args.id == 'heal_player' then
            local maxHealth = GetEntityMaxHealth(player)
            SetEntityHealth(player, maxHealth)
            lib.notify({title = 'Player Healed', type = 'success'})
        elseif args.id == 'give_armor' then
            SetPedArmour(player, 100)
            lib.notify({title = 'Armor Applied', type = 'success'})
        elseif args.id == 'clean_player' then
            ClearPedBloodDamage(player)
            ClearPedDamageDecalByZone(player, 0, "ALL")
            lib.notify({title = 'Player Cleaned', type = 'success'})
        elseif args.id == 'dry_player' then
            ClearPedWetness(player)
            lib.notify({title = 'Player Dried', type = 'success'})
        end
    end
end)

lib.registerMenu({
    id = 'teleport_options_menu',
    title = 'Teleport Options',
    position = 'top-right',
    options = {
        {label = 'Select Location', values = {'Sandy Shores', 'Los Santos', 'Mirror Park'}, description = 'Choose a location to teleport to'}
    }
}, function(selected, scrollIndex, args)
    if selected == 1 and scrollIndex then
        local player = PlayerPedId()
        local coords = {}
        
        if scrollIndex == 1 then 
            coords = {x = 1782.7810, y = 3325.0977, z = 41.3054} 
        elseif scrollIndex == 2 then 
            coords = {x = 196.6453, y = -928.1542, z = 30.6868}
        elseif scrollIndex == 3 then 
            coords = {x = 1150.7673, y = -556.3683, z = 63.5406} 
      
        end
        
        if coords.x then
            SetEntityCoords(player, coords.x, coords.y, coords.z, false, false, false, true)
            local locationNames = {'Sandy Shores', 'Los Santos', 'Mirror Park', 'RV Park'}
            lib.notify({title = 'Teleported', description = 'Teleported to ' .. locationNames[scrollIndex], type = 'success'})
        end
    end
end)

lib.registerMenu({
    id = 'online_players_menu',
    title = 'Online Players',
    position = 'top-right',
    options = (function()
        local players = {}
        for _, player in pairs(GetActivePlayers()) do
            local playerId = GetPlayerServerId(player)
            local playerName = GetPlayerName(player)
            table.insert(players, {
                label = playerName .. ' - ' .. playerId,
                description = 'Manage player ' .. playerName,
                args = {id = 'player_manage', playerId = playerId, playerName = playerName}
            })
        end
        if #players == 0 then
            table.insert(players, {label = 'No players online', disabled = true})
        end
        return players
    end)()
}, function(selected, scrollIndex, args)
    if args and args.id == 'player_manage' then
        lib.registerMenu({
            id = 'player_manage_' .. args.playerId,
            title = 'Manage ' .. args.playerName,
            position = 'top-right',
            options = {
                {label = 'Message Player', description = 'Send a message to this player', args = {id = 'message', playerId = args.playerId, playerName = args.playerName}},
                {label = 'Kick Player', description = 'Kick this player from server', args = {id = 'kick', playerId = args.playerId, playerName = args.playerName}},
                {label = 'Ban Player', description = 'Ban this player from server', args = {id = 'ban', playerId = args.playerId, playerName = args.playerName}},
                {label = 'Teleport To Player', description = 'Teleport to this player', args = {id = 'teleport_to', playerId = args.playerId, playerName = args.playerName}},
                {label = 'Teleport Player To You', description = 'Bring this player to you', args = {id = 'teleport_here', playerId = args.playerId, playerName = args.playerName}}
            }
        }, function(_, _, subArgs)
            if subArgs and subArgs.id then
                if subArgs.id == 'message' then
                    local input = lib.inputDialog('Send Message', {
                        {type = 'input', label = 'Message', required = true}
                    })
                    if input and input[1] then
                        TriggerServerEvent("vMenu:sendMessage", subArgs.playerId, input[1])
                        lib.notify({title = 'Message Sent', description = 'Message sent to ' .. subArgs.playerName, type = 'success'})
                    end
                elseif subArgs.id == 'kick' then
                    local input = lib.inputDialog('Kick Player', {
                        {type = 'input', label = 'Reason', required = true}
                    })
                    if input and input[1] then
                        TriggerServerEvent("vMenu:kickPlayer", subArgs.playerId, input[1])
                        lib.notify({title = 'Player Kicked', description = 'Kicked ' .. subArgs.playerName, type = 'success'})
                    end
                elseif subArgs.id == 'ban' then
                    local input = lib.inputDialog('Ban Player', {
                        {type = 'input', label = 'Reason', required = true}
                    })
                    if input and input[1] then
                        TriggerServerEvent("vMenu:banPlayer", subArgs.playerId, input[1])
                        lib.notify({title = 'Player Banned', description = 'Banned ' .. subArgs.playerName, type = 'success'})
                    end
                elseif subArgs.id == 'teleport_to' then
                    TriggerServerEvent("vMenu:teleportToPlayer", subArgs.playerId)
                    lib.notify({title = 'Teleported', description = 'Teleported to ' .. subArgs.playerName, type = 'success'})
                elseif subArgs.id == 'teleport_here' then
                    TriggerServerEvent("vMenu:teleportPlayerHere", subArgs.playerId)
                    lib.notify({title = 'Player Teleported', description = subArgs.playerName .. ' teleported to you', type = 'success'})
                end
            end
        end)
        
        lib.showMenu('player_manage_' .. args.playerId)
    end
end)


-- Main Menu
lib.registerMenu({
    id = 'main_menu',
    title = 'vMenu',
    position = 'top-right',
    options = {
        {label = 'Online Players', description = 'View and manage online players', args = {id = 'online_players'}},
        {label = 'Player Options', description = 'Heal, armor, clean, dry player', args = {id = 'player_options'}},
        {label = 'Outfit Management', description = 'Manage character outfits', args = {id = 'outfit_menu'}},
        {label = 'Vehicle Management', description = 'Spawn and manage vehicles', args = {id = 'vehicle_menu'}},
        {label = 'Teleport Options', description = 'Teleport to different locations', args = {id = 'teleport_options'}},
        {label = 'Weapon Management', description = 'Spawn weapons', args = {id = 'weapon_menu'}}
    }
}, function(selected, scrollIndex, args)
    if args and args.id then
        if args.id == 'online_players' then
            lib.showMenu('online_players_menu')
        elseif args.id == 'player_options' then
            lib.showMenu('player_options_menu')
        elseif args.id == 'outfit_menu' then
            TriggerServerEvent("lvl:core:getOutfits")
            lib.showMenu('outfit_menu')
        elseif args.id == 'vehicle_menu' then
            lib.showMenu('vehicle_menu')
        elseif args.id == 'teleport_options' then
            lib.showMenu('teleport_options_menu')
        elseif args.id == 'weapon_menu' then
            lib.showMenu('weapon_menu')
        end
    end
end)
RegisterCommand('openmainmenu', function()
    lib.showMenu('main_menu')
end)

RegisterKeyMapping('openmainmenu', 'Open vMenu', 'keyboard', 'F1')
