local robberyZones = {}
local isRobbing = false
local robbedHouses = {}
local houseMap = {}

local Framework = nil
local PlayerData = {}

CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        Framework = 'esx'
        ESX = exports['es_extended']:getSharedObject()
        PlayerData = ESX.GetPlayerData()

        RegisterNetEvent('esx:playerLoaded')
        AddEventHandler('esx:playerLoaded', function(xPlayer)
            PlayerData = xPlayer
        end)

        RegisterNetEvent('esx:setJob')
        AddEventHandler('esx:setJob', function(job)
            PlayerData.job = job
        end)
    elseif GetResourceState('qb-core') == 'started' then
        Framework = 'qb'
        QBCore = exports['qb-core']:GetCoreObject()
        PlayerData = QBCore.Functions.GetPlayerData()

        RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
        AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
            PlayerData = QBCore.Functions.GetPlayerData()
        end)

        RegisterNetEvent('QBCore:Client:OnJobUpdate')
        AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
            PlayerData.job = JobInfo
        end)
    end
end)

CreateThread(function()
    Wait(1000)

    if not Config or not Config.Houses then
        print('[HouseRobbery] ERROR: Config not loaded properly!')
        return
    end


    for _, house in pairs(Config.Houses) do
        if house and house.id and house.coords then
            houseMap[house.id] = house
            createRobberyZone(house)
            if Config.ShowBlips then
                createHouseBlip(house)
            end
        else
            print('[HouseRobbery] ERROR: Invalid house configuration!')
        end
    end

    TriggerServerEvent('houserobbery:getRobbedHouses')
end)

function createRobberyZone(house)
    robberyZones[house.id] = lib.zones.box({
        coords = house.coords,
        size = house.size,
        rotation = house.rotation,
        debug = false,
        onEnter = function()
            if not isRobbing and not robbedHouses[house.id] then

            end
        end,
        onExit = function()
            lib.hideTextUI()
        end,
        inside = function()
            if IsControlJustReleased(0, 38) then
                if not isRobbing and not robbedHouses[house.id] then
                    startRobbery(house)
                end
            end
        end
    })
end

function createHouseBlip(house)
    local blip = AddBlipForCoord(house.coords.x, house.coords.y, house.coords.z)
    SetBlipSprite(blip, Config.BlipSettings.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.BlipSettings.scale)
    SetBlipColour(blip, Config.BlipSettings.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.BlipSettings.name)
    EndTextCommandSetBlipName(blip)
end

function startRobbery(house)
    if Config.RequiredItem and Config.RequiredItem ~= '' then
        lib.callback('houserobbery:hasRequiredItem', false, function(hasItem)
            if not hasItem then
                local itemLabel = Config.RequiredItem
                if GetResourceState('ox_inventory') == 'started' then
                    local itemData = exports.ox_inventory:Items(Config.RequiredItem)
                    if itemData and itemData.label then
                        itemLabel = itemData.label
                    end
                end

                lib.notify({
                    title = 'Robbery',
                    description = 'Du benötigst eine/en ' .. itemLabel .. ' um dieses Haus auszurauben!',
                    type = 'error',
                    style = {
                        borderRadius = 16,
                        backgroundColor = 'black',
                        color = 'white',
                        border = '1px solid darkred',
                        padding = '12px 20px',
                        fontFamily = 'Inter, sans-serif',
                        fontSize = '14px',
                        fontWeight = 'bold',
                    }
                })
                return
            end

            checkPoliceAndStartRobbery(house)
        end, Config.RequiredItem)
    else
        checkPoliceAndStartRobbery(house)
    end
end

function checkPoliceAndStartRobbery(house)
    lib.callback('houserobbery:getPoliceCount', false, function(policeCount)
        if policeCount < Config.PoliceRequired then
            lib.notify({
                title = 'Robbery',
                description = 'Nicht genug Polizisten online! (' .. policeCount .. '/' .. Config.PoliceRequired .. ')',
                type = 'error',
                style = {
                    borderRadius = 16,
                    backgroundColor = 'black',
                    color = 'white',
                    border = '1px solid darkred',
                    padding = '12px 20px',
                    fontFamily = 'Inter, sans-serif',
                    fontSize = '14px',
                    fontWeight = 'bold',
                }
            })
            return
        end

        isRobbing = true
        lib.hideTextUI()
        TriggerServerEvent('houserobbery:notifyPolice', house.coords)
        if lib.progressBar({
                duration = Config.RobberyTime,
                label = 'Raubt ' .. tostring(house.name or 'Unbekanntes Haus') .. ' aus...',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    combat = true
                },
                anim = {
                    dict = 'anim@gangops@facility@servers@bodysearch@',
                    clip = 'player_search'
                }
            }) then
            completeRobbery(house)
        else
            TriggerServerEvent('houserobbery:notifyPoliceCancelled', house.coords)

            lib.notify({
                title = 'Robbery',
                description = 'Raub abgebrochen!',
                type = 'error',
                style = {
                    borderRadius = 16,
                    backgroundColor = 'black',
                    color = 'white',
                    border = '1px solid darkred',
                    padding = '12px 20px',
                    fontFamily = 'Inter, sans-serif',
                    fontSize = '14px',
                    fontWeight = 'bold',
                }
            })
        end

        isRobbing = false
    end)
