local json = require("json")
local outgoingData = {}
dB = {}

dB.addDataToBuffer = function(table)
    local tableString = json.encode(table)
    outgoingData[#outgoingData + 1] = tableString.."\n" -- Add the table to the buffer.
end

dB.fetchNextToGo = function()
    local tableCopy = {}

    for k,v in pairs( outgoingData ) do 
        tableCopy[k] = v
    end

    outgoingData = nil
    outgoingData = {}

    return tableCopy
end

return dB
