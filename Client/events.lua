RegisterNetEvent("2na_core:Client:HandleCallback")
AddEventHandler("2na_core:Client:HandleCallback", function(name, data) 
    if TwoNa.Callbacks[name] then
        TwoNa.Callbacks[name](data) 
    end
end)