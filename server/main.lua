local robbedHouses = {}
local Framework = nil

-- Framework Detection
CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        Framework = 'esx'
        ESX = exports['es_extended']:getSharedObject()
    elseif GetResourceState('qb-core') == 'started' then
        Framework = 'qb'
        QBCore = exports['qb-core']:GetCoreObject()
    end
end)

-- Get player from source
function GetPlayer(source)
    if Framework == 'esx' then
        return ESX.GetPlayerFromId(source)
    elseif Framework == 'qb' then
        return QBCore.Functions.GetPlayer(source)
    end
    return nil
end

-- Add item to player
function AddItem(player, item, amount)
    if Framework == 'esx' then
        if item == 'money' then
            player.addMoney(amount)
        else
            player.addInventoryItem(item, amount)
        end
    elseif Framework == 'qb' then
        if item == 'money' then
            player.Functions.AddMoney('cash', amount)
        else
            player.Functions.AddItem(item, amount)
        end
    end
end

-- Remove item from player
function RemoveItem(player, item, amount)
    if Framework == 'esx' then
        player.removeInventoryItem(item, amount)
    elseif Framework == 'qb' then
        player.Functions.RemoveItem(item, amount)
    end
end

-- Get police count
function GetPoliceCount()
    local count = 0
    local players = GetPlayers()
    
    for _, playerId in pairs(players) do
        local player = GetPlayer(playerId)
        if player then
            if Framework == 'esx' then
                if player.job and player.job.name == 'police' then
                    count = count + 1
                end
            elseif Framework == 'qb' then
                if player.PlayerData.job and player.PlayerData.job.name == 'police' then
                    count = count + 1
                end
            end
        end
    end
    
    return count
end

-- Callback to get police count
lib.callback.register('houserobbery:getPoliceCount', function(source)
    return GetPoliceCount()
end)

-- Event to get robbed houses
RegisterNetEvent('houserobbery:getRobbedHouses')
AddEventHandler('houserobbery:getRobbedHouses', function()
    local source = source
    TriggerClientEvent('houserobbery:updateRobbedHouses', source, robbedHouses)
end)

-- Event to complete robbery
RegisterNetEvent('houserobbery:completeRobbery')
AddEventHandler('houserobbery:completeRobbery', function(houseId)
    local source = source
    local player = GetPlayer(source)
    
    if not player then
        return
    end
    
    -- Check if house exists in config
    local house = nil
    for _, configHouse in pairs(Config.Houses) do
        if configHouse.id == houseId then
            house = configHouse
            break
        end
    end
    
    if not house then
        return
    end
    
    -- Check if house is already robbed
    if robbedHouses[houseId] and robbedHouses[houseId] > GetGameTimer() then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Robbery',
            description = 'Dieses Haus wurde bereits ausgeraubt!',
            type = 'error'
        })
        return
    end
    
    -- Mark house as robbed
    robbedHouses[houseId] = GetGameTimer() + Config.CooldownTime
    
    -- Update all clients
    TriggerClientEvent('houserobbery:updateRobbedHouses', -1, robbedHouses)
    
    -- Set timer to reset house
    SetTimeout(Config.CooldownTime, function()
        robbedHouses[houseId] = nil
        TriggerClientEvent('houserobbery:houseReset', -1, houseId)
    end)
    
    -- Log robbery
    print(string.format('[House Robbery] Player %s (%s) robbed house %s', 
          GetPlayerName(source), source, house.name))
    
    -- Optional: Send to Discord webhook
    if Config.DiscordWebhook then
        sendToDiscord('House Robbery', 
                     string.format('**%s** hat **%s** ausgeraubt!', 
                                   GetPlayerName(source), house.name))
    end
end)

-- Event to give loot to player
RegisterNetEvent('houserobbery:giveLoot')
AddEventHandler('houserobbery:giveLoot', function(item, amount)
    local source = source
    local player = GetPlayer(source)
    
    if not player then
        return
    end
    
    AddItem(player, item, amount)
    
    -- Log loot
    print(string.format('[House Robbery] Player %s (%s) received %dx %s', 
          GetPlayerName(source), source, amount, item))
end)

-- Event to remove item from player
RegisterNetEvent('houserobbery:removeItem')
AddEventHandler('houserobbery:removeItem', function(item, amount)
    local source = source
    local player = GetPlayer(source)
    
    if not player then
        return
    end
    
    RemoveItem(player, item, amount)
end)

-- Discord webhook function (optional)
function sendToDiscord(title, message)
    if not Config.DiscordWebhook then
        return
    end
    
    local embed = {
        {
            ["title"] = title,
            ["description"] = message,
            ["color"] = 15158332,
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            ["footer"] = {
                ["text"] = "House Robbery System"
            }
        }
    }
    
    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({
        username = "House Robbery Bot",
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

-- Admin commands
RegisterCommand('resethouse', function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, 'houserobbery.admin') then
        if args[1] then
            local houseId = args[1]
            robbedHouses[houseId] = nil
            TriggerClientEvent('houserobbery:houseReset', -1, houseId)
            
            if source == 0 then
                print('House ' .. houseId .. ' has been reset.')
            else
                TriggerClientEvent('ox_lib:notify', source, {
                    title = 'Admin',
                    description = 'Haus ' .. houseId .. ' wurde zurückgesetzt!',
                    type = 'success'
                })
            end
        else
            if source == 0 then
                print('Usage: /resethouse <house_id>')
            else
                TriggerClientEvent('ox_lib:notify', source, {
                    title = 'Admin',
                    description = 'Verwendung: /resethouse <house_id>',
                    type = 'error'
                })
            end
        end
    end
end, false)

RegisterCommand('resetallhouses', function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, 'houserobbery.admin') then
        robbedHouses = {}
        TriggerClientEvent('houserobbery:updateRobbedHouses', -1, robbedHouses)
        
        if source == 0 then
            print('All houses have been reset.')
        else
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Admin',
                description = 'Alle Häuser wurden zurückgesetzt!',
                type = 'success'
            })
        end
    end
end, false)

-- Print startup message
CreateThread(function()
    Wait(2000)
    print('^2[House Robbery]^7 Script loaded successfully!')
    print('^2[House Robbery]^7 Houses configured: ' .. #Config.Houses)
    print('^2[House Robbery]^7 Framework detected: ' .. (Framework or 'Standalone'))
end)
