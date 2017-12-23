package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";mods/oosp/scripts/lib/?.lua"

require ("oosproductionLib")
require ("utility")
require ("goods")
require ("productions")
require ("galaxy")
local oospConfig = require ("mods/oosp/config/oosp")

MOD = "[OOSP]"
VERSION = "[0.9_92d] "
local timeString = "online_time"
--sanitizing player input
oospConfig.consumptionTime = math.max(oospConfig.consumptionTime, 1)
oospConfig.consumptionTimeVariation = math.max(math.min(oospConfig.consumptionTimeVariation, 0.9), 0.0)
oospConfig.generationTime = math.max(oospConfig.generationTime, 1)
oospConfig.generationTimeVariation = math.max(math.min(oospConfig.generationTimeVariation, 0.9), 0.0)

local usesRightVersion = false
local derefferedTimeout = 20                    -- in seconds
local hasBeenChecked = false

function debugPrint(debuglvl, msg, tableToPrint, ...)
    if debuglvl <= oospConfig.debugLevel then
        print(MOD..VERSION..msg, ...)
        if type(tableToPrint) == "table" then
            printTable(tableToPrint)
        end
    end
end

function initialize()
    if onServer() then
        debugPrint(0,"======oos initialising for Player "..Player().name.."======")
        --unregister events to clear things up.
        local unregisterOnSectorLeftValue = Player():unregisterCallback("onSectorLeft", "onSectorLeft")
        local unregisterOnSectorEnteredValue = Player():unregisterCallback("onSectorEntered", "onSectorEntered")
        local unregisterOnPlayerLogOffValue = Server():unregisterCallback("onPlayerLogOff", "onPlayerLogOff")

        debugPrint(3,"Event cleanup: "..tostring(unregisterOnSectorLeftValue).." | "..tostring(unregisterOnSectorEnteredValue).." | "..tostring(unregisterOnPlayerLogOffValue).." Expected: 0|0|0")

        playerIndex = Faction().index
        if playerIndex ~= nil and oospConfig.ignoreVersioncheck == false then
            Player(): sendChatMessage("Sever", 2, "Waiting to receive version. Try not to Jump. This takes about 20 seconds!")
            deferredCallback(derefferedTimeout, "dCheck", playerIndex)
        end

        if playerIndex ~= nil and config.ignoreVersioncheck == true then
            usesRightVersion = true
            registerPlayer(playerIndex)
        end

        --begin registering events for a fresh start
        Server():registerCallback("onPlayerLogOff", "onPlayerLogOff")

    else
        debugPrint(3, "client init")
    end

end
--dereffered check, because invoking a client function on init is not possible
function dCheck(playerIndex)
    debugPrint(2, "dCheck passed")
    invokeClientFunction(Player(playerIndex), "checkVersion", playerIndex)
    deferredCallback(derefferedTimeout, "processVersion", playerIndex, nil)
end

function checkVersion(playerIndex)
    if onClient() then
        debugPrint(2, "Version check on Client")
        invokeServerFunction("compareVersion", Player().index, VERSION)
    end
end

function compareVersion(playerIndex, version)
    debugPrint(2, "Version Check")
    if VERSION == version then
        usesRightVersion = true
    else
        usesRightVersion = false
    end
    if onServer() then processVersion(playerIndex, version) end
end

