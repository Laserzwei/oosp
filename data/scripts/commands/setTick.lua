package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/server/?.lua"
OOSPVERSION = "[0.9_91]"  
function execute(sender, commandName, timeAmount, ...)
    if not timeAmount then
        Player(sender):sendChatMessage("Server", 2, "No arguments given.")
        return
    end
    timeAmount = tonumber(timeAmount)
    if type(timeAmount) ~= "number" then
        Player(sender):sendChatMessage("Server", 2, "No number entered.")
        return
    end
    Server():setValue("online_time", timeAmount)
    Player(sender):sendChatMessage("Server", 2, "Time changed to: "..tonumber(timeAmount))
    print(OOSPVERSION.."[OOSP][CO] ".."Changed TimeValue to: "..tonumber(timeAmount))

    return 0, "", ""
end

function getDescription()
    return "Sets the current time to the amount specified in the 1st argument."
end

function getHelp()
    return "/setTick <amount>"
end
