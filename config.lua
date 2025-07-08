Config = {}

-- Allgemeine Einstellungen
Config.RobberyTime = 10000 -- Zeit zum Ausrauben in ms (10 Sekunden)
Config.CooldownTime = 300000 -- Cooldown zwischen Raubüberfällen in ms (5 Minuten)
Config.RequiredItem = 'WEAPON_CROWBAR' -- Item das benötigt wird für den Raub (nil oder '' = kein Item benötigt)
Config.PoliceRequired = 0 -- Mindestanzahl Polizisten online

-- Loot Einstellungen
Config.EnableRandomLoot = true -- Aktiviert globalen Random-Loot
Config.MinRandomItems = 1 -- Mindestanzahl Random Items pro Raub
Config.MaxRandomItems = 3 -- Maximale Anzahl Random Items pro Raub
Config.RandomLootChance = 60 -- Chance in % dass Random-Loot spawnt

-- Häuser/Robbable Locations
Config.Houses = {
    {
        id = 'house_1',
        name = 'Grove Street Haus',
        coords = vector3(-14.23, -1442.19, 31.10),
        size = vector3(2.0, 2.0, 2.0),
        rotation = 45.0,
        -- Haus kann ausgeraubt werden
        robbable = true,
        loot = {
            -- Spezifischer Loot für dieses Haus (garantiert wenn Chance erfüllt)
            {item = 'money', amount = {min = 100, max = 500}, chance = 80, type = 'specific'},
            {item = 'gold_watch', amount = {min = 1, max = 1}, chance = 15, type = 'specific'},
            {item = 'diamond', amount = {min = 1, max = 2}, chance = 5, type = 'specific'}
        }
    },
    {
        id = 'house_2',
        name = 'Vinewood Hills Villa',
        coords = vector3(-174.35, 497.64, 137.67),
        size = vector3(3.0, 3.0, 3.0),
        rotation = 0.0,
        robbable = true,
        loot = {
            -- Spezifischer Loot für diese Villa (hochwertige Items)
            {item = 'money', amount = {min = 200, max = 1000}, chance = 90, type = 'specific'},
            {item = 'laptop', amount = {min = 1, max = 1}, chance = 40, type = 'specific'},
            {item = 'rolex', amount = {min = 1, max = 1}, chance = 10, type = 'specific'},
            {item = 'painting', amount = {min = 1, max = 1}, chance = 8, type = 'specific'} -- Exklusiv für Villa
        }
    },
    {
        id = 'house_3',
        name = 'Del Perro Apartment',
        coords = vector3(-1447.06, -538.28, 34.74),
        size = vector3(2.5, 2.5, 2.5),
        rotation = 25.0,
        robbable = true,
        loot = {
            -- Spezifischer Loot für dieses Apartment
            {item = 'money', amount = {min = 150, max = 750}, chance = 85, type = 'specific'},
            {item = 'tablet', amount = {min = 1, max = 1}, chance = 35, type = 'specific'},
            {item = 'documents', amount = {min = 1, max = 1}, chance = 15, type = 'specific'} -- Exklusiv für Apartment
        }
    }
}

-- Globaler Random-Loot (kann in allen Häusern gefunden werden)
Config.RandomLoot = {
    -- Häufige Items
    {item = 'phone', amount = {min = 1, max = 1}, chance = 25, rarity = 'common'},
    {item = 'jewelry', amount = {min = 1, max = 2}, chance = 20, rarity = 'common'},
    {item = 'cash_roll', amount = {min = 1, max = 1}, chance = 18, rarity = 'common'},
    {item = 'watch', amount = {min = 1, max = 1}, chance = 15, rarity = 'common'},
    
    -- Seltene Items
    {item = 'gold_necklace', amount = {min = 1, max = 1}, chance = 12, rarity = 'rare'},
    {item = 'usb_stick', amount = {min = 1, max = 1}, chance = 10, rarity = 'rare'},
    {item = 'silver_bar', amount = {min = 1, max = 1}, chance = 8, rarity = 'rare'},
    
    -- Sehr seltene Items
    {item = 'gold_bar', amount = {min = 1, max = 1}, chance = 5, rarity = 'epic'},
    {item = 'rare_coin', amount = {min = 1, max = 1}, chance = 3, rarity = 'epic'},
    
    -- Legendäre Items (extrem selten)
    {item = 'ancient_artifact', amount = {min = 1, max = 1}, chance = 1, rarity = 'legendary'},
    {item = 'rare_gem', amount = {min = 1, max = 1}, chance = 0.5, rarity = 'legendary'}
}

-- Loot Items mit Beschreibungen
Config.LootItems = {
    -- Basis Items
    money = {name = 'Bargeld', description = 'Gefundenes Bargeld'},
    
    -- Spezifische Haus Items
    gold_watch = {name = 'Goldene Uhr', description = 'Eine wertvolle goldene Uhr'},
    diamond = {name = 'Diamant', description = 'Ein funkelnder Diamant'},
    laptop = {name = 'Laptop', description = 'Ein teurer Laptop'},
    rolex = {name = 'Rolex', description = 'Eine teure Rolex Uhr'},
    tablet = {name = 'Tablet', description = 'Ein iPad'},
    painting = {name = 'Gemälde', description = 'Ein wertvolles Kunstwerk'},
    documents = {name = 'Dokumente', description = 'Wichtige Dokumente'},
    
    -- Random Loot Items
    phone = {name = 'Handy', description = 'Ein gestohlenes Handy'},
    jewelry = {name = 'Schmuck', description = 'Verschiedener Schmuck'},
    cash_roll = {name = 'Geldrolle', description = 'Eine dicke Geldrolle'},
    watch = {name = 'Armbanduhr', description = 'Eine normale Armbanduhr'},
    gold_necklace = {name = 'Goldkette', description = 'Eine glänzende Goldkette'},
    usb_stick = {name = 'USB Stick', description = 'Ein USB Stick mit unbekanntem Inhalt'},
    silver_bar = {name = 'Silberbarren', description = 'Ein kleiner Silberbarren'},
    gold_bar = {name = 'Goldbarren', description = 'Ein wertvoller Goldbarren'},
    rare_coin = {name = 'Seltene Münze', description = 'Eine antike, seltene Münze'},
    ancient_artifact = {name = 'Antikes Artefakt', description = 'Ein mysteriöses antikes Artefakt'},
    rare_gem = {name = 'Seltener Edelstein', description = 'Ein extrem seltener und wertvoller Edelstein'}
}

-- Blip Einstellungen
Config.ShowBlips = true
Config.BlipSettings = {
    sprite = 40,
    color = 1,
    scale = 0.7,
    name = 'Ausraubbares Haus'
}

-- Einstellungen für den Polizei Dispatch Blip
Config.DispatchBlip = {
    radius = 150.0,   -- Radius des Bereichs in dem der Raub vermutet wird
    duration = 60000  -- Wie lange der Dispatch Blip angezeigt wird (in ms)
}

-- Discord Webhook (optional)
Config.DiscordWebhook = nil -- "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"
