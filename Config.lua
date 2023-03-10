Config = {}

local Framework = "" -- Supports both ESX and QBCore
local Database = "" -- Supports both mysql-async and oxmysql



--------- DO NOT MODIFY ---------

Config.Framework = TwoNaShared.Functions.GetFramework(Framework)
Config.Database =  TwoNaShared.Functions.GetDatabase(Database)

---------------------------------