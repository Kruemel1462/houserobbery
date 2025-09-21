Config = {}

Config.RobberyTime = 60000
Config.CooldownTime = 300000
Config.RequiredItem = 'WEAPON_CROWBAR'
Config.PoliceRequired = 0

Config.EnableRandomLoot = false
Config.MinRandomItems = 1
Config.MaxRandomItems = 3
Config.RandomLootChance = 60
Config.Houses = {
    {
        id = 'house_1',
        name = 'Grove Street Haus',
        coords = vector3(-14.23, -1442.19, 31.10),
        size = vector3(2.0, 2.0, 2.0),
        rotation = 45.0,
        robbable = true,
        loot = {
            { item = 'money',      amount = { min = 100, max = 500 }, chance = 80, type = 'specific' },
            { item = 'gold_watch', amount = { min = 1, max = 1 },   chance = 15, type = 'specific' },
            { item = 'diamond',    amount = { min = 1, max = 2 },   chance = 5,  type = 'specific' }
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
            { item = 'money',    amount = { min = 200, max = 1000 }, chance = 90, type = 'specific' },
            { item = 'laptop',   amount = { min = 1, max = 1 },    chance = 40, type = 'specific' },
            { item = 'rolex',    amount = { min = 1, max = 1 },    chance = 10, type = 'specific' },
            { item = 'painting', amount = { min = 1, max = 1 },    chance = 8,  type = 'specific' }
        }
    },
    {
        id = 'house_3',
        name = 'Harmony Trailer 1',
        coords = vector3(403.85, 2584.48, 43.52),
        size = vector3(3.0, 3.0, 3.0),
        rotation = 0.0,
        robbable = true,
        loot = {
            { item = 'money',  amount = { min = 200, max = 1000 }, chance = 70, type = 'specific' },
            { item = 'ammo-9', amount = { min = 1, max = 10 },   chance = 40, type = 'specific' }
        }
    },
    {
        id = 'house_4',
        name = 'Del Perro Apartment',
        coords = vector3(-1447.06, -538.28, 34.74),
        size = vector3(2.5, 2.5, 2.5),
        rotation = 25.0,
        robbable = true,
        loot = {
            { item = 'money',     amount = { min = 150, max = 750 }, chance = 85, type = 'specific' },
            { item = 'tablet',    amount = { min = 1, max = 1 },   chance = 35, type = 'specific' },
            { item = 'documents', amount = { min = 1, max = 1 },   chance = 15, type = 'specific' }
        }
    },
    {
        id = 'house_5',
        name = 'Test Haus',
        coords = vector3(-1.95, -1442.38, 30.96),
        size = vector3(2.5, 2.5, 2.5),
        rotation = 25.0,
        robbable = true,
        loot = {
            { item = 'money', amount = { min = 150, max = 750 }, chance = 85, type = 'specific' }
        }
    }
}

Config.RandomLoot = {
    { item = 'phone',            amount = { min = 1, max = 1 }, chance = 25, rarity = 'common' },
    { item = 'jewelry',          amount = { min = 1, max = 2 }, chance = 20, rarity = 'common' },
    { item = 'cash_roll',        amount = { min = 1, max = 1 }, chance = 18, rarity = 'common' },
    { item = 'watch',            amount = { min = 1, max = 1 }, chance = 15, rarity = 'common' },

    { item = 'gold_necklace',    amount = { min = 1, max = 1 }, chance = 12, rarity = 'rare' },
    { item = 'usb_stick',        amount = { min = 1, max = 1 }, chance = 10, rarity = 'rare' },
    { item = 'silver_bar',       amount = { min = 1, max = 1 }, chance = 8, rarity = 'rare' },

    { item = 'gold_bar',         amount = { min = 1, max = 1 }, chance = 5, rarity = 'epic' },
    { item = 'rare_coin',        amount = { min = 1, max = 1 }, chance = 3, rarity = 'epic' },

    { item = 'ancient_artifact', amount = { min = 1, max = 1 }, chance = 1, rarity = 'legendary' },
    { item = 'rare_gem',         amount = { min = 1, max = 1 }, chance = 0.5, rarity = 'legendary' }
}

Config.LootItems = {
    money = { name = 'Bargeld', description = 'Gefundenes Bargeld' },

    gold_watch = { name = 'Goldene Uhr', description = 'Eine wertvolle goldene Uhr' },
    diamond = { name = 'Diamant', description = 'Ein funkelnder Diamant' },
    laptop = { name = 'Laptop', description = 'Ein teurer Laptop' },
    rolex = { name = 'Rolex', description = 'Eine teure Rolex Uhr' },
    tablet = { name = 'Tablet', description = 'Ein iPad' },
    painting = { name = 'Gemälde', description = 'Ein wertvolles Kunstwerk' },
    documents = { name = 'Dokumente', description = 'Wichtige Dokumente' },

    phone = { name = 'Handy', description = 'Ein gestohlenes Handy' },
    jewelry = { name = 'Schmuck', description = 'Verschiedener Schmuck' },
    cash_roll = { name = 'Geldrolle', description = 'Eine dicke Geldrolle' },
    watch = { name = 'Armbanduhr', description = 'Eine normale Armbanduhr' },
    gold_necklace = { name = 'Goldkette', description = 'Eine glänzende Goldkette' },
    usb_stick = { name = 'USB Stick', description = 'Ein USB Stick mit unbekanntem Inhalt' },
    silver_bar = { name = 'Silberbarren', description = 'Ein kleiner Silberbarren' },
    gold_bar = { name = 'Goldbarren', description = 'Ein wertvoller Goldbarren' },
    rare_coin = { name = 'Seltene Münze', description = 'Eine antike, seltene Münze' },
    ancient_artifact = { name = 'Antikes Artefakt', description = 'Ein mysteriöses antikes Artefakt' },
    rare_gem = { name = 'Seltener Edelstein', description = 'Ein extrem seltener und wertvoller Edelstein' }
}

Config.ShowBlips = false
Config.BlipSettings = {
    sprite = 40,
    color = 1,
    scale = 0.7,
    name = 'Ausraubbares Haus'
}

Config.DispatchBlip = {
    radius = 100.0,
    duration = 300000,
    offset = 100.0
}

Config.DiscordWebhook = nil
