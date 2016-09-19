from machine import ADC
arr = [16,5,4,0,2,14,12,13,15,3,1,9,10] #GPIO->PIN
adc = ADC(0)
print(adc.read())