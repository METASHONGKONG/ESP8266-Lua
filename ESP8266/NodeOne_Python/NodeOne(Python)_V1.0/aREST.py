from machine import ADC,PWM
import json
from si7021 import *
class aREST:
	flag = 1
	def handle(self,client,request_handle):
		self.si7021 = si7021()
		pin = [16,5,4,0,2,14,12,13,15,3,1,9,10] #GPIO->pin
		mode = ''
		num = ''
		value = ''
		answer={}
		pin5 = Pin(pin[5],Pin.OUT)
		pin3 = Pin(pin[3],Pin.OUT)
		req = request_handle.decode('UTF-8','strict')
		c = client
		#find start
		e = req.find('/')
		req = req[e+1:]
		#find end
		e = req.find('HTTP')
		req = req[:e-1]
		#find mode
		e = req.find('/')
		if -1 == e:
			mode = req
		else:
			mode = req[:e]
			#find pin num
			req = req[e+1:]
			e = req.find('/')
			if -1 == e:
				num = req
			else:
				num = req[:e]
				#find value
				value = req[e+1:]
		if mode == 'exit':
			self.flag = 0
			answer['message'] = 'A socket to stop working,start again please restart'
		if mode == 'mode':
			if value == 'o':
				answer['message'] = 'Pin '+num+' set to output'
			if value == 'i':
				answer['message'] = 'Pin '+num+' set to input'
		if mode == 'digital':
			if value == '0':
				pin_out = Pin(pin[int(num)],Pin.OUT)
				pin_out.value(0)
				answer['message'] = 'Pin '+num+' set to 0'
			if value == '1':
				pin_out = Pin(pin[int(num)],Pin.OUT)
				pin_out.value(1)
				answer['message'] = 'Pin '+num+' set to 1'
			if value == 'r':
				pin_in = Pin(pin[int(num)],Pin.IN)
				read_value = pin_in.value()
				answer['message'] = 'Pin '+num+' read value '+str(read_value)
		if mode == 'analog':
			if num == '0':
				pin_out = Pin(pin[8],Pin.OUT)
				pin_out.value(1)
			if num == '1':
				pin_out = Pin(pin[8],Pin.OUT)
				pin_out.value(0)	
			adc_value = ADC(0).read()
			answer['message'] = 'A'+num+' value:'+str(adc_value)
		if mode == 'pwm':
			pin_pwm = PWM(Pin(pin[int(num)]),freq=100,duty=int(value))#pwm init
			answer['message'] = 'PWM:Pin '+num+' set to '+value
		if mode == 'temperature':
			answer['message'] = 'Temperature(¡æ):'+str(self.si7021.temp_value())
		if mode == 'humidity':
			answer['message'] = 'Humidity(%RH):'+str(self.si7021.humi_value())	
		if mode == 'forward':
			pin5.value(1)
			pin3.value(1)
			answer['message'] = 'car forward now...'	
		#send answer	
		c.send('HTTP/1.1 200 OK\r\nContent-type: text/html\r\nAccess-Control-Allow-Origin:* \r\n\r\n'+json.dumps(answer)+'\r\n')	
		
		
