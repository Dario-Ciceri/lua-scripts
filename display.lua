local monitor = peripheral.find("monitor")
local modem = peripheral.find("modem") or error("No modem attached", 0)
modem.open(0)

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    print(("Message received on side %s on channel %d (reply to %d) from %f blocks away with message %s"):format(
            side, channel, replyChannel, distance, tostring(message)
    ))
    monitor.clear()
    monitor.setCursorPos(1, 1)
    --monitor.setTextScale(5)
    --monitor.write(message)
    
    --local method, args = parseCommand(message)
    
    peripheral.call("left", "paintutils.drawLine", 2, 3, 30, 7, colors.red)
    
end

local function parseCommand(str)
    local parts = {}
    for part in string.gmatch(str, "([^,]+)") do
        table.insert(parts, part)
    end
    
    local methodName = parts[1]
    local params = {}
    for i = 2, #parts do
        table.insert(params, parts[i])
    end
    
    return methodName, params
end

local function drawLine(startX, startY, endX, endY, color)
    paintutils.drawLine(startX, startY, endX, endY, color)
end
    
