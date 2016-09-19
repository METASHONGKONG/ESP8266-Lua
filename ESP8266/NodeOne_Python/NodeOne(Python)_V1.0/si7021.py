
from machine import Pin,I2C
import ustruct
import time
import ssd1306
class si7021:
    
    def __init__(self):
        self.pin = [16,5,4,0,2,14,12,13,15,3,1,9,10] #GPIO->PIN
        self.i2c = I2C(scl=Pin(self.pin[6]),sda=Pin(self.pin[7]),freq=50000)#sda=7,scl=6
        self.addr = 0x40#si7021 address 
        self.Humi_command = bytearray(1)
        self.Humi_command[0]=0xE5         #humidity command 0XE5
        self.Temp_command = bytearray(1)     
        self.Temp_command[0]=0xE3    #temperature command 0xE3
    def humi_value(self):
        self.i2c.start()
        self.i2c.writeto(self.addr,self.Humi_command)#write command
        time.sleep_ms(20)
        self.i2c.stop()
        self.i2c.start()
        self.data_H,self.data_L=ustruct.unpack('BB',self.i2c.readfrom(self.addr,2))#read data
        time.sleep_ms(20)
        self.i2c.stop()
        return (self.data_H*256+self.data_L)*125/65536-6#return humidity value
    def temp_value(self):   
        self.i2c.start()
        self.i2c.writeto(self.addr,self.Temp_command)#write_command
        time.sleep_ms(20)
        self.i2c.stop()
        self.i2c.start()
        self.data_H,self.data_L=ustruct.unpack('BB',self.i2c.readfrom(self.addr,2))#read data
        time.sleep_ms(20)
        self.i2c.stop()
        return (self.data_H*256+self.data_L)*175.72/65536-46.85#return temperature value
        
        
        
        
        
        
        