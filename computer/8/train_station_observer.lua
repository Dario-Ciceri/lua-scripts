-- Trova modem
local modem = peripheral.find("modem") or error("No modem attached", 0)
local CHANNEL = 14
modem.open(CHANNEL)

local ackReceived = false
local RETRIES = 3
local TIMEOUT = 1

-- Invia ping e input, attende ACK
local function sendInputs()
  local rightInput = redstone.getInput("right")
  local leftInput = redstone.getInput("left")

  local dataMsg = {
    type = "input_update",
    right = rightInput,
    left = leftInput
  }

  for attempt = 1, RETRIES do
    ackReceived = false
    modem.transmit(CHANNEL, CHANNEL, { type = "ping" }) -- Prima ping
    modem.transmit(CHANNEL, CHANNEL, dataMsg)

    local start = os.clock()
    while os.clock() - start < TIMEOUT do
      local event, _, rcvChannel, _, msg = os.pullEvent("modem_message")
      if rcvChannel == CHANNEL and type(msg) == "table" and msg.type == "ack" then
        ackReceived = true
        break
      end
    end

    if ackReceived then break else print("No ACK, retry " .. attempt) end
  end

  if not ackReceived then
    print("Errore: nessun ACK dal ricevitore.")
  end
end

-- Elabora eventuali comandi in ingresso
local function handleModemMessage(message)
  if type(message) ~= "table" then return end
  if message.type == "set_output" and type(message.state) == "boolean" then
    redstone.setOutput("front", message.state)
    print("Set front output to:", message.state)
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
