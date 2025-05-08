local modem = peripheral.find("modem") or error("No modem attached", 0)
local CHANNEL = 14
modem.open(CHANNEL)

local monitor = peripheral.find("monitor") or error("No monitor attached", 0)
term.redirect(monitor)

-- Tabella 7 segmenti: ogni cifra è una matrice 5x3
local digits = {
  -- 0
  {
    {1,1,1},
    {1,0,1},
    {1,0,1},
    {1,0,1},
    {1,1,1}
  },
  -- 1
  {
    {0,1},
    {0,1},
    {0,1},
    {0,1},
    {0,1}
  },
  -- 2
  {
    {1,1,1},
    {0,0,1},
    {1,1,1},
    {1,0,0},
    {1,1,1}
  },
  -- 3
  {
    {1,1,1},
    {0,0,1},
    {0,1,1},
    {0,0,1},
    {1,1,1}
  },
  -- 4
  {
    {1,0,1},
    {1,0,1},
    {1,1,1},
    {0,0,1},
    {0,0,1}
  },
  -- 5
  {
    {1,1,1},
    {1,0,0},
    {1,1,1},
    {0,0,1},
    {1,1,1}
  },
  -- 6
  {
    {1,1,1},
    {1,0,0},
    {1,1,1},
    {1,0,1},
    {1,1,1}
  },
  -- 7
  {
    {1,1,1},
    {0,0,1},
    {0,1,0},
    {0,1,0},
    {0,1,0}
  },
  -- 8
  {
    {1,1,1},
    {1,0,1},
    {1,1,1},
    {1,0,1},
    {1,1,1}
  },
  -- 9
  {
    {1,1,1},
    {1,0,1},
    {1,1,1},
    {0,0,1},
    {1,1,1}
  }
}

-- Costruisce la matrice finale per un numero a 2 cifre
local function buildNumberMatrix(number)
  local numStr = tostring(number)
  local result = {}

  for row = 1, 5 do
    result[row] = {}
    for i = 1, #numStr do
      local digit = tonumber(numStr:sub(i,i))
      local digitRow = digits[digit + 1][row]
      for j = 1, #digitRow do
        table.insert(result[row], digitRow[j])
      end
      if i < #numStr then
        table.insert(result[row], 0) -- spazio tra le cifre
      end
    end
  end

  return result
end

-- Disegna la matrice sul monitor
local function drawMatrix(matrix, bgColor)
  for y = 1, #matrix do
    for x = 1, #matrix[y] do
      local color = (matrix[y][x] == 1) and bgColor or colors.black
      -- Disegna blocco 2x2 per ogni cella
      paintutils.drawPixel(x*2 - 1, y*2 - 1, color)
      paintutils.drawPixel(x*2,     y*2 - 1, color)
      paintutils.drawPixel(x*2 - 1, y*2,     color)
      paintutils.drawPixel(x*2,     y*2,     color)
    end
  end
end

-- Pulisce il monitor all'avvio
monitor.setBackgroundColor(colors.black)
monitor.clear()

-- Elabora i messaggi ricevuti
local function displayMessage(msg)
  if type(msg) == "table" and msg.type == "input_update" then
    local matrix = buildNumberMatrix(10)
    drawMatrix(matrix, msg.right and colors.red or colors.green)
  else
    monitor.setBackgroundColor(colors.black)
    monitor.setCursorPos(1, 2)
    monitor.write("Invalid message format")
  end
end

-- Ciclo principale in attesa di messaggi
while true do
  local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
  if channel == CHANNEL then
    displayMessage(message)
  end
end
