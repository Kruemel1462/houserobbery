local robberyZones = {}
local isRobbing = false
local robbedHouses = {}

-- ESX/QB-Core Integration (optional)
local Framework = nil
local PlayerData = {}

-- Framework Detection
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

-- Initialize robbery zones
CreateThread(function()
    Wait(1000) -- Wait for ox_lib to load
    
    for _, house in pairs(Config.Houses) do
        createRobberyZone(house)
        if Config.ShowBlips then
            createHouseBlip(house)
        end
    end
    
    -- Get robbed houses from server
    TriggerServerEvent('houserobbery:getRobbedHouses')
end)

-- Create robbery zone
function createRobberyZone(house)
    robberyZones[house.id] = lib.zones.box({
        coords = house.coords,
        size = house.size,
        rotation = house.rotation,
        debug = false, -- Set to true for debugging
        onEnter = function()
            if not isRobbing and not robbedHouses[house.id] then
                lib.showTextUI('Drücke [E] um das Haus auszurauben', {
                    position = "top-center",
                    icon = 'fa-solid fa-mask',
                    style = {
                        borderRadius = 10,
                        backgroundColor = '#1a1a1a',
                        color = 'white'
                    }
                })
            end
        end,
        onExit = function()
            lib.hideTextUI()
        end,
        inside = function()
            if IsControlJustReleased(0, 38) then -- E key
                if not isRobbing and not robbedHouses[house.id] then
                    startRobbery(house)
                end
            end
        end
    })
end

-- Create house blip
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

