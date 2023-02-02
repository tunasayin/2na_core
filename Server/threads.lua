Citizen.CreateThread(function() 
    TwoNa.CheckUpdate()

    while TwoNa.Framework == nil do
        if Config.Framework == 'ESX' then
            TriggerEvent("esx:getSharedObject", function(framewok) 
                TwoNa.Framework = framewok
            end)
        else if Config.Framework == 'QB' then
                TwoNa.Framework = exports["qb-core"]:GetCoreObject()
            end
        end

        Citizen.Wait(10)
    end

    TwoNa.GetAllVehicles()
end)