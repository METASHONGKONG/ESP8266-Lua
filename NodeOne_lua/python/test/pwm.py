from machine import Pin,PWM
arr = [16,5,4,0,2,14,12,13,15,3,1,9,10] #GPIO->PIN
pwm1 = PWM(Pin(arr[1]),freq=500,duty=0)#Pin1 PWM mode
pwm1.duty(1023)   #freq:1~1000 duty:0~1023