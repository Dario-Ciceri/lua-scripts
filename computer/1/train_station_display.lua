local monitor = peripheral.find("monitor") or error("Nessun monitor trovato", 0)
monitor.setTextScale(0.5)
monitor.clear()

local numero = "14"
monitor.setCursorPos(1, 1)

while true do
  local statoRedstone = redstone.getInput("rigth")
  local colore = statoRedstone and colors.red or colors.green
  monitor.setTextColor(colore)
  monitor.write(numero)
  sleep(0.1)
end
