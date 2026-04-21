Config = {}

-- Framework mode: 'auto', 'qbcore', 'esx', 'qbox', 'standalone'
Config.Framework = 'auto'

Config.Settings = {
    command = 'list',
    keybind = 'PAGEUP',
    showDistance = 15.0,
    refreshDelayMs = 150,
}

Config.Admin = {
    -- If true, only users with matching groups can open the list.
    control = false,

    -- QBCore/Qbox permission groups.
    qbPerms = { 'admin', 'god', 'mod' },

    -- ESX groups.
    esxGroups = { 'admin', 'superadmin', 'mod' },

    -- Standalone ACE permissions (used when framework is standalone).
    acePerms = { 'command', 'admin' },
}
