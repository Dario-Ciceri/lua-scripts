local modem = peripheral.wrap("top")
modem.open(0)

modem.transmit(0,1,'drawLine,0,0,10,0,colors.red')
