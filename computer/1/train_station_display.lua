local modem = peripheral.find("modem") or error("No modem attached", 0)
local monitor = peripheral.find("monitor") or error("No monitor attached", 0)

-- va gestito meglio redirect 
term.redirect(monitor)

local CHANNEL = 14
modem.open(CHANNEL)

-- 7 segmenti
local digits = {
  {{1,1,1}, {1,0,1}, {1,0,1}, {1,0,1}, {1,1,1}},
  {{0,1},   {0,1},   {0,1},   {0,1},   {0,1}},
  {{1,1,1}, {0,0,1}, {1,1,1}, {1,0,0}, {1,1,1}},
  {{1,1,1}, {0,0,1}, {0,1,1}, {0,0,1}, {1,1,1}},
  {{1,0,1}, {1,0,1}, {1,1,1}, {0,0,1}, {0,0,1}},
  {{1,1,1}, {1,0,0}, {1,1,1}, {0,0,1}, {1,1,1}},
  {{1,1,1}, {1,0,0}, {1,1,1}, {1,0,1}, {1,1,1}},
  {{1,1,1}, {0,0,1}, {0,1,0}, {0,1,0}, {0,1,0}},
  {{1,1,1}, {1,0,1}, {1,1,1}, {1,0,1}, {1,1,1}},
  {{1,1,1}, {1,0,1}, {1,1,1}, {0,0,1}, {1,1,1}}
}

local function buildNumberMatrix(number)
  local str = tostring(number)
  local matrix = {}
  for y = 1, 5 do
    matrix[y] = {}
    for i = 1, #str do
      local digit = tonumber(str:sub(i, i))
      for _, v in ipairs(digits[digit + 1][y]) do
        table.insert(matrix[y], v)
      end
      if i < #str then table.insert(matrix[y], 0) end
    end
  end
  return matrix
end

local function drawMatrix(matrix, color)
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

local function initMonitor()
  monitor.setBackgroundColor(colors.black)
  monitor.setTextScale(5)
  monitor.clear()
end

local function showOffline()
  initMonitor()
  monitor.setCursorPos(1, 1)
  monitor.write("OFFLINE")
end

local lastPing = os.clock()
local TIMEOUT = 5
local TRACK = CHANNEL

-- Setup
initMonitor()

-- Loop non bloccante
while true do
  local timeout = 0.1
  local timerID = os.startTimer(timeout)

  local event, p1, p2, p3, p4 = os.pullEvent()
  if event == "modem_message" and p2 == CHANNEL then
    local msg = p4
    if type(msg) == "table" then
      if msg.type == "ping" then
        lastPing = os.clock()
        modem.transmit(CHANNEL, CHANNEL, { type = "ack" })
      elseif msg.type == "input_update" then
        local matrix = buildNumberMatrix(TRACK)
        drawMatrix(matrix, msg.right and colors.red or colors.green)
      end
    end
  elseif event == "timer" and p1 == timerID then
    -- Check timeout
    if os.clock() - lastPing > TIMEOUT then
      showOffline()
    end
  end
end