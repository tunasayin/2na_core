TwoNa = {}
TwoNa.Callbacks = {}
TwoNa.Framework = {}
TwoNa.Game = {}

TwoNa.TriggerServerCallback = function(name, payload, func) 
    TwoNa.Callbacks[name] = func

    TriggerServerEvent("2na_core:Server:HandleCallback", name, payload)
end

TwoNa.Game.GetVehicleProperties = TwoNa.Framework.GetVehicleProperties
TwoNa.Game.SetVehicleProperties = TwoNa.Framework.SetVehicleProperties