-- Start robbery process
function startRobbery(house)
    -- Check if item is required
    if Config.RequiredItem then
        local hasItem = false
        if Framework == 'esx' then
            local item = ESX.SearchInventory(Config.RequiredItem, 1)
            hasItem = item and item > 0
        elseif Framework == 'qb' then
            local item = QBCore.Functions.HasItem(Config.RequiredItem)
            hasItem = item ~= nil
        else
            -- For standalone, assume player has item
            hasItem = true
        end
        
        if not hasItem then
            lib.notify({
                title = 'Robbery',
                description = 'Du benötigst einen ' .. Config.RequiredItem .. ' um dieses Haus auszurauben!',
                type = 'error'
            })
            return
        end
    end
    
    -- Check police count
    lib.callback('houserobbery:getPoliceCount', false, function(policeCount)
        if policeCount < Config.PoliceRequired then
            lib.notify({
                title = 'Robbery',
                description = 'Nicht genug Polizisten online! (' .. policeCount .. '/' .. Config.PoliceRequired .. ')',
                type = 'error'
            })
            return
        end
        
        -- Start robbery
        isRobbing = true
        lib.hideTextUI()
        
        -- Remove required item
        if Config.RequiredItem then
            TriggerServerEvent('houserobbery:removeItem', Config.RequiredItem, 1)
        end
        
        -- Show progress bar
        if lib.progressBar({
            duration = Config.RobberyTime,
            label = 'Raubt ' .. house.name .. ' aus...',
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
            -- Robbery successful
            completeRobbery(house)
        else
            -- Robbery cancelled
            lib.notify({
                title = 'Robbery',
                description = 'Raub abgebrochen!',
                type = 'error'
            })
        end
        
        isRobbing = false
    end)
end

-- Complete robbery and show loot menu
function completeRobbery(house)
    TriggerServerEvent('houserobbery:completeRobbery', house.id)
    
    -- Generate specific house loot
    local generatedLoot = {}
    
    -- Add specific loot for this house
    for _, lootItem in pairs(house.loot) do
        if lootItem.type == 'specific' and math.random(100) <= lootItem.chance then
            local amount = math.random(lootItem.amount.min, lootItem.amount.max)
            table.insert(generatedLoot, {
                item = lootItem.item,
                amount = amount,
                label = Config.LootItems[lootItem.item].name,
                description = Config.LootItems[lootItem.item].description,
                rarity = 'specific'
            })
        end
    end
    
    -- Add random loot if enabled
    if Config.EnableRandomLoot and math.random(100) <= Config.RandomLootChance then
        local randomItemCount = math.random(Config.MinRandomItems, Config.MaxRandomItems)
        local addedRandomItems = 0
        
        for i = 1, randomItemCount do
            for _, randomLoot in pairs(Config.RandomLoot) do
                if addedRandomItems >= randomItemCount then break end
                
                if math.random(100) <= randomLoot.chance then
                    local amount = math.random(randomLoot.amount.min, randomLoot.amount.max)
                    table.insert(generatedLoot, {
                        item = randomLoot.item,
                        amount = amount,
                        label = Config.LootItems[randomLoot.item].name,
                        description = Config.LootItems[randomLoot.item].description,
                        rarity = randomLoot.rarity
                    })
                    addedRandomItems = addedRandomItems + 1
                    break -- Verhindert doppelte Items
                end
            end
        end
    end
    
    if #generatedLoot > 0 then
        showLootMenu(generatedLoot, house.name)
    else
        lib.notify({
            title = 'Robbery',
            description = 'Du hast nichts Wertvolles gefunden!',
            type = 'info'
        })
    end
    
    -- Mark house as robbed locally
    robbedHouses[house.id] = true
end

-- Show loot context menu
function showLootMenu(loot, houseName)
    local options = {}
    
    -- Sort loot by rarity (specific items first, then by rarity)
    table.sort(loot, function(a, b)
        local rarityOrder = {specific = 1, common = 2, rare = 3, epic = 4, legendary = 5}
        return (rarityOrder[a.rarity] or 6) < (rarityOrder[b.rarity] or 6)
    end)
    
    for i, item in pairs(loot) do
        local icon = 'fa-solid fa-hand-holding-dollar'
        local iconColor = 'white'
        local rarityText = ''
        
        -- Set icon and color based on rarity
        if item.rarity == 'specific' then
            icon = 'fa-solid fa-star'
            iconColor = 'gold'
            rarityText = ' [SPEZIFISCH]'
        elseif item.rarity == 'common' then
            icon = 'fa-solid fa-circle'
            iconColor = 'gray'
            rarityText = ' [HÄUFIG]'
        elseif item.rarity == 'rare' then
            icon = 'fa-solid fa-gem'
            iconColor = 'blue'
            rarityText = ' [SELTEN]'
        elseif item.rarity == 'epic' then
            icon = 'fa-solid fa-crown'
            iconColor = 'purple'
            rarityText = ' [EPISCH]'
        elseif item.rarity == 'legendary' then
            icon = 'fa-solid fa-trophy'
            iconColor = 'orange'
            rarityText = ' [LEGENDÄR]'
        end
        
        table.insert(options, {
            title = item.label .. ' (x' .. item.amount .. ')' .. rarityText,
            description = item.description,
            icon = icon,
            iconColor = iconColor,
            onSelect = function()
                TriggerServerEvent('houserobbery:giveLoot', item.item, item.amount)
                lib.notify({
                    title = 'Loot erhalten',
                    description = 'Du hast ' .. item.amount .. 'x ' .. item.label .. ' erhalten!',
                    type = 'success'
                })
            end
        })
    end
    
    -- Add "Take All" option
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
                type = 'success'
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

-- Network events
RegisterNetEvent('houserobbery:updateRobbedHouses')
AddEventHandler('houserobbery:updateRobbedHouses', function(houses)
    robbedHouses = houses
end)

RegisterNetEvent('houserobbery:houseReset')
AddEventHandler('houserobbery:houseReset', function(houseId)
    robbedHouses[houseId] = nil
    lib.notify({
        title = 'System',
        description = 'Ein Haus ist wieder ausraubbar!',
        type = 'info'
    })
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, zone in pairs(robberyZones) do
            zone:remove()
        end
        lib.hideTextUI()
    end
end)
