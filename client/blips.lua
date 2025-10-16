
Blips = {}
Blips.Config = {
    {name = "Mirror Park PD", coords = vector3(416.3998, -997.1676, 29.3189), sprite = 60, color = 3, scale = 0.8},
    {name = "Sandy Shores PD", coords = vector3(1854.0, 3683.0, 34.0), sprite = 60, color = 3, scale = 0.8},
    {name = "Paleto Bay PD", coords = vector3(-447.5, 6012.0, 31.7), sprite = 60, color = 3, scale = 0.8},

    {name = "Maze Bank", coords = vector3(-75.71, -818.52, 326.17), sprite = 108, color = 2, scale = 0.7},
    {name = "Fleeca Bank – Mirror Park", coords = vector3(147.66, -1044.13, 29.37), sprite = 108, color = 2, scale = 0.7},
    {name = "Fleeca Bank – Paleto Bay", coords = vector3(-105.77, 6473.55, 31.63), sprite = 108, color = 2, scale = 0.7},

    {name = "Sandy Shores Hospital", coords = vector3(1838.77, 3672.87, 34.27), sprite = 61, color = 1, scale = 0.8},
    {name = "Los Santos Airport", coords = vector3(-1034.6, -2733.6, 13.8), sprite = 90, color = 5, scale = 0.9}
}

CreateThread(function()
    for _, blip in ipairs(Blips.Config) do
        local blipCreated = AddBlipForCoord(blip.coords.x, blip.coords.y, blip.coords.z)
        SetBlipSprite(blipCreated, blip.sprite)
        SetBlipDisplay(blipCreated, 4)
        SetBlipScale(blipCreated, blip.scale)
        SetBlipColour(blipCreated, blip.color)
        SetBlipAsShortRange(blipCreated, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blip.name)
        EndTextCommandSetBlipName(blipCreated)
    end
end)


CreateThread(function()
    while true do
        Citizen.Wait(0) 
        if GetPlayerWantedLevel(PlayerId()) ~= 0 then 
            SetPlayerWantedLevel(PlayerId(), 0, false)
            SetPlayerWantedLevelNow(PlayerId(), false)
        end
    end
end)

CreateThread( function()
    while true do
      Citizen.Wait(1000)
      RestorePlayerStamina(PlayerId(), 1.0)
    end
  end)
