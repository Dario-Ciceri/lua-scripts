local modem = peripheral.find("modem") or error("No modem attached", 0)
local CHANNEL = 14

modem.open(CHANNEL)

local monitor = peripheral.find("monitor") or error("No monitor attached", 0)

monitor.setBackgroundColor(colors.black)
monitor.clear()
monitor.setCursorPos(1, 1)
monitor.setTextScale(15) 

local function displayMessage(msg)
  
  if type(msg) == "table" and msg.type == "input_update" then
  
    if msg.right then
        monitor.setTextColor(colors.red)
        monitor.clear()
        monitor.setCursorPos(1, 1)
        monitor.write("14")
        print(msg.right)
    else
        monitor.setTextColor(colors.green)
        monitor.clear()
        monitor.setCursorPos(1, 1)
        monitor.write("14")
        print(msg.right)
    end

  else
      monitor.setBackgroundColor(colors.black)
      monitor.setCursorPos(1, 2)
      monitor.write("Invalid message format")
  end
end

while true do
  local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
  if channel == CHANNEL then
    displayMessage(message)
  end
end