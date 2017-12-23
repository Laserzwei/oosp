config = {}

config.includePlayerProperty = false            -- When false oosp will not update sectors with playerproperty in it, since the vanilla game can handle that. Defult false.
config.ignoreVersioncheck = true                -- Allows to check, if a
config.debugLevel = 0
--These affect Tradingposts and consumers
config.consumptionTime = 86400                  -- Time in s until stock of sold goods is emptied. Default 86400(24h). Has to be >0
config.consumptionTimeVariation = 0.1           -- Variance in time. default 0.1 (10%) range [0.0 - 0.9]. Has +- effect
--This only affects Tradingposts
config.generationTime = 86400                   -- Time in s until Stock of bought goods is filled. Default 86400(24h). Has to be >0
config.generationTimeVariation = 0.1            -- Variance in time. default 0.1 (10%) range [0.0 - 0.9]. Has +- effect
--This affects resource depots
config.ResourcefillTime = 86400                 -- Time in suntil the resource depot fills up. Default 86400 (24h). Has to be >0
config.ResourceMax = 100000                     -- Max. Stock the resource depot can get through oosp. Default 100.000. Has to be >0
config.ResourceVariation = 0.1                  -- Variance in max. Stock and max. resource added by oosp. Default 0.1 (10%) range [0.0 - 0.9]. Has +- effect

--Turn on/off update of specific stationtypes
config.includeTradingPosts = true               -- This includes planetarytradingposts
config.includeConsumers = true                  -- This includes biotope, casino, equipmentdock, habitat, militaryoutpost, repairdock, researchstation, resistance outpost, scrapyard, shipyard-trading, mines
config.includeFactories = true
config.includeResourceDepots = true
config.includeShipyards = true                  -- This is for shipyard building time

return config
