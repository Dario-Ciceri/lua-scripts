local channel = 142
local modem = peripheral.find("modem") or error("No modem attached", 0)
modem.open(channel)

modem.transmit(channel, channel, "boot")
sleep(8)

while true do
    if redstone.getInput("front") == true then
        modem.transmit(channel, channel, "red")
    else
        modem.transmit(channel, channel, "green")
    end
    sleep(1)
end

