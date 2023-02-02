TwoNa = {}
TwoNa.Callbacks = {}
TwoNa.Framework = {}
TwoNa.Vehicles = {}
TwoNa.MySQL = {
    Async = {},
    Sync = {}
}

TwoNa.RegisterServerCallback = function(name, func) 
    TwoNa.Callbacks[name] = func
end

TwoNa.TriggerCallback = function() 
    -- TODO
end

TwoNa.Log = function(str) 
    print("[\x1b[44m2na_core\x1b[0m]: " .. str)
end

-- TODO: Implement sync system
TwoNa.MySQL.Async.Fetch = function(query, variables, cb) 
    if not cb or type(cb) ~= 'function' then 
        cb = function() end
    end

    if Config.MySQL == 'mysql-async' then
        return exports["mysql-async"]:mysql_fetch_all(query, variables, cb) 
    elseif Config.MySQL == 'oxmysql' then
        return exports["oxmysql"]:prepare(query, variables, cb) 
    end
end

TwoNa.MySQL.Sync.Fetch = function(query, variables) 
    local result = {}
    local finishedQuery = false
    local cb = function(r) 
        result = r
        finishedQuery = true
    end

    if Config.MySQL == 'mysql-async' then
        exports["mysql-async"]:mysql_fetch_all(query, variables, cb) 
    elseif Config.MySQL == 'oxmysql' then
        exports["oxmysql"]:prepare(query, variables, cb)
    end

    while not finishedQuery do
        Citizen.Wait(0)
    end

    return result
end

TwoNa.MySQL.Async.Execute = function(query, variables, cb) 
    if not cb or type(cb) ~= 'function' then 
        cb = function() end
    end

    if Config.MySQL == 'mysql-async' then
        return exports["mysql-async"]:mysql_execute(query, variables, cb) 
    elseif Config.MySQL == 'oxmysql' then
        return exports["oxmysql"]:execute_async(query, variables, cb)
    end
end

TwoNa.MySQL.Sync.Execute = function(query, variables) 
    local result = {}
    local finishedQuery = false
    local cb = function(r) 
        result = r
        finishedQuery = true
    end

    if Config.MySQL == 'mysql-async' then
        exports["mysql-async"]:mysql_execute(query, variables, cb) 
    elseif Config.MySQL == 'oxmysql' then
        exports["oxmysql"]:execute_async(query, variables, cb)
    end

    while not finishedQuery do
        Citizen.Wait(0)
    end
    
    return result
end

TwoNa.GetIdentifier = function(source) 
    if Config.Framework == 'ESX' then
        return TwoNa.Framework.Functions.GetIdentifier(source)
    elseif Config.Framework == 'QB' then
        local xPlayer = TwoNa.Framework.GetPlayerFromId(source)
        return xPlayer.getIdentifier()
    end
end

TwoNa.GetPlayer = function(source) 
    local player = {}

    if Config.Framework == 'ESX' then
        local xPlayer = TwoNa.Framework.GetIdentifier(source)

        player["name"] = xPlayer.getName()
        player["accounts"] = xPlayer.getAccounts()

        player.getMoney = xPlayer.getMoney
        player.addMoney = xPlayer.addMoney
        player.removeMoney = xPlayer.removeMoney

    elseif Config.Framework == 'QB' then
        local xPlayer = TwoNa.Framework.Functions.GetPlayer(source)

        player["name"] = xPlayer.charinfo.firstname .. " " .. xPlayer.charinfo.lastame
        player["accounts"] = xPlayer.money

        player.getMoney = function()
            return xPlayer.Functions.GetMoney("cash") 
        end
        player.addMoney = function(amount)
            return xPlayer.Functions.AddMoney("cash", amount, "") 
        end
        player.removeMoney = function(amount) 
            return xPlayer.Functions.RemoveMoney("cash", amount, "")
        end
    end

    return player
end

TwoNa.GetAllVehicles = function(force)
    if TwoNa.Vehicles and not force then 
        return TwoNa.Vehicles
    end
    
    local vehicles = {}

    if Config.Framework == 'ESX' then
        local data = TwoNa.MySQL.Sync.Fetch("SELECT * FROM vs_cars", {})

        for k, v in ipairs(data) do 
            vehicles[v.model] = {
                model = v.model,
                name = v.name,
                category = v.category,
                price = v.price
            }
        end
        
    elseif Config.Framework == 'QB' then 
        for k,v in ipairs(TwoNa.Framework.Shared.Vehicles) do
            vehicles[k] = {
                model = k,
                name = v.name,
                category = v.category,
                price = v.price
            } 
        end
    end

    TwoNa.Vehicles = vehicles

    return vehicles
end

TwoNa.CheckUpdate = function() 
    PerformHttpRequest("https://api.github.com/repos/tunasayin/2na_core/releases/latest", function(errorCode, rawData, headers) 
        if rawData ~= nil then
            local data = json.decode(tostring(rawData))
            local version = string.gsub(data.tag_name, "v", "")
            local installedVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)

            if installedVersion == version then
                TwoNa.Log("An update is available for 2na_core. Download update from: " .. data.html_url) 
            end
        end
    end)
end