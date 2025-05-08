local modem = peripheral.find("modem") or error("Nessun modem trovato", 0)
local CHANNEL = 14
modem.open(CHANNEL)

local monitor = peripheral.find("monitor") or error("Nessun monitor trovato", 0)
monitor.setTextScale(1)
monitor.clear()

local function displayNumber(color)
  monitor.setTextColor(color)
  monitor.setCursorPos(1, 1)
  monitor.write("14")
end

local function handleModemMessage(message)
  if type(message) == "table" and message.type == "input_update" then
    local color = redstone.getInput("left") and colors.red or colors.green
    displayNumber(color)
  end
end

while true do
  local event, side, channel, replyChannel, message, distance = os.pullEvent()
  if event == "modem_message" and channel == CHANNEL then
    handleModemMessage(message)
  end
end
