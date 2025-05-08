local modem = peripheral.find("modem") or error("Nessun modem trovato", 0)
local CHANNEL = 14
modem.open(CHANNEL)

local monitor = peripheral.find("monitor") or error("Nessun monitor trovato", 0)
monitor.setTextScale(0.5)
monitor.clear()

local number14 = {
  "  #  ",
  " # # ",
  "   # ",
  "   # ",
  "   # ",
  "   # ",
  "   # "
}

local function drawNumber(color)
  for i = 1, #number14 do
    for j = 1, #number14[i] do
      if number14[i]:sub(j, j) == "#" then
        monitor.setCursorPos(j, i)
        monitor.setBackgroundColor(color)
        monitor.write(" ")
      end
    end
  end
end

local function handleModemMessage(message)
  if type(message) == "table" and message.type == "input_update" then
    local color = redstone.getInput("right") and colors.red or colors.green
    drawNumber(color)
  end
end

while true do
  local event, side, channel, replyChannel, message, distance = os.pullEvent()
  if event == "modem_message" and channel == CHANNEL then
    handleModemMessage(message)
  end
end
