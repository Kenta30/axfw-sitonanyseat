Settings = {
    KeepEngineOn = false, ---Keeps The engine on after leaving the vehicle if the engine is on,
    NPCCheck = true --- Adds NPC Check to the code(Checks if there is any ped inside vehicle or not)
}

RegisterKeyMapping('entercar', 'Enter vehicle', 'KEYBOARD', 'F')

RegisterCommand('entercar', function()
    local dist, index, ped
            ped = PlayerPedId()
            if IsPedInAnyVehicle(ped) then
                if Settings.KeepEngineOn then
                    local veh = GetVehiclePedIsIn(ped)
                    if GetIsVehicleEngineRunning(veh) then
                        TaskLeaveVehicle(ped, veh, 0)
                        Wait(1000)
                        SetVehicleEngineOn(veh, true, true, true)
                    end
                end
            else
                local coords = GetEntityCoords(ped)
                local veh = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 127)
                if veh ~= 0 then
                    --print(veh)
                    if CanSit(veh) then
                        local coords = GetEntityCoords(ped)
                        if #(coords - GetEntityCoords(veh)) <= 3.5 then
                            ClearPedTasks(ped)
                            ClearPedSecondaryTask(ped)
                            for i = 0, GetNumberOfVehicleDoors(veh) do
                                local coord = GetEntryPositionOfDoor(veh, i)
                                if (IsVehicleSeatFree(veh, i - 1) and
                                    GetVehicleDoorLockStatus(veh) ~= 2) then
                                    if dist == nil then
                                        dist = #(coords - coord)
                                        index = i
                                    end
                                    if #(coords - coord) < dist then
                                        dist = #(coords - coord)
                                        index = i
                                    end
                                end
                            end
                            if index then
                                TaskEnterVehicle(ped, veh, 10000, index - 1, 1.0, 1, 0)
                            end
                            index, dist = nil, nil
                        end
                    end
                end
            end
end, false)

CanSit = function(veh)
    if not Settings.NPCCheck then 
        return true 
    end
    for i = -1, 15 do
        if IsEntityAPed(GetPedInVehicleSeat(veh, i)) then return false end
    end
    return true
end
