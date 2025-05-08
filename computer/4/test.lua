local monitor = peripheral.wrap("top")

monitor.setBackgroundColor(colors.black)
monitor.setTextColor(colors.green)
monitor.clear()

local count = 0
while true do
    monitor.setCursorPos(1, 1)
    monitor.clearLine()
    monitor.write(count)
    count = count + 1
    sleep(1)
end
