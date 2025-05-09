-- Trasmettitore - Invia stato con ACK e ping
local modem = peripheral.find("modem") or error("No modem attached", 0)
local CHANNEL = 14
modem.open(CHANNEL)

local RETRIES = 3
local TIMEOUT = 1

local function sendInputs()
  local rightInput = redstone.getInput("right")
  local leftInput = redstone.getInput("left")

  local message = {
    type = "input_update",
    right = rightInput,
    left = leftInput
  }

  for attempt = 1, RETRIES do
    local ackReceived = false
    modem.transmit(CHANNEL, CHANNEL, { type = "ping" })
    modem.transmit(CHANNEL, CHANNEL, message)

    local start = os.clock()
    while os.clock() - start < TIMEOUT do
      local event, _, rcvChannel, _, msg = os.pullEvent("modem_message")
      if rcvChannel == CHANNEL and type(msg) == "table" and msg.type == "ack" then
        ackReceived = true
        break
      end
    end

    if ackReceived then return else print("Retry " .. attempt .. ": no ACK") end
  end

  print("Errore: ricevitore non risponde.")
end

local function handleModemMessage(message)
  if type(message) == "table" and message.type == "set_output" and type(message.state) == "boolean" then
    redstone.setOutput("front", message.state)
    print("Output front:", message.state)
  end
end

-- Invio iniziale
sendInputs()

-- Loop principale
while true do
  local event, _, _, _, message = os.pullEvent()
  if event == "redstone" then
    sendInputs()
  elseif event == "modem_message" then
    handleModemMessage(message)
  end
end
