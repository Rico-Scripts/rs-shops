local function notify(message, kind)
    lib.notify({ title = 'Winkel', description = message, type = kind or 'inform' })
end

local function buy(shopId, item)
    local maximum = math.min(Config.MaxQuantity, tonumber(item.max) or Config.MaxQuantity)
    local input = lib.inputDialog(item.label, {
        { type = 'number', label = 'Aantal', required = true, min = 1, max = maximum, default = 1 },
        { type = 'select', label = 'Betaalmethode', required = true, default = 'cash', options = {
            { value = 'cash', label = 'Contant' }, { value = 'bank', label = 'Bank' }
        } }
    })
    if not input then return end
    local ok, message = lib.callback.await('rs-shops:server:buy', false, shopId, item.name, input[1], input[2])
    notify(message, ok and 'success' or 'error')
end

local function openShop(shopId)
    local shop = Config.Shops[shopId]
    if not shop then return end
    local options = {}
    for index = 1, #shop.items do
        local item = shop.items[index]
        options[#options + 1] = {
            title = item.label,
            description = ('€%s per stuk'):format(item.price),
            icon = 'cart-plus',
            onSelect = function() buy(shopId, item) end
        }
    end
    lib.registerContext({ id = 'rs_shop_' .. shopId, title = shop.label, options = options })
    lib.showContext('rs_shop_' .. shopId)
end

CreateThread(function()
    for shopId, shop in pairs(Config.Shops) do
        for index = 1, #shop.locations do
            local coords = shop.locations[index]
            local currentShopId = shopId
            exports.ox_target:addSphereZone({ coords = coords, radius = 1.5, options = {{ name = ('rs_shop_%s_%s'):format(currentShopId,index), icon = 'fa-solid fa-basket-shopping', label = shop.label, distance = 2.0, onSelect = function() openShop(currentShopId) end }} })
            if shop.blip then
                local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
                SetBlipSprite(blip, shop.blip.sprite)
                SetBlipColour(blip, shop.blip.colour)
                SetBlipScale(blip, shop.blip.scale)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentString(shop.label)
                EndTextCommandSetBlipName(blip)
            end
        end
    end
end)
