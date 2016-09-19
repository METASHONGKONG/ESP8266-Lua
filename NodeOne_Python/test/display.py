import ssd1306
from machine import I2C, Pin
import math
arr = [16,5,4,0,2,14,12,13,15,3,1,9,10] #GPIO->PIN
i2c = I2C(sda=Pin(arr[7]), scl=Pin(arr[6]))
display = ssd1306.SSD1306_I2C(128,32, i2c, 60)
display.fill(0)
<<<<<<< HEAD
display.text('hello world!',1,10,1)
=======
display.text('Awesome!',1,15,1)
>>>>>>> 9c8eefb0faaac8ae97796d00282bf653d3dcbdb8
display.show()