function processVersion(playerIndex, version)
    if onServer() then
        debugPrint(2, "Processing Version: ", nil, version, tostring(hasBeenChecked))
        if hasBeenChecked == true then return end
        hasBeenChecked = true
        local name
        if version == nil then
            version = "No Version received"
        end
        name = Player().name
        if usesRightVersion == true then
            debugPrint(1, "Player "..name.." Logged in with the correct version of OOSP: "..VERSION)
            Player():sendChatMessage("Server", 3, "OOSP version received and validated: "..VERSION..". OOSP is activated for you! ")
            registerPlayer(playerIndex)
        elseif usesRightVersion == false then
            debugPrint(1, "Player "..name.." uses a different"..version.." version of OOSP")
            Player():sendChatMessage("Server", 2, "Update your version ("..version..") to "..VERSION..". OOSP is deactivated for you! ")
            local unregisterOnSectorLeftValue = Player():unregisterCallback("onSectorLeft", "onSectorLeft")
            local unregisterOnSectorEnteredValue = Player():unregisterCallback("onSectorEntered", "onSectorEntered")
            local unregisterOnPlayerLogOffValue = Server():unregisterCallback("onPlayerLogOff", "onPlayerLogOff")
            debugPrint(2, "Event unregisteration due to wrong version: "..tostring(unregisterOnSectorLeftValue).." | "..tostring(unregisterOnSectorEnteredValue).." | "..tostring(unregisterOnPlayerLogOffValue))
            sendMoreMessages(playerIndex, tostring(version))
        else
            debugPrint(3, "[T] Empty")
        end
    end
 end

function sendMoreMessages(playerIndex, version)
    local player = Player(playerIndex)
    local name = Player(playerIndex).name
    if usesRightVersion == true then
        debugPrint(1, "Player "..name.." has send the correct Version after an unexpected long delay ")
        player:sendChatMessage("Laserzwei", 3, "Your Version check took longer than expected. You are ready to use OOSP now.")
        registerPlayer(playerIndex)
        return
    end
    player:sendChatMessage("Server", 2, "Update your version ("..version..") to "..VERSION..". OOSP is deactivated for you! ")
    if version == "No Version received" then
        player:sendChatMessage("Laserzwei", 2, "If you are 100% sure you installed OOSP, correctly contact Laserzwei on the Avorion Forum.")
    end
    debugPrint(2, "Remembered "..name.." that he is using the wrong version: "..version)
    deferredCallback(10,"sendMoreMessages",playerIndex, version)
end

 function registerPlayer(playerIndex)
    local player = Player(playerIndex)
    Server():registerCallback("onPlayerLogOff", "onPlayerLogOff")
    player:registerCallback("onSectorLeft", "onSectorLeft")
    player:registerCallback("onSectorEntered", "onSectorEntered")
    debugPrint(1, Player(playerIndex).name.." has been activated.")
    onPlayerLogIn(playerIndex)
 end

--When a Player logs in, the onSectorEntered-Event is not fired. This would cause the Sector to be ignored by the oosproduction-Script.
function onPlayerLogIn(playerIndex)
    if Player(playerIndex).name ~= Player().name then            --wrong player called
        return
    end
    if usesRightVersion == false then
        onPlayerLogOff(playerIndex)
        return
    end
    if onClient() then debugPrint(4, "onPlayerLogIn executed from Client") end
    local x,y = Sector():getCoordinates()
    onSectorEntered(playerIndex, x, y)
end

function onPlayerLogOff(playerIndex)--Initialize gets called on PlayerLogIn
    if Player(playerIndex).name ~= Player().name then            --wrong player called
        debugPrint(1, "Wrong Player Logoff")
        return
    end
    --unregister twice: better safe than sorry
    local unregisterOnSectorLeftValue = Player():unregisterCallback("onSectorLeft", "onSectorLeft")
    local unregisterOnSectorEnteredValue = Player():unregisterCallback("onSectorEntered", "onSectorEntered")

    debugPrint(3, "Event unregisteration: "..tostring(unregisterOnSectorLeftValue).." | "..tostring(unregisterOnSectorEnteredValue))
    debugPrint(0, "======oos unloading Player "..Player(playerIndex).name.."======")
    local x,y = Sector():getCoordinates()
    debugPrint(2, Player(playerIndex).name .. " " .. x .. ":" .. y)
    onSectorLeft(playerIndex, x, y)
end

