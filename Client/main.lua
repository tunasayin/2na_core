TwoNa = {}
TwoNa.Callbacks = {}
TwoNa.Framework = nil
TwoNa.Game = {}

TwoNa.TriggerServerCallback = function(name, payload, func) 
    TwoNa.Callbacks[name] = func

    TriggerServerEvent("2na_core:Server:HandleCallback", name, payload)
end

TwoNa.Game.GetVehicleProperties = function(vehicle) 
    if Config.Framework == 'ESX' then
        return TwoNa.Framework.Game.GetVehicleProperties(vehicle)
    elseif Config.Framework == 'QB' then
        return TwoNa.Framework.Functions.GetVehicleProperties(vehicle)
    end
end
TwoNa.Game.SetVehicleProperties = function(vehicle, props) 
    if Config.Framework == 'ESX' then
        return TwoNa.Framework.Game.SetVehicleProperties(vehicle, props)
    elseif Config.Framework == 'QB' then
        return TwoNa.Framework.Functions.SetVehicleProperties(vehicle, props)
    end
end

exports("getSharedObject", function() 
    return TwoNa
end)