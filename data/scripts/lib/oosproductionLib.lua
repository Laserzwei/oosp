--[[
This Helper Funktion is required because in oosproduction.lua there is no Entity Context. Therfore the tradingmanager.lua does not provide useful results.
]]
package.path = package.path .. ";data/scripts/lib/?.lua"
require ("goods")

local DEBUGLEVEL = 2

function debugPrint(debuglvl, msg, tableToPrint, ...)
    if debuglvl <= DEBUGLEVEL then
        print(MOD..VERSION..msg, ...)
        if type(tableToPrint) == "table" then
            printTable(tableToPrint)
        end
    end
end

function getNumGoods(entity, name)
    local self = entity

    local good = goods[name]:good() -- I have legitimately no idea why this works, but it works ;D
    if not good then return 0 end

    return self:getCargoAmount(good)
end

function getMaxGoods(entity, tradingGoodsData, name)
    local boughtGoods, soldGoods = extractTradingGoods(tradingGoodsData)
    local amount = 0

    for i, good in pairs(soldGoods) do
        if good.name == name then
            return getMaxStock(boughtGoods, soldGoods, entity, good.size)
        end
    end

    for i, good in pairs(boughtGoods) do
        if good.name == name then
            return getMaxStock(boughtGoods, soldGoods, entity, good.size)
        end
    end

    return amount
end

function getMaxStock(boughtGoods, soldGoods, entity, goodSize)

    local self = entity

    local space = self.maxCargoSpace
    local slots = #boughtGoods + #soldGoods

    if slots > 0 then space = space / slots end

    if space / goodSize > 100 then
        -- round to 100
        return math.min(25000, round(space / goodSize / 100) * 100)
    else
        -- not very much space already, don't round
        return math.floor(space / goodSize)
    end
end

function increaseGoods(entity, tradingGoodsData, name, delta)
    local boughtGoods, soldGoods = extractTradingGoods(tradingGoodsData)
    local self = entity
    for i, good in pairs(soldGoods) do
        if good.name == name then
            -- increase
            local current = self:getCargoAmount(good)
            delta = math.min(delta, getMaxStock(boughtGoods, soldGoods, self, good.size) - current)

            self:addCargo(good, delta)

            --broadcastInvokeClientFunction("updateSoldGoodAmount", i) --This is soley for when the UI is open. It will never be in oos.
        end
    end

    for i, good in pairs(boughtGoods) do
        if good.name == name then
            -- increase
            local current = self:getCargoAmount(good)
            delta = math.min(delta, getMaxStock(boughtGoods, soldGoods, self, good.size) - current)

            self:addCargo(good, delta)

            --broadcastInvokeClientFunction("updateBoughtGoodAmount", i) --This is soley for when the UI is open. It will never be in oos
        end
    end

end

function decreaseGoods(entity, tradingGoodsData, name, amount)
    local boughtGoods, soldGoods = extractTradingGoods(tradingGoodsData)
    local self = entity
    for i, good in pairs(soldGoods) do
        if good.name == name then
            self:removeCargo(good, amount)

            --broadcastInvokeClientFunction("updateSoldGoodAmount", i) --This is soley for when the UI is open. It will never be in oos
        end
    end

    for i, good in pairs(boughtGoods) do
        if good.name == name then
            self:removeCargo(good, amount)

            --broadcastInvokeClientFunction("updateBoughtGoodAmount", i) --This is soley for when the UI is open. It will never be in oos
        end
    end

end

--returns boughtGoods, soldGoods
function extractTradingGoods(tradingGoodsData)
    local boughtGoods = {}
    for _, g in pairs(tradingGoodsData.boughtGoods) do
        table.insert(boughtGoods, tableToGood(g))
    end

    local soldGoods = {}
    for _, g in pairs(tradingGoodsData.soldGoods) do
        table.insert(soldGoods, tableToGood(g))
    end
    return boughtGoods , soldGoods
end

