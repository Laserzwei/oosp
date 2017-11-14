config = {}

config.includePlayerProperty = false            -- When false oosp will not update sectors with playerproperty in it, since the vanilla game can handle that. Defult false.
config.ignoreVersioncheck = true                -- Allows to check, if a
config.debugLevel = 2
--These affect Tradingposts and consumers
config.consumptionTime = 86400                  -- Time in s until stock of sold goods is emptied. Default 86400(24h). Has to be >0
config.consumptionTimeVariation = 0.1         -- Variance in time. default 0.1 (10%) range [0.0 - 0.9]
--This only affects Tradingposts
config.generationTime = 86400                   -- Time in s until Stock of bought goods is filled. Default 86400(24h). Has to be >0
config.generationTimeVariaton = 0.1            -- Variance in time. default 0.1 (10%) range [0.0 - 0.9]

--Turn on/off update of specific stationtypes
config.includeTradingPosts = true               -- This includes planetarytradingposts
config.includeConsumers = true                  -- This includes biotope, casino, equipmentdock, habitat, militaryoutpost, repairdock, researchstation, resistance outpost, scrapyard, shipyard-trading, mines
config.includeFactories = true
config.includeResourceDepots = true
config.includeShipyards = true                  -- This is for shipyard building time

return config
