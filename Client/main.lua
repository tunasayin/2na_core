TwoNa = {}
TwoNa.Callbacks = {}
TwoNa.Framework = nil
TwoNa.Game = {}
TwoNa.Functions = TwoNa_Functions

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

TwoNa.Draw3DText = function(x, y, z, scale, text) 
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())

    SetTextScale(0.40, 0.40)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)

    local factor = (string.len(text)) / 350

    DrawRect(_x,_y+0.0140, 0.025+ factor, 0.03, 0, 0, 0, 105)
end

exports("getSharedObject", function() 
    return TwoNa
end)