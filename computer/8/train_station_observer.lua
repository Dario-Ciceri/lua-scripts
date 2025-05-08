local modem = peripheral.find("modem") or error("No modem attached", 0)
local CHANNEL = 14 
modem.open(CHANNEL)

local function sendInputs()
  local rightInput = redstone.getInput("right")
  local leftInput = redstone.getInput("left")
  local message = {
    type = "input_update",
    right = rightInput,
    left = leftInput
  }
  modem.transmit(CHANNEL, CHANNEL, message)
end

local function handleModemMessage(message)
  if type(message) ~= "table" then return end
  if message.type == "set_output" and type(message.state) == "boolean" then
    redstone.setOutput("front", message.state)
    print("Set front output to:", message.state)
  end
end

sendInputs()

while true do
  local event, side, channel, replyChannel, message, distance = os.pullEvent()
  if event == "redstone" then
    sendInputs()
  elseif event == "modem_message" and channel == CHANNEL then
    handleModemMessage(message)
  end
end
