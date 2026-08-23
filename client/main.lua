local locations = {}

local function notify(message, kind)
    lib.notify({ title = 'Winkel', description = message, type = kind or 'inform' })
end

local function buy(shopId, locationIndex, item)
    local maximum = math.min(Config.MaxQuantity, tonumber(item.max) or Config.MaxQuantity)
    local input = lib.inputDialog(item.label, {
        { type = 'number', label = 'Aantal', required = true, min = 1, max = maximum, default = 1 },
        { type = 'select', label = 'Betaalmethode', required = true, default = 'cash', options = {
            { value = 'cash', label = 'Contant' }, { value = 'bank', label = 'Bank' }
        } }
    })
    if not input then return end
    local ok, message = lib.callback.await('rs-shops:server:buy', false, shopId, locationIndex, item.name, input[1], input[2])
    notify(message, ok and 'success' or 'error')
end

local function openShop(shopId, locationIndex)
    local shop = Config.Shops[shopId]
    if not shop then return end
    local options = {}
    for index = 1, #shop.items do
        local item = shop.items[index]
        options[#options + 1] = {
            title = item.label,
            description = ('€%s per stuk'):format(item.price),
            icon = 'cart-plus',
            onSelect = function() buy(shopId, locationIndex, item) end
        }
    end
    lib.registerContext({ id = 'rs_shop_' .. shopId, title = shop.label, options = options })
    lib.showContext('rs_shop_' .. shopId)
end

local function locationKey(shopId, index)
    return ('%s:%s'):format(shopId, index)
end

local function ownedBusinessNear(coords, businessList)
    local integration = Config.BusinessIntegration
    if not integration or not integration.enabled then return false end

    local maximum = tonumber(integration.matchDistance) or 30.0
    for index = 1, #(businessList or {}) do
        local business = businessList[index]
        local businessCoords = business and business.coords
        if business and business.owner and businessCoords then
            local x = (coords.x or 0.0) - (businessCoords.x or 0.0)
            local y = (coords.y or 0.0) - (businessCoords.y or 0.0)
            local z = (coords.z or 0.0) - (businessCoords.z or 0.0)
            if (x * x + y * y + z * z) <= maximum * maximum then return true end
        end
    end
    return false
end

local function removeLocation(location)
    if location.zone then
        exports.ox_target:removeZone(location.zone)
        location.zone = nil
    end
    if location.blip and DoesBlipExist(location.blip) then
        RemoveBlip(location.blip)
        location.blip = nil
    end
end

local function addLocation(location)
    if not location.zone then
        local shopId, locationIndex, shop = location.shopId, location.index, location.shop
        location.zone = exports.ox_target:addSphereZone({
            coords = location.coords,
            radius = 1.5,
            options = {{
                name = ('rs_shop_%s_%s'):format(shopId, locationIndex),
                icon = 'fa-solid fa-basket-shopping',
                label = shop.label,
                distance = 2.0,
                onSelect = function() openShop(shopId, locationIndex) end
            }}
        })
    end

    if location.shop.blip and not location.blip then
        local settings = location.shop.blip
        local coords = location.coords
        location.blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(location.blip, settings.sprite)
        SetBlipColour(location.blip, settings.colour)
        SetBlipScale(location.blip, settings.scale)
        SetBlipAsShortRange(location.blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(location.shop.label)
        EndTextCommandSetBlipName(location.blip)
    end
end

local function refreshLocations(businessList)
    for _, location in pairs(locations) do
        if ownedBusinessNear(location.coords, businessList) then
            removeLocation(location)
        else
            addLocation(location)
        end
    end
end

local function getBusinesses()
    local integration = Config.BusinessIntegration
    if not integration or not integration.enabled then return {} end
    if GetResourceState(integration.resource) ~= 'started' then return {} end

    local success, result = pcall(function()
        return exports[integration.resource]:GetBusinesses()
    end)
    return success and type(result) == 'table' and result or {}
end

RegisterNetEvent('rs-businesses:client:sync', refreshLocations)
AddEventHandler('rs-businesses:client:locationsReady', refreshLocations)

AddEventHandler('onClientResourceStart', function(resource)
    local integration = Config.BusinessIntegration
    if integration and resource == integration.resource then
        Wait(250)
        refreshLocations(getBusinesses())
    end
end)

CreateThread(function()
    for shopId, shop in pairs(Config.Shops) do
        for index = 1, #shop.locations do
            local key = locationKey(shopId, index)
            locations[key] = { shopId = shopId, index = index, shop = shop, coords = shop.locations[index] }
        end
    end
    refreshLocations(getBusinesses())
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, location in pairs(locations) do removeLocation(location) end
end)
