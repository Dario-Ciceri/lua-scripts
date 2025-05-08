modem = peripheral.wrap("top")
modem.open(15)

print("In attesa di messaggi sul canale 5...")
local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
print("Ricevuto: "..tostring(message))
print("Rispondere a: "..replyChannel)

modem.transmit(replyChannel, channel, "Messaggio ricevuto!")
