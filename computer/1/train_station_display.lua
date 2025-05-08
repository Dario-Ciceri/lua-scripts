local modem = peripheral.find("modem") or error("No modem attached", 0)
local CHANNEL = 14
modem.open(CHANNEL)

local monitor = peripheral.find("monitor") or error("No monitor attached", 0)
term.redirect(monitor)

-- Tabella 7 segmenti (dimensione 3x5)
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
    {0,0,1},
    {0,0,1},
    {0,0,1},
    {0,0,1},
    {0,0,1}
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

-- Funzione per costruire la matrice di un numero
local function buildNumberMatrix(number)
  local numStr = tostring(number)
  local result = {}

  for row = 1, 5 do
    result[row] = {}
    for i = 1, #numStr do
      local digit = tonumber(numStr:sub(i, i))
      local digitRow = digits[digit + 1][row]
      
      for j = 1, #digitRow do
        table.insert(result[row], digitRow[j])
      end

      if i < #numStr then
        table.insert(result[row], 0) -- Aggiungi uno spazio tra le cifre
      end
    end
  end
  
  return result
end

-- Funzione per disegnare la matrice sul monitor
local function drawMatrix(matrix, bgColor, offsetX, offsetY)
  offsetX = offsetX or 0
  offsetY = offsetY or 0
  
  for y = 1, #matrix do
    for x = 1, #matrix[y] do
      local color = (matrix[y][x] == 1) and bgColor or colors.black
      local px = offsetX + (x - 1) * 2
      local py = offsetY + (y - 1) * 2
      -- Disegna ogni "pixel" 2x2
      paintutils.drawPixel(px,     py,     color)
      paintutils.drawPixel(px + 1, py,     color)
      paintutils.drawPixel(px,     py + 1, color)
      paintutils.drawPixel(px + 1, py + 1, color)
    end
  end
end

-- Funzione per gestire il messaggio
local function displayMessage(msg)
  if type(msg) == "table" and msg.type == "input_update" then
    local matrix = buildNumberMatrix(tonumber(msg.value or 14)) -- usa il numero ricevuto
    local matrixWidth = #matrix[1] * 2 + (#matrix[1] - 1)  -- Larghezza totale (inclusi spazi tra cifre)
    local offsetX = math.floor((monWidth - matrixWidth) / 2)  -- Calcola offset orizzontale per centrare
    local offsetY = 2  -- Posizione verticale per centratura
    
    drawMatrix(matrix, msg.right and colors.red or colors.green, offsetX, offsetY)
  else
    monitor.setBackgroundColor(colors.black)
    monitor.setCursorPos(1, 2)
    monitor.write("Invalid message format")
  end
end

-- Avvia la connessione con il modem
local monWidth, monHeight = monitor.getSize()
monitor.setBackgroundColor(colors.black)
monitor.clear()

-- Ciclo principale in attesa di messaggi
while true do
  local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
  if channel == CHANNEL then
    displayMessage(message)
  end
end
