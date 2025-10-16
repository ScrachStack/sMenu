-- config/weapons.lua
Config = {}

Config.Weapons = {
    handguns = {
        { label = "Pistol", model = "WEAPON_PISTOL" },
        { label = "AP Pistol", model = "WEAPON_APPISTOL" },
        { label = "Combat Pistol", model = "WEAPON_COMBATPISTOL" },
        { label = "Pistol 50", model = "WEAPON_PISTOL50" },
        { label = "SNS Pistol", model = "WEAPON_SNSPISTOL" }
    },
    shotguns = {
        { label = "Pump Shotgun", model = "WEAPON_PUMPSHOTGUN" },
        { label = "Sawn-Off Shotgun", model = "WEAPON_SAWNOFFSHOTGUN" }
    },
    assault = {
        { label = "Assault Rifle", model = "WEAPON_ASSAULTRIFLE" },
        { label = "Carbine Rifle", model = "WEAPON_CARBINERIFLE" }
    }
   
}



RegisterNetEvent("vMenu:spawnVehicle", function(model)
    local src = source

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local hash = GetHashKey(model)

    local veh = CreateVehicle(hash, coords.x, coords.y, coords.z, heading, true, true)
    SetVehicleNumberPlateText(veh, "VMENU")

    local netId = NetworkGetNetworkIdFromEntity(veh)
    SetNetworkIdCanMigrate(netId, true)
    SetEntityAsMissionEntity(veh, true, true)
    TriggerClientEvent("vMenu:vehicleSpawned", src, netId)
end)

RegisterNetEvent("vMenu:spawnWeapon", function(weaponModel)
    local src = source
    local ped = GetPlayerPed(src)
    if not weaponModel or weaponModel == "" then return end
    local valid = false
    for _, category in pairs(Config.Weapons) do
        for _, w in pairs(category) do
            if w.model == weaponModel then
                valid = true
                break
            end
        end
    end
    if not valid then
        print(("Player %s tried to spawn invalid weapon: %s"):format(src, weaponModel))
        return
    end
    GiveWeaponToPed(ped, GetHashKey(weaponModel), 9999, false, false) -- 9999 ammo
    SetCurrentPedWeapon(ped, GetHashKey(weaponModel), true)

end)
