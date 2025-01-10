local showStats = false

-- Toggle HP Display Command /car_showstats
RegisterCommand("car_showstats", function()
    showStats = not showStats
    if showStats then
        TriggerEvent('chat:addMessage', {
            color = { 0, 255, 0 },
            multiline = true,
            args = {"System", "Vehicle stats display enabled."}
        })
    else
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            multiline = true,
            args = {"System", "Vehicle stats display disabled."}
        })
    end
end, false)

-- Function: Draw 3D Text
function DrawText3D(x, y, z, text)
    SetDrawOrigin(x, y, z, 0)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEdge(2, 0, 0, 0, 150) -- Adds outline to the text
    SetTextOutline() -- Ensures text stands out
    SetTextColour(255, 255, 255, 215) -- White color
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

-- Function: Get Health Dynamically
function GetMaxBodyHealth(vehicle)
    local deformationMult = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fDeformationDamageMult') or 1.0
    local collisionMult = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fCollisionDamageMult') or 1.0
    return math.floor(1000.0 * (1.0 / math.max(deformationMult, collisionMult)) + 0.5) -- Ensure proper rounding
end

-- Function: Calculate Actual Body Health
function GetActualBodyHealth(vehicle)
    local rawBodyHealth = GetVehicleBodyHealth(vehicle)
    local maxBodyHealth = GetMaxBodyHealth(vehicle)
    return math.min(rawBodyHealth, maxBodyHealth)
end

-- Display Stats
CreateThread(function()
    while true do
        Wait(0)

        if showStats then
            local playerPed = PlayerPedId()
            local playerPos = GetEntityCoords(playerPed)
            local playerVehicle = GetVehiclePedIsIn(playerPed, false)

            -- Stats when Player inside Vehicle
            if playerVehicle ~= 0 and IsPedInAnyVehicle(playerPed, false) then
                local vehiclePos = GetEntityCoords(playerVehicle)
                local engineHealth = GetVehicleEngineHealth(playerVehicle)
                local bodyHealth = GetActualBodyHealth(playerVehicle) -- Use dynamic max body health

                -- Stats positioning
                DrawText3D(vehiclePos.x, vehiclePos.y, vehiclePos.z + 1.5, string.format("Engine HP: %.2f", engineHealth))
                DrawText3D(vehiclePos.x, vehiclePos.y, vehiclePos.z + 1.3, string.format("Body HP: %.2f", bodyHealth))
            end

            -- Stats for nearby vehicle and player not inside vehicle
            if not IsPedInAnyVehicle(playerPed, false) then
                local vehicles = GetVehiclesInArea(playerPos, 50.0) -- Nearby vehs
                for _, vehicle in ipairs(vehicles) do
                    if vehicle ~= playerVehicle then -- Exclude the player's current vehicle entirely
                        local vehiclePos = GetEntityCoords(vehicle)
                        local engineHealth = GetVehicleEngineHealth(vehicle)
                        local bodyHealth = GetActualBodyHealth(vehicle)

                        -- Stats positioning
                        DrawText3D(vehiclePos.x, vehiclePos.y, vehiclePos.z + 1.5, string.format("Engine HP: %.2f", engineHealth))
                        DrawText3D(vehiclePos.x, vehiclePos.y, vehiclePos.z + 1.3, string.format("Body HP: %.2f", bodyHealth))
                    end
                end
            end
        end
    end
end)

-- Function: Show Nearby Vehicles
function GetVehiclesInArea(coords, radius)
    local vehicles = {}
    local handle, vehicle = FindFirstVehicle()
    local success

    repeat
        local vehicleCoords = GetEntityCoords(vehicle)
        if #(vehicleCoords - coords) <= radius then
            table.insert(vehicles, vehicle)
        end
        success, vehicle = FindNextVehicle(handle)
    until not success

    EndFindVehicle(handle)
    return vehicles
end



