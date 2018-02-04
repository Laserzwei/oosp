package.path = package.path .. ";data/scripts/lib/?.lua"
require ("utility")
config = {}
config.MOD = "OOSP"
config.VERSION = "[0.99_5b] "
config.debugLevel = 0

--This affects resource depots
config.ResourcefillTime = 86400                 -- Time in suntil the resource depot fills up. Default 86400 (24h). Has to be >0
config.ResourceMaxFactor = 10.0                 -- Defines the maximum Stock-INCRESE as a factor of 10.000, per loading. Has to be >0
config.ResourceVariation = 0.1                  -- Variance in max. Stock and max. resource added by oosp. Default 0.1 (10%) range [0.0 - 1.0]. Has +- effect

config.debugPrint = function (debuglvl, msg, ...)
    if debuglvl <= config.debugLevel then
        local str = config.MOD..config.VERSION..msg
        local strs = {}
        local tabls = {}
        for _,arg in ipairs({...}) do
            if type(arg) == "table" then
                table.insert(tabls, arg)
            else
                table.insert(strs, arg)
            end
        end
        for _,table in ipairs(tabls) do
            printTable(table)
        end
        print(str, unpack(strs))
    end
end

return config