--sets a Timestamp when the last player leaves the Sector
function onSectorLeft(playerIndex, x, y)
    if Player(playerIndex).name ~= Player().name then            --wrong player called
        return
    end
    local numplayer = Sector().numPlayers
    local galaxyTickName = timeString

    if(numplayer <=1) then   -- we only need a new timestamp when a sector gets unloaded. The player is still in sector when the Hook calls, thus we check for mor remaining players
        local timestamp = Sector():getValue("oosTimestamp")
        if timestamp ~= nil then --update Timestamp
            timestamp = Server():getValue(timeString)
            Sector():setValue("oosTimestamp", timestamp)
            debugPrint(2, "timestamp: ".. timestamp .. " for Sector ".. x .. ":" .. y.." updated")
        else        --sector was never timestamped
            timestamp = Server():getValue(timeString)
            Sector():setValue("oosTimestamp", timestamp)
            debugPrint(2, "Sector get first timestamp: ".. timestamp .. " | ".. x .. ":" .. y)
        end
    end
end
--Test
--Is there a timestamp on which we can work?-Then do so.
function onSectorEntered(playerIndex, x, y)
    if Player(playerIndex).name ~= Player().name then            --wrong player called
        return
    end
    local timer = Timer()
    timer:start()
    sector = Sector()
    local stations = {sector:getEntitiesByType(EntityType.Station)}
    local ships = {sector:getEntitiesByType(EntityType.Ship)}
    if oospConfig.includePlayerProperty == false then
        for _,station in pairs(stations) do
            if station ~= nil and station.factionIndex ~= nil then
                if Faction(station.factionIndex) and Faction(station.factionIndex).isPlayer then
                    debugPrint(3,"no OOSP update for Playersectors", nil, "Sector "..sector.name.." ("..x..":"..y..")Station: ", station.name, Player(station.factionIndex).name)
                    return
                end
            else
                debugPrint(2,"Found Factionless station", nil, station.name)
            end
        end

        for _,ship in pairs(ships) do
            if ship.factionIndex ~= nil then
                local faction = Faction(ship.factionIndex)
                if faction ~= nil then
                    if faction.isPlayer and ship.index ~= Player().craftIndex then
                        debugPrint(3,"no OOSP update for Playersectors", nil, "Sector "..sector.name.." ("..x..":"..y..") Ship: ", ship.name, Player(ship.factionIndex).name)
                        return
                    end
                else
                    debugPrint(2,"Found Factionless ship", nil, ship.name)
                end
            end
        end

        debugPrint(3, "Sector: "..x..":"..y.. " needed " ..(timer.microseconds/1000) .."ms for sorting out")
    end

    debugPrint(2, "Player: "..Player().name.." entered sector with: "..(Sector().numPlayers-1).." more player(s)")

    local timestamp = Sector():getValue("oosTimestamp")

    if timestamp ~= nil then
        if Sector().numPlayers <= 1 then
            debugPrint(2, "timestamp aquired: " .. timestamp)
            calculateOOSProductionForStations(Sector(),timestamp)
        else
            debugPrint(1, "Sector has been loaded already: "..Sector().numPlayers)
        end
    else
        debugPrint(1, "no timestamp - no production!")
    end
    timer:stop()
    debugPrint(3, "Sector: "..x..":"..y.. " needed " ..(timer.microseconds/1000) .."ms for Production catch-up")
end

--apply retro-production to factories and shipyards.
function calculateOOSProductionForStations(sector,timestamp)
    local stations = {sector:getEntitiesByType(EntityType.Station)}
    local countS, countF = 0, 0
    for _, station in pairs(stations) do
        local t = Timer()
        t:start()
        countS = countS + 1
        if (oospConfig.includeFactories and station:hasScript("factory.lua")) then                      --normal factory
            if (station:hasScript("turretfactory.lua")) then            --factory is a substring of turretfactory, but a turretfactory doesn't produce anything
            else
                countF = countF + 1
                calculateOOSProductionForFactory(station, timestamp)
            end
        end
        if (oospConfig.includeConsumers and station:hasScript("consumer.lua")) then --biotope, casino, equip.dock, habitat, militaryoutpost, repairdock, researchstation, resistance outpost, scrapyard, shipyard-trading
            consumption(station, timestamp)
        end
        if (oospConfig.includeTradingPosts and station:hasScript("planetarytradingpost.lua")) then
            calculateOOSProductionForTradingPost(station, timestamp, "scripts/entity/merchants/planetarytradingpost.lua")
        end
        if (oospConfig.includeTradingPosts and station:hasScript("tradingpost.lua")) then
            calculateOOSProductionForTradingPost(station, timestamp, "scripts/entity/merchants/tradingpost.lua")
        end
        if (oospConfig.includeResourceDepots and station:hasScript("resourcetrader.lua")) then
            calculateOOSProductionForResourcetrader(station, timestamp)
        end
        if (oospConfig.includeShipyards and station:hasScript("shipyard.lua")) then                      --shipyard-ships
            debugPrint(3, "update shipyard: "..station.name)
            calculateOOSProductionForShipyard(station,timestamp)
        end
        t:stop()
        debugPrint(4,"Needed ", nil, (t.microseconds/1000).."ms for station: ", station.name, station.typename)
        t:reset()
    end
    debugPrint(1, countF .. "/"..countS.." Factories/Stations")
