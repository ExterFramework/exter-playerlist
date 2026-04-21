local framework = {
    name = 'standalone',
    object = nil,
}

local function hasResourceStarted(name)
    return GetResourceState(name) == 'started'
end

local function detectFramework()
    if Config.Framework and Config.Framework ~= 'auto' then
        framework.name = Config.Framework
    elseif hasResourceStarted('qbx_core') then
        framework.name = 'qbox'
    elseif hasResourceStarted('qb-core') then
        framework.name = 'qbcore'
    elseif hasResourceStarted('es_extended') then
        framework.name = 'esx'
    else
        framework.name = 'standalone'
    end

    if framework.name == 'qbcore' and hasResourceStarted('qb-core') then
        framework.object = exports['qb-core']:GetCoreObject()
    elseif framework.name == 'esx' and hasResourceStarted('es_extended') then
        framework.object = exports['es_extended']:getSharedObject()
    end

    print(('[exter-playerlist] Framework active: %s'):format(framework.name))
end

CreateThread(detectFramework)

local function getPlayerIdentifier(src)
    local identifiers = GetPlayerIdentifiers(src)
    return identifiers[1] or ('license:unknown:%s'):format(src)
end

local function buildActivePlayers()
    local players = {}
    for _, player in ipairs(GetPlayers()) do
        local src = tonumber(player)
        players[#players + 1] = {
            id = src,
            name = GetPlayerName(src) or ('Player %s'):format(src),
            identifier = getPlayerIdentifier(src),
        }
    end

    table.sort(players, function(a, b)
        return a.id < b.id
    end)

    return players
end

local disconnectedPlayers = {}

AddEventHandler('playerDropped', function(reason)
    local src = source
    disconnectedPlayers[#disconnectedPlayers + 1] = {
        id = src,
        name = GetPlayerName(src) or ('Player %s'):format(src),
        identifier = getPlayerIdentifier(src),
        reason = reason or 'Disconnected',
        at = os.time(),
    }

    if #disconnectedPlayers > 100 then
        table.remove(disconnectedPlayers, 1)
    end
end)

local function hasQbPermission(src)
    if framework.name == 'qbox' then
        for _, perm in ipairs(Config.Admin.qbPerms or {}) do
            if IsPlayerAceAllowed(src, ('qbx.%s'):format(perm)) or IsPlayerAceAllowed(src, ('qbcore.%s'):format(perm)) then
                return true
            end
        end
        return false
    end

    if not framework.object then
        return false
    end

    for _, perm in ipairs(Config.Admin.qbPerms or {}) do
        if framework.object.Functions.HasPermission(src, perm) then
            return true
        end
    end

    return false
end

local function hasEsxPermission(src)
    if not framework.object then
        return false
    end

    local xPlayer = framework.object.GetPlayerFromId(src)
    if not xPlayer then
        return false
    end

    local group = xPlayer.getGroup and xPlayer.getGroup() or 'user'
    for _, allowed in ipairs(Config.Admin.esxGroups or {}) do
        if group == allowed then
            return true
        end
    end

    return false
end

local function hasStandalonePermission(src)
    for _, ace in ipairs(Config.Admin.acePerms or {}) do
        if IsPlayerAceAllowed(src, ace) then
            return true
        end
    end
    return false
end

local function hasAccess(src)
    if not Config.Admin.control then
        return true
    end

    if framework.name == 'qbcore' or framework.name == 'qbox' then
        return hasQbPermission(src)
    elseif framework.name == 'esx' then
        return hasEsxPermission(src)
    end

    return hasStandalonePermission(src)
end

RegisterNetEvent('exter-playerlist:server:requestData', function()
    local src = source
    if not hasAccess(src) then
        TriggerClientEvent('exter-playerlist:client:accessDenied', src)
        return
    end

    TriggerClientEvent('exter-playerlist:client:receiveData', src, {
        activePlayers = buildActivePlayers(),
        disconnectedPlayers = disconnectedPlayers,
    })
end)
