'PicoCalc-dht22.bas

' Copyright (C) 2024 Chris Stoddard
' MIT License
' MMBASIC 5.08

Const BLK=RGB(BLACK)
Const WHT=RGB(WHITE)
Const YLW=RGB(YELLOW)
Const GRN=RGB(GREEN)
Const RED=RGB(RED)
Const BLU=RGB(BLUE)
Const CYA=RGB(CYAN)

Dim FLOAT temp, humidity

Font 2.5
CLS BLU
Colour WHT,BLU

' These settings untested and are likely screwed up.
GUI FRAME #1, "Temperature and Humidity",  20, 20, 310, 310, WHT
GUI CAPTION #3, "Temp: " + Str$(temp), 50, 50, LT, WHT, BLU
GUI CAPTION #4, "Humi: " + Str$(humidity), 50, 150, LT, WHT, BLU
GUI BARGAUGE #6, 50, 100, 300, 25, WHT, BLU, 0, 120, GRN, 40, YLW, 80, RED, 120
GUI BARGAUGE #7, 50, 200, 300, 25, WHT, BLU, 0, 100, GRN, 33, YLW, 66, RED, 100

Do
' The next line sets the GPIO pin, this will need to be
' adjusted for the PicoCalc's available pins.
  Device HUMID GP27, temp, humidity
  ' If you want the temp dispayed in Celsius
  ' comment out the next 2 lines
  f_temp = (temp * 1.8) + 32
  temp = f_temp
  CtrlVal(#3) = "Temp: " + Str$(temp)
  CtrlVal(#4) = "Humi: " + Str$(humidity)
  CtrlVal(#6) = temp
  CtrlVal(#7) = humidity
  Pause 1000
Loop
