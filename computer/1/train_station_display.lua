-- Trova periferiche modem e monitor
local modem = peripheral.find("modem") or error("No modem attached", 0)
local monitor = peripheral.find("monitor") or error("No monitor attached", 0)
term.redirect(monitor)

local CHANNEL = 14
modem.open(CHANNEL)

-- Tabella 7 segmenti: cifre come matrici 5x3
local digits = {
  {
    {1,1,1}, {1,0,1}, {1,0,1}, {1,0,1}, {1,1,1}
  }, {
    {0,1}, {0,1}, {0,1}, {0,1}, {0,1}
  }, {
    {1,1,1}, {0,0,1}, {1,1,1}, {1,0,0}, {1,1,1}
  }, {
    {1,1,1}, {0,0,1}, {0,1,1}, {0,0,1}, {1,1,1}
  }, {
    {1,0,1}, {1,0,1}, {1,1,1}, {0,0,1}, {0,0,1}
  }, {
    {1,1,1}, {1,0,0}, {1,1,1}, {0,0,1}, {1,1,1}
  }, {
    {1,1,1}, {1,0,0}, {1,1,1}, {1,0,1}, {1,1,1}
  }, {
    {1,1,1}, {0,0,1}, {0,1,0}, {0,1,0}, {0,1,0}
  }, {
    {1,1,1}, {1,0,1}, {1,1,1}, {1,0,1}, {1,1,1}
  }, {
    {1,1,1}, {1,0,1}, {1,1,1}, {0,0,1}, {1,1,1}
  }
}

-- Costruisce la matrice per un numero a 2 cifre
local function buildNumberMatrix(number)
  local numStr = tostring(number)
  local result = {}

  for row = 1, 5 do
    result[row] = {}
    for i = 1, #numStr do
      local digit = tonumber(numStr:sub(i,i))
      local digitRow = digits[digit + 1][row]
      for _, v in ipairs(digitRow) do
        table.insert(result[row], v)
      end
      if i < #numStr then table.insert(result[row], 0) end
    end
  end

  return result
end

-- Disegna una matrice sul monitor con colori
local function drawMatrix(matrix, bgColor)
  for y = 1, #matrix do
    for x = 1, #matrix[y] do
      local color = (matrix[y][x] == 1) and bgColor or colors.black
      paintutils.drawPixel(x*2 - 1, y*2 - 1, color)
      paintutils.drawPixel(x*2,     y*2 - 1, color)
      paintutils.drawPixel(x*2 - 1, y*2,     color)
      paintutils.drawPixel(x*2,     y*2,     color)
    end
  end
end

-- Visualizza "offline"
local function showOffline()
  monitor.setBackgroundColor(colors.black)
  monitor.clear()
  monitor.setCursorPos(1, 2)
  monitor.write("Stato: OFFLINE")
end

-- Visualizza stato online
local function showOnline()
  monitor.setBackgroundColor(colors.black)
  monitor.clear()
  monitor.setCursorPos(1, 1)
  monitor.write("Stato: ONLINE")
end

-- Elabora i messaggi ricevuti
local function handleMessage(msg)
  if type(msg) == "table" and msg.type == "input_update" then
    showOnline()
    local matrix = buildNumberMatrix(14)
    drawMatrix(matrix, msg.right and colors.red or colors.green)
  end
end

-- Timer ping
local lastPing = os.clock()
local TIMEOUT = 5

-- Loop principale
while true do
  local event, _, channel, _, message = os.pullEvent()
  
  if event == "modem_message" and channel == CHANNEL then
    if type(message) == "table" then
      if message.type == "ping" then
        lastPing = os.clock()
        modem.transmit(CHANNEL, CHANNEL, { type = "ack" }) -- Risposta ACK
      else
        handleMessage(message)
      end
    end
  end

  -- Mostra OFFLINE se troppo tempo senza ping
  if os.clock() - lastPing > TIMEOUT then
    showOffline()
  end

  os.sleep(0.1)
end
