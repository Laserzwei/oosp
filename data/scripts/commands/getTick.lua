package.path = package.path .. ";data/scripts/lib/?.lua"
OOSPVERSION = "[0.9_91]"  
function execute(sender, commandName, ...)
    Player(sender):sendChatMessage("Server", 3, tostring(Server():getValue("online_time")))
    return 0, "", ""
end

function getDescription()
    return "Gives back the current Tickvalue."
end

function getHelp()
    return "/getTick "
end
