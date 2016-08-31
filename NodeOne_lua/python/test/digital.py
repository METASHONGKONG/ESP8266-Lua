from machine import Pin
arr = [16,5,4,0,2,14,12,13,15,3,1,9,10] #GPIO->PIN
P0 = Pin(arr[0],Pin.OUT)                                       
P0.value(0) #0:LOW,1:HIGH