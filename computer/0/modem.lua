modem = peripheral.wrap("top")
modem.open(15)
modem.transmit(15,15,'hello')

