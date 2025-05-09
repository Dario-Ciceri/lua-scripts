-- Trova periferiche modem e monitor
local modem = peripheral.find("modem") or error("No modem attached", 0)
local monitor = peripheral.find("monitor") or error("No monitor attached", 0)
term.redirect(monitor)

local CHANNEL = 14
local TRACK = CHANNEL

modem.open(CHANNEL)

-- Cifre stile 7 segmenti
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

-- Costruisce matrice per numero
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

-- Disegna matrice
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

local function initMonitor()
  monitor.setBackgroundColor(colors.black)
  monitor.setTextScale(5)
  monitor.setCursorPos(1, 1)
  monitor.clear()
end

local function showOffline()
  initMonitor()
  monitor.write("Stato: OFFLINE")
end

local function handleMessage(msg)
  if type(msg) == "table" and msg.type == "input_update" then
    local matrix = buildNumberMatrix(TRACK)
    drawMatrix(matrix, msg.right and colors.red or colors.green)
  end
end

-- Timeout ping
local lastPing = os.clock()
local TIMEOUT = 5

initMonitor()

-- Loop principale non bloccante
while true do
  local event, p1, p2, p3, p4 = os.pullEvent()
  if event == "modem_message" and p2 == CHANNEL then
    local message = p4
    if type(message) == "table" then
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

  os.sleep(0.05)
end
