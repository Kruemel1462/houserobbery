local robbedHouses = {}
local Framework = nil
local houseMap = {}
local dataFile = 'robbed_houses.json'

CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        Framework = 'esx'
        ESX = exports['es_extended']:getSharedObject()
    elseif GetResourceState('qb-core') == 'started' then
        Framework = 'qb'
        QBCore = exports['qb-core']:GetCoreObject()
    end
end)

CreateThread(function()
    for _, house in pairs(Config.Houses) do
        houseMap[house.id] = house
    end
    LoadRobbedHouses()
end)

function SaveRobbedHouses()
    SaveResourceFile(GetCurrentResourceName(), dataFile, json.encode(robbedHouses), -1)
end

function LoadRobbedHouses()
    local data = LoadResourceFile(GetCurrentResourceName(), dataFile)
    if not data then return end

    local decoded = json.decode(data)
    if not decoded then return end

    for id, expire in pairs(decoded) do
        if expire > os.time() then
            robbedHouses[id] = expire

            local remaining = (expire - os.time()) * 1000
            SetTimeout(remaining, function()
                robbedHouses[id] = nil
                SaveRobbedHouses()
            end)
        end
    end

    TriggerClientEvent('houserobbery:updateRobbedHouses', -1, robbedHouses)
end

function GetPlayer(source)
    if Framework == 'esx' then
        return ESX.GetPlayerFromId(source)
    elseif Framework == 'qb' then
        return QBCore.Functions.GetPlayer(source)
    end
    return nil
end

function AddItem(player, item, amount)
    if GetResourceState('ox_inventory') == 'started' then
        if item == 'money' then
            exports.ox_inventory:AddItem(player.source or player, 'money', amount)
        else
            exports.ox_inventory:AddItem(player.source or player, item, amount)
        end
        return
    end

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

function RemoveItem(player, item, amount)
    if GetResourceState('ox_inventory') == 'started' then
        exports.ox_inventory:RemoveItem(player.source or player, item, amount)
        return
    end

    if Framework == 'esx' then
        player.removeInventoryItem(item, amount)
    elseif Framework == 'qb' then
        player.Functions.RemoveItem(item, amount)
    end
end

function GetPoliceCount()
    local count = 0
    local players = GetPlayers()

    for _, playerId in pairs(players) do
        local playerIdNum = tonumber(playerId)
        if playerIdNum then
            local player = GetPlayer(playerIdNum)
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
    end

    return count
end

lib.callback.register('houserobbery:getPoliceCount', function(source)
    return GetPoliceCount()
end)

lib.callback.register('houserobbery:hasRequiredItem', function(source, item)
    if not item or item == '' then
        return true
    end

    local player = GetPlayer(source)
    if not player then
        return false
    end

    if GetResourceState('ox_inventory') == 'started' then
        local count = exports.ox_inventory:GetItemCount(source, item)
        return count and count > 0
    end

    if Framework == 'esx' then
        local item = player.getInventoryItem(item)
        return item and item.count > 0
    elseif Framework == 'qb' then
        local item = player.Functions.GetItemByName(item)
        return item and item.amount > 0
    end

    return false
end)

lib.callback.register('houserobbery:canRobHouse', function(source, houseId)
    local house = houseMap[houseId]
    if not house then
        return false, 'Haus nicht gefunden!'
    end

    if robbedHouses[houseId] and robbedHouses[houseId] > os.time() then
        local remainingTime = robbedHouses[houseId] - os.time()
        local minutes = math.ceil(remainingTime / 60)
        return false, 'Dieses Haus wurde bereits ausgeraubt! Verfügbar in ' .. minutes .. ' Minuten.'
    end

    return true, nil
end)

RegisterNetEvent('houserobbery:getRobbedHouses')
AddEventHandler('houserobbery:getRobbedHouses', function()
    local source = source
    TriggerClientEvent('houserobbery:updateRobbedHouses', source, robbedHouses)
end)