end

function completeRobbery(house)
    TriggerServerEvent('houserobbery:completeRobbery', house.id)

    local generatedLoot = {}

    local houseConfig = houseMap[house.id]

    if houseConfig and houseConfig.loot then
        for _, lootItem in pairs(houseConfig.loot) do
            if lootItem.type == 'specific' and math.random(100) <= lootItem.chance then
                local amount = math.random(lootItem.amount.min, lootItem.amount.max)
                local itemInfo = Config.LootItems[lootItem.item]
                if itemInfo then
                    table.insert(generatedLoot, {
                        item = lootItem.item,
                        amount = amount,
                        label = itemInfo.name,
                        description = itemInfo.description,
                        rarity = 'specific'
                    })
                end
            end
        end
    end

    if Config.EnableRandomLoot and Config.RandomLoot and math.random(100) <= Config.RandomLootChance then
        local randomItemCount = math.random(Config.MinRandomItems, Config.MaxRandomItems)
        local addedRandomItems = 0

        local shuffledLoot = {}
        for _, item in pairs(Config.RandomLoot) do
            if item and item.item and item.amount then
                table.insert(shuffledLoot, item)
            end
        end

        for i = 1, randomItemCount do
            for _, randomLoot in pairs(shuffledLoot) do
                if addedRandomItems >= randomItemCount then break end

                if math.random(100) <= randomLoot.chance then
                    local amount = math.random(randomLoot.amount.min, randomLoot.amount.max)
                    local itemInfo = Config.LootItems[randomLoot.item]
                    if itemInfo then
                        table.insert(generatedLoot, {
                            item = randomLoot.item,
                            amount = amount,
                            label = itemInfo.name,
                            description = itemInfo.description,
                            rarity = randomLoot.rarity
                        })
                        addedRandomItems = addedRandomItems + 1
                        break
                    end
                end
            end
        end
    end

    if #generatedLoot > 0 then
        showLootMenu(generatedLoot, tostring(house.name or 'Unbekanntes Haus'))
    else
        lib.notify({
            title = 'Robbery',
            description = 'Du hast nichts Wertvolles gefunden!',
            type = 'info',
            style = {
                borderRadius = 16,
                backgroundColor = 'black',
                color = 'white',
                border = '1px solid darkgreen',
                padding = '12px 20px',
                fontFamily = 'Inter, sans-serif',
                fontSize = '14px',
                fontWeight = 'bold',
            }
        })
    end

    robbedHouses[house.id] = true
end