end

function calculateOOSProductionForShipyard(shipyard,timestamp)
    local currentTime = Server():getValue(timeString)
    local timeDelta = currentTime - timestamp
    if timeDelta <= 0 then
        return
    end
    local dat = shipyard:invokeFunction("data/scripts/entity/merchants/shipyard.lua","update",timeDelta)
    if(tostring(dat) == "0") then
        debugPrint(3, "update shipyard +: "..timeDelta)
    else
        debugPrint(3, "Error updating shipyard: "..tostring(dat))

    end
end

function calculateOOSProductionForTradingPost(station, timestamp, script)
    local status, tradingdata = station:invokeFunction(script, "secure")
    if status ~= 0 then
        debugPrint(4, "Could not update tradingpost ", nil, station.name, status)
        return
    end
    local currentTime = Server():getValue(timeString)
    if type(currentTime) ~= "number" then
        debugPrint(0, "galaxyticks not found!")
        return
    end

    local timeDelta = currentTime - timestamp
    local boughtGoods = tradingdata.boughtGoods

    for _,good in pairs(boughtGoods) do
        local status, currentStock, maxStock = station:invokeFunction(script, "getStock", good.name)
        local percentageToTake = (timeDelta / oospConfig.consumptionTime) * (1 + (math.random() * 2 * oospConfig.consumptionTimeVariation) - oospConfig.consumptionTimeVariation)
        local amount = maxStock * percentageToTake
        debugPrint(4, "removing", nil, amount, good.name, "from", station.name, maxStock, percentageToTake, currentStock)
        if amount > 5 then
            local status = station:invokeFunction(script, "decreaseGoods", good.name, amount)
        end
    end

    local soldGoods = tradingdata.soldGoods
    for _,good in pairs(soldGoods) do
        local status, currentStock, maxStock = station:invokeFunction(script, "getStock", good.name)
        local percentageToAdd = (timeDelta / oospConfig.generationTime) * (1 + (math.random() * 2 * oospConfig.generationTimeVariation) - oospConfig.generationTimeVariation)
        local amount = maxStock * percentageToAdd
        debugPrint(4, "adding", nil, amount, good.name, "to", station.name, maxStock, percentageToAdd, currentStock)
        if amount > 5 then
            local status = station:invokeFunction(script, "increaseGoods", good.name, amount)
        end
    end


end

function calculateOOSProductionForResourcetrader(station, timestamp)
    local status, stock = station:invokeFunction("scripts/entity/merchants/resourcetrader.lua", "secure")
    if status ~= 0 then
        debugPrint(4, "Could not update resourcetrader ", nil, station.name, status)
        return
    end
    local currentTime = Server():getValue(timeString)
    if type(currentTime) ~= "number" then
        debugPrint(0, "galaxyticks not found!")
        return
    end

    local timeDelta = currentTime - timestamp
    local probabilities = Balancing_GetMaterialProbability(Sector():getCoordinates());
    for index, amount in ipairs(stock) do
        if probabilities[index-1]-0.1 > 0 and index <= 7 then
            local variance = 1 + (math.random() * 2 * oospConfig.ResourceVariation) - oospConfig.ResourceVariation
            local stockChange = timeDelta/oospConfig.ResourcefillTime * oospConfig.ResourcefillTime * variance
            local newStock = math.min(math.floor(oospConfig.ResourceMax*variance), math.floor(amount + stockChange))
            newStock = math.max(0,newStock)
            station:invokeFunction("scripts/entity/merchants/resourcetrader.lua", "setData", index, newStock)
            debugPrint(3,"Resource depotupdate", nil, "Res:", Material(index-1).name, "before:", amount, "after:", newStock)
        else
            break
        end
    end