RegisterNetEvent('houserobbery:notifyPolice')
AddEventHandler('houserobbery:notifyPolice', function(coords)
    local range = Config.DispatchBlip.offset or 30.0
    local offset = vector3(
        coords.x + math.random(-range, range),
        coords.y + math.random(-range, range),
        coords.z
    )

    for _, playerId in pairs(GetPlayers()) do
        local playerIdNum = tonumber(playerId)
        if not playerIdNum then goto continue end

        local player = GetPlayer(playerIdNum)
        if player then
            local jobName
            if Framework == 'esx' and player.job then
                jobName = player.job.name
            elseif Framework == 'qb' and player.PlayerData.job then
                jobName = player.PlayerData.job.name
            end

            if jobName == 'police' then
                TriggerClientEvent('houserobbery:policeDispatch', playerIdNum, offset)
            end
        end
        ::continue::
    end
end)

RegisterNetEvent('houserobbery:notifyPoliceCancelled')
AddEventHandler('houserobbery:notifyPoliceCancelled', function(coords)
    local range = Config.DispatchBlip.offset or 30.0
    local offset = vector3(
        coords.x + math.random(-range, range),
        coords.y + math.random(-range, range),
        coords.z
    )

    for _, playerId in pairs(GetPlayers()) do
        local playerIdNum = tonumber(playerId)
        if not playerIdNum then goto continue end

        local player = GetPlayer(playerIdNum)
        if player then
            local jobName
            if Framework == 'esx' and player.job then
                jobName = player.job.name
            elseif Framework == 'qb' and player.PlayerData.job then
                jobName = player.PlayerData.job.name
            end

            if jobName == 'police' then
                TriggerClientEvent('houserobbery:policeDispatchCancelled', playerIdNum, offset)
            end
        end
        ::continue::
    end
end)

RegisterNetEvent('houserobbery:completeRobbery')
AddEventHandler('houserobbery:completeRobbery', function(houseId)
    local source = source
    local player = GetPlayer(source)

    if not player then
        return
    end

    local house = houseMap[houseId]

    if not house then
        return
    end

    if robbedHouses[houseId] and robbedHouses[houseId] > os.time() then
        local remainingTime = robbedHouses[houseId] - os.time()
        local minutes = math.ceil(remainingTime / 60)
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Robbery',
            description = 'Dieses Haus wurde bereits ausgeraubt! Verfügbar in ' .. minutes .. ' Minuten.',
            type = 'error'
        })
        return
    end

    robbedHouses[houseId] = os.time() + (Config.CooldownTime / 1000)
    SaveRobbedHouses()

    TriggerClientEvent('houserobbery:updateRobbedHouses', -1, robbedHouses)

    SetTimeout(Config.CooldownTime, function()
        robbedHouses[houseId] = nil
        SaveRobbedHouses()
    end)

    print(string.format('[House Robbery] Player %s (%s) robbed house %s',
        GetPlayerName(source), source, house.name))

    if Config.DiscordWebhook then
        sendToDiscord('House Robbery',
            string.format('**%s** hat **%s** ausgeraubt!',
                GetPlayerName(source), house.name))
    end
end)

RegisterNetEvent('houserobbery:giveLoot')
AddEventHandler('houserobbery:giveLoot', function(item, amount)
    local source = source

    if GetResourceState('ox_inventory') == 'started' then
        if item == 'money' then
            exports.ox_inventory:AddItem(source, 'money', amount)
        else
            exports.ox_inventory:AddItem(source, item, amount)
        end

        print(string.format('[House Robbery] Player %s (%s) received %dx %s',
            GetPlayerName(source), source, amount, item))
        return
    end

    local player = GetPlayer(source)
    if not player then
        return
    end

    AddItem(player, item, amount)

    print(string.format('[House Robbery] Player %s (%s) received %dx %s',
        GetPlayerName(source), source, amount, item))
end)

RegisterNetEvent('houserobbery:removeItem')
AddEventHandler('houserobbery:removeItem', function(item, amount)
    local source = source

    if GetResourceState('ox_inventory') == 'started' then
        exports.ox_inventory:RemoveItem(source, item, amount)
        return
    end

    local player = GetPlayer(source)
    if not player then
        return
    end

    RemoveItem(player, item, amount)
end)

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

RegisterCommand('resethouse', function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, 'houserobbery.admin') then
        if args[1] then
            local houseId = args[1]
            robbedHouses[houseId] = nil
            SaveRobbedHouses()

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
        SaveRobbedHouses()

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

CreateThread(function()
    Wait(2000)
    print('^2[House Robbery]^7 Script loaded successfully!')
    print('^2[House Robbery]^7 Houses configured: ' .. #Config.Houses)
    print('^2[House Robbery]^7 Framework detected: ' .. (Framework or 'Standalone'))
end)