function showLootMenu(loot, houseName)
    local options = {}

    table.sort(loot, function(a, b)
        local rarityOrder = { specific = 1, common = 2, rare = 3, epic = 4, legendary = 5 }
        return (rarityOrder[a.rarity] or 6) < (rarityOrder[b.rarity] or 6)
    end)

    for i, item in pairs(loot) do
        local icon = 'fa-solid fa-hand-holding-dollar'
        local iconColor = 'white'

        if item.rarity == 'specific' then
            icon = 'fa-solid fa-star'
            iconColor = 'gold'
        elseif item.rarity == 'common' then
            icon = 'fa-solid fa-circle'
            iconColor = 'gray'
        elseif item.rarity == 'rare' then
            icon = 'fa-solid fa-gem'
            iconColor = 'blue'
        elseif item.rarity == 'epic' then
            icon = 'fa-solid fa-crown'
            iconColor = 'purple'
        elseif item.rarity == 'legendary' then
            icon = 'fa-solid fa-trophy'
            iconColor = 'orange'
        end

        table.insert(options, {
            title = item.label .. ' (x' .. item.amount .. ')',
            description = item.description,
            icon = icon,
            iconColor = iconColor,
            onSelect = function()
                TriggerServerEvent('houserobbery:giveLoot', item.item, item.amount)
                lib.notify({
                    title = 'Loot erhalten',
                    description = 'Du hast ' .. item.amount .. 'x ' .. item.label .. ' erhalten!',
                    type = 'success',
                    style = {
                        borderRadius = 16,
                        backgroundColor = 'black',
                        color = 'white',
                        border = '1px solid darkgreen',
                        padding = '12px 20px',
                        fontFamily = 'Inter, sans-serif',
                        fontSize = '14px',
                        fontWeight = 'bold',
                    }
                })
            end
        })
    end

    table.insert(options, {
        title = 'Alles nehmen',
        description = 'Nimm alle gefundenen Gegenstände',
        icon = 'fa-solid fa-hand-holding',
        iconColor = 'green',
        onSelect = function()
            for _, item in pairs(loot) do
                TriggerServerEvent('houserobbery:giveLoot', item.item, item.amount)
            end
            lib.notify({
                title = 'Loot erhalten',
                description = 'Du hast alle Gegenstände genommen!',
                type = 'success',
                style = {
                    borderRadius = 16,
                    backgroundColor = 'black',
                    color = 'white',
                    border = '1px solid darkgreen',
                    padding = '12px 20px',
                    fontFamily = 'Inter, sans-serif',
                    fontSize = '14px',
                    fontWeight = 'bold',
                }
            })
        end
    })

    lib.registerContext({
        id = 'houserobbery_loot',
        title = 'Beute aus ' .. houseName,
        options = options
    })

    lib.showContext('houserobbery_loot')
end

RegisterNetEvent('houserobbery:updateRobbedHouses')
AddEventHandler('houserobbery:updateRobbedHouses', function(houses)
    robbedHouses = houses
end)

RegisterNetEvent('houserobbery:policeDispatch')
AddEventHandler('houserobbery:policeDispatch', function(coords)
    if not PlayerData.job or PlayerData.job.name ~= 'police' then return end

    lib.notify({
        title = 'Verdächtige Handlungen',
        description = 'Eine auffällige Person wurde gemeldet !',
        type = 'warning',
        duration = 5000,
        style = {
            borderRadius = 16,
            backgroundColor = 'black',
            color = 'white',
            border = '1px solid darkred',
            padding = '12px 20px',
            fontFamily = 'Inter, sans-serif',
            fontSize = '14px',
            fontWeight = 'bold',
        }
    })

    local radiusBlip = AddBlipForRadius(coords.x, coords.y, coords.z, Config.DispatchBlip.radius)
    SetBlipColour(radiusBlip, 1)
    SetBlipAlpha(radiusBlip, 80)
    SetBlipFlashes(radiusBlip, true)

    SetTimeout(Config.DispatchBlip.duration, function()
        RemoveBlip(radiusBlip)
    end)
end)

RegisterNetEvent('houserobbery:policeDispatchCancelled')
AddEventHandler('houserobbery:policeDispatchCancelled', function(coords)
    if not PlayerData.job or PlayerData.job.name ~= 'police' then return end

    lib.notify({
        title = 'Raubversuch abgebrochen',
        description = 'Ein Raubversuch wurde abgebrochen - Verdächtige Person möglicherweise noch in der Nähe!',
        type = 'info',
        duration = 5000,
        style = {
            borderRadius = 16,
            backgroundColor = 'black',
            color = 'white',
            border = '1px solid orange',
            padding = '12px 20px',
            fontFamily = 'Inter, sans-serif',
            fontSize = '14px',
            fontWeight = 'bold',
        }
    })

    local radiusBlip = AddBlipForRadius(coords.x, coords.y, coords.z, Config.DispatchBlip.radius)
    SetBlipColour(radiusBlip, 47)
    SetBlipAlpha(radiusBlip, 60)
    SetBlipFlashes(radiusBlip, false)

    SetTimeout(Config.DispatchBlip.duration / 2, function()
        RemoveBlip(radiusBlip)
    end)
end)

RegisterNetEvent('houserobbery:houseReset')
AddEventHandler('houserobbery:houseReset', function(houseId)
    robbedHouses[houseId] = nil
    lib.notify({
        title = 'System',
        description = 'Ein Haus ist wieder ausraubbar!',
        type = 'info',
        style = {
            borderRadius = 16,
            backgroundColor = 'black',
            color = 'white',
            border = '1px solid darkgreen',
            padding = '12px 20px',
            fontFamily = 'Inter, sans-serif',
            fontSize = '14px',
            fontWeight = 'bold',
        }
    })
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, zone in pairs(robberyZones) do
            zone:remove()
        end
        lib.hideTextUI()
    end
end)
