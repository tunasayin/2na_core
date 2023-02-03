Citizen.CreateThread(function() 
    while TwoNa.Framework == nil do
        if Config.Framework == 'ESX' then
            TriggerEvent("esx:getSharedObject", function(framewok)
                TwoNa.Framework = framewok
            end)
        else if Config.Framework == 'QB' then
                TwoNa.Framework = exports["qb-core"]:GetCoreObject()
            end
        end

        Citizen.Wait(1)
    end
end)