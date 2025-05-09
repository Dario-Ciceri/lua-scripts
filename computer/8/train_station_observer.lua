local modem = peripheral.find("modem") or error("No modem attached", 0)
local CHANNEL = 14
modem.open(CHANNEL)

local RETRIES = 3
local TIMEOUT = 1

-- Invia dati e aspetta ACK non bloccante
local function sendInputs()
  local rightInput = redstone.getInput("right")
  local leftInput = redstone.getInput("left")

  local dataMsg = {
    type = "input_update",
    right = rightInput,
    left = leftInput
  }

  for attempt = 1, RETRIES do
    local ackReceived = false
    modem.transmit(CHANNEL, CHANNEL, { type = "ping" }) -- PING
    modem.transmit(CHANNEL, CHANNEL, dataMsg)

    local timerID = os.startTimer(TIMEOUT)

    while true do
      local event, p1, p2, p3, p4 = os.pullEvent()
      if event == "modem_message" then
        local msg = p4
        if type(msg) == "table" and msg.type == "ack" then
          ackReceived = true
          break
        end
      elseif event == "timer" and p1 == timerID then
        break -- timeout
      end
    end

    if ackReceived then
      return -- OK, fine
    else
      print("No ACK, retry #" .. attempt)
    end
  end

  print("Errore: nessun ACK ricevuto dopo " .. RETRIES .. " tentativi.")
end

-- Comandi ricevuti dal monitor
local function handleModemMessage(message)
  if type(message) == "table" and message.type == "set_output" and type(message.state) == "boolean" then
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
