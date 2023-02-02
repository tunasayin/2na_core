RegisterNetEvent("2na_core:Server:HandleCallback")
AddEventHandler("2na_core:Server:HandleCallback", function(name, payload)
    if TwoNa.Callbacks[name] then
        local cb = TwoNa.Callbacks[name](source, payload)

        TriggerClientEvent("2na_core:Client:HandleCallback", source, name, cb)
    end 
end)

AddEventHandler("onResourceStart", CheckUpdate)

RegisterNetEvent("2na_core:getSharedObject")
AddEventHandler("2na_core:getSharedObject", function(cb)
    if cb and type(cb) == 'function' then 
        cb(TwoNa)
    end 
end)