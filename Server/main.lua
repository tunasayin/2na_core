TwoNa = {}
TwoNa.Callbacks = {}
TwoNa.Framework = nil
TwoNa.Vehicles = nil
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
        exports["oxmysql"]:execute(query, variables, cb)
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
        exports["oxmysql"]:execute(query, variables, cb)
    end

    while not finishedQuery do
        Citizen.Wait(0)
    end
    
    return result
end

TwoNa.GetPlayerIdentifier = function(source) 
    if Config.Framework == 'ESX' then
        local xPlayer = TwoNa.Framework.GetPlayerFromId(source)
        return xPlayer.getIdentifier()
    elseif Config.Framework == 'QB' then
        return TwoNa.Framework.Functions.GetIdentifier(source, 'license')
    end
end

TwoNa.GetPlayer = function(source) 
    local player = {}

    if Config.Framework == 'ESX' then
        local xPlayer = TwoNa.Framework.GetPlayerFromId(source)

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
        for k,v in pairs(TwoNa.Framework.Shared.Vehicles) do
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

TwoNa.GetVehicleByName = function(name) 
    local vehicles = TwoNa.GetAllVehicles(false)
    local targetVehicle = nil

    for k,v in pairs(vehicles) do
        if v.name == name then 
            targetVehicle = v
            break
        end
    end 

    return targetVehicle
end

TwoNa.GetPlayerVehicles = function(source) 
    local identifier = TwoNa.GetPlayerIdentifier(source)
    local vehicles = TwoNa.GetAllVehicles(false)
    local playerVehicles = {}

    if Config.Framework == 'ESX' then
        local data = TwoNa.MySQL.Sync.Fetch("SELECT * FROM owned_vehicles WHERE owner = @identifier", { ["@identifier"] = identifier })

        for k,v in ipairs(data) do
            if vehicles[v.name] == nil then 
                vehicles[v.name] = TwoNa.GetVehicleByName(v.name)
            end

            table.insert(playerVehicles, {
                name = v.name,
                model = vehicles[v.name].model,
                category = v.category,
                plate = v.plate,
                fuel = v.fuel,
                price = vehicles[v.name].price,
                properties = json.decode(v.vehicle),
                stored = v.stored,
                garage = v.garage or nil
            })
        end
    elseif Config.Framework == 'QB'  then
        local data = TwoNa.MySQL.Sync.Fetch("SELECT * FROM player_vehicles WHERE license = @identifier", { ["@identifier"] = identifier })

        for k,v in ipairs(data) do
            table.insert(playerVehicles, {
                name = vehicles[v.vehicle].name,
                model = vehicles[v.vehicle].model,
                category = vehicles[v.vehicle].category,
                plate = v.plate,
                fuel = v.fuel,
                price = vehicles[v.vehicle].price or -1,
                properties = json.decode(v.mods),
                stored = v.stored or nil,
                garage = v.garage
            })
        end
    end

    return playerVehicles
end

TwoNa.UpdatePlayerVehicle = function(source, plate, vehicleData) 
    local identifier = TwoNa.GetPlayerIdentifier(source)
    local playerVehicles = TwoNa.GetPlayerVehicles(source)
    local targetVehicle = nil

    for k,v in ipairs(playerVehicles) do
         if v.plate == plate then
            targetVehicle = v 
        end
    end

    if not targetVehicle then 
        return false
    end

    if Config.Framework == 'ESX' then
        TwoNa.MySQL.Sync.Execute("UPDATE owned_vehicles SET vehicle = @props, fuel = @fuel, stored = @stored, garage = @garage WHERE owner = @identifier AND plate = @plate", {
            ["@props"] = json.encode(vehicleData.properties or targetVehicle.properties),
            ["@fuel"] = vehicleData.fuel or targetVehicle.fuel,
            ["@stored"] = vehicleData.stored,
            ["@garage"] = vehicleData.garage,
            ["@identifier"] = identifier,
            ["@plate"] = plate
        })
    elseif Config.Framework == 'QB' then
        TwoNa.MySQL.Sync.Execute("UPDATE player_vehicles SET mods = @props, fuel = @fuel, stored = @stored, garage = @garage WHERE license = @identifier AND plate = @plate", {
            ["@props"] = json.encode(vehicleData.properties or targetVehicle.properties),
            ["@fuel"] = vehicleData.fuel or targetVehicle.fuel,
            ["@stored"] = vehicleData.stored,
            ["@garage"] = vehicleData.garage,
            ["@identifier"] = identifier,
            ["@plate"] = plate
        })
    end

    return true
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

exports("getSharedObject", function() 
    return TwoNa
end)