end

function consumption(station, timestamp)
    local status, tradingdata = station:invokeFunction("scripts/entity/merchants/consumer.lua", "secure")
    if status ~= 0 then
        debugPrint(4, "Could not update consumer ", nil, station.name, status)
        return
    end
    local currentTime = Server():getValue(timeString)
    if type(currentTime) ~= "number" then
        debugPrint(0, "galaxyticks not found!")
        return
    end

    local timeDelta = currentTime - timestamp
    local boughtGoods = tradingdata.boughtGoods

    for _,good in pairs(boughtGoods) do
        local status, currentStock, maxStock = station:invokeFunction("scripts/entity/merchants/consumer.lua", "getStock", good.name)
        local percentageToTake = (timeDelta / oospConfig.consumptionTime) * (1 + (math.random() * 2 * oospConfig.consumptionTimeVariation) - oospConfig.consumptionTimeVariation)
        local amount = math.floor(maxStock * percentageToTake)
        debugPrint(4, "removing", nil, amount, good.name, "from", station.name, maxStock, percentageToTake, currentStock)
        if amount > 5 then
            local status = station:invokeFunction("scripts/entity/merchants/consumer.lua", "decreaseGoods", good.name, amount)
        end
    end
end

--calculate the production in absence
function calculateOOSProductionForFactory(factory,timestamp)
    local currentTime = Server():getValue(timeString)
    if type(currentTime) ~= "number" then
        debugPrint(0, "galaxyticks not found!")
        return
    end
    local timeDelta = currentTime - timestamp
    if timeDelta < 1 then
        debugPrint(0, "There was a Jump back in time! Did the server crash previously?") --more likely : the Tickhandler restarted or could not load the Ticksfile
        return
    end

    local status , factoryData = factory:invokeFunction("factory", "secure", nil)
    debugPrint(4, "Status of the underlaying Factoryrequest: " .. status)
    local maxDuration = 0
    local maxNumProductions = 0
    local factorySize = 0
    local production = {}
    local currentProductions = {}
    local tradingdata = {}
    if status == 0 then
        maxDuration = factoryData.maxDuration                 --Factory total cycle time
        maxNumProductions = factoryData.maxNumProductions     --max. number simultainious Productions
        factorySize = factoryData.maxNumProductions - 1       --self explained
        production = factoryData.production                   -- *.ingredients, *.results, *.garbage
        currentProductions = factoryData.currentProductions   --Table with the passed cycletime per running Production
        tradingdata = factoryData.tradingData                 --All Information about stored Goods in a Station
        local name, args = formatFactoryName(factoryData.production, factoryData.maxNumProductions - 1)
        name = string.gsub(name, "${good}", tostring(args.good))
        name = string.gsub(name, "${size}", "S")
        debugPrint(1, "    "..name.. "    "..factory.name)
    else
        debugPrint(0, factory.name..": Could not receive factory Data")
        return
    end

    local value = 0
    for _, result in pairs(production.results) do
        local good = goods[result.name]
        if good then
            value = value + good.price * result.amount * math.max(1, good.level)
        end
    end

    if production.garbages then
        for i, garbage in pairs(production.garbages) do
            local good = goods[garbage.name]
            if good then
                value = value + good.price * garbage.amount
            end
        end
    end
    local productionCapacity = math.max(100, factory:getPlan():getStats().productionCapacity)
    local timeToProduce = math.max(15.0, value / productionCapacity)

    local maximumProcesses = (timeDelta / (timeToProduce)) * maxNumProductions -- theoretical maximum we can produce ine the Timeframe. Might be corrected down later on.
    debugPrint(3, "timeDelta: "..timeDelta)
    debugPrint(3, "Starting with: "..maximumProcesses)
    local spaceForExtraProcessesNeeded = 0     --since the currently running processes will be ended within the factory script, we need to make sure that they will still fit in.
    for i,timepassed in pairs(currentProductions) do
        if(timeToProduce - timepassed) <= timeDelta then
            debugPrint(4, "Current Process at: "..timepassed)
            maximumProcesses = maximumProcesses - 1
            spaceForExtraProcessesNeeded = spaceForExtraProcessesNeeded + 1
        end
    end
    debugPrint(3, "Current production reduces to: "..maximumProcesses)
    if(maximumProcesses <= 0 )then
        debugPrint(3, "no Production catch-up needed.")
        return
    end
    --get max. amount of Processcycles we can have with our ressources
    for _, ingredient in pairs(production.ingredients) do
        if(ingredient.amount == 0) then
            debugPrint(4, factory.name.." doesn't need "..ingredient.name.."for production.")
        else
            if ingredient.optional == 0 and math.floor(getNumGoods(factory, ingredient.name) / ingredient.amount) > 0 then
                debugPrint(3, ingredient.name..": "..getNumGoods(factory, ingredient.name).." | required: " .. ingredient.amount)
                maximumProcesses = math.min(math.floor(getNumGoods(factory, ingredient.name) / ingredient.amount), maximumProcesses)
            end
            if(ingredient.optional == 0 and getNumGoods(factory, ingredient.name) < ingredient.amount) then
                debugPrint(2, "Not enough resources for a single process: "..ingredient.name)
                return
            end
        end
    end
    debugPrint(3, "Ressources reduce to: "..maximumProcesses)
    --get max. amount of Processcycles we can have with our garbage capacity
    for _, garbage in pairs(production.garbages) do
        debugPrint(4, "Free space for "..garbage.name..": "..(getMaxGoods(factory, tradingdata, garbage.name) - getNumGoods(factory, garbage.name)).." | required: " .. garbage.amount)
        maximumProcesses = math.min((getMaxGoods(factory, tradingdata, garbage.name) - getNumGoods(factory, garbage.name)), maximumProcesses)
        if maximumProcesses == 0 then
            debugPrint(2, "Not enough cargospace for a single process: "..garbage.name)
            return
        end
    end
    debugPrint(2, "Garbage Storage Space reduces to: "..maximumProcesses)
    --get max. amount of Processcycles we can have with our result capacity
    for _, result in pairs(production.results) do
        debugPrint(4, "Free space for "..result.name..": "..(getMaxGoods(factory, tradingdata, result.name) - getNumGoods(factory, result.name)).. " minus: "..spaceForExtraProcessesNeeded.. " | required: " .. result.amount)
        maximumProcesses = math.min((getMaxGoods(factory, tradingdata, result.name) - getNumGoods(factory, result.name) - spaceForExtraProcessesNeeded), maximumProcesses)
        if maximumProcesses == 0 then
            debugPrint(2, "not enough Cargospace for a single process: "..result.name)
            return
        end
    end
    maximumProcesses = math.floor(maximumProcesses)
    if(maximumProcesses <= 0) then -- just in case. We wouldn't want negative Production right?
        debugPrint(0, factory.name.." needs no Production catch-up.")
        return
    end
    debugPrint(1, "The Factory is "..maximumProcesses.." processes behind.")

    for _, ingredient in pairs(production.ingredients) do
        debugPrint(4, "remove "..ingredient.amount * maximumProcesses.." of " .. ingredient.name)
        decreaseGoods(factory, tradingdata, ingredient.name, ingredient.amount * maximumProcesses)
    end

    for i, result in pairs(production.results) do
        debugPrint(4, "add "..result.amount * maximumProcesses.." of " .. result.name)
        increaseGoods(factory, tradingdata, result.name, result.amount * maximumProcesses)
    end

    for i, garbage in pairs(production.garbages) do
        debugPrint(4, "add "..garbage.amount * maximumProcesses.." of " .. garbage.name)
        increaseGoods(factory, tradingdata, garbage.name, garbage.amount * maximumProcesses)
    end
end
