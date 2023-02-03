Citizen.CreateThread(function() 
    while TwoNa.Framework == nil do
        if Config.Framework == 'ESX' then
            TriggerEvent("esx:getSharedObject", function(framewok) 
                TwoNa.Framework = framewok
            end)
        elseif Config.Framework == 'QB' then
            TwoNa.Framework = exports["qb-core"]:GetCoreObject()
        end

        Citizen.Wait(10)
    end
end)