-- Ricevitore - Visualizza stato e gestisce ACK
local modem = peripheral.find("modem") or error("No modem attached", 0)
local monitor = peripheral.find("monitor") or error("No monitor attached", 0)

local CHANNEL = 14
local TRACK = CHANNEL
modem.open(CHANNEL)

-- Cifre 0-9 per display 7 segmenti
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

local function drawMatrix(matrix, color)
  local w, h = monitor.getSize()
  monitor.setBackgroundColor(colors.black)
  monitor.clear()

  for y = 1, #matrix do
    for x = 1, #matrix[y] do
      local c = matrix[y][x] == 1 and color or colors.black
      paintutils.drawPixel(x*2 - 1, y*2 - 1, c)
      paintutils.drawPixel(x*2,     y*2 - 1, c)
      paintutils.drawPixel(x*2 - 1, y*2,     c)
      paintutils.drawPixel(x*2,     y*2,     c)
    end
  end
end

local function showOffline()
  monitor.setBackgroundColor(colors.black)
  monitor.clear()
  monitor.setCursorPos(1, 1)
  monitor.setTextColor(colors.white)
  monitor.setTextScale(2)
  monitor.write("Stato: OFFLINE")
end

local function handleMessage(msg)
  if msg.type == "input_update" then
    local matrix = buildNumberMatrix(TRACK)
    drawMatrix(matrix, msg.right and colors.red or colors.green)
  end
end

-- Stato ping
local lastPing = os.clock()
local TIMEOUT = 5

-- Loop principale non bloccante
while true do
  while os.pullEventRaw("modem_message") do
    local event, _, channel, _, message = os.pullEvent("modem_message")
    if channel == CHANNEL and type(message) == "table" then
      if message.type == "ping" then
        lastPing = os.clock()
        modem.transmit(CHANNEL, CHANNEL, { type = "ack" })
      else
        handleMessage(message)
      end
    end
  end

  if os.clock() - lastPing > TIMEOUT then
    showOffline()
  end

  os.sleep(0.1)
end
