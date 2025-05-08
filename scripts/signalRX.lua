local channel = 142
local monitor = peripheral.find("monitor")
local modem = peripheral.find("modem") or error("No modem attached", 0)
modem.open(channel)

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    print(("Message received on side %s on channel %d (reply to %d) from %f blocks away with message %s"):format(
            side, channel, replyChannel, distance, tostring(message)
    ))
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.setTextScale(5)

    if message == "red" then
        monitor.setBackgroundColor(colors.red)
        monitor.clear()
    elseif message == "green" then
        monitor.setBackgroundColor(colors.green)
        monitor.clear()
    else
        for i = 0, 9 do
            modem.transmit(channel, channel, i)
            sleep(1)
        end
        sleep(2)
    end
    sleep(1)
end