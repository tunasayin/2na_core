TwoNa = {}
TwoNa.Callbacks = {}
TwoNa.Framework = {}

TwoNa.RegisterServerCallback = function(name, func) 
    TwoNa.Callbacks[name] = func
end

TwoNa.TriggerCallback = function() 
    -- TODO
end

TwoNa.MySQL_Execute = function(query, variables, cb) 
    if Config.MySQL == 'mysql-async' then
        if cb then
            exports["mysql-async"]:mysql_execute(query, variables, function(result) 
                cb(result)
            end) 
        else
            return exports["mysql-async"]:mysql_execute(query, variables) 
        end
    elseif Config.MySQL == 'oxmysql' then
        if cb then 
            exports["oxmysql"]:execute_async(query, variables, function(result) 
                cb(result)
            end)
        else
            return exports["oxmysql"]:execute_async(query, variables)
        end
    end
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

TwoNa.GetAllVehicles = function() 
    -- TODO:
end

TwoNa.CheckUpdate = function() 
    PerformHttpRequest("https://raw.githubusercontent.com/tunasayin/2na_core/main/version.txt", function(errorCode, data, headers) 
        if data ~= nil then

        end
    end)
end