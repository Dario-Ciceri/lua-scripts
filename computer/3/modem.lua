local modem = peripheral.wrap("top")
modem.open(6)
modem.transmit(15, 6, "Ciao dal trasmettitore!")  
