Config = {}
Config.MaxDistance = 4.0
Config.MaxQuantity = 25
Config.WebhookConvar = 'rs_shops_webhook'
Config.WebhookColor = 5763719

Config.Shops = {
    convenience = {
        label = '24/7 Supermarkt',
        icon = 'basket-shopping',
        blip = { sprite = 52, colour = 2, scale = 0.65 },
        locations = {
            vec3(25.74, -1347.27, 29.50), vec3(-3038.94, 585.95, 7.91),
            vec3(-3241.93, 1001.46, 12.83), vec3(1729.22, 6414.13, 35.04),
            vec3(1698.08, 4924.55, 42.06), vec3(1961.46, 3740.67, 32.34),
            vec3(547.43, 2671.71, 42.16), vec3(2678.91, 3280.67, 55.24),
            vec3(2557.46, 382.28, 108.62), vec3(373.88, 325.90, 103.57)
        },
        items = {
            { name = 'water', label = 'Water', price = 8 },
            { name = 'bread', label = 'Brood', price = 10 },
            { name = 'burger', label = 'Burger', price = 18 },
            { name = 'sprunk', label = 'Sprunk', price = 12 },
            { name = 'phone', label = 'Telefoon', price = 750, max = 1 },
            { name = 'radio', label = 'Portofoon', price = 350, max = 1 }
        }
    },
    hardware = {
        label = 'Bouwmarkt',
        icon = 'screwdriver-wrench',
        blip = { sprite = 402, colour = 5, scale = 0.65 },
        locations = { vec3(2748.74, 3472.59, 55.67), vec3(46.84, -1749.52, 29.63) },
        items = {
            { name = 'paperbag', label = 'Papieren tas', price = 5 },
            { name = 'fixkit', label = 'Reparatieset', price = 850, max = 3 },
            { name = 'fixtool', label = 'Reparatiegereedschap', price = 500, max = 3 },
            { name = 'gazbottle', label = 'Gasfles', price = 275, max = 3 },
            { name = 'blowpipe', label = 'Snijbrander', price = 950, max = 1 }
        }
    },
    pharmacy = {
        label = 'Apotheek',
        icon = 'staff-snake',
        blip = { sprite = 51, colour = 2, scale = 0.65 },
        locations = { vec3(318.15, -1078.46, 29.48), vec3(-172.46, 6381.78, 31.50) },
        items = {
            { name = 'bandage', label = 'Verband', price = 75, max = 5 }
        }
    }
}
