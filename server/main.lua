local ESX = exports.es_extended:getSharedObject()
local cooldown = {}

local function getShop(shopId)
    return type(shopId) == 'string' and Config.Shops[shopId] or nil
end

local function getItem(shop, itemName)
    if not shop or type(itemName) ~= 'string' then return nil end
    for index = 1, #shop.items do
        if shop.items[index].name == itemName then return shop.items[index] end
    end
end

local function nearShop(source, shop)
    local ped = GetPlayerPed(source)
    if ped == 0 then return false end
    local coords = GetEntityCoords(ped)
    for index = 1, #shop.locations do
        if #(coords - shop.locations[index]) <= Config.MaxDistance then return true end
    end
    return false
end

local function notify(source, message, kind)
    TriggerClientEvent('ox_lib:notify', source, { title = 'Winkel', description = message, type = kind or 'inform' })
end

local function log(title, description)
    local webhook = GetConvar(Config.WebhookConvar, '')
    if webhook == '' then return end
    PerformHttpRequest(webhook, function() end, 'POST', json.encode({ username = 'Rico Scripts', embeds = {{ title = title, description = description, color = Config.WebhookColor, footer = { text = 'rs-shops' }, timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ') }} }), { ['Content-Type'] = 'application/json' })
end

MySQL.ready(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS `rs_shop_transactions` (
        `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, `identifier` VARCHAR(80) NOT NULL,
        `shop` VARCHAR(60) NOT NULL, `item` VARCHAR(80) NOT NULL, `quantity` INT UNSIGNED NOT NULL,
        `amount` INT UNSIGNED NOT NULL, `payment` ENUM('cash','bank') NOT NULL,
        `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (`id`), KEY `identifier_created` (`identifier`,`created_at`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])
end)

lib.callback.register('rs-shops:server:buy', function(source, shopId, itemName, rawQuantity, payment)
    local now = GetGameTimer()
    if cooldown[source] and now - cooldown[source] < 500 then return false, 'Wacht even.' end
    cooldown[source] = now

    local xPlayer = ESX.GetPlayerFromId(source)
    local shop = getShop(shopId)
    local item = getItem(shop, itemName)
    local quantity = math.floor(tonumber(rawQuantity) or 0)
    if not xPlayer or not shop or not item or not nearShop(source, shop) then return false, 'Aankoop geweigerd.' end
    local maximum = math.min(Config.MaxQuantity, tonumber(item.max) or Config.MaxQuantity)
    if quantity < 1 or quantity > maximum or (payment ~= 'cash' and payment ~= 'bank') then return false, 'Ongeldig aantal of betaalmiddel.' end
    if not exports.ox_inventory:CanCarryItem(source, item.name, quantity) then return false, 'Je hebt onvoldoende ruimte.' end

    local total = item.price * quantity
    local balance = payment == 'cash' and xPlayer.getMoney() or xPlayer.getAccount('bank').money
    if balance < total then return false, payment == 'cash' and 'Onvoldoende contant geld.' or 'Onvoldoende banksaldo.' end

    if payment == 'cash' then xPlayer.removeMoney(total, 'Shop purchase') else xPlayer.removeAccountMoney('bank', total, 'Shop purchase') end
    local added = exports.ox_inventory:AddItem(source, item.name, quantity)
    if added ~= true then
        if payment == 'cash' then xPlayer.addMoney(total, 'Failed shop purchase') else xPlayer.addAccountMoney('bank', total, 'Failed shop purchase') end
        return false, 'Het item kon niet worden toegevoegd; je betaling is teruggedraaid.'
    end

    MySQL.insert.await('INSERT INTO rs_shop_transactions (identifier, shop, item, quantity, amount, payment) VALUES (?, ?, ?, ?, ?, ?)', { xPlayer.identifier, shopId, item.name, quantity, total, payment })
    log('Winkelaankoop', ('**%s** kocht **%sx %s** voor **€%s** bij %s.'):format(GetPlayerName(source), quantity, item.name, total, shop.label))
    return true, ('%sx %s gekocht voor €%s.'):format(quantity, item.label, total)
end)

AddEventHandler('playerDropped', function() cooldown[source] = nil end)
