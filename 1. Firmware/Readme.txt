1. Start ESP8266Flasher64.exe
2. Select the COM Port
3. Config -> Do following Setting
  a. Upload nodemcu-master-11-modules-2017-03-28-06-41-55-float.bin to address offset   0x000000
  b. Upload 2.bin to address offset   0x3FC000
4. Operation -> Flash
5. Wait unti flash finished
6. Close ESP8266Flasher64.exe, replug the USB

For output.bin, it is the whole OS 1.3 file. Flash it to 0x00000 using ESP8266 DOWNLOAD TOOL