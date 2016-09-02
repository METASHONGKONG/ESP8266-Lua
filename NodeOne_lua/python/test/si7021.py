from machine import Pin,I2C
import ustruct
import time
pin = [16,5,4,0,2,14,12,13,15,3,1,9,10] #GPIO->PIN
i2c = I2C(scl=Pin(pin[6]),sda=Pin(pin[7]),freq=400000)
Humi_command = bytearray(1)
Humi_command[0]=0xE5 		#humidity command 0XE5
Temp_command = bytearray(1)		
Temp_command[0]=0xE3 	#temperature command 0xE3
i2c.start()
time.sleep_ms(1)
i2c.writeto(64,Humi_command) #si7021 address 0x40 == 64
time.sleep_ms(1)
i2c.stop()
time.sleep_ms(1)

i2c.start()
time.sleep_ms(1)
Humi_H,Humi_L=ustruct.unpack('BB',i2c.readfrom(64,2))
time.sleep_ms(1)
i2c.stop()
time.sleep_ms(1)

i2c.start()
time.sleep_ms(1)
i2c.writeto(64,Temp_command)
time.sleep_ms(1)
i2c.stop()
time.sleep_ms(1)

i2c.start()
time.sleep_ms(1)
Temp_H,Temp_L=ustruct.unpack('BB',i2c.readfrom(64,2))
time.sleep_ms(1)
i2c.stop()
time.sleep_ms(1)

print((Humi_H*256+Humi_L)*125/65536-6)
print((Temp_H*256+Temp_L)*175.72/65536-46.85)