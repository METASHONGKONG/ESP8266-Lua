import ssd1306
from machine import I2C, Pin
import math
arr = [16,5,4,0,2,14,12,13,15,3,1,9,10] #GPIO->PIN
i2c = I2C(sda=Pin(arr[7]), scl=Pin(arr[6]))
display = ssd1306.SSD1306_I2C(128,32, i2c, 60)
display.fill(0)
display.text('Welcome',1,15,1)
display.show()

import network
import time

wlan = network.WLAN(network.STA_IF) # create station interface
wlan.active(True)       # activate the interface
wlan.scan()             # scan for access points
#print(wlan.scan())

wlan.isconnected()      # check if the station is connected to an AP
wlan.connect('METAS6', '12345678') # connect to an AP
wlan.config('mac')      # get the interface's MAC adddress
ip = wlan.ifconfig()         # get the interface's IP/netmask/gw/DNS addresses

while True:
   ip = wlan.ifconfig()
   if ip[0] == "0.0.0.0":
     print("waiting")
     i2c = I2C(sda=Pin(arr[7]), scl=Pin(arr[6]))
     display = ssd1306.SSD1306_I2C(128,32, i2c, 60)
     display.fill(0)
     display.text('waiting...',1,15,1)
     display.show()
     time.sleep_ms(1000)
   else:
     print(ip[0])
     i2c = I2C(sda=Pin(arr[7]), scl=Pin(arr[6]))
     display = ssd1306.SSD1306_I2C(128,32, i2c, 60)
     display.fill(0)
     display.text(ip[0],1,15,1)
     display.show()
     break
     

