local playerList = {}
local disconnectedPlayers = {}
local showingPlayerIds = false
local uiOpen = false

RegisterKeyMapping(Config.Settings.command, 'Open Player List', 'keyboard', Config.Settings.keybind)

local function closeUi()
    if not uiOpen then
        return
    end

    uiOpen = false
    showingPlayerIds = false

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)

    SendNUIMessage({ type = 'CLOSE' })
end

local function openUi()
    SendNUIMessage({
        type = 'OPEN',
        data = {
            activePlayers = playerList,
            disconnectedPlayers = disconnectedPlayers,
        },
    })

    uiOpen = true
    showingPlayerIds = true

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(true)
end

RegisterCommand(Config.Settings.command, function()
    TriggerServerEvent('exter-playerlist:server:requestData')
end, false)

RegisterNetEvent('exter-playerlist:client:receiveData', function(payload)
    playerList = payload.activePlayers or {}
    disconnectedPlayers = payload.disconnectedPlayers or {}
    openUi()
end)

RegisterNetEvent('exter-playerlist:client:accessDenied', function()
    TriggerEvent('chat:addMessage', {
        color = { 255, 0, 0 },
        multiline = false,
        args = { 'PlayerList', 'You do not have permission to use this command.' },
    })
end)

RegisterNUICallback('getData', function(data, cb)
    if data.variable == 'online' then
        cb(playerList)
    else
        cb(disconnectedPlayers)
    end
end)

RegisterNUICallback('close', function(_, cb)
    closeUi()
    cb(true)
end)

CreateThread(function()
    while true do
        if uiOpen and IsControlJustReleased(0, 322) then
            closeUi()
        end

        if showingPlayerIds then
            local playerPed = PlayerPedId()
            local myCoords = GetEntityCoords(playerPed)

            for _, localPlayer in ipairs(GetActivePlayers()) do
                local targetPed = GetPlayerPed(localPlayer)
                if targetPed ~= playerPed then
                    local coords = GetEntityCoords(targetPed)
                    if #(myCoords - coords) <= (Config.Settings.showDistance or 15.0) then
                        local serverId = GetPlayerServerId(localPlayer)
                        DrawText3D(coords.x, coords.y, coords.z + 1.0, tostring(serverId))
                    end
                end
            end
        end

        Wait(Config.Settings.refreshDelayMs or 150)
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, screenX, screenY = World3dToScreen2d(x, y, z)
    if not onScreen then
        return
    end

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextCentre(true)
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(screenX, screenY)

    local factor = string.len(text) / 370
    DrawRect(screenX, screenY + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 75)
end
