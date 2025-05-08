local modem = peripheral.find("modem") or error("No modem attached", 0)

local CHANNEL = 14
modem.open(CHANNEL)

local monitor = peripheral.find("monitor") or error("No monitor attached", 0)

monitor.clear()
monitor.setCursorPos(1, 1)
monitor.setTextScale(1)

local function displayMessage(msg)
  monitor.clear()
  monitor.setCursorPos(1, 1)
  monitor.write("Received message:")
  monitor.setCursorPos(1, 2)
  monitor.write(tostring(msg))
end

while true do
  local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
  if channel == CHANNEL then
    displayMessage(message)
  end
end
